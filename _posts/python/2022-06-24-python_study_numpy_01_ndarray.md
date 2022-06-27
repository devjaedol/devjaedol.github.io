---
title: "[Python][Numpy] 배열 생성(Array creation)"
categories:  
    - python
tags: 
    [python, python강좌,'lecture-python-numpy', numpy ]
toc : true
toc_sticky  : true    
---
`Numpy(Numerical Python)` 는 python으로 행열 연산 등 대규모 다타원 배열과 행열 연산 등에 사용할 수 있는 라이브러 입니다.   
python이 데이터 분석 머신너링에 이용되기 위해서 데이터 전처리 등의 과정을 거치는데 numpy는 이런 전처리 과정에 사용됩니다.   
기본적은 사용법을 배워보겠습니다.  
Array creation routines :  [API 참조](https://numpy.org/doc/stable/reference/routines.array-creation.html){:target="_blank"}      

Numpy 홈페이지 : [numpy.org](https://numpy.org/doc){:target="_blank"}    

Numpy를 사용하려면 설치를 진행 해야됩니다.    
# 설치하기
`pip install numpy` 로 설치를 진행 합니다.   
설치 후 `import numpy as np` 를 통해서 사용 합니다.   

# numpy 배열

## 배열 생성 
기본적인 배열을 만들어 봅니다.  
다양한 생성 방법이 있는데, 공식 문서에서 확인 바랍니다.    
[Array creation routines](https://numpy.org/doc/stable/reference/routines.array-creation.html){:target="_blank"}    
type을 확인해보면, `list` 타입과 다른 `ndarray` 가 출력 됩니다.    

```python
import numpy as np
# 1차원 생성
a1 = np.array([1,2,3,4,5]);
print(a1)   # [1 2 3 4 5]

print(type([1,2,3,4,5]))    #<class 'list'>
print(type(a1))             #<class 'numpy.ndarray'>
print(a1.shape)             #(5,)     
print(a1.ndim)              #1     

# 2차원 생성
a2 = np.array([[1,2,3],[4,5,6],[7,8,9]])
print(a2.shape)             #(3,3)
print(a2.ndim)              #2     

# 3차원 생성
a3 = np.array( [
    [[1,2,3],[4,5,6],[7,8,9]],
    [[1,2,3],[4,5,6],[7,8,9]],
    [[1,2,3],[4,5,6],[7,8,9]]
])
print(a3.shape)             #(3, 3, 3)
print(a3.ndim)              #3     

# 배열의 타입 선택
np.array([1, 2, 3, 4, 5], dtype=int)
np.array([1.1, 2.2, 3.3, 4.4, 5.5], dtype=float)
np.array([1, 1, 0, -1, 2], dtype=bool) # array([ True,  True, False,  True,  True])  0만 False
```
생성한 배열의 크기와 형태를 확인하는 방법은 `shape`은 tuple형태로 반환하고, 
`ndim`은 차원수를 반환한다. 

## Date 배열 생성
```python
# 데이터 타입 생성
date = np.array('2022-07-01', dtype=np.datetime64)
print(date) # 2022-07-01

date        # array('2022-07-01', dtype='datetime64[D]')
date + np.arange(40)

# array(['2022-07-01', '2022-07-02', '2022-07-03', '2022-07-04',
#        '2022-07-05', '2022-07-06', '2022-07-07', '2022-07-08',
#        '2022-07-09', '2022-07-10', '2022-07-11', '2022-07-12',
#        '2022-07-13', '2022-07-14', '2022-07-15', '2022-07-16',
#        '2022-07-17', '2022-07-18', '2022-07-19', '2022-07-20',
#        '2022-07-21', '2022-07-22', '2022-07-23', '2022-07-24',
#        '2022-07-25', '2022-07-26', '2022-07-27', '2022-07-28',
#        '2022-07-29', '2022-07-30', '2022-07-31', '2022-08-01',
#        '2022-08-02', '2022-08-03', '2022-08-04', '2022-08-05',
#        '2022-08-06', '2022-08-07', '2022-08-08', '2022-08-09'],
#       dtype='datetime64[D]')

datetime = np.datetime64('2022-07-01 13:20')
datetime
# numpy.datetime64('2022-07-01T13:20')

```
생성한 배열의 크기와 형태를 확인하는 방법은 `shape`은 tuple형태로 반환하고, 
`ndim`은 차원수를 반환한다. 


## 배열 복사
기존 생성된 ndarray를  복사하여 생성 할수 있습니다.   
아래 `new_1 = a1` 로 인해서 두 변수는 같이 변경되는 것을 알 수 있습니다.   

```python
a1 = np.array([1,2,3,4,5]);
new_1 = a1
new_2 = a1.copy()

new_1[0] = 200

print(a1)
print(new_1)
print(new_2)

# 결과
# [200   2   3   4   5]
# [200   2   3   4   5]
# [1 2 3 4 5]

```

## 배열 정보 확인
다음 함수를 통해서 배열의 정보를 확인할 수 있습니다.    

| 항목 | 설명 |
|:---:|:---:|
| ndim | 배열 차원 |
| shape | 배열 shape |
| dtype | 배열 데이터 타입| 
| size | 배열 요소 수 |
| itemsize | 배열 각 맴버의 바이트 크기 |
| nbytes | 배열의 요소가 소비 한 총 바이트 |
| strides | 배열을 탐색 할 때 각 차원에서 단계별로 이동할 바이트 수 |

```python
def ainfo(array):
    print("ndim : ", array.ndim)
    print("shape : ", array.shape)
    print("dytpe : ", array.dtype)
    print("size : ", array.size)
    print("itemsize : ", array.itemsize)
    print("nbytes : ", array.nbytes)
    print("strides : ", array.strides)
    print(array)
```

## 배열 접근
`list` 배열과 같이 접근 할 수 있습니다.
```python
# 1차원 접근
print(a1[0],a1[1],a1[2]) # 1 2 3
print(a1[-1]) # 5
print(a1[:2]) # [1 2]

# 2차원 접근
print(a2[0,0],a2[1,1],a2[2,2]) # 1 5 9

# 3차원 접근
print(a3[0,0,0],a3[1,1,1],a3[2,2,2]) # 1 5 9 

#값 변경
a1[0]=15


```

## numpy.zeros
`0` 값으로 채우기 위해서 사용합니다.    
`numpy.zeros(shape, dtype=float, order='C', *, like=None)`     
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.zeros.html){:target="_blank"} 
```python
# 1차원
z = np.zeros(10)
print(type(z))      # <class 'numpy.ndarray'>
print(z)            # [0. 0. 0. 0. 0. 0. 0. 0. 0. 0.]

np.zeros(10)        # array([0., 0., 0., 0., 0., 0., 0., 0., 0., 0.])


# 2차원
np.zeros((10,10))

# 형태
# array([[0., 0., 0., 0., 0., 0., 0., 0., 0., 0.],
#        [0., 0., 0., 0., 0., 0., 0., 0., 0., 0.],
#        [0., 0., 0., 0., 0., 0., 0., 0., 0., 0.],
#        [0., 0., 0., 0., 0., 0., 0., 0., 0., 0.],
#        [0., 0., 0., 0., 0., 0., 0., 0., 0., 0.],
#        [0., 0., 0., 0., 0., 0., 0., 0., 0., 0.],
#        [0., 0., 0., 0., 0., 0., 0., 0., 0., 0.],
#        [0., 0., 0., 0., 0., 0., 0., 0., 0., 0.],
#        [0., 0., 0., 0., 0., 0., 0., 0., 0., 0.],
#        [0., 0., 0., 0., 0., 0., 0., 0., 0., 0.]])

```



## numpy.ones
`1` 값으로 채우기 위해서 사용합니다.    
`numpy.ones(shape, dtype=None, order='C', *, like=None)`     
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.ones.html){:target="_blank"} 
```python
# 1차원
np.ones(10)
# array([1., 1., 1., 1., 1., 1., 1., 1., 1., 1.])

# 2차원
np.ones((10,10))
# 형태
# array([[1., 1., 1., 1., 1., 1., 1., 1., 1., 1.],
#        [1., 1., 1., 1., 1., 1., 1., 1., 1., 1.],
#        [1., 1., 1., 1., 1., 1., 1., 1., 1., 1.],
#        [1., 1., 1., 1., 1., 1., 1., 1., 1., 1.],
#        [1., 1., 1., 1., 1., 1., 1., 1., 1., 1.],
#        [1., 1., 1., 1., 1., 1., 1., 1., 1., 1.],
#        [1., 1., 1., 1., 1., 1., 1., 1., 1., 1.],
#        [1., 1., 1., 1., 1., 1., 1., 1., 1., 1.],
#        [1., 1., 1., 1., 1., 1., 1., 1., 1., 1.],
#        [1., 1., 1., 1., 1., 1., 1., 1., 1., 1.]])

# bool 타입 선언

np.ones((3,3), dtype=bool)
# 형태
# array([[ True,  True,  True],
    #    [ True,  True,  True],
    #    [ True,  True,  True]])
```


## numpy.full
`특정` 값으로 채우기 위해서 사용합니다.    
`numpy.full(shape, fill_value, dtype=None, order='C', *, like=None)`     
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.full.html){:target="_blank"} 
```python
np.full((3,3), 3.14 )

# 형태
# array([[3.14, 3.14, 3.14],
#        [3.14, 3.14, 3.14],
#        [3.14, 3.14, 3.14]])
```



## numpy.eye
단위행렬 형태로 대각선의 `1`로 만들어진 정사각형 행열을 반환 합니다.    
`numpy.eye(N, M=None, k=0, dtype=<class 'float'>, order='C', *, like=None)`     
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.eye.html){:target="_blank"} 
```python
np.eye(5)

# 형태
# array([[1., 0., 0., 0., 0.],
#        [0., 1., 0., 0., 0.],
#        [0., 0., 1., 0., 0.],
#        [0., 0., 0., 1., 0.],
#        [0., 0., 0., 0., 1.]])
```


## numpy.tri
정사각형 행렬에서 3각 행렬 형태의 값을 `1`로 채운 행열을 반환 합니다.   
`numpy.tri(N, M=None, k=0, dtype=<class 'float'>, *, like=None)`     
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.tri.html){:target="_blank"} 
```python
np.tri(5)

# 형태
# array([[1., 0., 0., 0., 0.],
#        [1., 1., 0., 0., 0.],
#        [1., 1., 1., 0., 0.],
#        [1., 1., 1., 1., 0.],
#        [1., 1., 1., 1., 1.]])
```



## numpy.empty
초기화 하지 않은 배열을 반환하는데, 값은 기존 메모리에 값들이 출력되는 현상이 발생한다.     
`numpy.empty(shape, dtype=float, order='C', *, like=None)`     
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.empty.html){:target="_blank"} 
```python
np.empty((3,3))
# 형태 (임의의 값)
# array([1., 1., 1., 1., 1.])

np.empty((3,3))
# 형태 (임의의 값)
# array([[3.14, 3.14, 3.14],
#        [3.14, 3.14, 3.14],
#        [3.14, 3.14, 3.14]])
       
```

## *_like, ones_like,  zeros_like, full_like, empty_like
`*_like`는 인자로 제공된 데이터 형태와 같은 `shape`을 가지고 있는 배열을 반환합니다.    
예 를 들어 `sample1`은 `(5,5)`의 sahpe을 가진 ndarray이고 `sample2`는 `sample1`의 형태(shape)을 동일하게 만들고 값은 `full_like`로 특정값을 선택하는 의미 입니다.    

```python
sample1 = np.ones((5,5))
print(sample1.shape)        # (5, 5) 
# print(sample1)
# [[1. 1. 1. 1. 1.]
#  [1. 1. 1. 1. 1.]
#  [1. 1. 1. 1. 1.]
#  [1. 1. 1. 1. 1.]
#  [1. 1. 1. 1. 1.]]

sample2 = np.full_like(sample1, 7)
print(sample2)              # (5, 5)
# print(sample2.shape)
# [[7. 7. 7. 7. 7.]
#  [7. 7. 7. 7. 7.]
#  [7. 7. 7. 7. 7.]
#  [7. 7. 7. 7. 7.]
#  [7. 7. 7. 7. 7.]]
```

## numpy.arange
`range` 함수와 동일한 형태로 ndarray를 생성하는 방법 입니다.
`numpy.arange([start, ]stop, [step, ]dtype=None, *, like=None)`    
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.arange.html){:target="_blank"} 
```python
np.arange(0, 10)
# array([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])

np.arange(0, 10, 2)
# array([0, 2, 4, 6, 8])

```



[학습 내용 참고처](https://www.youtube.com/watch?v=mirZPrWwvao){:target="_blank"} 

{% assign c-category = 'python' %}
{% assign c-tag = 'lecture-python-basic' %}
{% include /custom-ref.html %}
