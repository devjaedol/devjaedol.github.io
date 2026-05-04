---
title: "[PostgreSQL] 13. 자주 발생하는 Troubleshooting"
categories: 
    - postgresql
tags: 
    [postgresql, postgres, postgresql강좌, 고급, 'lecture-postgresql']
toc : true
toc_sticky  : true    
---

PostgreSQL 운영 중 자주 발생하는 문제와 해결 방법을 빈도순으로 정리합니다.

# 접속 오류

## FATAL: password authentication failed

```text
FATAL: password authentication failed for user "devuser"
```

| 원인 | 해결 방법 |
|------|----------|
| 비밀번호 오류 | 비밀번호 재확인 |
| pg_hba.conf 설정 | 인증 방식 확인 (peer → scram-sha-256) |
| 롤 미존재 | `\du`로 롤 존재 여부 확인 |

```sql
-- 비밀번호 재설정
ALTER ROLE devuser WITH PASSWORD 'NewPass123!';
```

## FATAL: no pg_hba.conf entry for host

```text
FATAL: no pg_hba.conf entry for host "192.168.1.100", user "devuser", database "mydb"
```

```bash
# pg_hba.conf에 접속 허용 규칙 추가
# host  mydb  devuser  192.168.1.0/24  scram-sha-256

# 설정 리로드
sudo systemctl reload postgresql
```

## connection refused / could not connect to server

| 원인 | 해결 방법 |
|------|----------|
| 서비스 미실행 | `sudo systemctl start postgresql` |
| listen_addresses 설정 | `postgresql.conf`에서 `listen_addresses = '*'` |
| 포트 불일치 | 기본 5432 확인 |
| 방화벽 차단 | 5432 포트 허용 |

---

## 테이블 부풀림 (Table Bloat)

PostgreSQL의 MVCC 특성상 UPDATE/DELETE가 많은 테이블은 크기가 계속 증가합니다.

### 증상
- 테이블 크기가 실제 데이터 대비 비정상적으로 큼
- 쿼리 성능이 점진적으로 저하

### 확인
```sql
-- 죽은 튜플 비율 확인
SELECT relname, n_live_tup, n_dead_tup,
    ROUND(n_dead_tup::NUMERIC / NULLIF(n_live_tup + n_dead_tup, 0) * 100, 1) AS dead_pct,
    last_autovacuum
FROM pg_stat_user_tables
WHERE n_dead_tup > 1000
ORDER BY n_dead_tup DESC;
```

### 해결
```sql
-- 일반 VACUUM (공간 재사용 표시, 서비스 중단 없음)
VACUUM ANALYZE large_table;

-- VACUUM FULL (물리적 공간 반환, 배타 락 주의)
VACUUM FULL large_table;

-- pg_repack (온라인 테이블 재구축, 확장 설치 필요)
-- pg_repack -U postgres -d mydb -t large_table
```

---

## 락 대기 / 쿼리 멈춤

### 락 대기 확인
```sql
SELECT
    blocked.pid AS blocked_pid,
    blocked_activity.usename AS blocked_user,
    blocked_activity.query AS blocked_query,
    blocking.pid AS blocking_pid,
    blocking_activity.usename AS blocking_user,
    blocking_activity.query AS blocking_query,
    NOW() - blocked_activity.query_start AS wait_duration
FROM pg_catalog.pg_locks blocked
JOIN pg_catalog.pg_locks blocking
    ON blocking.locktype = blocked.locktype
    AND blocking.relation = blocked.relation
    AND blocking.pid != blocked.pid
JOIN pg_stat_activity blocked_activity ON blocked_activity.pid = blocked.pid
JOIN pg_stat_activity blocking_activity ON blocking_activity.pid = blocking.pid
WHERE NOT blocked.granted;
```

### 해결
```sql
-- 블로킹 쿼리 취소 (graceful)
SELECT pg_cancel_backend(blocking_pid);

-- 블로킹 세션 강제 종료
SELECT pg_terminate_backend(blocking_pid);

-- 락 타임아웃 설정 (예방)
SET lock_timeout = '10s';
```

---

## 디스크 용량 부족

```text
ERROR: could not extend file "base/16384/12345": No space left on device
```

### 확인
```sql
-- 데이터베이스별 크기
SELECT datname, pg_size_pretty(pg_database_size(datname)) AS size
FROM pg_database ORDER BY pg_database_size(datname) DESC;

-- 대용량 테이블
SELECT relname,
    pg_size_pretty(pg_total_relation_size(relid)) AS total_size
FROM pg_stat_user_tables
ORDER BY pg_total_relation_size(relid) DESC
LIMIT 10;
```

### 해결

| 방법 | 명령어 |
|------|--------|
| WAL 파일 정리 | `pg_archivecleanup` 또는 `max_wal_size` 조정 |
| 불필요한 데이터 삭제 | DELETE + VACUUM |
| 테이블 부풀림 해소 | VACUUM FULL 또는 pg_repack |
| 로그 파일 정리 | 로그 로테이션 설정 |
| 임시 파일 정리 | `temp_file_limit` 설정 |

---

## 슬로우 쿼리 / 성능 저하

### 점검 체크리스트

| 순서 | 점검 항목 | 확인 방법 |
|:----:|----------|----------|
| 1 | 현재 활성 쿼리 | `pg_stat_activity` |
| 2 | 락 대기 여부 | `pg_locks` |
| 3 | 실행 계획 확인 | `EXPLAIN ANALYZE` |
| 4 | 통계 정보 갱신 | `ANALYZE table_name` |
| 5 | 죽은 튜플 확인 | `pg_stat_user_tables` |
| 6 | 캐시 히트율 | `pg_stat_database` |
| 7 | 디스크 I/O | OS 레벨 `iostat` 확인 |

```sql
-- 장시간 실행 중인 쿼리
SELECT pid, usename, state,
    NOW() - query_start AS duration,
    LEFT(query, 100) AS query
FROM pg_stat_activity
WHERE state != 'idle'
ORDER BY duration DESC;

-- 통계 갱신 (실행 계획이 갑자기 바뀐 경우)
ANALYZE employees;
```

---

## too many connections

```text
FATAL: too many connections for role "devuser"
FATAL: sorry, too many clients already
```

### 해결
```sql
-- 현재 접속 수 확인
SELECT count(*) FROM pg_stat_activity;
SELECT usename, count(*) FROM pg_stat_activity GROUP BY usename;

-- max_connections 확인
SHOW max_connections;

-- 유휴 세션 종료
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE state = 'idle'
  AND query_start < NOW() - INTERVAL '30 minutes'
  AND pid != pg_backend_pid();
```

### 근본 해결
```ini
# postgresql.conf
max_connections = 200

# 커넥션 풀러 사용 권장 (PgBouncer)
# PgBouncer는 수천 개의 애플리케이션 연결을 수십 개의 DB 연결로 관리
```

---

## 인코딩 / 한글 문제

```text
ERROR: character with byte sequence 0xec 0x95 0x88 in encoding "UTF8" has no equivalent in encoding "LATIN1"
```

### 확인
```sql
-- 데이터베이스 인코딩 확인
SELECT datname, pg_encoding_to_char(encoding) AS encoding, datcollate
FROM pg_database;

-- 클라이언트 인코딩 확인
SHOW client_encoding;
```

### 해결
```sql
-- 클라이언트 인코딩 변경
SET client_encoding = 'UTF8';

-- 데이터베이스 생성 시 인코딩 지정
CREATE DATABASE mydb
  ENCODING = 'UTF8'
  LC_COLLATE = 'ko_KR.UTF-8'
  LC_CTYPE = 'ko_KR.UTF-8'
  TEMPLATE = template0;
```

---

## SERIALIZABLE 격리 수준 오류

```text
ERROR: could not serialize access due to concurrent update
ERROR: could not serialize access due to read/write dependencies among transactions
```

SERIALIZABLE 격리 수준에서 동시 트랜잭션 충돌 시 발생합니다.

### 해결
```python
# 애플리케이션에서 재시도 로직 구현
MAX_RETRIES = 3
for attempt in range(MAX_RETRIES):
    try:
        cursor.execute("BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE")
        cursor.execute("UPDATE accounts SET balance = balance - 100 WHERE id = 1")
        cursor.execute("COMMIT")
        break
    except psycopg2.errors.SerializationFailure:
        cursor.execute("ROLLBACK")
        time.sleep(0.1 * (attempt + 1))
```

---

## OOM Killer (Linux)

메모리 부족 시 OS가 PostgreSQL 프로세스를 강제 종료합니다.

### 확인
```bash
dmesg | grep -i "oom\|killed"
grep -i "oom" /var/log/syslog
```

### 해결

| 방법 | 설명 |
|------|------|
| shared_buffers 축소 | 전체 메모리의 25% 이하로 |
| work_mem 축소 | 세션당 메모리 제한 |
| max_connections 축소 | 동시 접속 수 제한 |
| huge_pages 활성화 | 메모리 효율 개선 |

```bash
# PostgreSQL 프로세스의 OOM 점수 낮추기
echo -1000 > /proc/$(head -1 /var/lib/postgresql/17/main/postmaster.pid)/oom_score_adj
```

---

## 복제 (Replication) 오류

### 복제 상태 확인
```sql
-- Primary에서 확인
SELECT client_addr, state, sent_lsn, write_lsn, flush_lsn, replay_lsn,
    pg_wal_lsn_diff(sent_lsn, replay_lsn) AS replay_lag_bytes
FROM pg_stat_replication;

-- Standby에서 확인
SELECT pg_is_in_recovery();  -- true면 Standby
SELECT pg_last_wal_receive_lsn(), pg_last_wal_replay_lsn();
```

### 복제 지연 해결

| 방법 | 설명 |
|------|------|
| max_wal_senders 증가 | WAL 전송 프로세스 수 |
| wal_keep_size 증가 | WAL 보존 크기 |
| Standby 성능 개선 | 디스크 I/O, 메모리 확인 |
| hot_standby_feedback | Standby에서 VACUUM 충돌 방지 |

---

## 트러블슈팅 필수 명령어 요약

```sql
-- 현재 활성 세션
SELECT pid, usename, state, query_start, LEFT(query, 80) FROM pg_stat_activity WHERE state = 'active';

-- 락 확인
SELECT pid, relation::regclass, mode, granted FROM pg_locks WHERE NOT granted;

-- 쿼리 취소 / 세션 종료
SELECT pg_cancel_backend(pid);
SELECT pg_terminate_backend(pid);

-- 데이터베이스 크기
SELECT datname, pg_size_pretty(pg_database_size(datname)) FROM pg_database;

-- 테이블 통계
SELECT relname, n_live_tup, n_dead_tup, last_autovacuum FROM pg_stat_user_tables;

-- 로그 파일 위치
SHOW log_directory;
SHOW data_directory;

-- 설정 리로드
SELECT pg_reload_conf();
```

{% assign c-category = 'postgresql' %}
{% assign c-tag = 'lecture-postgresql' %}
{% include /custom-ref.html %}
