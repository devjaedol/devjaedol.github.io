---
title: "[Redis] 10. 실전 설계 패턴"
categories: 
    - redis
tags: 
    [redis, nosql, redis강좌, 고급, 'lecture-redis']
toc : true
toc_sticky  : true    
---

Redis를 활용한 실전 설계 패턴과 애플리케이션 연동 방법을 정리합니다.

# 캐시 패턴

## Cache-Aside (Lazy Loading)

가장 일반적인 캐시 패턴입니다. 캐시에 없으면 DB에서 조회 후 캐시에 저장합니다.

```text
1. 캐시 조회 → HIT → 반환
2. 캐시 조회 → MISS → DB 조회 → 캐시 저장 → 반환
```

```python
def get_user(user_id):
    # 1. 캐시 조회
    cached = redis.get(f"user:{user_id}")
    if cached:
        return json.loads(cached)

    # 2. DB 조회
    user = db.query("SELECT * FROM users WHERE id = %s", user_id)

    # 3. 캐시 저장 (5분 TTL)
    redis.setex(f"user:{user_id}", 300, json.dumps(user))
    return user
```

## Write-Through

데이터 쓰기 시 캐시와 DB를 동시에 업데이트합니다.

```python
def update_user(user_id, data):
    # DB 업데이트
    db.execute("UPDATE users SET name=%s WHERE id=%s", data['name'], user_id)

    # 캐시도 업데이트
    redis.setex(f"user:{user_id}", 300, json.dumps(data))
```

## Write-Behind (Write-Back)

캐시에 먼저 쓰고, 비동기로 DB에 반영합니다. 쓰기 성능이 중요할 때 사용합니다.

```python
def update_user(user_id, data):
    # 캐시에 즉시 반영
    redis.setex(f"user:{user_id}", 300, json.dumps(data))

    # 비동기 큐에 DB 업데이트 작업 추가
    redis.rpush("db_write_queue", json.dumps({"user_id": user_id, "data": data}))
```

## 캐시 무효화 전략

| 전략 | 설명 | 적합한 경우 |
|------|------|-----------|
| TTL 기반 | 일정 시간 후 자동 만료 | 약간의 지연 허용 |
| 이벤트 기반 | 데이터 변경 시 즉시 삭제 | 실시간 일관성 필요 |
| 버전 기반 | 키에 버전 포함 (`user:1:v3`) | 롤백 필요 시 |

```bash
# 이벤트 기반 무효화
DEL cache:user:123              # 단일 키 삭제

# 패턴 기반 무효화 (SCAN 사용)
# KEYS cache:user:* 는 운영 환경에서 사용 금지
```

---

## 분산 락 (Distributed Lock)

### 단일 인스턴스 락
```bash
# 락 획득 (NX + EX로 원자적)
SET lock:resource:123 "owner-uuid" NX EX 30
# OK → 획득 성공, nil → 이미 잠김

# 락 해제 (Lua로 안전하게)
EVAL "
if redis.call('GET', KEYS[1]) == ARGV[1] then
    return redis.call('DEL', KEYS[1])
else
    return 0
end
" 1 lock:resource:123 "owner-uuid"
```

### Redlock (다중 인스턴스 락)

5개의 독립 Redis 인스턴스에서 과반수(3개 이상) 락을 획득해야 성공으로 판단합니다.

```text
1. 현재 시간 기록
2. 5개 인스턴스에 순차적으로 락 시도 (짧은 타임아웃)
3. 과반수(3개+) 성공 AND 경과 시간 < TTL → 락 획득 성공
4. 실패 시 모든 인스턴스에서 락 해제
```

---

## 세션 관리

```bash
# 세션 저장 (Hash 활용)
HSET session:abc123 user_id 1 role "admin" login_at "2026-05-05T10:00:00"
EXPIRE session:abc123 1800    # 30분 TTL

# 세션 조회
HGETALL session:abc123

# 세션 갱신 (접근 시 TTL 리셋)
EXPIRE session:abc123 1800

# 세션 삭제 (로그아웃)
DEL session:abc123
```

---

## 실시간 랭킹 시스템

```bash
# 점수 갱신
ZINCRBY ranking:daily 10 "user:홍길동"
ZINCRBY ranking:daily 5 "user:김철수"

# 상위 10명
ZREVRANGE ranking:daily 0 9 WITHSCORES

# 내 순위
ZREVRANK ranking:daily "user:홍길동"

# 내 점수
ZSCORE ranking:daily "user:홍길동"

# 일별 랭킹 초기화 (자정에)
DEL ranking:daily

# 주간 랭킹 합산
ZUNIONSTORE ranking:weekly 7 ranking:mon ranking:tue ranking:wed ranking:thu ranking:fri ranking:sat ranking:sun
```

---

## 실시간 알림 / 이벤트

### Pub/Sub 기반 알림
```bash
# 알림 발행
PUBLISH notifications:user:123 '{"type":"order","message":"주문이 완료되었습니다"}'

# 구독 (클라이언트)
SUBSCRIBE notifications:user:123
```

### Stream 기반 이벤트 (영속성 필요 시)
```bash
# 이벤트 발행
XADD events:orders * user_id 123 action "created" order_id 456

# Consumer Group으로 처리
XGROUP CREATE events:orders order_processors $ MKSTREAM
XREADGROUP GROUP order_processors worker1 COUNT 10 BLOCK 5000 STREAMS events:orders >
XACK events:orders order_processors "1714900000000-0"
```

---

## 키 네이밍 컨벤션

| 패턴 | 예시 | 설명 |
|------|------|------|
| `object:id` | `user:123` | 기본 객체 |
| `object:id:field` | `user:123:name` | 객체의 필드 (String) |
| `action:object:id` | `cache:user:123` | 용도 접두사 |
| `scope:object:id` | `session:abc123` | 범위 접두사 |
| `object:id:relation` | `user:123:followers` | 관계 |
| `time:object:id` | `rate:user:123` | 시간 기반 |

### 권장 규칙
- 구분자는 `:` 사용 (일관성)
- 짧지만 의미 있는 이름
- 환경 접두사 사용 (`prod:`, `dev:`)
- 날짜 포함 시 ISO 형식 (`2026-05-05`)

{% assign c-category = 'redis' %}
{% assign c-tag = 'lecture-redis' %}
{% include /custom-ref.html %}
