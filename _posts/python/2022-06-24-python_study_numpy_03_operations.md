---
title: "[Python][Numpy] 배열 연산(Array operations)"
categories:  
    - python
tags: 
    [python, python강좌, 'lecture-python-basic','lecture-python-numpy', numpy ]
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


[학습 내용 참고처](https://www.youtube.com/watch?v=mirZPrWwvao){:target="_blank"} 

{% assign c-category = 'python' %}
{% assign c-tag = 'lecture-python-basic' %}
{% include /custom-ref.html %}
