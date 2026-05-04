---
title: "[Oracle] 11. 백업과 복구 (Backup & Recovery)"
categories: 
    - oracle
tags: 
    [oracle, oracle강좌, 고급, 'lecture-oracle']
toc : true
toc_sticky  : true    
---

Oracle의 백업 전략, RMAN, Data Pump, Flashback 기능을 정리합니다.

# 백업 종류

| 구분 | 논리적 백업 | 물리적 백업 |
|------|-----------|-----------|
| 방식 | 데이터를 SQL/덤프로 내보내기 | 데이터파일 직접 복사 |
| 도구 | Data Pump (expdp/impdp) | RMAN, OS 복사 |
| 속도 | 상대적으로 느림 | 빠름 |
| 복구 | 논리적 복원 | 물리적 복원 + 미디어 복구 |
| 시점 복구 | 불가 | 가능 (아카이브 로그) |
| 용도 | 마이그레이션, 부분 백업 | 전체 DB 백업/복구 |

---

## Data Pump (논리적 백업)

Oracle 10g부터 도입된 고성능 논리적 백업/복구 도구입니다.    
기존 exp/imp를 대체합니다.

### 디렉토리 객체 생성
Data Pump는 서버 측 디렉토리를 사용합니다.
```sql
-- 디렉토리 생성 (DBA 권한)
CREATE OR REPLACE DIRECTORY dp_dir AS '/backup/datapump';
-- Windows
CREATE OR REPLACE DIRECTORY dp_dir AS 'D:\backup\datapump';

-- 사용자에게 권한 부여
GRANT READ, WRITE ON DIRECTORY dp_dir TO devuser;
```

### Export (expdp)
```bash
# 전체 스키마 백업
expdp devuser/pass123@XE \
  SCHEMAS=devuser \
  DIRECTORY=dp_dir \
  DUMPFILE=devuser_20260504.dmp \
  LOGFILE=devuser_export.log

# 특정 테이블만 백업
expdp devuser/pass123@XE \
  TABLES=employees,departments \
  DIRECTORY=dp_dir \
  DUMPFILE=tables_20260504.dmp \
  LOGFILE=tables_export.log

# 전체 데이터베이스 백업 (DBA 권한)
expdp sys/password@XE AS SYSDBA \
  FULL=Y \
  DIRECTORY=dp_dir \
  DUMPFILE=full_20260504_%U.dmp \
  FILESIZE=2G \
  LOGFILE=full_export.log \
  PARALLEL=4

# 조건부 백업
expdp devuser/pass123@XE \
  TABLES=employees \
  QUERY="employees:\"WHERE hire_date >= TO_DATE('2024-01-01','YYYY-MM-DD')\"" \
  DIRECTORY=dp_dir \
  DUMPFILE=emp_2024.dmp

# 구조만 백업 (데이터 제외)
expdp devuser/pass123@XE \
  SCHEMAS=devuser \
  CONTENT=METADATA_ONLY \
  DIRECTORY=dp_dir \
  DUMPFILE=schema_only.dmp

# 데이터만 백업 (구조 제외)
expdp devuser/pass123@XE \
  SCHEMAS=devuser \
  CONTENT=DATA_ONLY \
  DIRECTORY=dp_dir \
  DUMPFILE=data_only.dmp
```

### Import (impdp)
```bash
# 스키마 복원
impdp devuser/pass123@XE \
  SCHEMAS=devuser \
  DIRECTORY=dp_dir \
  DUMPFILE=devuser_20260504.dmp \
  LOGFILE=devuser_import.log

# 다른 스키마로 복원 (REMAP_SCHEMA)
impdp sys/password@XE AS SYSDBA \
  REMAP_SCHEMA=devuser:testuser \
  DIRECTORY=dp_dir \
  DUMPFILE=devuser_20260504.dmp

# 다른 테이블스페이스로 복원
impdp sys/password@XE AS SYSDBA \
  REMAP_TABLESPACE=ts_old:ts_new \
  DIRECTORY=dp_dir \
  DUMPFILE=devuser_20260504.dmp

# 테이블 존재 시 처리 옵션
impdp devuser/pass123@XE \
  TABLES=employees \
  TABLE_EXISTS_ACTION=REPLACE \
  DIRECTORY=dp_dir \
  DUMPFILE=tables_20260504.dmp
```

#### TABLE_EXISTS_ACTION 옵션

| 옵션 | 설명 |
|------|------|
| SKIP | 이미 존재하면 건너뜀 (기본값) |
| REPLACE | 기존 테이블 삭제 후 재생성 |
| APPEND | 기존 데이터에 추가 |
| TRUNCATE | 기존 데이터 삭제 후 삽입 |

---

## RMAN (Recovery Manager) - 물리적 백업

Oracle의 공식 물리적 백업/복구 도구입니다.

### RMAN 접속
```bash
# 로컬 접속
rman target /

# 원격 접속
rman target sys/password@XE
```

### 아카이브 로그 모드 설정
RMAN 온라인 백업과 시점 복구를 위해 필수입니다.
```sql
-- 현재 모드 확인
SELECT log_mode FROM v$database;

-- 아카이브 로그 모드 활성화
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE ARCHIVELOG;
ALTER DATABASE OPEN;

-- 확인
ARCHIVE LOG LIST;
```

### RMAN 백업
```bash
# RMAN 프롬프트에서 실행

# 전체 데이터베이스 백업
RMAN> BACKUP DATABASE PLUS ARCHIVELOG;

# 압축 백업
RMAN> BACKUP AS COMPRESSED BACKUPSET DATABASE PLUS ARCHIVELOG;

# 특정 테이블스페이스 백업
RMAN> BACKUP TABLESPACE users;

# 증분 백업 (Level 0: 전체, Level 1: 변경분)
RMAN> BACKUP INCREMENTAL LEVEL 0 DATABASE;
RMAN> BACKUP INCREMENTAL LEVEL 1 DATABASE;

# 백업 목록 확인
RMAN> LIST BACKUP SUMMARY;
RMAN> LIST BACKUP OF DATABASE;

# 오래된 백업 삭제
RMAN> DELETE OBSOLETE;
```

### RMAN 복구
```bash
# 전체 복구
RMAN> RESTORE DATABASE;
RMAN> RECOVER DATABASE;
RMAN> ALTER DATABASE OPEN;

# 시점 복구 (Point-in-Time Recovery)
RMAN> RUN {
  SET UNTIL TIME "TO_DATE('2026-05-04 14:00:00', 'YYYY-MM-DD HH24:MI:SS')";
  RESTORE DATABASE;
  RECOVER DATABASE;
  ALTER DATABASE OPEN RESETLOGS;
}

# 특정 테이블스페이스 복구
RMAN> RUN {
  SQL 'ALTER TABLESPACE users OFFLINE';
  RESTORE TABLESPACE users;
  RECOVER TABLESPACE users;
  SQL 'ALTER TABLESPACE users ONLINE';
}
```

### RMAN 자동 백업 스크립트
```bash
#!/bin/bash
# rman_backup.sh

export ORACLE_HOME=/opt/oracle/product/21c/dbhome_1
export ORACLE_SID=XE

$ORACLE_HOME/bin/rman target / << EOF
RUN {
  ALLOCATE CHANNEL c1 DEVICE TYPE DISK;
  BACKUP AS COMPRESSED BACKUPSET
    INCREMENTAL LEVEL 1
    DATABASE
    FORMAT '/backup/rman/%d_%T_%s_%p.bkp';
  BACKUP ARCHIVELOG ALL
    FORMAT '/backup/rman/arch_%d_%T_%s_%p.bkp'
    DELETE INPUT;
  DELETE NOPROMPT OBSOLETE;
}
EXIT;
EOF
```

```bash
# crontab 등록 (매일 새벽 2시)
0 2 * * * /path/to/rman_backup.sh >> /backup/rman/backup.log 2>&1
```

---

## Flashback 기능

Oracle의 Flashback은 데이터를 과거 시점으로 되돌리는 기능입니다.

### Flashback Query (과거 데이터 조회)
```sql
-- 특정 시점의 데이터 조회
SELECT * FROM employees
AS OF TIMESTAMP (SYSTIMESTAMP - INTERVAL '30' MINUTE);

-- 특정 SCN 기준 조회
SELECT * FROM employees AS OF SCN 12345678;

-- 변경 이력 조회 (Flashback Version Query)
SELECT name, salary, versions_operation, versions_starttime, versions_endtime
FROM employees
VERSIONS BETWEEN TIMESTAMP
    (SYSTIMESTAMP - INTERVAL '1' HOUR) AND SYSTIMESTAMP
WHERE id = 1;
```

### Flashback Table
```sql
-- 테이블을 과거 시점으로 복원
ALTER TABLE employees ENABLE ROW MOVEMENT;

FLASHBACK TABLE employees
TO TIMESTAMP (SYSTIMESTAMP - INTERVAL '1' HOUR);

-- 휴지통에서 복구 (DROP 취소)
FLASHBACK TABLE employees TO BEFORE DROP;
```

### Flashback Database (전체 DB 복원)
```sql
-- Flashback Database 활성화 (DBA)
ALTER SYSTEM SET db_flashback_retention_target = 1440;  -- 24시간
ALTER DATABASE FLASHBACK ON;

-- 전체 DB를 과거 시점으로 복원
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
FLASHBACK DATABASE TO TIMESTAMP
    TO_TIMESTAMP('2026-05-04 12:00:00', 'YYYY-MM-DD HH24:MI:SS');
ALTER DATABASE OPEN RESETLOGS;
```

---

## 백업 전략 가이드

| 환경 | 전략 | 주기 |
|------|------|------|
| 개발 | Data Pump 스키마 백업 | 주 1회 |
| 스테이징 | RMAN 전체 + 아카이브 로그 | 일 1회 |
| 운영 (소규모) | RMAN Level 0 + Level 1 증분 | 주 1회 전체 + 일 1회 증분 |
| 운영 (대규모) | RMAN 증분 + Data Guard | 실시간 복제 + 일 1회 증분 |

{% assign c-category = 'oracle' %}
{% assign c-tag = 'lecture-oracle' %}
{% include /custom-ref.html %}
