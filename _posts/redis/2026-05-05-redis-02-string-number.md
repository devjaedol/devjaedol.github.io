---
title: "[Redis] 02. String과 숫자 (기본 자료구조)"
categories: 
    - redis
tags: 
    [redis, nosql, redis강좌, 초급, 'lecture-redis']
toc : true
toc_sticky  : true    
---

Redis의 가장 기본 자료구조인 String 타입과 숫자 연산을 정리합니다.

# String 타입

String은 Redis의 가장 단순하고 기본적인 자료구조입니다.    
텍스트, 숫자, 바이너리 데이터(이미지, 직렬화된 객체 등) 모두 저장 가능하며, 최대 512MB까지 저장할 수 있습니다.

## 기본 명령어

### SET / GET
```bash
# 값 설정
SET name "홍길동"

# 값 조회
GET name
# "홍길동"

# 키가 없을 때만 설정 (NX = Not eXists)
SET name "김철수" NX
# nil (이미 존재하므로 설정 안됨)

SETNX lock:order:123 "processing"
# 1 (성공) 또는 0 (이미 존재)

# 키가 있을 때만 설정 (XX = eXists)
SET name "김철수" XX
# OK (존재하므로 덮어씀)

# 만료 시간과 함께 설정
SET session:abc123 "user_data" EX 3600      # 3600초 후 만료
SET session:abc123 "user_data" PX 3600000   # 3600000밀리초 후 만료
SETEX session:abc123 3600 "user_data"       # EX와 동일 (구버전 호환)

# 여러 키 한번에 설정/조회
MSET name "홍길동" age "30" city "서울"
MGET name age city
# 1) "홍길동"
# 2) "30"
# 3) "서울"
```

### 문자열 조작
```bash
# 문자열 길이
STRLEN name
# 9 (UTF-8 바이트 수)

# 문자열 뒤에 추가
APPEND name " 님"
GET name
# "홍길동 님"

# 부분 문자열 조회
GETRANGE name 0 5
# "홍길"  (바이트 기준)

# 값 설정하면서 이전 값 반환
GETSET name "이영희"
# "홍길동 님" (이전 값 반환)

# GET + DELETE (Redis 6.2+)
GETDEL temp_key
```

---

## 숫자 연산

String에 저장된 값이 정수/실수일 때 원자적 증감 연산이 가능합니다.    
별도의 락 없이 동시성 안전한 카운터를 구현할 수 있습니다.

### 정수 연산
```bash
SET counter 100

# 1 증가
INCR counter
# 101

# 1 감소
DECR counter
# 100

# 지정 값만큼 증가
INCRBY counter 50
# 150

# 지정 값만큼 감소
DECRBY counter 30
# 120
```

### 실수 연산
```bash
SET price 19.99

# 실수 증가
INCRBYFLOAT price 0.01
# "20"

INCRBYFLOAT price -5.5
# "14.5"
```

---

## 키 관리 명령어

```bash
# 키 존재 여부
EXISTS name
# 1 (존재) 또는 0 (미존재)

# 키 삭제
DEL name age city
# 3 (삭제된 키 수)

# 비동기 삭제 (대용량 키)
UNLINK large_key

# 키 이름 변경
RENAME name new_name

# 키 타입 확인
TYPE name
# string

# 키 검색 (패턴 매칭, 운영 환경 주의)
KEYS user:*
KEYS *session*

# SCAN (운영 환경 권장, 커서 기반)
SCAN 0 MATCH user:* COUNT 100
```

---

## TTL (만료 시간) 관리

```bash
# 만료 시간 설정 (초)
EXPIRE name 60

# 만료 시간 설정 (밀리초)
PEXPIRE name 60000

# 특정 시점에 만료 (Unix timestamp)
EXPIREAT name 1748000000

# 남은 TTL 확인
TTL name
# 58 (초), -1 (만료 없음), -2 (키 없음)

PTTL name
# 58000 (밀리초)

# 만료 시간 제거 (영구 보존)
PERSIST name
```

---

## 실전 활용 패턴

### 캐시
```bash
# DB 쿼리 결과 캐싱 (5분 TTL)
SET cache:user:123 '{"id":123,"name":"홍길동","email":"hong@test.com"}' EX 300

# 캐시 조회
GET cache:user:123
```

### 세션 스토어
```bash
# 세션 저장 (30분 TTL)
SET session:abc123def456 '{"user_id":1,"role":"admin"}' EX 1800

# 세션 갱신 (접근 시 TTL 리셋)
EXPIRE session:abc123def456 1800
```

### 분산 락 (간단 버전)
```bash
# 락 획득 (NX + EX로 원자적 설정)
SET lock:order:789 "worker-1" NX EX 30
# OK (획득 성공) 또는 nil (이미 잠김)

# 락 해제
DEL lock:order:789
```

### Rate Limiting (API 호출 제한)
```bash
# 사용자별 1분당 100회 제한
INCR rate:user:123
EXPIRE rate:user:123 60

# 현재 횟수 확인
GET rate:user:123
```

### 조회수 카운터
```bash
# 게시글 조회수 증가 (원자적)
INCR views:post:456
# 1, 2, 3, ...

# 조회수 확인
GET views:post:456
```

{% assign c-category = 'redis' %}
{% assign c-tag = 'lecture-redis' %}
{% include /custom-ref.html %}
