---
title: "[Python][Numpy] 배열 연산(Array operations)"
categories:  
    - python
tags: 
    [python, python강좌, 'lecture-python-numpy', numpy ]
toc : true
toc_sticky  : true    
---
nparray의 연산에 대해서 알아보겠습니다.   
mathematical function 메뉴에는 다양한 수학 관련 numpy 함수가 제공 되고 있으니 참고 바랍니다.   
[API 참조](https://numpy.org/doc/stable/reference/routines.math.html){:target="_blank"}    


# numpy operations
## 브로드캐스팅
nparray를 연산 하는 과정에서 부족한 배열 부분을 이전 배열의 패턴으로 채워서 연산되는 형태를 말합니다.    
```python
a1 = np.array([1,2,3])
print(a1)       # [1 2 3]
print(a1+5)     # [6 7 8]

a2 = np.arange(1,10).reshape(3,3)
print(a2)
# [[1 2 3]
#  [4 5 6]
#  [7 8 9]]


# 빈값은 브로드캐스팅 되어 채워진 채로 더해짐
print( a2 + a1 ) 
# [[ 2  4  6]
#  [ 5  7  9]
#  [ 8 10 12]]

b2 = np.array([1,2,3]).reshape(3,1)
print(a1)
# [1 2 3]
print(b2)
# [[1]
#  [2]
#  [3]]

print(a1+b2)
# [[2 3 4]
#  [3 4 5]
#  [4 5 6]]

```

## 사칙연산
```python
a1 = np.arange(1, 10)
print(a1)   
b1 = np.random.randint(1,10, size=9)
print(b1)

# [1 2 3 4 5 6 7 8 9]  al
# [3 9 6 5 6 9 2 9 6]  b1 램덤값

print(a1 + b1)  # [ 4 11  9  9 11 15  9 17 15]

print(a1 - b1)  # [-2 -7 -3 -1 -1 -3  5 -1  3]
print(a1 * b1)  # [ 3 18 18 20 30 54 14 72 54]
print(a1 / b1)  # [0.33333333 0.22222222 0.5        0.8        0.83333333 0.66666667  3.5        0.88888889 1.5       ]
print(a1 // b1) # [0 0 0 0 0 0 3 0 1]
print(a1 ** b1) # [        1       512       729      1024     15625  10077696        49   134217728    531441]

print(a1 % b1)  # [1 2 3 4 5 6 1 8 3]


```

## numpy.add
`numpy.add(x1, x2, /, out=None, *, where=True, casting='same_kind', order='K', dtype=None, subok=True[, signature, extobj])`    
nparray를 더하는 기능을 제공합니다.    
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.add.html){:target="_blank"} 
```python
a1 = np.arange(1,10)
print(a1)
print(a1+10)
print(np.add(a1, 10))

# [1 2 3 4 5 6 7 8 9]
# [11 12 13 14 15 16 17 18 19]
# [11 12 13 14 15 16 17 18 19]

```



## numpy.subtract
`numpy.subtract(x1, x2, /, out=None, *, where=True, casting='same_kind', order='K', dtype=None, subok=True[, signature, extobj])`    
nparray를 빼는 기능을 제공합니다.    
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.subtract.html){:target="_blank"} 
```python
print(a1)
print(a1-2)
print(np.subtract(a1, 2))

# [1 2 3 4 5 6 7 8 9]
# [-1  0  1  2  3  4  5  6  7]
# [-1  0  1  2  3  4  5  6  7]
```



## numpy.negative
`numpy.negative(x, /, out=None, *, where=True, casting='same_kind', order='K', dtype=None, subok=True[, signature, extobj])`    
nparray를 부호를 반전 기능을 제공합니다.    
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.negative.html){:target="_blank"} 
```python
print(a1)
print(-a1)
print(np.negative(a1))

# [1 2 3 4 5 6 7 8 9]
# [-1 -2 -3 -4 -5 -6 -7 -8 -9]
# [-1 -2 -3 -4 -5 -6 -7 -8 -9]
```



## numpy.multiply
`numpy.multiply(x1, x2, /, out=None, *, where=True, casting='same_kind', order='K', dtype=None, subok=True[, signature, extobj])`    
nparray를 곱하는 기능을 제공합니다.    
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.multiply.html){:target="_blank"} 
```python
print(a1)
print(a1*2)
print(np.multiply(a1,2))

# [1 2 3 4 5 6 7 8 9]
# [ 2  4  6  8 10 12 14 16 18]
# [ 2  4  6  8 10 12 14 16 18]

```



## numpy.divide
`numpy.divide(x1, x2, /, out=None, *, where=True, casting='same_kind', order='K', dtype=None, subok=True[, signature, extobj])`    
nparray를 나누는 기능을 제공합니다.    
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.divide.html){:target="_blank"} 
```python
print(a1)
print(a1/2)
print(np.divide(a1,2))

# [1 2 3 4 5 6 7 8 9]
# [0.5 1.  1.5 2.  2.5 3.  3.5 4.  4.5]
# [0.5 1.  1.5 2.  2.5 3.  3.5 4.  4.5]
```


## numpy.floor_divide
`numpy.floor_divide(x1, x2, /, out=None, *, where=True, casting='same_kind', order='K', dtype=None, subok=True[, signature, extobj])`    
nparray를 나누기 값의 소수부만 제공하는 기능을 제공합니다.(버림)    
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.floor_divide.html){:target="_blank"} 
```python
print(a1//2)
print(np.floor_divide(a1,2))

# [0 1 1 2 2 3 3 4 4]
# [0 1 1 2 2 3 3 4 4]
```


## numpy.mod
`numpy.mod(x1, x2, /, out=None, *, where=True, casting='same_kind', order='K', dtype=None, subok=True[, signature, extobj])`    
nparray를 나머지 값을 제공합니다.    
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.mod.html){:target="_blank"} 
```python
print(a1)
print(a1 % 2)
print(np.mod(a1,2))

# [1 2 3 4 5 6 7 8 9]
# [1 0 1 0 1 0 1 0 1]
# [1 0 1 0 1 0 1 0 1]
```


## numpy.absolute, np.abs
`numpy.absolute(x, /, out=None, *, where=True, casting='same_kind', order='K', dtype=None, subok=True[, signature, extobj])`    
np.abs is a shorthand for this function.
nparray를 절대값을 제공합니다.    
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.absolute.html){:target="_blank"} 
```python
x = np.array([-1.2, 1.2])
np.absolute(x)

# array([ 1.2,  1.2])
```


## numpy.square
`numpy.square(x, /, out=None, *, where=True, casting='same_kind', order='K', dtype=None, subok=True[, signature, extobj])`    
nparray를 제곱값을 제공합니다.    
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.square.html){:target="_blank"} 
```python
print(a1)
print(np.square(a1))

# [1 2 3 4 5 6 7 8 9]
# [ 1  4  9 16 25 36 49 64 81]
```


## numpy.sqrt
`numpy.sqrt(x, /, out=None, *, where=True, casting='same_kind', order='K', dtype=None, subok=True[, signature, extobj])`   
루트 값을 제공 합니다.
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.sqrt.html){:target="_blank"} 

```python
a2 = np.array([4,9,25,36,10])
print(a2)
print(np.sqrt(a2))

# [ 4  9 25 36 10]
# [2.         3.         5.         6.         3.16227766]
```

## numpy.exp
`numpy.exp(x, /, out=None, *, where=True, casting='same_kind', order='K', dtype=None, subok=True[, signature, extobj])`   
밑이 자연상수 e인 지수함수(e^x)의 그래프 값을 제공 합니다.
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.exp.html){:target="_blank"} 

```python
print(np.exp(0))    # e^0 와 동일
# 1.0

print(np.exp(1))    # e^1 와 동일
# 2.718281828459045

print(np.exp(10))   # e^10 와 동일
# 22026.465794806718

x = np.array([-1, -0.5, 0, 1 , 1.5, 5, 10])
print(np.exp(x))
#[3.67879441e-01 6.06530660e-01 1.00000000e+00 2.71828183e+00 4.48168907e+00 1.48413159e+02 2.20264658e+04]

```



## numpy.sum
`numpy.sum(a, axis=None, dtype=None, out=None, keepdims=<no value>, initial=<no value>, where=<no value>)`   
nparray의 합산된 값을 제공 합니다.    
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.sum.html){:target="_blank"} 

```python
a2 = np.random.randint(1,10, size=(3,3))
print(a2)
# [[7 9 7]
#  [5 6 2]
#  [3 3 8]]

print(a2.sum(), np.sum(a2)) #전체 item을 합
# 50 50

print(a2.sum(axis=0), np.sum(a2, axis=0))
#[15 18 17] [15 18 17]

print(a2.sum(axis=1), np.sum(a2, axis=1))
#[23 13 14] [23 13 14]

```



## numpy.cumsum
`numpy.cumsum(a, axis=None, dtype=None, out=None)`   
nparray의 `누적` 합산된 값을 제공 합니다.    
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.cumsum.html){:target="_blank"} 

```python
print(a2)
# [[7 9 7]
#  [5 6 2]
#  [3 3 8]]
print(np.cumsum(a2)) #누적합을 제공함
# [ 7 16 23 28 34 36 39 42 50]

print(np.cumsum(a2, axis=0))  # 행방향의 누적된 합으로 naddray변경됨
# [[ 7  9  7]
#  [12 15  9]
#  [15 18 17]]
 
print(np.cumsum(a2, axis=1)) # 열 방향의 누적된 합으로 naddray변경됨
# [[ 7 16 23]
#  [ 5 11 13]
#  [ 3  6 14]]

```



## numpy.diff
`numpy.diff(a, n=1, axis=-1, prepend=<no value>, append=<no value>)`   
naddray의 정해진 축의 방향으로 이전 값과의 차이 값을 제공 합니다.
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.diff.html){:target="_blank"} 

```python
print(a2)
# [[7 9 7]
#  [5 6 2]
#  [3 3 8]]

print(np.diff(a2))  # 기본 axis=1 값과 동일
# [[ 2 -2]
#  [ 1 -4]
#  [ 0  5]]

print(np.diff(a2, axis=0))
# [[-2 -3 -5]
#  [-2 -3  6]]

print(np.diff(a2, axis=1))
# [[ 2 -2]
#  [ 1 -4]
#  [ 0  5]]

```



## numpy.any
`numpy.any(a, axis=None, out=None, keepdims=<no value>, *, where=<no value>)`   
ndarray 항목중 `True` 값이 1개 이상 존재한다면 `True` (or조건) 제공 합니다.
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.any.html){:target="_blank"} 

```python
a2 = np.array([
    [False,False,False],
    [False,True,True],
    [False,False,False]
])

print(a2)
# [[False False False]
#  [False  True  True]
#  [False False False]]

print(np.any(a2)) # 항목중에 하나라도 True 면 True 임 OR
# True   (전체중에 True가 한개 이상 있으므로 True반환)
print(np.any(a2, axis=0)) #열단위
# [False  True  True]   
print(np.any(a2, axis=1)) #행단위
# [False  True False]
```



## numpy.all
`numpy.all(a, axis=None, out=None, keepdims=<no value>, *, where=<no value>)`   
ndarray 항목 모두 `True` 값이이라면 `True` (and조건) 제공 합니다.
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.all.html){:target="_blank"} 

```python
print(a2)
# [[False False False]
#  [False  True  True]
#  [False False False]]

print(np.all(a2)) # 전체가 True여야 True임 AND
# False

print(np.all(a2, axis=0))
# [False False False]

print(np.all(a2, axis=1))
# [False False False]
```
   

## numpy.sort
`numpy.sort(a, axis=- 1, kind=None, order=None)`    
ndarray의 정렬을 제공 합니다.    
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.sort.html){:target="_blank"} 

```python
a1 = np.random.randint(1, 10, size=10)
print(a1)
# [2 2 2 9 2 6 5 7 5 9]

print(np.sort(a1))
# [2 2 2 2 5 5 6 7 9 9]

a = np.array([[1,4],[3,1]])
np.sort(a)                # sort along the last axis
# array([[1, 4],
#        [1, 3]])
np.sort(a, axis=None)     # sort the flattened array
# array([1, 1, 3, 4])

np.sort(a, axis=0)        # sort along the first axis
# array([[1, 1],
#        [3, 4]])

```


## numpy.argosrt
`numpy.argsort(a, axis=- 1, kind=None, order=None)`    
ndarray의 정렬 `index` 값을 제공 합니다.    
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.argsort.html){:target="_blank"} 

```python
print(a1)
# [2 2 2 9 2 6 5 7 5 9]

print(np.argsort(a1))#정렬의 index순서
# [0 1 2 4 6 8 5 7 3 9]
```


## 그밖에 배열 연산 팁
조건을 통한 배열의 필터링하여 재생성할 수도 있습니다.
```python
a1 = np.arange(1,10)
print(a1)
print(a1 == 5)
print(a1 != 5)
print(a1 > 5)
print(a1 <= 5)

# [1 2 3 4 5 6 7 8 9]
# [False False False False  True False False False False]
# [ True  True  True  True False  True  True  True  True]
# [False False False False False  True  True  True  True]
# [ True  True  True  True  True False False False False]


a2 = np.arange(1,10).reshape(3,3)
print(a2)
# [[1 2 3]
#  [4 5 6]
#  [7 8 9]]
print(np.sum(a2))
# 45
print(np.count_nonzero(a2>5)) # 5초과 인 수량을 카운트함
# 4
print(np.sum(a2>5))
# 4
print(np.sum(a2>5, axis=0)) # 축에 해당하는 5초과 카운트가 출력됨
# [1 1 2]
print(np.sum(a2>5, axis=1)) # 축에 해당하는 5초과 카운트가 출력됨
# [0 1 3]

```




그 밖에 표준편차 `numpy.std`, 분산 `numpy.var`, 로그 `numpy.log` 등 다양한 함수가 있습니다.    
세부 내용은 공식 API를 참고 바랍니다.    
필요할 때 찾아쓸 정도만 알고 있으면 될 것 같네요.    

[학습 내용 참고처](https://www.youtube.com/watch?v=mirZPrWwvao){:target="_blank"} 

{% assign c-category = 'python' %}
{% assign c-tag = 'lecture-python-basic' %}
{% include /custom-ref.html %}
