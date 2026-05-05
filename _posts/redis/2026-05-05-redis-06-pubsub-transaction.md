---
title: "[Redis] 06. Pub/Sub, 트랜잭션, Lua 스크립팅"
categories: 
    - redis
tags: 
    [redis, nosql, redis강좌, 중급, 'lecture-redis']
toc : true
toc_sticky  : true    
---

Redis의 Pub/Sub 메시징, 트랜잭션(MULTI/EXEC), Lua 스크립팅을 정리합니다.

# Pub/Sub (발행/구독)

Pub/Sub은 메시지를 채널에 발행하면, 해당 채널을 구독 중인 모든 클라이언트가 메시지를 수신하는 패턴입니다.

## 기본 사용법
```bash
# 구독자 (터미널 1)
SUBSCRIBE chat:room:1
# 메시지 대기 상태...

# 발행자 (터미널 2)
PUBLISH chat:room:1 "안녕하세요!"
# (integer) 1  (수신한 구독자 수)

# 구독자에게 표시:
# 1) "message"
# 2) "chat:room:1"
# 3) "안녕하세요!"
```

### 패턴 구독
```bash
# 패턴으로 여러 채널 구독
PSUBSCRIBE chat:*
# chat:room:1, chat:room:2, chat:lobby 등 모두 수신

PSUBSCRIBE news.*
# news.sports, news.tech 등 수신

# 구독 해제
UNSUBSCRIBE chat:room:1
PUNSUBSCRIBE chat:*
```

### Pub/Sub 특징과 한계

| 특징 | 설명 |
|------|------|
| 실시간 | 메시지 즉시 전달 |
| 1:N | 하나의 메시지를 여러 구독자에게 |
| Fire & Forget | 메시지 영속성 없음 |
| 구독자 없으면 유실 | 구독자가 없으면 메시지 사라짐 |
| 히스토리 없음 | 과거 메시지 조회 불가 |

> 메시지 영속성이 필요하면 Stream을 사용하세요.

---

## 트랜잭션 (MULTI / EXEC)

Redis 트랜잭션은 여러 명령을 원자적으로 실행합니다.    
RDBMS의 트랜잭션과 달리 롤백이 없으며, 큐에 쌓인 명령을 한번에 실행합니다.

### 기본 사용법
```bash
MULTI                           # 트랜잭션 시작
SET balance:user:1 1000         # QUEUED
DECRBY balance:user:1 200       # QUEUED
INCRBY balance:user:2 200       # QUEUED
EXEC                            # 일괄 실행
# 1) OK  2) 800  3) 200
```

### 트랜잭션 취소
```bash
MULTI
SET key1 "value1"               # QUEUED
SET key2 "value2"               # QUEUED
DISCARD                         # 트랜잭션 취소 (큐 비움)
```

### WATCH (낙관적 락)

WATCH는 특정 키를 감시하여, EXEC 전에 해당 키가 변경되면 트랜잭션을 실패시킵니다.    
CAS(Check-And-Set) 패턴을 구현할 수 있습니다.

```bash
WATCH balance:user:1            # 키 감시 시작
GET balance:user:1              # "1000"

MULTI
DECRBY balance:user:1 200       # QUEUED
EXEC
# 다른 클라이언트가 balance:user:1을 변경했으면:
# (nil)  → 트랜잭션 실패, 재시도 필요

# 감시 해제
UNWATCH
```

### RDBMS 트랜잭션과의 차이

| 항목 | RDBMS | Redis |
|------|-------|-------|
| 롤백 | ROLLBACK 지원 | 롤백 없음 (DISCARD는 실행 전 취소) |
| 격리 | 격리 수준 설정 | 명령 큐잉 후 일괄 실행 (원자적) |
| 오류 처리 | 오류 시 롤백 | 개별 명령 오류는 나머지에 영향 없음 |
| 락 | 비관적/낙관적 락 | WATCH (낙관적 락만) |

---

## Lua 스크립팅

Lua 스크립트를 사용하면 여러 명령을 서버 측에서 원자적으로 실행할 수 있습니다.    
네트워크 왕복을 줄이고, 복잡한 원자적 연산을 구현할 수 있습니다.

### EVAL 기본 사용법
```bash
# 기본 구조: EVAL "스크립트" 키수 키... 인자...
EVAL "return 'Hello Redis'" 0
# "Hello Redis"

# 키와 인자 사용
EVAL "return redis.call('GET', KEYS[1])" 1 name
# "홍길동"

# 조건부 설정
EVAL "
local current = redis.call('GET', KEYS[1])
if current == false then
    redis.call('SET', KEYS[1], ARGV[1])
    return 1
else
    return 0
end
" 1 mykey "myvalue"
```

### 실전 Lua 스크립트 예시

#### Rate Limiting (원자적)
```bash
EVAL "
local key = KEYS[1]
local limit = tonumber(ARGV[1])
local window = tonumber(ARGV[2])

local current = tonumber(redis.call('GET', key) or '0')
if current >= limit then
    return 0  -- 제한 초과
else
    redis.call('INCR', key)
    if current == 0 then
        redis.call('EXPIRE', key, window)
    end
    return 1  -- 허용
end
" 1 rate:user:123 100 60
# 1분에 100회 제한
```

#### 분산 락 해제 (안전한 버전)
```bash
# 자신이 설정한 락만 해제 (값 비교 후 삭제)
EVAL "
if redis.call('GET', KEYS[1]) == ARGV[1] then
    return redis.call('DEL', KEYS[1])
else
    return 0
end
" 1 lock:resource "unique-token-abc123"
```

### EVALSHA (스크립트 캐싱)
```bash
# 스크립트 로드 (SHA1 해시 반환)
SCRIPT LOAD "return redis.call('GET', KEYS[1])"
# "a42059b356c875f0717db19a51f6aaa9161571a2"

# SHA1로 실행 (네트워크 절약)
EVALSHA "a42059b356c875f0717db19a51f6aaa9161571a2" 1 name

# 스크립트 존재 확인
SCRIPT EXISTS "a42059b356c875f0717db19a51f6aaa9161571a2"

# 스크립트 캐시 초기화
SCRIPT FLUSH
```

---

### Pipeline (파이프라인)

파이프라인은 여러 명령을 한번에 보내고 응답을 모아서 받는 기법입니다.    
네트워크 왕복(RTT)을 줄여 대량 명령 실행 시 성능을 크게 향상시킵니다.

```bash
# redis-cli에서 파이프라인
echo -e "SET key1 val1\nSET key2 val2\nSET key3 val3\nGET key1\nGET key2\nGET key3" | redis-cli --pipe
```

```python
# Python 예시 (redis-py)
import redis
r = redis.Redis()

pipe = r.pipeline()
for i in range(1000):
    pipe.set(f'key:{i}', f'value:{i}')
pipe.execute()  # 1000개 명령을 한번에 전송
```

| 방식 | 1000개 명령 실행 시간 |
|------|---------------------|
| 개별 실행 | ~1000ms (RTT × 1000) |
| Pipeline | ~10ms (RTT × 1) |

{% assign c-category = 'redis' %}
{% assign c-tag = 'lecture-redis' %}
{% include /custom-ref.html %}
