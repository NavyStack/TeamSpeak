# TeamSpeak-Docker

[TeamSpeak 공식 홈페이지](https://www.teamspeak.com/en/) <br />
[해당 도커이미지의 Github](https://github.com/NavyStack/TeamSpeak) <br />
[해당 Github의 Docker Hub](https://hub.docker.com/r/navystack/teamspeak) <br />

## Askfront.com

초보자도 자유롭게 질문할 수 있는 포럼을 만들었습니다. <br />
NavyStack의 가이드 뿐만 아니라, 아니라 모든 종류의 질문을 하실 수 있습니다.

검색해도 도움이 되지 않는 정보만 나오는 것 같고, 주화입마에 빠진 것 같은 기분이 들 때가 있습니다.<br />
그럴 때, 부담 없이 질문해 주세요. 같이 의논하며 생각해봅시다.

[AskFront.com (에스크프론트) 포럼](https://askfront.com/?github)
<br /><br />

## TeamSpeak3 도커이미지를 보고 *한숨*이 나와서 만들어본 Dockerfile입니다.

1. Arm64는 만들 생각이 없어보여서 Qemu로 에뮬레이팅 합니다. <br />
   다른 이미지와 다르게 처음에 실행했을 떄 나오는 `Puzzle precompute time`이 1/3 정도로 작게 나옵니다 :)
2. Signal 전달이 제대로 되지 않아 강제종료가 되는 것을 확인하고, tini를 사용했습니다.
3. 사용가능한 환경 변수는 아래에서 확인하실 수 있습니다.
4. 성능 상 Sqlite를 사용하는 것이 바람직해 보입니다. (MySQL 등을 사용할 수는 있으나, 오버킬 같음.)
5. 아무것도 지정하지 않으면 Sqlite를 사용해서 실행합니다.

<br />

## TeamSpeak Server 환경 변수 (기본 값: 아무것도 입력하지 않았을 경우) (ts3server.ini)

| 환경 변수                        |             기본값              |                                설명                                |
| -------------------------------- | :-----------------------------: | :----------------------------------------------------------------: |
| TS3SERVER_QUERY_PROTOCOLS        |               raw               |                         쿼리 프로토콜 설정                         |
| TS3SERVER_QUERY_TIMEOUT          |               300               |                      쿼리 타임아웃 설정 (초)                       |
| TS3SERVER_QUERY_SSH_RSA_HOST_KEY |        ssh_host_rsa_key         |                       SSH RSA 호스트 키 파일                       |
| TS3SERVER_IP_WHITELIST           |     query_ip_allowlist.txt      |                       쿼리 IP 허용 목록 파일                       |
| TS3SERVER_IP_BLACKLIST           |      query_ip_denylist.txt      |                       쿼리 IP 거부 목록 파일                       |
| TS3SERVER_DB_PLUGIN              |          ts3db_sqlite3          |                     데이터베이스 플러그인 설정                     |
| TS3SERVER_DB_PLUGINPARAMETER     |  /var/run/ts3server/ts3db.ini   |              데이터베이스 플러그인 매개변수 파일 경로              |
| TS3SERVER_DB_SQLPATH             |       /opt/ts3server/sql/       |                           SQL 파일 경로                            |
| TS3SERVER_DB_SQLCREATEPATH       |          create_sqlite          |                 SQLite 데이터베이스 생성 파일 경로                 |
| TS3SERVER_DB_CONNECTIONS         |               10                |                        데이터베이스 연결 수                        |
| TS3SERVER_DB_CLIENTKEEPDAYS      |               30                |                   클라이언트 정보 보관 기간 (일)                   |
| TS3SERVER_LOG_PATH               |       /var/ts3server/logs       |                        로그 파일 저장 경로                         |
| TS3SERVER_LOG_QUERY_COMMANDS     |                0                |      쿼리 명령 로깅 여부 <br /> (1: 로깅 활성화, 0: 비활성화)      |
| TS3SERVER_LOG_APPEND             |                0                | 로그 파일 추가 모드 <br /> (1: 추가 모드 활성화, 0: 덮어쓰기 모드) |
| TS3SERVER_SERVERQUERYDOCS_PATH   | /opt/ts3server/serverquerydocs/ |                        서버 쿼리 문서 경로                         |
| TS3SERVER_QUERY_PORT             |              10011              |                           쿼리 포트 번호                           |
| TS3SERVER_FILETRANSFER_PORT      |              30033              |                        파일 전송 포트 번호                         |
| TS3SERVER_DEFAULT_VOICE_PORT     |              9987               |                       기본 보이스 포트 번호                        |
| TS3SERVER_QUERY_SSH_PORT         |              10022              |                         쿼리 SSH 포트 번호                         |

## TeamSpeak Server DB관련 도커 환경변수 (기본 값: 아무것도 입력하지 않았을 경우) (ts3db.ini)

| 환경 변수                   | 기본값 |                 설명                 |
| --------------------------- | :----: | :----------------------------------: |
| TS3SERVER_DB_PORT           |  3306  |        데이터베이스 포트 번호        |
| TS3SERVER_DB_WAITUNTILREADY |   30   | 데이터베이스 준비까지 대기 시간 (초) |

<br />

## TeamSpeak Server 환경 변수 (지정 가능한 전체) (ts3server.ini)

| 환경 변수                           |             기본값              |                                설명                                |
| ----------------------------------- | :-----------------------------: | :----------------------------------------------------------------: |
| TS3SERVER_LICENSEPATH               |                -                |                         라이선스 파일 경로                         |
| TS3SERVER_QUERY_PROTOCOLS           |               raw               |                         쿼리 프로토콜 설정                         |
| TS3SERVER_QUERY_TIMEOUT             |               300               |                      쿼리 타임아웃 설정 (초)                       |
| TS3SERVER_QUERY_SSH_RSA_HOST_KEY    |        ssh_host_rsa_key         |                       SSH RSA 호스트 키 파일                       |
| TS3SERVER_IP_ALLOWLIST              |     query_ip_allowlist.txt      |                       쿼리 IP 허용 목록 파일                       |
| TS3SERVER_IP_DENYLIST               |      query_ip_denylist.txt      |                       쿼리 IP 거부 목록 파일                       |
| TS3SERVER_DB_PLUGIN                 |          ts3db_sqlite3          |                     데이터베이스 플러그인 설정                     |
| TS3SERVER_DB_PLUGINPARAMETER        |  /var/run/ts3server/ts3db.ini   |              데이터베이스 플러그인 매개변수 파일 경로              |
| TS3SERVER_DB_SQLPATH                |       /opt/ts3server/sql/       |                           SQL 파일 경로                            |
| TS3SERVER_DB_SQLCREATEPATH          |          create_sqlite          |                 SQLite 데이터베이스 생성 파일 경로                 |
| TS3SERVER_DB_CONNECTIONS            |               10                |                        데이터베이스 연결 수                        |
| TS3SERVER_DB_CLIENTKEEPDAYS         |               30                |                   클라이언트 정보 보관 기간 (일)                   |
| TS3SERVER_LOG_PATH                  |       /var/ts3server/logs       |                        로그 파일 저장 경로                         |
| TS3SERVER_LOG_QUERY_COMMANDS        |                0                |      쿼리 명령 로깅 여부 <br /> (1: 로깅 활성화, 0: 비활성화)      |
| TS3SERVER_LOG_APPEND                |                0                | 로그 파일 추가 모드 <br /> (1: 추가 모드 활성화, 0: 덮어쓰기 모드) |
| TS3SERVER_SERVERQUERYDOCS_PATH      | /opt/ts3server/serverquerydocs/ |                        서버 쿼리 문서 경로                         |
| TS3SERVER_QUERY_IP                  |                -                |                      쿼리 IP 주소 `(선택적)`                       |
| TS3SERVER_QUERY_PORT                |              10011              |                           쿼리 포트 번호                           |
| TS3SERVER_FILETRANSFER_IP           |                -                |                    파일 전송 IP 주소 `(선택적)`                    |
| TS3SERVER_FILETRANSFER_PORT         |              30033              |                        파일 전송 포트 번호                         |
| TS3SERVER_VOICE_IP                  |                -                |                   보이스 서버 IP 주소 `(선택적)`                   |
| TS3SERVER_DEFAULT_VOICE_PORT        |              9987               |                       기본 보이스 포트 번호                        |
| TS3SERVER_QUERY_SSH_IP              |                -                |                    쿼리 SSH IP 주소 `(선택적)`                     |
| TS3SERVER_QUERY_SSH_PORT            |              10022              |                         쿼리 SSH 포트 번호                         |
| TS3SERVER_SERVERADMIN_PASSWORD      |                -                |                  서버 관리자 비밀번호 `(선택적)`                   |
| TS3SERVER_MACHINE_ID                |                -                |                         머신 ID `(선택적)`                         |
| TS3SERVER_QUERY_SKIPBRUTEFORCECHECK |                -                |             쿼리 브루트포스 체크 생략 여부 `(선택적)`              |
| TS3SERVER_HINTS_ENABLED             |                -                |                    힌트 활성화 여부 `(선택적)`                     |

## TeamSpeak Server DB관련 도커 환경변수 (지정가능한 전체) (ts3db.ini)

| 환경 변수                   | 기본값 |                 설명                 |
| --------------------------- | :----: | :----------------------------------: |
| TS3SERVER_DB_HOST           |   -    |         데이터베이스 호스트          |
| TS3SERVER_DB_PORT           |  3306  |        데이터베이스 포트 번호        |
| TS3SERVER_DB_USER           |   -    |       데이터베이스 사용자 이름       |
| TS3SERVER_DB_PASSWORD       |   -    |     데이터베이스 사용자 비밀번호     |
| TS3SERVER_DB_NAME           |   -    |          데이터베이스 이름           |
| TS3SERVER_DB_WAITUNTILREADY |   30   | 데이터베이스 준비까지 대기 시간 (초) |

<br /><br />

## License

SPDX-License-Identifier: MIT

Like all Docker images, this one may contain other software which is governed by additional licenses (e.g., Bash from the base distribution and direct or indirect dependencies of included software).

When using pre-built images, it is the responsibility of the user to ensure compliance with relevant licenses for all software included in the image.

All other trademarks are the property of their respective owners, and unless otherwise specified, we do not claim affiliation, endorsement, or association with any trademark owners mentioned in this text.
