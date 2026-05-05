---
title: "[Redis] 05. 고급 자료구조 (Stream, HyperLogLog, Bitmap, Geo)"
categories: 
    - redis
tags: 
    [redis, nosql, redis강좌, 중급, 'lecture-redis']
toc : true
toc_sticky  : true    
---

Redis의 고급 자료구조인 Stream, HyperLogLog, Bitmap, Geospatial을 정리합니다.

# Stream

Stream은 Redis 5.0에서 도입된 로그형 자료구조입니다.    
Kafka와 유사한 메시지 스트리밍을 지원하며, Consumer Group으로 분산 처리가 가능합니다.

## 기본 명령어
```bash
# 메시지 추가 (* = 자동 ID 생성)
XADD mystream * name "홍길동" action "login"
# "1714900000000-0" (타임스탬프-시퀀스)

XADD mystream * name "김철수" action "purchase" amount 50000

# 길이 확인
XLEN mystream

# 범위 조회
XRANGE mystream - +              # 전체 (오래된 순)
XRANGE mystream - + COUNT 10     # 최근 10개
XREVRANGE mystream + -           # 전체 (최신 순)

# 특정 ID 이후 조회
XREAD COUNT 5 BLOCK 5000 STREAMS mystream 0
# BLOCK: 새 메시지 대기 (밀리초, 0=무한)
```

## Consumer Group
```bash
# 그룹 생성
XGROUP CREATE mystream mygroup $ MKSTREAM
# $: 새 메시지부터, 0: 처음부터

# 그룹으로 읽기
XREADGROUP GROUP mygroup consumer1 COUNT 1 BLOCK 5000 STREAMS mystream >

# 처리 완료 확인 (ACK)
XACK mystream mygroup "1714900000000-0"

# 미확인 메시지 확인 (Pending)
XPENDING mystream mygroup

# 메시지 삭제
XDEL mystream "1714900000000-0"

# 스트림 트리밍 (최대 1000개 유지)
XTRIM mystream MAXLEN ~ 1000
```

---

## HyperLogLog

HyperLogLog는 고유 원소 수(카디널리티)를 근사적으로 계산하는 확률적 자료구조입니다.    
수백만 개의 고유 값을 단 12KB 메모리로 추적할 수 있습니다 (오차율 약 0.81%).

```bash
# 원소 추가
PFADD visitors:2026-05-05 "user:1" "user:2" "user:3"
PFADD visitors:2026-05-05 "user:1" "user:4"  # 중복은 무시

# 고유 원소 수 (근사값)
PFCOUNT visitors:2026-05-05
# 4

# 여러 HyperLogLog 합치기
PFADD visitors:2026-05-04 "user:1" "user:5" "user:6"
PFMERGE visitors:week visitors:2026-05-04 visitors:2026-05-05
PFCOUNT visitors:week
# 6
```

### 활용: 일별 고유 방문자 수 (UV)
```bash
# 페이지 방문 시
PFADD uv:page:home:2026-05-05 "user:123"

# 일별 UV 조회
PFCOUNT uv:page:home:2026-05-05

# 주간 UV (합산)
PFMERGE uv:page:home:week uv:page:home:2026-05-01 uv:page:home:2026-05-02 uv:page:home:2026-05-03
PFCOUNT uv:page:home:week
```

---

## Bitmap

Bitmap은 String을 비트 배열로 활용하는 기법입니다.    
각 비트(0/1)로 상태를 표현하여 매우 적은 메모리로 대량의 불리언 데이터를 관리합니다.

```bash
# 비트 설정 (offset, value)
SETBIT daily_active:2026-05-05 1001 1    # user:1001 활성
SETBIT daily_active:2026-05-05 1002 1    # user:1002 활성
SETBIT daily_active:2026-05-05 1003 0    # user:1003 비활성

# 비트 조회
GETBIT daily_active:2026-05-05 1001
# 1

# 1인 비트 수 (활성 사용자 수)
BITCOUNT daily_active:2026-05-05

# 비트 연산
BITOP AND both_days daily_active:2026-05-04 daily_active:2026-05-05
# 양일 모두 활성인 사용자

BITOP OR any_day daily_active:2026-05-04 daily_active:2026-05-05
# 어느 날이든 활성인 사용자

# 첫 번째 1(또는 0) 비트 위치
BITPOS daily_active:2026-05-05 1
```

### 활용: 출석 체크
```bash
# 5월 5일 출석 (user_id를 offset으로)
SETBIT attendance:2026-05-05 123 1

# 이번 달 개근 사용자 (AND 연산)
BITOP AND perfect_may attendance:2026-05-01 attendance:2026-05-02 ... attendance:2026-05-31
BITCOUNT perfect_may
```

---

## Geospatial

Redis의 Geo 명령어는 위도/경도 기반의 위치 데이터를 저장하고 거리/반경 검색을 지원합니다.    
내부적으로 Sorted Set을 사용합니다.

```bash
# 위치 추가 (경도, 위도, 멤버)
GEOADD stores 126.9780 37.5665 "서울시청"
GEOADD stores 127.0276 37.4979 "강남역"
GEOADD stores 126.9516 37.5547 "홍대입구"
GEOADD stores 129.0756 35.1796 "부산역"

# 위치 조회
GEOPOS stores "강남역"
# 1) "127.02760" 2) "37.49790"

# 두 지점 간 거리
GEODIST stores "서울시청" "강남역" km
# "8.2345"

GEODIST stores "서울시청" "부산역" km
# "325.1234"

# 반경 검색 (Redis 6.2+: GEOSEARCH)
GEOSEARCH stores FROMMEMBER "강남역" BYRADIUS 10 km ASC COUNT 5 WITHCOORD WITHDIST
# 강남역 기준 10km 이내, 가까운 순 5개

# 좌표 기준 반경 검색
GEOSEARCH stores FROMLONLAT 127.0 37.5 BYRADIUS 15 km ASC WITHCOORD WITHDIST

# 사각형 범위 검색
GEOSEARCH stores FROMLONLAT 127.0 37.5 BYBOX 20 20 km ASC

# Geohash 조회
GEOHASH stores "서울시청"
```

### 활용: 주변 매장 검색
```bash
# 사용자 현재 위치 기준 3km 이내 매장
GEOSEARCH stores FROMLONLAT 127.0 37.5 BYRADIUS 3 km ASC WITHDIST
```

{% assign c-category = 'redis' %}
{% assign c-tag = 'lecture-redis' %}
{% include /custom-ref.html %}
