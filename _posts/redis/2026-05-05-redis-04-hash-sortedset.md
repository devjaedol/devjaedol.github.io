---
title: "[Redis] 04. Hash와 Sorted Set"
categories: 
    - redis
tags: 
    [redis, nosql, redis강좌, 초급, 'lecture-redis']
toc : true
toc_sticky  : true    
---

Redis의 Hash(필드-값 쌍)와 Sorted Set(점수 기반 정렬 컬렉션) 자료구조를 정리합니다.

# Hash

Hash는 하나의 키 안에 여러 필드-값 쌍을 저장하는 자료구조입니다.    
객체(Object)를 표현하기에 적합하며, RDBMS의 한 행(row)과 유사합니다.

## 기본 명령어

### 설정/조회
```bash
# 단일 필드 설정
HSET user:1 name "홍길동"
HSET user:1 age 30
HSET user:1 email "hong@test.com"

# 여러 필드 한번에 설정
HSET user:2 name "김철수" age 25 email "kim@test.com" dept "개발팀"

# 단일 필드 조회
HGET user:1 name
# "홍길동"

# 여러 필드 조회
HMGET user:1 name age email
# 1) "홍길동"  2) "30"  3) "hong@test.com"

# 전체 필드-값 조회
HGETALL user:1
# 1) "name"  2) "홍길동"  3) "age"  4) "30"  5) "email"  6) "hong@test.com"

# 필드만 조회
HKEYS user:1
# 1) "name"  2) "age"  3) "email"

# 값만 조회
HVALS user:1

# 필드 수
HLEN user:1
# 3
```

#### 삭제/확인
```bash
# 필드 삭제
HDEL user:1 email

# 필드 존재 여부
HEXISTS user:1 name
# 1 (존재) 또는 0 (미존재)

# 필드가 없을 때만 설정
HSETNX user:1 name "이영희"
# 0 (이미 존재하므로 설정 안됨)
```

#### 숫자 연산
```bash
# 정수 증가
HINCRBY user:1 age 1
# 31

# 실수 증가
HINCRBYFLOAT product:1 price 0.5
```

---

### Hash 활용 패턴

#### 사용자 프로필
```bash
HSET user:123 name "홍길동" email "hong@test.com" age 30 role "admin" login_count 0

# 로그인 시 카운트 증가
HINCRBY user:123 login_count 1

# 특정 필드만 조회
HMGET user:123 name role
```

#### 상품 정보
```bash
HSET product:456 name "노트북" price 1500000 stock 50 category "전자제품"

# 재고 감소 (원자적)
HINCRBY product:456 stock -1
```

#### 설정값 저장
```bash
HSET config:app max_connections 100 timeout 30 debug "false" version "2.1.0"
HGET config:app timeout
```

---

## Sorted Set (ZSet)

Sorted Set은 각 멤버에 점수(score)가 부여되어 자동으로 정렬되는 컬렉션입니다.    
Set처럼 중복을 허용하지 않으면서, 점수 기반 범위 조회와 순위 조회가 가능합니다.

### 기본 명령어

#### 추가/수정
```bash
# 멤버 추가 (score member)
ZADD leaderboard 100 "player:1"
ZADD leaderboard 85 "player:2" 92 "player:3" 78 "player:4"

# 점수 증가
ZINCRBY leaderboard 5 "player:2"
# 90 (85 + 5)

# 조건부 추가
ZADD leaderboard NX 50 "player:5"   # 없을 때만 추가
ZADD leaderboard XX 110 "player:1"  # 있을 때만 수정
ZADD leaderboard GT 95 "player:3"   # 새 점수가 클 때만 수정 (Redis 6.2+)
```

#### 조회 (점수 오름차순)
```bash
# 순위별 조회 (오름차순, 0부터)
ZRANGE leaderboard 0 -1
ZRANGE leaderboard 0 2              # 상위 3명 (점수 낮은 순)

# 점수와 함께 조회
ZRANGE leaderboard 0 -1 WITHSCORES

# 점수 범위로 조회
ZRANGEBYSCORE leaderboard 80 100
ZRANGEBYSCORE leaderboard -inf +inf # 전체
ZRANGEBYSCORE leaderboard 80 100 LIMIT 0 5  # 페이징
```

#### 조회 (점수 내림차순)
```bash
# 내림차순 조회 (높은 점수부터)
ZREVRANGE leaderboard 0 2           # 상위 3명 (점수 높은 순)
ZREVRANGE leaderboard 0 -1 WITHSCORES

# 점수 범위 내림차순
ZREVRANGEBYSCORE leaderboard 100 80
```

#### 순위/점수 조회
```bash
# 순위 조회 (0부터, 오름차순)
ZRANK leaderboard "player:1"
# 3 (4번째)

# 역순위 (내림차순)
ZREVRANK leaderboard "player:1"
# 0 (1등)

# 점수 조회
ZSCORE leaderboard "player:1"
# "110"

# 멤버 수
ZCARD leaderboard

# 점수 범위 내 멤버 수
ZCOUNT leaderboard 80 100
```

#### 삭제
```bash
# 멤버 삭제
ZREM leaderboard "player:4"

# 순위 범위로 삭제
ZREMRANGEBYRANK leaderboard 0 1     # 하위 2명 삭제

# 점수 범위로 삭제
ZREMRANGEBYSCORE leaderboard -inf 50 # 50점 이하 삭제
```

#### 집합 연산
```bash
ZADD quiz:1 80 "user:a" 90 "user:b" 70 "user:c"
ZADD quiz:2 85 "user:a" 75 "user:b" 95 "user:c"

# 합집합 (점수 합산)
ZUNIONSTORE total 2 quiz:1 quiz:2
# user:a=165, user:b=165, user:c=165

# 교집합
ZINTERSTORE common 2 quiz:1 quiz:2

# 가중치 적용
ZUNIONSTORE weighted 2 quiz:1 quiz:2 WEIGHTS 0.7 0.3
```

---

### Sorted Set 활용 패턴

#### 실시간 랭킹 (리더보드)
```bash
# 점수 갱신
ZINCRBY game:leaderboard 10 "player:홍길동"

# 상위 10명 조회
ZREVRANGE game:leaderboard 0 9 WITHSCORES

# 내 순위 확인
ZREVRANK game:leaderboard "player:홍길동"
```

#### 시간 기반 정렬 (타임라인)
```bash
# Unix timestamp를 점수로 사용
ZADD timeline:user:1 1714900000 "post:100"
ZADD timeline:user:1 1714900060 "post:101"
ZADD timeline:user:1 1714900120 "post:102"

# 최신순 조회
ZREVRANGE timeline:user:1 0 9

# 특정 시간 범위 조회
ZRANGEBYSCORE timeline:user:1 1714900000 1714900100
```

#### 지연 작업 큐 (Delayed Queue)
```bash
# 실행 시간을 점수로 설정
ZADD delayed_queue 1714900060 '{"task":"send_email","to":"user@test.com"}'
ZADD delayed_queue 1714900120 '{"task":"cleanup","target":"temp_files"}'

# 현재 시간 이전의 작업 조회 (실행할 작업)
ZRANGEBYSCORE delayed_queue -inf 1714900060

# 처리 후 삭제
ZREM delayed_queue '{"task":"send_email","to":"user@test.com"}'
```

#### Rate Limiting (슬라이딩 윈도우)
```bash
# 현재 시간 기준 1분 이내 요청만 유지
ZADD rate:user:123 1714900050 "req:1"
ZADD rate:user:123 1714900051 "req:2"

# 1분 이전 요청 삭제
ZREMRANGEBYSCORE rate:user:123 -inf 1714899990

# 현재 요청 수 확인
ZCARD rate:user:123
```

{% assign c-category = 'redis' %}
{% assign c-tag = 'lecture-redis' %}
{% include /custom-ref.html %}
