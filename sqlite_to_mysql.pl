#!/usr/bin/perl
use strict;
use warnings;

# SQLite 덤프 파일과 MySQL로 변환할 파일명 설정
my $sqlite_dump_file = 'ts3dump.sql';
my $mysql_dump_file  = 'ts3mysql.sql';

# 스크립트 시작
open(my $sqlite_fh, '<', $sqlite_dump_file) or die "Cannot open $sqlite_dump_file: $!";
open(my $mysql_fh, '>', $mysql_dump_file) or die "Cannot create $mysql_dump_file: $!";

# 기존 테이블 존재 여부 체크 변수
my %existing_tables;

while (my $line = <$sqlite_fh>) {
    chomp $line;

    # SQLite의 트랜잭션 문법을 MySQL로 변환
    if ($line =~ /^PRAGMA foreign_keys=OFF;/) {
        $line =~ s/^PRAGMA foreign_keys=OFF;/SET foreign_key_checks=0;/;
        print $mysql_fh "$line\n";
    } elsif ($line =~ /^BEGIN TRANSACTION;/) {
        $line =~ s/^BEGIN TRANSACTION;/START TRANSACTION;/;
        print $mysql_fh "$line\n";
    } elsif ($line =~ /^COMMIT;/) {
        # SQLite의 COMMIT 문 그대로 사용
        print $mysql_fh "$line\n";
    } elsif ($line =~ /^ROLLBACK;/) {
        # SQLite의 ROLLBACK 문 그대로 사용
        print $mysql_fh "$line\n";
    } elsif ($line =~ /^CREATE TABLE/) {
        # SQLite의 AUTOINCREMENT를 MySQL의 AUTO_INCREMENT로 변환
        $line =~ s/AUTOINCREMENT/AUTO_INCREMENT/g;

        # 테이블 이름 추출
        if ($line =~ /^CREATE TABLE (\w+)/) {
            my $table_name = $1;

            # 테이블이 이미 존재하는 경우 DROP TABLE 후 생성
            if ($existing_tables{$table_name}) {
                print $mysql_fh "DROP TABLE IF EXISTS $table_name;\n";
            }

            $existing_tables{$table_name} = 1;
        }

        print $mysql_fh "$line\n";
    } elsif ($line =~ / DEFAULT 't'/) {
        # SQLite의 boolean 값을 MySQL의 boolean 값으로 변환
        $line =~ s/ DEFAULT 't'/ DEFAULT 1/;
        print $mysql_fh "$line\n";
    } elsif ($line =~ / DEFAULT 'f'/) {
        $line =~ s/ DEFAULT 'f'/ DEFAULT 0/;
        print $mysql_fh "$line\n";
    } elsif ($line =~ /^INSERT INTO sqlite_sequence/) {
        # SQLite의 sqlite_sequence 관련 쿼리는 MySQL에서는 필요하지 않으므로 제외
        next;
    } elsif ($line =~ /^DELETE FROM sqlite_sequence;/) {
        # SQLite의 sqlite_sequence 관련 쿼리는 MySQL에서는 필요하지 않으므로 제외
        next;
    } else {
        # 그 외의 경우는 그대로 출력
        print $mysql_fh "$line\n";
    }
}

close $sqlite_fh;
close $mysql_fh;

print "Conversion completed. MySQL dump file is saved as $mysql_dump_file.\n";
