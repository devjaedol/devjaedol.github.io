---
title: Python - for, enumerate 
categories: 
    - python
tags: 
    - enumerate
    - for
toc : true
toc_sticky  : true    
---

반복문의 for와 enumerate 사용 정리

# for문을 통한 list 순회
```python

arr = ['a','b','c','d','e']
for c in arr:
    print(c)

#출력
a
b
c
d
e
```
위 조건에서 index를 함께 출력하고 싶을때?

```python

arr = ['a','b','c','d','e']
i = 0
for c in arr:
    print(i, c )
    i += 1

#출력
0 a
1 b
2 c
3 d
4 e
```
위 i의 변수가 for 종료 이후에도 메모리에 남는 문제가 있습니다.    
아래 `len`을 사용하지만, 이부분도 최적의 해결안은 아닙니다.    
index를 순회하면 되지만, 전체 len을 구해야되는 문제가 존재합니다    
```python

arr = ['a','b','c','d','e']
for i in range(len(arr)):
    print(i, arr[i] )

#출력
0 a
1 b
2 c
3 d
4 e
```


# enumerate을 통한 list 순회
enumerate(순회데이터[,시작 인덱스])

```python
arr = ['a','b','c','d','e']
for idx, data in enumerate(arr):
    print(idx, data )

#출력
0 a
1 b
2 c
3 d
4 e
```
시작 인자를 변경한다면, 다음과 같이 출력됩니다.     
```python
arr = ['a','b','c','d','e']
for idx, data in enumerate(arr,50):
    print(idx, data )

#출력
50 a
51 b
52 c
53 d
54 e
```

# enumerate vs iter
`iter` 함수는 `next`를 통해 item을 접근하는 enumerate와 동일한 방식을 제공합니다.
그러나 다른점은 index 를 반환 하는 여부가 차이가 존재합니다.   

```python
arr = ['a','b','c','d','e']
iter_data = iter(arr)
next(iter_data)
> 'a'
next(iter_data)
> 'b'
next(iter_data)
> 'c'
next(iter_data)
> 'd'
next(iter_data)
> 'e'
next(iter_data)
----------------------------
StopIterationTraceback (most recent call last)
Input In [49], in <cell line: 1>()
----> 1 next(iter_data)
```
동일 기능을 enumerate를 사용할 경우

```python
arr = ['a','b','c','d','e']
enum_data = enumerate(arr)
next(enum_data)
> (0, 'a')
next(enum_data)
> (1, 'b')
next(enum_data)
> (2, 'c')
next(enum_data)
> (3, 'd')
next(enum_data)
> (4, 'e')
next(enum_data)
----------------------------
StopIterationTraceback (most recent call last)
Input In [56], in <cell line: 1>()
----> 1 next(enum_data)
```

# enumerate을 사용 예

## 2중 탐색 예제 O(n^2)
```python
arr = ['a','b','c','d','e']
for i, data1 in enumerate(arr):
    for j, data2 in enumerate(arr[i:],i+1):
        print(data2, end=' ')
    print('')

#출력
a b c d e 
b c d e 
c d e 
d e 
e 
```

## 리스트 형 변환
```python
arr = ['a','b','c','d','e']
list(enumerate(arr))
#출력
> [(0, 'a'), (1, 'b'), (2, 'c'), (3, 'd'), (4, 'e')]
```

## 2차원 배열 쉽게 접근
```python
arr = [['a','b'],['c','d'],['e','f']]
for r in range(len(arr)):
    for c in range(len(arr[r])):
        print(r, c, arr[r][c])
#출력
0 0 a
0 1 b
1 0 c
1 1 d
2 0 e
2 1 f
```

```python
arr = [['a','b'],['c','d'],['e','f']]
for r, row in enumerate(arr):
    for c, data in enumerate(row):
        print(r, c, data)
#출력
0 0 a
0 1 b
1 0 c
1 1 d
2 0 e
2 1 f
```



