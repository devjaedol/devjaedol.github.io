---
title: "[PostgreSQL] 11. 백업과 복구 (Backup & Recovery)"
categories: 
    - postgresql
tags: 
    [postgresql, postgres, postgresql강좌, 고급, 'lecture-postgresql']
toc : true
toc_sticky  : true    
---

PostgreSQL의 백업 전략, 도구, WAL 아카이빙, 시점 복구를 정리합니다.

# 백업 종류

| 구분 | 논리적 백업 | 물리적 백업 |
|------|-----------|-----------|
| 방식 | SQL/덤프로 내보내기 | 데이터 디렉토리 복사 |
| 도구 | pg_dump, pg_dumpall | pg_basebackup, 파일 복사 |
| 속도 | 느림 (대용량 시) | 빠름 |
| 시점 복구 | 불가 | 가능 (WAL 아카이빙) |
| 호환성 | 다른 버전 간 이식 가능 | 동일 메이저 버전 필요 |
| 선택적 백업 | 테이블/스키마 단위 가능 | 전체 클러스터만 |

---

## pg_dump (논리적 백업)

### 데이터베이스 백업
```bash
# 기본 백업 (SQL 형식)
pg_dump -U postgres mydb > mydb_backup.sql

# 커스텀 형식 (압축, 병렬 복원 가능, 권장)
pg_dump -U postgres -Fc mydb > mydb_backup.dump

# 디렉토리 형식 (병렬 백업 가능)
pg_dump -U postgres -Fd -j 4 mydb -f mydb_backup_dir

# 특정 테이블만
pg_dump -U postgres -t employees -t departments mydb > tables_backup.sql

# 특정 스키마만
pg_dump -U postgres -n app mydb > schema_backup.sql

# 구조만 (데이터 제외)
pg_dump -U postgres --schema-only mydb > schema_only.sql

# 데이터만 (구조 제외)
pg_dump -U postgres --data-only mydb > data_only.sql

# 압축 백업
pg_dump -U postgres mydb | gzip > mydb_backup.sql.gz
```

### 전체 클러스터 백업 (pg_dumpall)
```bash
# 모든 데이터베이스 + 글로벌 객체 (롤, 테이블스페이스)
pg_dumpall -U postgres > all_backup.sql

# 글로벌 객체만 (롤, 권한)
pg_dumpall -U postgres --globals-only > globals_backup.sql
```

---

## 복구 (Restore)

### SQL 형식 복원
```bash
# SQL 파일 복원
psql -U postgres mydb < mydb_backup.sql

# 압축 파일 복원
gunzip < mydb_backup.sql.gz | psql -U postgres mydb

# 데이터베이스 생성 후 복원
createdb -U postgres mydb_restored
psql -U postgres mydb_restored < mydb_backup.sql
```

### 커스텀/디렉토리 형식 복원 (pg_restore)
```bash
# 커스텀 형식 복원
pg_restore -U postgres -d mydb mydb_backup.dump

# 병렬 복원 (디렉토리 형식)
pg_restore -U postgres -d mydb -j 4 mydb_backup_dir

# 기존 데이터 삭제 후 복원
pg_restore -U postgres -d mydb --clean --if-exists mydb_backup.dump

# 특정 테이블만 복원
pg_restore -U postgres -d mydb -t employees mydb_backup.dump

# 목록 확인 (복원 전 내용 확인)
pg_restore -l mydb_backup.dump
```

---

## WAL 아카이빙과 시점 복구 (PITR)

WAL(Write-Ahead Log)을 아카이빙하면 특정 시점으로 복구할 수 있습니다.

### WAL 아카이빙 설정 (postgresql.conf)
```ini
wal_level = replica
archive_mode = on
archive_command = 'cp %p /backup/wal_archive/%f'
# Windows: archive_command = 'copy "%p" "D:\\backup\\wal_archive\\%f"'
```

### 베이스 백업 (pg_basebackup)
```bash
# 기본 베이스 백업
pg_basebackup -U postgres -D /backup/base -Ft -z -P

# 옵션 설명
# -D: 백업 디렉토리
# -Ft: tar 형식
# -z: gzip 압축
# -P: 진행률 표시
# -Xs: WAL 스트리밍 포함
pg_basebackup -U postgres -D /backup/base -Ft -z -Xs -P
```

### 시점 복구 (PITR) 절차
```bash
# 1. PostgreSQL 중지
sudo systemctl stop postgresql

# 2. 기존 데이터 디렉토리 백업
mv /var/lib/postgresql/17/main /var/lib/postgresql/17/main_old

# 3. 베이스 백업 복원
tar xzf /backup/base/base.tar.gz -C /var/lib/postgresql/17/main

# 4. recovery.signal 파일 생성 (PostgreSQL 12+)
touch /var/lib/postgresql/17/main/recovery.signal

# 5. postgresql.conf에 복구 설정 추가
# restore_command = 'cp /backup/wal_archive/%f %p'
# recovery_target_time = '2026-05-04 14:00:00'

# 6. PostgreSQL 시작
sudo systemctl start postgresql

# 7. 복구 완료 후 타임라인 승격
SELECT pg_wal_replay_resume();
```

---

## 자동 백업 스크립트

```bash
#!/bin/bash
# backup_postgresql.sh

BACKUP_DIR="/backup/postgresql"
DATE=$(date +%Y%m%d_%H%M%S)
PG_USER="postgres"
DATABASES="mydb production_db"
RETENTION_DAYS=30

mkdir -p $BACKUP_DIR

for DB in $DATABASES; do
    pg_dump -U $PG_USER -Fc $DB > $BACKUP_DIR/${DB}_${DATE}.dump
    echo "$(date): $DB 백업 완료" >> $BACKUP_DIR/backup.log
done

# 글로벌 객체 백업
pg_dumpall -U $PG_USER --globals-only > $BACKUP_DIR/globals_${DATE}.sql

# 오래된 백업 삭제
find $BACKUP_DIR -name "*.dump" -mtime +$RETENTION_DAYS -delete
find $BACKUP_DIR -name "*.sql" -mtime +$RETENTION_DAYS -delete
```

```bash
# crontab 등록 (매일 새벽 3시)
0 3 * * * /path/to/backup_postgresql.sh
```

---

## 백업 전략 가이드

| 환경 | 전략 | 주기 |
|------|------|------|
| 개발 | pg_dump 커스텀 형식 | 주 1회 |
| 스테이징 | pg_dump + WAL 아카이빙 | 일 1회 |
| 운영 (소규모) | pg_basebackup + WAL 아카이빙 | 일 1회 + PITR |
| 운영 (대규모) | pg_basebackup + WAL 아카이빙 + 스트리밍 복제 | 실시간 복제 + 일 1회 |

{% assign c-category = 'postgresql' %}
{% assign c-tag = 'lecture-postgresql' %}
{% include /custom-ref.html %}
