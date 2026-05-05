---
title: "[Redis] 03. List와 Set"
categories: 
    - redis
tags: 
    [redis, nosql, redis강좌, 초급, 'lecture-redis']
toc : true
toc_sticky  : true    
---

Redis의 List(순서 있는 컬렉션)와 Set(중복 없는 컬렉션) 자료구조를 정리합니다.

# List

List는 순서가 있는 문자열 컬렉션입니다. 양쪽 끝에서 삽입/삭제가 O(1)로 빠릅니다.    
큐(Queue), 스택(Stack), 최근 항목 목록 등에 활용됩니다.

## 기본 명령어

### 삽입
```bash
# 왼쪽(앞)에 삽입
LPUSH queue "task1"
LPUSH queue "task2" "task3"
# queue: [task3, task2, task1]

# 오른쪽(뒤)에 삽입
RPUSH queue "task4"
# queue: [task3, task2, task1, task4]

# 리스트가 존재할 때만 삽입
LPUSHX queue "task5"    # 존재하면 삽입
LPUSHX nolist "task5"   # 존재하지 않으면 무시
```

#### 조회
```bash
# 범위 조회 (0부터 시작, -1은 마지막)
LRANGE queue 0 -1       # 전체
LRANGE queue 0 2        # 처음 3개

# 인덱스로 조회
LINDEX queue 0          # 첫 번째
LINDEX queue -1         # 마지막

# 길이
LLEN queue
```

#### 삭제/추출
```bash
# 왼쪽에서 꺼내기 (큐: FIFO)
LPOP queue
# "task3"

# 오른쪽에서 꺼내기 (스택: LIFO)
RPOP queue
# "task4"

# 여러 개 꺼내기 (Redis 6.2+)
LPOP queue 2

# 특정 값 삭제 (count: 0=전체, 양수=앞에서, 음수=뒤에서)
LREM queue 0 "task2"    # "task2" 모두 삭제
LREM queue 1 "task2"    # 앞에서 1개만 삭제

# 범위만 남기고 삭제 (트리밍)
LTRIM queue 0 99        # 최근 100개만 유지
```

#### 블로킹 명령어 (메시지 큐)
```bash
# 블로킹 왼쪽 POP (타임아웃 초)
BLPOP queue 30
# 데이터가 올 때까지 최대 30초 대기

# 블로킹 오른쪽 POP
BRPOP queue 30

# 한 리스트에서 빼서 다른 리스트에 넣기
LMOVE source destination LEFT RIGHT
BLMOVE source destination LEFT RIGHT 30
```

---

### List 활용 패턴

#### 메시지 큐 (Producer-Consumer)
```bash
# Producer: 작업 추가
RPUSH job_queue '{"type":"email","to":"user@test.com"}'
RPUSH job_queue '{"type":"sms","to":"010-1234-5678"}'

# Consumer: 작업 처리 (블로킹)
BLPOP job_queue 0
# 무한 대기하다가 작업이 오면 처리
```

#### 최근 활동 로그 (최대 100개 유지)
```bash
LPUSH recent:user:123 '{"action":"login","time":"2026-05-05T10:00:00"}'
LTRIM recent:user:123 0 99
LRANGE recent:user:123 0 9    # 최근 10개 조회
```

#### 타임라인 (SNS 피드)
```bash
# 새 게시글을 팔로워들의 타임라인에 추가
LPUSH timeline:user:456 "post:789"
LTRIM timeline:user:456 0 199    # 최근 200개 유지
```

---

## Set

Set은 순서가 없고 중복을 허용하지 않는 문자열 컬렉션입니다.    
멤버 존재 여부 확인이 O(1)로 빠르며, 집합 연산(교집합, 합집합, 차집합)을 지원합니다.

### 기본 명령어

#### 추가/삭제
```bash
# 멤버 추가
SADD tags:post:1 "redis" "nosql" "database"
SADD tags:post:1 "redis"    # 이미 존재하면 무시 (0 반환)

# 멤버 삭제
SREM tags:post:1 "nosql"

# 랜덤 멤버 꺼내기 (삭제됨)
SPOP tags:post:1

# 랜덤 멤버 조회 (삭제 안됨)
SRANDMEMBER tags:post:1 2    # 2개 랜덤 조회
```

#### 조회
```bash
# 전체 멤버 조회
SMEMBERS tags:post:1

# 멤버 존재 여부
SISMEMBER tags:post:1 "redis"
# 1 (존재) 또는 0 (미존재)

# 여러 멤버 존재 여부 (Redis 6.2+)
SMISMEMBER tags:post:1 "redis" "java" "nosql"
# 1) 1  2) 0  3) 1

# 멤버 수
SCARD tags:post:1
```

#### 집합 연산
```bash
SADD set:a "1" "2" "3" "4"
SADD set:b "3" "4" "5" "6"

# 교집합
SINTER set:a set:b
# "3", "4"

# 합집합
SUNION set:a set:b
# "1", "2", "3", "4", "5", "6"

# 차집합 (A - B)
SDIFF set:a set:b
# "1", "2"

# 결과를 새 키에 저장
SINTERSTORE result set:a set:b
SUNIONSTORE result set:a set:b
SDIFFSTORE result set:a set:b
```

---

### Set 활용 패턴

#### 태그 시스템
```bash
# 게시글에 태그 추가
SADD tags:post:1 "redis" "nosql" "tutorial"
SADD tags:post:2 "redis" "cache" "performance"

# 특정 태그의 게시글 목록
SADD tag:redis "post:1" "post:2"
SADD tag:nosql "post:1"

# "redis" AND "nosql" 태그를 모두 가진 게시글
SINTER tag:redis tag:nosql
# "post:1"
```

#### 좋아요 / 팔로우
```bash
# 게시글 좋아요
SADD likes:post:123 "user:1" "user:2" "user:3"

# 좋아요 취소
SREM likes:post:123 "user:2"

# 좋아요 수
SCARD likes:post:123

# 내가 좋아요 했는지 확인
SISMEMBER likes:post:123 "user:1"
```

#### 온라인 사용자 추적
```bash
# 로그인 시
SADD online_users "user:123"

# 로그아웃 시
SREM online_users "user:123"

# 현재 온라인 수
SCARD online_users

# 특정 사용자 온라인 여부
SISMEMBER online_users "user:123"
```

#### 중복 방지 (방문자, IP 등)
```bash
# 오늘 방문한 IP 기록
SADD visitors:2026-05-05 "192.168.1.1" "192.168.1.2" "192.168.1.1"

# 고유 방문자 수
SCARD visitors:2026-05-05
# 2 (중복 자동 제거)
```

{% assign c-category = 'redis' %}
{% assign c-tag = 'lecture-redis' %}
{% include /custom-ref.html %}
