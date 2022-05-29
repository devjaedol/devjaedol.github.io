---
title: "[Python] input 처리"
categories: 
    - codingtest
    - python
    - input
tags: 
    [python, python, stdin, readline]
toc : true
toc_sticky  : true    
---

Python에서 코딩 테스트시에 입력을 처리하는 방법

# 배열 생성 및 초기화
## 1차원 배열 초기화
```python
arr = [0]*5
arr
#출력 
> [0, 0, 0, 0, 0]
```

## 2차원 배열 초기화
```python
row = 5
col = 2
arr = [[0]*col]*row
arr
#출력 
> [[0, 0], [0, 0], [0, 0], [0, 0], [0, 0]]

arr = [[0]*col for _ in range(row)]
arr
#출력 
> [[0, 0], [0, 0], [0, 0], [0, 0], [0, 0]]

```

# 입력 값 처리
## 입력 샘플
```text
5
10  10
20  35
22  34
58  60
123 2148
```

## input() 사용법

```python
import sys

N = int(input())
for i in range(N):
        a,b = map(int, sys.stdin.readline().split())
        print( a , b )
#출력
> 10  10
> 20  35
> 22  34
> 58  60
> 123 2148

```

## sys.stdin.readline()

```python
import sys

N = int(sys.stdin.readline())  ## 동일 하고 이부분만 ㅂ녁여되ㅏㅁ
for i in range(N):
        a,b = map(int, sys.stdin.readline().split())
        print( a , b )
#출력
> 10  10
> 20  35
> 22  34
> 58  60
> 123 2148

```

## 라인단위 처리
### 한줄에 한개의 변수 저장 하기
입력 형태    
```text
79
```   

`int`을 변한화여 대입   
```python
import sys
a = int(int,sys.stdin.readline())

```

### 한줄에 여러개의 변수를 Split 하기
입력 형태    
```text
1 3 5 7 9 
```   
`split`을 이용하여, `map->int`로 변한화여 개별 대입 방법
```python
import sys

a, b, c, d, e = map(int,sys.stdin.readline().split())

```


`split`을 이용하여, `map->int`로 변한화여 리스트에 저장
```python
import sys

listdata = list(map(int,sys.stdin.readline().split()))

```

# 활용 예제
## N줄의 리스트 저장
입력 형태 ( 5줄의 이름 출력 경우)    
```text
5       
홍길동
김철수
이귀남
하현수
이진수
``` 

`strip()`는 trim()과 같이 앞뒤 공백 제거 역할.

```python
import sys
N = int(sys.stdin.readline())
data = [sys.stdin.readline().strip() for i in range(N)]
```

## N줄의 2차원을 1차원 리스트로 처리
입력 형태 ( 3행 3열의의미)    
```text
3       
1 2 3
4 5 6
7 8 9
``` 
1차원 리스트로 모두 등록될 때
```python
import sys
N = int(sys.stdin.readline())
arr =[];
for i in range(N):
    arr.append(list(map(int,sys.stdin.readline().split())))
arr
#출력
> [1,2,3,4,5,6,7,8,9]
```

## N줄의 2차원을2차원 리스트로 처리
입력 형태 ( 3행 3열의의미)    
```text
3       
1 2 3
4 5 6
7 8 9
``` 

2차원 리스트로 모두 등록될 때
```python
import sys

INF=-1  #초기값
N = int(sys.stdin.readline())
arr = [[INF for _ in range(N)] for _ in range(N)] # _ 의미 값을 사용하지 않는 무시의 의미
print(arr)

#출력
> [[-1, -1, -1, -1, -1, -1],
>  [-1, -1, -1, -1, -1, -1],
>  [-1, -1, -1, -1, -1, -1],
>  [-1, -1, -1, -1, -1, -1],
>  [-1, -1, -1, -1, -1, -1],
>  [-1, -1, -1, -1, -1, -1]]


for i in range(N):
    data = sys.stdin.readline().split();
    for j in range(N):
        arr[i][j] = data(j);
arr
#출력
> [[1,2,3],[4,5,6],[7,8,9]]

```
