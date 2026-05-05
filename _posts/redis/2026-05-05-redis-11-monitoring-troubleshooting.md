---
title: "[Redis] 11. 모니터링과 Troubleshooting"
categories: 
    - redis
tags: 
    [redis, nosql, redis강좌, 고급, 'lecture-redis']
toc : true
toc_sticky  : true    
---

Redis의 모니터링 방법과 자주 발생하는 문제의 해결 방법을 정리합니다.

# 모니터링

## INFO 명령어
```bash
INFO                    # 전체 정보
INFO server             # 서버 정보
INFO clients            # 클라이언트 정보
INFO memory             # 메모리 정보
INFO stats              # 통계
INFO replication        # 복제 상태
INFO keyspace           # DB별 키 수
INFO commandstats       # 명령어별 통계
```

## 핵심 모니터링 지표

| 지표 | 확인 명령 | 정상 범위 |
|------|----------|----------|
| 메모리 사용량 | `INFO memory` → used_memory | maxmemory의 80% 이하 |
| 메모리 단편화 | mem_fragmentation_ratio | 1.0 ~ 1.5 |
| 연결된 클라이언트 | `INFO clients` → connected_clients | maxclients 이하 |
| 초당 명령 수 | `INFO stats` → instantaneous_ops_per_sec | 환경에 따라 |
| 캐시 히트율 | keyspace_hits / (hits + misses) | 90% 이상 |
| Eviction 수 | evicted_keys | 0에 가까울수록 좋음 |
| 블로킹 클라이언트 | blocked_clients | 0에 가까울수록 좋음 |
| 복제 지연 | master_repl_offset 차이 | 0에 가까울수록 좋음 |

## 실시간 모니터링
```bash
# 실시간 명령 모니터링 (디버깅용, 운영 주의)
MONITOR

# 실시간 지연 시간 측정
redis-cli --latency
redis-cli --latency-history

# 실시간 통계 (1초 간격)
redis-cli --stat

# 대용량 키 스캔
redis-cli --bigkeys

# 메모리 분석
redis-cli --memkeys
```

## 슬로우 로그
```bash
# 슬로우 로그 조회
SLOWLOG GET 10

# 출력 예시:
# 1) (integer) 14           ← 로그 ID
# 2) (integer) 1714900000   ← Unix timestamp
# 3) (integer) 15000        ← 실행 시간 (마이크로초)
# 4) 1) "KEYS"             ← 명령어
#    2) "*"

# 슬로우 로그 설정
CONFIG SET slowlog-log-slower-than 10000    # 10ms 이상
CONFIG SET slowlog-max-len 256
```

---

## 자주 발생하는 문제

### 1. OOM (Out of Memory)

```text
OOM command not allowed when used memory > 'maxmemory'
```

| 원인 | 해결 |
|------|------|
| maxmemory 초과 | maxmemory 증가 또는 Eviction 정책 설정 |
| TTL 미설정 | 캐시 키에 TTL 추가 |
| 대용량 키 | 키 분할 또는 불필요한 데이터 삭제 |
| 메모리 누수 | `--bigkeys`로 대용량 키 확인 |

```bash
# 대용량 키 찾기
redis-cli --bigkeys

# 메모리 사용량 상위 키
MEMORY USAGE large_key

# Eviction 정책 설정
CONFIG SET maxmemory-policy allkeys-lru
```

### 2. 높은 지연 시간 (Latency)

| 원인 | 해결 |
|------|------|
| 느린 명령어 (KEYS, SMEMBERS 등) | SCAN 사용, 대용량 컬렉션 분할 |
| RDB/AOF fork | 메모리 여유 확보, 빈도 조정 |
| 네트워크 문제 | 로컬 접속 확인, 네트워크 진단 |
| 스왑 사용 | 스왑 비활성화, 메모리 확보 |
| 대용량 키 삭제 | UNLINK (비동기 삭제) 사용 |

```bash
# 지연 원인 분석
redis-cli --latency
redis-cli --intrinsic-latency 10    # 시스템 기본 지연 측정

# 느린 명령어 확인
SLOWLOG GET 20

# 스왑 사용 확인 (Linux)
# cat /proc/$(pidof redis-server)/smaps | grep Swap
```

### 3. 연결 거부 (maxclients 초과)

```text
ERR max number of clients reached
```

```bash
# 현재 연결 수 확인
INFO clients
# connected_clients: 10001

# 최대 연결 수 확인/변경
CONFIG GET maxclients
CONFIG SET maxclients 20000

# 유휴 연결 타임아웃 설정
CONFIG SET timeout 300    # 5분 유휴 시 자동 종료

# 연결된 클라이언트 목록
CLIENT LIST
CLIENT KILL ID 12345      # 특정 클라이언트 종료
```

### 4. KEYS 명령어로 인한 블로킹

`KEYS *` 명령은 모든 키를 스캔하므로 운영 환경에서 서버를 블로킹합니다.

```bash
# ❌ 운영 환경 금지
KEYS user:*

# ✅ SCAN 사용 (커서 기반, 비블로킹)
SCAN 0 MATCH user:* COUNT 100
# 반환된 커서가 0이 될 때까지 반복
```

### 5. 메모리 단편화

```bash
INFO memory
# mem_fragmentation_ratio: 2.5  ← 비정상 (1.5 이상)
```

| 원인 | 해결 |
|------|------|
| 잦은 키 생성/삭제 | `activedefrag yes` 활성화 (Redis 4.0+) |
| 다양한 크기의 값 | 값 크기 통일 시도 |
| 오래 실행된 인스턴스 | 재시작 (RDB 로드) |

```ini
# redis.conf - 자동 단편화 해소
activedefrag yes
active-defrag-ignore-bytes 100mb
active-defrag-threshold-lower 10
active-defrag-threshold-upper 100
```

### 6. 복제 지연 / 연결 끊김

```bash
# Master에서 확인
INFO replication
# slave0:...,lag=5  ← 5초 지연

# 원인 확인
# - Replica 네트워크 대역폭 부족
# - Replica 디스크 I/O 느림
# - 대량 쓰기로 인한 버퍼 초과
```

```ini
# redis.conf - 복제 버퍼 크기 증가
repl-backlog-size 256mb
client-output-buffer-limit replica 512mb 256mb 60
```

### 7. Thundering Herd (캐시 스탬피드)

인기 캐시 키가 만료되는 순간 수많은 요청이 동시에 DB를 조회하는 문제입니다.

| 해결 방법 | 설명 |
|----------|------|
| 락 기반 갱신 | 한 요청만 DB 조회, 나머지는 대기 |
| TTL 분산 | 만료 시간에 랜덤 값 추가 |
| 사전 갱신 | TTL 만료 전에 백그라운드에서 갱신 |

```python
# 락 기반 캐시 갱신
def get_with_lock(key):
    value = redis.get(key)
    if value:
        return value

    lock_key = f"lock:{key}"
    if redis.set(lock_key, "1", nx=True, ex=5):
        # 락 획득 성공 → DB 조회 후 캐시 저장
        value = db.query(...)
        redis.setex(key, 300, value)
        redis.delete(lock_key)
        return value
    else:
        # 락 획득 실패 → 잠시 대기 후 재시도
        time.sleep(0.1)
        return get_with_lock(key)
```

---

## 운영 체크리스트

| 항목 | 확인 방법 | 권장 |
|------|----------|------|
| maxmemory 설정 | `CONFIG GET maxmemory` | 물리 메모리의 70~80% |
| Eviction 정책 | `CONFIG GET maxmemory-policy` | 용도에 맞게 설정 |
| 영속성 설정 | `CONFIG GET save`, `CONFIG GET appendonly` | 용도에 맞게 |
| 슬로우 로그 | `SLOWLOG GET` | 정기 확인 |
| 대용량 키 | `redis-cli --bigkeys` | 정기 스캔 |
| 메모리 단편화 | `INFO memory` | ratio < 1.5 |
| 연결 수 | `INFO clients` | maxclients 대비 여유 |
| 복제 상태 | `INFO replication` | lag = 0 |
| KEYS 명령 사용 금지 | `rename-command KEYS ""` | 운영 환경 필수 |
| 비밀번호 설정 | `requirepass` 또는 ACL | 필수 |

{% assign c-category = 'redis' %}
{% assign c-tag = 'lecture-redis' %}
{% include /custom-ref.html %}
