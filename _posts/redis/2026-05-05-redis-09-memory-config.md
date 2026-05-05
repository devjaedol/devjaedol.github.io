---
title: "[Redis] 09. 메모리 관리와 설정"
categories: 
    - redis
tags: 
    [redis, nosql, redis강좌, 고급, 'lecture-redis']
toc : true
toc_sticky  : true    
---

Redis의 메모리 관리, Eviction 정책, 주요 설정을 정리합니다.

# 메모리 관리

Redis는 모든 데이터를 RAM에 저장하므로 메모리 관리가 핵심입니다.

## 메모리 사용량 확인
```bash
INFO memory

# 주요 항목
# used_memory: Redis가 할당한 메모리 (바이트)
# used_memory_human: 사람이 읽기 쉬운 형태
# used_memory_rss: OS가 보고하는 실제 메모리 (단편화 포함)
# used_memory_peak: 최대 사용 메모리
# mem_fragmentation_ratio: 단편화 비율 (rss/used, 1.0~1.5 정상)
# maxmemory: 최대 메모리 제한

# 키별 메모리 사용량
MEMORY USAGE mykey

# 메모리 통계
MEMORY STATS

# 메모리 의사 (최적화 제안)
MEMORY DOCTOR
```

## 최대 메모리 설정
```ini
# redis.conf
maxmemory 4gb

# 동적 변경
CONFIG SET maxmemory 4gb
```

---

## Eviction 정책 (메모리 초과 시 키 제거)

`maxmemory`에 도달하면 Eviction 정책에 따라 키를 자동 삭제합니다.

| 정책 | 설명 |
|------|------|
| noeviction | 삭제 안함, 쓰기 명령 오류 반환 (기본값) |
| allkeys-lru | 모든 키 중 가장 오래 사용 안된 키 삭제 |
| allkeys-lfu | 모든 키 중 가장 적게 사용된 키 삭제 (Redis 4.0+) |
| allkeys-random | 모든 키 중 랜덤 삭제 |
| volatile-lru | TTL 설정된 키 중 LRU 삭제 |
| volatile-lfu | TTL 설정된 키 중 LFU 삭제 |
| volatile-random | TTL 설정된 키 중 랜덤 삭제 |
| volatile-ttl | TTL이 가장 짧은 키 삭제 |

```ini
# redis.conf
maxmemory-policy allkeys-lru

# 동적 변경
CONFIG SET maxmemory-policy allkeys-lfu
```

### 용도별 권장 정책

| 용도 | 권장 정책 |
|------|----------|
| 캐시 (모든 키 동등) | allkeys-lru 또는 allkeys-lfu |
| 캐시 (TTL 있는 키만 제거) | volatile-lru |
| 세션 스토어 | volatile-ttl |
| 데이터 유실 불가 | noeviction (메모리 모니터링 필수) |

---

## 메모리 최적화 기법

### 1. 적절한 자료구조 선택
```bash
# ❌ 개별 String 키 (오버헤드 큼)
SET user:1:name "홍길동"
SET user:1:age "30"
SET user:1:email "hong@test.com"

# ✅ Hash 사용 (메모리 효율적)
HSET user:1 name "홍길동" age 30 email "hong@test.com"
```

### 2. 키 이름 축약
```bash
# ❌ 긴 키 이름
SET user:session:authentication:token:abc123 "data"

# ✅ 축약된 키 이름
SET s:auth:abc123 "data"
```

### 3. TTL 적극 활용
```bash
# 캐시 데이터에 반드시 TTL 설정
SET cache:query:123 "result" EX 300
```

### 4. 대용량 키 분할
```bash
# ❌ 하나의 거대한 Set (100만 멤버)
SADD huge_set member1 member2 ... member1000000

# ✅ 여러 키로 분할
SADD set:bucket:0 member1 member2 ...
SADD set:bucket:1 member1001 member1002 ...
```

### 5. 인코딩 최적화 (자동)

Redis는 작은 데이터에 대해 메모리 효율적인 인코딩을 자동 적용합니다.

| 자료구조 | 작은 데이터 인코딩 | 큰 데이터 인코딩 |
|---------|-----------------|----------------|
| String | int, embstr | raw |
| List | listpack | quicklist |
| Hash | listpack | hashtable |
| Set | listpack / intset | hashtable |
| Sorted Set | listpack | skiplist |

```bash
# 인코딩 확인
OBJECT ENCODING mykey

# 임계값 설정 (redis.conf)
# hash-max-listpack-entries 128
# hash-max-listpack-value 64
# list-max-listpack-size -2
# set-max-intset-entries 512
# zset-max-listpack-entries 128
```

---

## 주요 설정 (redis.conf)

### 네트워크
```ini
bind 0.0.0.0                    # 바인드 주소 (0.0.0.0 = 모든 인터페이스)
port 6379                       # 포트
protected-mode yes              # 보호 모드 (비밀번호 없으면 외부 접속 차단)
tcp-backlog 511                 # TCP 백로그
timeout 0                       # 클라이언트 유휴 타임아웃 (0=무제한)
tcp-keepalive 300               # TCP keepalive (초)
```

### 보안
```ini
requirepass "StrongPassword123!" # 비밀번호 설정
rename-command FLUSHALL ""       # 위험 명령어 비활성화
rename-command FLUSHDB ""
rename-command CONFIG ""
# Redis 6.0+ ACL 사용 권장
```

### 클라이언트
```ini
maxclients 10000                # 최대 동시 접속 수
```

### 로깅
```ini
loglevel notice                 # 로그 레벨 (debug, verbose, notice, warning)
logfile "/var/log/redis/redis.log"
```

### 슬로우 로그
```ini
slowlog-log-slower-than 10000   # 10ms 이상 걸리는 명령 기록 (마이크로초)
slowlog-max-len 128             # 최대 기록 수
```

```bash
# 슬로우 로그 조회
SLOWLOG GET 10          # 최근 10개
SLOWLOG LEN             # 기록된 수
SLOWLOG RESET           # 초기화
```

---

## ACL (Access Control List, Redis 6.0+)

```bash
# 사용자 생성
ACL SETUSER devuser on >DevPass123! ~app:* +@all -@dangerous

# 읽기 전용 사용자
ACL SETUSER readonly on >ReadPass! ~* +@read -@write -@admin

# 사용자 목록
ACL LIST
ACL WHOAMI

# 카테고리 확인
ACL CAT
ACL CAT dangerous
```

### ACL 규칙 설명

| 규칙 | 설명 |
|------|------|
| `on` / `off` | 사용자 활성화/비활성화 |
| `>password` | 비밀번호 설정 |
| `~pattern` | 접근 가능한 키 패턴 |
| `+command` | 허용 명령어 |
| `-command` | 차단 명령어 |
| `+@category` | 카테고리 전체 허용 |
| `-@category` | 카테고리 전체 차단 |

{% assign c-category = 'redis' %}
{% assign c-tag = 'lecture-redis' %}
{% include /custom-ref.html %}
