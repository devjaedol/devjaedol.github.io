---
title: "[MySQL] 11. 백업과 복구 (Backup & Restore)"
categories: 
    - mysql
tags: 
    [mysql, mariadb, mysql강좌, 고급, 'lecture-mysql']
toc : true
toc_sticky  : true    
---

MySQL/MariaDB의 백업 전략, 도구, 복구 방법을 정리합니다.

# 백업 종류

| 구분 | 논리적 백업 | 물리적 백업 |
|------|-----------|-----------|
| 방식 | SQL 문으로 내보내기 | 데이터 파일 직접 복사 |
| 도구 | mysqldump, mysqlpump | xtrabackup, 파일 복사 |
| 속도 | 느림 (대용량에 부적합) | 빠름 |
| 복구 속도 | 느림 (SQL 재실행) | 빠름 (파일 복사) |
| 호환성 | 다른 버전/서버 간 이식 가능 | 동일 버전/설정 필요 |
| 용량 | 상대적으로 작음 (텍스트) | 큼 (바이너리) |

---

## mysqldump (논리적 백업)

가장 기본적이고 널리 사용되는 백업 도구입니다.

### 데이터베이스 백업
```bash
# 단일 데이터베이스 백업
mysqldump -u root -p mydb > mydb_backup.sql

# 특정 테이블만 백업
mysqldump -u root -p mydb employees departments > tables_backup.sql

# 여러 데이터베이스 백업
mysqldump -u root -p --databases mydb testdb > multi_db_backup.sql

# 전체 데이터베이스 백업
mysqldump -u root -p --all-databases > all_backup.sql

# 구조만 백업 (데이터 제외)
mysqldump -u root -p --no-data mydb > schema_only.sql

# 데이터만 백업 (구조 제외)
mysqldump -u root -p --no-create-info mydb > data_only.sql
```

### 주요 옵션

| 옵션 | 설명 |
|------|------|
| `--single-transaction` | InnoDB 테이블을 일관된 상태로 백업 (락 없이) |
| `--routines` | 스토어드 프로시저/함수 포함 |
| `--triggers` | 트리거 포함 (기본 활성화) |
| `--events` | 이벤트 스케줄러 포함 |
| `--add-drop-table` | DROP TABLE 문 포함 (기본 활성화) |
| `--compress` | 전송 시 압축 |
| `--where` | 조건부 백업 |

### 운영 환경 권장 백업 명령
```bash
# InnoDB 기반 운영 DB 백업 (락 없이 일관된 백업)
mysqldump -u root -p \
  --single-transaction \
  --routines \
  --triggers \
  --events \
  --set-gtid-purged=OFF \
  mydb > mydb_$(date +%Y%m%d_%H%M%S).sql

# 압축 백업
mysqldump -u root -p --single-transaction mydb | gzip > mydb_backup.sql.gz
```

---

## 복구 (Restore)

### SQL 파일로 복구
```bash
# 데이터베이스 복구
mysql -u root -p mydb < mydb_backup.sql

# 압축 파일 복구
gunzip < mydb_backup.sql.gz | mysql -u root -p mydb

# 데이터베이스가 없는 경우 (--databases 옵션으로 백업한 경우)
mysql -u root -p < multi_db_backup.sql
```

### MySQL 클라이언트에서 복구
```sql
-- 데이터베이스 생성 (필요 시)
CREATE DATABASE IF NOT EXISTS mydb;
USE mydb;

-- SQL 파일 실행
SOURCE /path/to/mydb_backup.sql;
```

---

## 바이너리 로그 (Binary Log)

바이너리 로그는 데이터 변경 이벤트를 기록하며, 시점 복구(Point-in-Time Recovery)에 사용됩니다.

### 바이너리 로그 설정
```ini
# my.cnf (my.ini)
[mysqld]
log-bin = mysql-bin
binlog_format = ROW
expire_logs_days = 7
max_binlog_size = 100M
```

### 바이너리 로그 관리
```sql
-- 바이너리 로그 목록
SHOW BINARY LOGS;

-- 현재 바이너리 로그 파일
SHOW MASTER STATUS;

-- 바이너리 로그 내용 확인
SHOW BINLOG EVENTS IN 'mysql-bin.000001' LIMIT 10;

-- 오래된 로그 삭제
PURGE BINARY LOGS BEFORE '2026-05-01 00:00:00';
PURGE BINARY LOGS TO 'mysql-bin.000005';
```

### 시점 복구 (Point-in-Time Recovery)
```bash
# 1단계: 전체 백업 복구
mysql -u root -p mydb < mydb_full_backup.sql

# 2단계: 바이너리 로그로 특정 시점까지 복구
mysqlbinlog --stop-datetime="2026-05-04 14:30:00" mysql-bin.000010 | mysql -u root -p mydb

# 특정 위치(position)까지 복구
mysqlbinlog --stop-position=12345 mysql-bin.000010 | mysql -u root -p mydb
```

---

## 자동 백업 스크립트

### Linux (crontab)
```bash
#!/bin/bash
# backup_mysql.sh

BACKUP_DIR="/backup/mysql"
DATE=$(date +%Y%m%d_%H%M%S)
DB_USER="backup_user"
DB_PASS="BackupP@ss1!"
DATABASES="mydb production_db"
RETENTION_DAYS=30

mkdir -p $BACKUP_DIR

for DB in $DATABASES; do
    mysqldump -u $DB_USER -p$DB_PASS \
        --single-transaction \
        --routines --triggers --events \
        $DB | gzip > $BACKUP_DIR/${DB}_${DATE}.sql.gz
    
    echo "$(date): $DB 백업 완료" >> $BACKUP_DIR/backup.log
done

# 오래된 백업 삭제
find $BACKUP_DIR -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete
```

```bash
# crontab 등록 (매일 새벽 3시)
crontab -e
0 3 * * * /path/to/backup_mysql.sh
```

### Windows (작업 스케줄러)
```bat
@echo off
set BACKUP_DIR=D:\backup\mysql
set DATE=%date:~0,4%%date:~5,2%%date:~8,2%
set DB_USER=backup_user
set DB_PASS=BackupP@ss1!

mysqldump -u %DB_USER% -p%DB_PASS% --single-transaction mydb > %BACKUP_DIR%\mydb_%DATE%.sql
```

---

## 백업 전략 가이드

| 환경 | 전략 | 주기 |
|------|------|------|
| 개발 | mysqldump 전체 백업 | 주 1회 |
| 스테이징 | mysqldump + 바이너리 로그 | 일 1회 |
| 운영 (소규모) | mysqldump + 바이너리 로그 | 일 1회 + 시점 복구 |
| 운영 (대규모) | xtrabackup 증분 백업 + 바이너리 로그 | 주 1회 전체 + 일 1회 증분 |

핵심 원칙:
- 백업은 반드시 복구 테스트를 해야 합니다
- 백업 파일은 원본 서버와 다른 위치에 보관합니다
- 3-2-1 규칙: 3개 복사본, 2가지 매체, 1개는 원격지

{% assign c-category = 'mysql' %}
{% assign c-tag = 'lecture-mysql' %}
{% include /custom-ref.html %}
