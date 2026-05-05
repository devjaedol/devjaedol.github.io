---
title: "[InfluxDB] 03. Flux 쿼리 언어"
categories: 
    - influxdb
tags: 
    [influxdb, timeseries, influxdb강좌, 초급, 'lecture-influxdb']
toc : true
toc_sticky  : true    
---

InfluxDB 2.x의 쿼리 언어인 Flux의 기본 문법과 주요 함수를 정리합니다.

# Flux란?

Flux는 InfluxDB 2.x에서 사용하는 함수형 데이터 스크립팅 언어입니다.    
파이프(`|>`) 연산자로 데이터를 단계별로 변환하는 파이프라인 방식입니다.

```text
데이터 소스 |> 필터 |> 변환 |> 집계 |> 출력
```

---

## 기본 쿼리 구조

### 필수 3요소
```flux
from(bucket: "mybucket")        // 1. 데이터 소스
  |> range(start: -1h)          // 2. 시간 범위 (필수)
  |> filter(fn: (r) => r._measurement == "cpu")  // 3. 필터
```

### 시간 범위 (range)
```flux
// 상대 시간
|> range(start: -1h)              // 최근 1시간
|> range(start: -7d)              // 최근 7일
|> range(start: -30m, stop: -5m)  // 30분 전 ~ 5분 전

// 절대 시간
|> range(start: 2026-05-01T00:00:00Z, stop: 2026-05-05T23:59:59Z)
```

### 필터 (filter)
```flux
// 단일 조건
|> filter(fn: (r) => r._measurement == "cpu")

// 다중 조건 (AND)
|> filter(fn: (r) => r._measurement == "cpu" and r.host == "server01")

// OR 조건
|> filter(fn: (r) => r.host == "server01" or r.host == "server02")

// 필드 필터
|> filter(fn: (r) => r._field == "usage_user")

// 값 필터
|> filter(fn: (r) => r._value > 80.0)

// 정규식
|> filter(fn: (r) => r.host =~ /server0[1-3]/)
```

---

## 집계 함수

### 기본 집계
```flux
// 평균
from(bucket: "mybucket")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "cpu" and r._field == "usage_user")
  |> mean()

// 최대/최소
|> max()
|> min()

// 합계/개수
|> sum()
|> count()

// 마지막/첫 번째 값
|> last()
|> first()

// 중앙값/백분위
|> median()
|> quantile(q: 0.95)    // 95 퍼센타일
```

### 시간 윈도우 집계 (aggregateWindow)
```flux
// 5분 간격 평균
from(bucket: "mybucket")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "cpu" and r._field == "usage_user")
  |> aggregateWindow(every: 5m, fn: mean, createEmpty: false)

// 1시간 간격 최대값
|> aggregateWindow(every: 1h, fn: max)

// 1일 간격 합계
|> aggregateWindow(every: 1d, fn: sum)
```

### 그룹핑 (group)
```flux
// 호스트별 그룹핑 후 평균
from(bucket: "mybucket")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "cpu")
  |> group(columns: ["host"])
  |> mean()

// 그룹 해제
|> group()
```

---

## 변환 함수

### 정렬/제한
```flux
// 정렬
|> sort(columns: ["_time"], desc: true)
|> sort(columns: ["_value"], desc: true)

// 상위 N개
|> top(n: 10, columns: ["_value"])
|> bottom(n: 5, columns: ["_value"])

// 제한
|> limit(n: 100)
|> tail(n: 10)    // 마지막 10개
```

### 수학 연산
```flux
// 값 변환
|> map(fn: (r) => ({ r with _value: r._value * 100.0 }))

// 새 컬럼 추가
|> map(fn: (r) => ({ r with celsius: (r._value - 32.0) * 5.0 / 9.0 }))

// 절대값, 반올림
|> math.abs()
|> math.round(precision: 2)
```

### 시간 함수
```flux
// 시간 이동
|> timeShift(duration: -1d)

// 시간 단위 추출
|> map(fn: (r) => ({ r with hour: date.hour(t: r._time) }))
```

### 피벗 (Pivot)
```flux
// 필드를 컬럼으로 변환
from(bucket: "mybucket")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "cpu")
  |> pivot(rowKey: ["_time"], columnKey: ["_field"], valueColumn: "_value")
// 결과: _time | usage_user | usage_system | usage_idle
```

---

## 고급 함수

### 이동 평균 (Moving Average)
```flux
|> movingAverage(n: 5)          // 단순 이동 평균 (5포인트)
|> exponentialMovingAverage(n: 10)  // 지수 이동 평균
|> timedMovingAverage(every: 5m, period: 15m)  // 시간 기반
```

### 변화율 (Derivative)
```flux
// 초당 변화율
|> derivative(unit: 1s, nonNegative: true)

// 차이 (현재 - 이전)
|> difference(nonNegative: true)

// 증가분 (카운터용)
|> increase()
```

### 조건부 알림
```flux
// 임계값 초과 필터
from(bucket: "mybucket")
  |> range(start: -5m)
  |> filter(fn: (r) => r._measurement == "cpu" and r._field == "usage_user")
  |> filter(fn: (r) => r._value > 90.0)
```

### 다운샘플링 (데이터 축소)
```flux
// 원본 데이터를 1시간 평균으로 축소하여 다른 버킷에 저장
from(bucket: "raw_data")
  |> range(start: -24h)
  |> filter(fn: (r) => r._measurement == "cpu")
  |> aggregateWindow(every: 1h, fn: mean)
  |> to(bucket: "downsampled_data", org: "myorg")
```

---

## InfluxQL (SQL 유사 문법, 호환 모드)

InfluxDB 2.x에서도 InfluxQL을 사용할 수 있습니다 (1.x 호환).

```sql
-- 기본 조회
SELECT usage_user FROM cpu WHERE host = 'server01' AND time > now() - 1h

-- 집계
SELECT MEAN(usage_user) FROM cpu WHERE time > now() - 1h GROUP BY time(5m), host

-- 최근 값
SELECT LAST(usage_user) FROM cpu GROUP BY host
```

### Flux vs InfluxQL 비교

| 항목 | Flux | InfluxQL |
|------|------|----------|
| 문법 스타일 | 함수형 파이프라인 | SQL 유사 |
| 기능 범위 | 풍부 (JOIN, 수학, 알림) | 제한적 |
| 학습 곡선 | 높음 | 낮음 (SQL 경험자) |
| 크로스 버킷 쿼리 | 가능 | 불가 |
| 권장 | InfluxDB 2.x 기본 | 마이그레이션/호환 |

{% assign c-category = 'influxdb' %}
{% assign c-tag = 'lecture-influxdb' %}
{% include /custom-ref.html %}
