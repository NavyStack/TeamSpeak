FROM debian:bookworm-slim

ENV SINUSBOT_VERSION="1.0.2-arm64"
ENV LC_ALL=ko_KR.UTF-8
ENV LANG=ko_KR.UTF-8
ENV LANGUAGE=ko_KR:ko

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    bzip2 \
    ca-certificates \
    curl \
    jq \
    libasound2 \
    libc6 \
    libegl1-mesa \
    libglib2.0-0 \
    libnss3 \
    libpci3 \
    libxcursor1 \
    libxkbcommon0 \
    libxcomposite-dev \
    libxslt1.1 \
    locales \
    procps \
    python3 \
    unzip \
    x11vnc \
    xvfb \
    && sed -i -e 's/# ko_KR.UTF-8 UTF-8/ko_KR.UTF-8 UTF-8/' /etc/locale.gen && locale-gen \
    && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

WORKDIR /opt/sinusbot

RUN echo "Downloading SinusBot..." && \
    curl -s "https://www.sinusbot.com/pre/sinusbot-$SINUSBOT_VERSION.tar.bz2" | tar xj && \
    chmod 755 sinusbot && \
    mv scripts default_scripts && \
    ln -s data/private.dat private.dat && \
    cp config.ini.dist config.ini.configured && \
    sed -i "s|^TS3Path.*|TS3Path = \"\"|g" config.ini.configured && \
    echo "Successfully installed SinusBot"

RUN echo "Installing Text-to-Speech..." && \
    mkdir -p tts/tmp && \
    cd tts/tmp && \
    curl -s https://chromium.googlesource.com/chromiumos/platform/assets/+archive/master/speech_synthesis/patts.tar.gz | tar -xz && \
    unzip -q tts_service_x86_64.nexe.zip && \
    mv tts_service_x86_64.nexe .. && \
    mv voice_lstm_en-US.zvoice .. && \
    mv voice_lstm_de-DE.zvoice .. && \
    cd .. && \
    rm -rf tmp && \
    cd .. && \
    printf '%s\n' \
        '[TTS]' \
        'Enabled = false' \
        '' \
        '[[TTS.Modules]]' \
        'Locale = "en-US"' \
        'Filename = "voice_lstm_en-US.zvoice"' \
        'PipelineFile = "voice_lstm_en-US/sfg/pipeline"' \
        'Prefix = "voice_lstm_en-US/sfg/"' \
        'Instances = 2' \
        '' \
        '[[TTS.Modules]]' \
        'Locale = "de-DE"' \
        'Filename = "voice_lstm_de-DE.zvoice"' \
        'PipelineFile = "voice_lstm_de-DE/nfh/pipeline"' \
        'Prefix = "voice_lstm_de-DE/nfh/"' \
        'Instances = 2' >> config.ini.configured && \
    echo "Successfully installed Text-to-Speech"

RUN echo "Downloading yt-dlp..." && \
    curl -s -L -o /usr/local/bin/yt-dlp https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp && \
    chmod 755 /usr/local/bin/yt-dlp && \
    echo 'YoutubeDLPath = "/usr/local/bin/yt-dlp"' >> config.ini.configured && \
    echo "Successfully installed yt-dlp"

RUN echo "Installing TeamSpeak Client..." && \
    DOWNLOAD_URL=$(curl -s https://www.teamspeak.com/versions/client.json | jq -r '.linux.x86_64.mirrors["teamspeak.com"]') && \
    echo "Downloading TeamSpeak Client..." && \
    curl -s -o TeamSpeak3-Client-linux_amd64.run "https://files.teamspeak-services.com/releases/client/3.5.6/TeamSpeak3-Client-linux_amd64-3.5.6.run" && \
    chmod 755 TeamSpeak3-Client-linux_amd64.run && \
    yes | ./TeamSpeak3-Client-linux_amd64.run && \
    rm TeamSpeak3-Client-linux_amd64.run && \
    mkdir TeamSpeak3-Client-linux_amd64/plugins && \
    cp plugin/libsoundbot_plugin.so TeamSpeak3-Client-linux_amd64/plugins && \
    rm TeamSpeak3-Client-linux_amd64/xcbglintegrations/libqxcb-glx-integration.so && \
    sed -i "s|^TS3Path.*|TS3Path = \"/opt/sinusbot/TeamSpeak3-Client-linux_amd64/ts3client_linux_amd64\"|g" config.ini.configured && \
    echo "Successfully installed the TeamSpeak Client"

COPY bot.entrypoint.sh /opt/sinusbot/entrypoint.sh
RUN chmod +x /opt/sinusbot/entrypoint.sh

EXPOSE 8087

VOLUME ["/opt/sinusbot/data", "/opt/sinusbot/scripts"]

RUN groupadd -g 1001 sinusbot && useradd -r -u 1001 -g sinusbot sinusbot && \
    chown -R sinusbot:sinusbot /opt/sinusbot

ENTRYPOINT ["/opt/sinusbot/entrypoint.sh"]
HEALTHCHECK --interval=1m --timeout=10s \
  CMD curl --no-keepalive -f http://localhost:8087/api/v1/botId || exit 1
