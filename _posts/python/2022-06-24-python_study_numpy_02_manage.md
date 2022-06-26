---
title: "[Python][Numpy] 배열 사용(Array manipulation)"
categories:  
    - python
tags: 
    [python, python강좌, 'lecture-python-basic','lecture-python-numpy', numpy, manipulation ]
toc : true
toc_sticky  : true    
---
이번에는 `Numpy(Numerical Python)` 배열을 조작하는 내용을 주로 공부해 보겠습니다.

Numpy 홈페이지 : [numpy.org](https://numpy.org/doc){:target="_blank"}       
Array manipulation routines :  [API 참조](https://numpy.org/doc/stable/reference/routines.array-manipulation.html){:target="_blank"}    

# numpy 조작

## 배열 정보
배열 정보 확인을 위해서 아래 배열 함수를 작성하겠습니다.

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

ainfo(np.array([1,2,3,4,5]))
# ndim :  1
# shape :  (5,)
# dytpe :  int32
# size :  5
# itemsize :  4
# nbytes :  20
# strides :  (4,)
# [1 2 3 4 5]


```


## 기본 인덱싱
```python
a1 = np.array([1,2,3,4,5]);
a2 = np.array([[1,2,3],[4,5,6],[7,8,9]])
a3 = np.array( [
    [[1,2,3],[4,5,6],[7,8,9]],
    [[1,2,3],[4,5,6],[7,8,9]],
    [[1,2,3],[4,5,6],[7,8,9]]
])

print(a1)           # [1 2 3 4 5]
print(a1[0])        # 1
print(a1[1])        # 2
print(a1[2])        # 3
print(a1[-1])       # 4
print(a1[-2])       # 5

print(a2)
print(a2[0,0])      # 1
print(a2[0,2])      # 3
print(a2[1,1])      # 5
print(a2[2,-1])     # 9

print(a3)
print(a3[0,0,0])    # 1
print(a3[1,1,1])    # 5
print(a3[2,-1,-1])  # 9

```

## Boolean Indexing
`True` 값인 인덱스의 배열을 생성 합니다.   
```python
print(a1)
bi = [False, True, True, False, True]
print(bi)
print(a1[bi])

#[1 2 3 4 5]
#[False, True, True, False, True]
#[2 3 5]


print(a2)
bi = np.random.randint(0,2, (3,3), dtype=bool)
print(bi)
print(a2[bi])

# [[1 2 3]
#  [4 5 6]
#  [7 8 9]]

# [[ True  True False]
#  [ True False  True]
#  [False False  True]]
 
#  [1 2 4 6 9] or random으로 선택된 배열이 출력됨
```

## Fancy Indedxing
`index 번호`에 해당하는 데이터로 배열을 생성 합니다.
```python
print(a1)                   # [1 2 3 4 5]
print([a1[0],a1[2]])        # [1, 3]
index = [0,2]
print(a1[index])            # [1 3]  



#2차원으로 전달할 경우, 출력도 2차원으로 반환됨
index = np.array([[0,1],[2,0]])
print(index)
# [[0 1]
#  [2 0]]

print(a1[index])  
# [[1 2]
#  [3 1]]

# 복합으로 인덱스를 만들어서 제공할 경우에도 출력됨
print(a2)
# [[1 2 3]
#  [4 5 6]
#  [7 8 9]]
row = np.array([0,2])
col = np.array([1,2])
print(a2[row, col])         # [2 9]
#위 (0,1) (2,2) 에 해당하는 값이 [2 9] 출력됨

print(a2[row, :])  
# [[1 2 3]
#  [7 8 9]]

print(a2[:, col]) 
# [[2 3]
#  [5 6]
#  [8 9]]

print(a2[row, 1])
# [2 8]

print(a2[2, col])
# [8 9]

print(a2[row, 1:])
# [[2 3]
#  [8 9]]

print(a2[1:, col])  
# [[5 6]
#  [8 9]]

```
Fancy Indedxing 은 배열의 재정의 뿐 아니라, 배열의 연산에도 사용될 수 있습니다.

```python
a1 = np.array([1,2,3,4,5])
i = np.array([1,3,4])
a1[i] = 0
print(a1)   # [1 0 3 0 0]   i의 index 번호의 값이 0으로 초기화됨 

a1[i] +=4 # i가 있는 index에 +4 가 된것을 확인함.
print(a1)   # [1 4 3 4 4]
```


## 슬라이싱
`list` 형의 슬라이싱과 동일한 비슷한 형태로 제공합니다.

```python
print(a1)       #[1 2 3 4 5]
print(a1[0:2])  #[1 2]
print(a1[0:])   #[1 2 3 4 5]
print(a1[:1])   #[1]
print(a1[::2])  #[1 3 5]
print(a1[::-1]) #[5 4 3 2 1]
print(a1[:])    #[1 2 3 4 5]


print(a2)
# [[1 2 3]
#  [4 5 6]
#  [7 8 9]]

print(a2[1])            # [4 5 6]
print(a2[1, :])         # [4 5 6]

print(a2[:2,:2])
# [[1 2]
#  [4 5]

print(a2[1:,::-1])
# [[6 5 4]
#  [9 8 7]]

print(a2[::-1,::-1])
# [[9 8 7]
#  [6 5 4]
#  [3 2 1]]


a2_sub = a2[:2,:2];
print(a2_sub)
# [[1 2]
#  [4 5]]

a2_sub[:,1] = 0     # 값을 변경함.
print(a2_sub)
# [[1 0]
#  [4 0]]

print(a2) #numpy의 slicing 했을떄 원본도 값이 변경됨
# [[1 0 3]
#  [4 0 6]
#  [7 8 9]]

# a2_sub = a2[:2,:2].copy() 로 복사본 사용시 원본과 분리됨.
```


## numpy.insert
배열에 데이터를 삽입을 학습하겠습니다.     
`numpy.insert(arr, obj, values, axis=None)`     
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.insert.html){:target="_blank"}     
데이터를 추가할때 `axis`을 추가할 수 있는데, `axis=0`는 `행`, `axis=1`은 `열`으로 인식합니다. 

```python
print(a1)   # [1 2 3 4 5]
b1 = np.insert(a1, 0, 10) #0번째 10값을 추가해서 b1 새로운 array를 반환함
print(b1)   # [10  1  2  3  4  5]
print(a1)   # [1 2 3 4 5]


print(a2)
# [[1 2 3]
#  [4 5 6]
#  [7 8 9]]

b2 = np.insert(a2, 1, 10, axis = 0)
print(b2)

# [[ 1  2  3]
#  [10 10 10]           <- 1번 째 10 값을 axis=0(행) 단위로 추가함
#  [ 4  5  6]
#  [ 7  8  9]]
 
b2 = np.insert(a2, 1, 10, axis = 1)
print(b2)

# <- 1번 째 10 값을 axis=1(열) 단위로 추가함
# [[ 1 10  2  3]    
#  [ 4 10  5  6]
#  [ 7 10  8  9]]
```



## numpy.delete
배열에 데이터를 삽입을 학습하겠습니다.     
`numpy.delete(arr, obj, axis=None)`     
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.delete.html){:target="_blank"}     
데이터를 삭제할때 `axis`을 추가할 수 있는데, `axis=0`는 `행`, `axis=1`은 `열`으로 인식합니다. 
```python

# 1차원에서 배열 삭제
a1 = np.array([1,2,3,4,5])
print(a1)               # [1 2 3 4 5]
b1 = np.delete(a1, 1)   
print(b1)               # [1 3 4 5]
print(a1)               # [1 2 3 4 5] 원본 배열은 값을 유지함

# 2 차원에서 배열 삭제
print(a2)
# [[1 2 3]
#  [4 5 6]
#  [7 8 9]]

b3 = np.delete(a2, 1, 0) # axis = 0
print(b3)
# 1번 행이 없어짐
# [[1 2 3]
#  [7 8 9]]

print(a2)
b4 = np.delete(a2, 1, 1) # axis = 1
# [[1 3]
#  [4 6]
#  [7 9]]
```


## numpy.ndarray.T
`ndarray.T`로 데이터 형태를 피벗을 합니다.
```python

# 1차원은 변화 없음
a1 = np.array([1,2,3,4,5])
print(a1.T)
# [1 2 3 4 5]  


# 2차원
a2 = np.array([[1,2,3],[4,5,6],[7,8,9]])
print(a2)
# [[1 2 3]
#  [4 5 6]
#  [7 8 9]]

print(a2.T) #행열이 전환,
#  [[1 4 7]
#  [2 5 8]
#  [3 6 9]]

# 3차원
a3 = np.array( [
    [[1,2,3],[4,5,6],[7,8,9]],
    [[1,2,3],[4,5,6],[7,8,9]],
    [[1,2,3],[4,5,6],[7,8,9]]
])
print(a3.T) 
# [[[1 1 1]
#   [4 4 4]
#   [7 7 7]]
#  [[2 2 2]
#   [5 5 5]
#   [8 8 8]]
#  [[3 3 3]
#   [6 6 6]
#   [9 9 9]]]

# [[[1 1 1][4 4 4][7 7 7]]
#  [[2 2 2][5 5 5][8 8 8]]
#  [[3 3 3][6 6 6][9 9 9]]]

a4 = a3.T.copy()
print(a4.T) 
# [[[1 2 3]
#   [4 5 6]
#   [7 8 9]]

#  [[1 2 3]
#   [4 5 6]
#   [7 8 9]]

#  [[1 2 3]
#   [4 5 6]
#   [7 8 9]]]
```



## numpy.reshape
배열의 shape 을 재 구조화 합니다.   
`numpy.reshape(a, newshape, order='C')[source]`    
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.reshape.html){:target="_blank"} 

```python
n1 = np.arange(1, 10)
print(n1)  # [1 2 3 4 5 6 7 8 9]

print(n1.reshape(3,3))
# [[1 2 3]
#  [4 5 6]
#  [7 8 9]]

# 사이즈가 맞지 않는 경우, 다음 에러를 발생 시킵니다.
n2 = np.arange(1, 10)
print(n2.reshape(5,5))

------------------------------------------------
ValueError     Traceback (most recent call last)
Input In [119], in <cell line: 2>()
      1 n2 = np.arange(1, 10)
----> 2 print(n2.reshape(5,5))

ValueError: cannot reshape array of size 9 into shape (5,5)

```



## numpy.append
배열의 병합하는 역할을 진행 합니다.    
`numpy.append(arr, values, axis=None)`   
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.append.html){:target="_blank"} 
```python
a2 = np.arange(1,10).reshape(3,3)
# print(a2)
# [[1 2 3]
#  [4 5 6]
#  [7 8 9]]

b2 = np.arange(10,19).reshape(3,3)
print(b2)
# [[10 11 12]
#  [13 14 15]
#  [16 17 18]]

c2 = np.append(a2, b2)
print(c2) #1차원으로 결과 반환
#[ 1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18]

# 축을 지정하여 추가함.
c2 = np.append(a2, b2, axis=0) # 행단위
print(c2)

# [[ 1  2  3]
#  [ 4  5  6]
#  [ 7  8  9]
#  [10 11 12]
#  [13 14 15]
#  [16 17 18]]

c2 = np.append(a2, b2, axis=1)
print(c2)

# [[ 1  2  3 10 11 12]
#  [ 4  5  6 13 14 15]
#  [ 7  8  9 16 17 18]]
```
## numpy.stack
nparray의 축을 선택 하여 누적 시킵니다. 
`numpy.stack(arrays, axis=0, out=None)`     
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.stack.html){:target="_blank"} 
```python
a = np.array([1, 2, 3])
b = np.array([4, 5, 6])
np.stack((a, b))       # np.stack((a, b), axis=0) 과 동일
# array([[1, 2, 3],
#        [4, 5, 6]])

a = np.array([1, 2, 3])
b = np.array([4, 5, 6])
np.stack((a, b),axis=1)
# array([[1, 4],
#        [2, 5],
#        [3, 6]])
```


## numpy.vstack
nparray의 vertical 축의 병합 입니다. 
`np.append(a2, b2, axis=0)` 동일 결과를 나타납니다. 
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.vstack.html){:target="_blank"} 
```python
np.vstack((a2,b2))
# array([[ 1,  2,  3],
#        [ 4,  5,  6],
#        [ 7,  8,  9],
#        [10, 11, 12],
#        [13, 14, 15],
#        [16, 17, 18]])
```


## numpy.hstack
nparray의 horizontal 축의 병합 입니다. 
`np.append(a2, b2, axis=1)` 동일 결과를 나타납니다. 
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.hstack.html){:target="_blank"} 
```python
np.hstack((a2,b2))
# array([[ 1,  2,  3, 10, 11, 12],
#        [ 4,  5,  6, 13, 14, 15],
#        [ 7,  8,  9, 16, 17, 18]])
```

## numpy.concatenate
nparray를 연결 합니다. 
`numpy.concatenate((a1, a2, ...), axis=0, out=None, dtype=None, casting="same_kind")`
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.concatenate.html){:target="_blank"} 
```python
a = np.array([[1, 2], [3, 4]])
b = np.array([[5, 6]])
np.concatenate((a, b), axis=0)
# array([[1, 2],
#        [3, 4],
#        [5, 6]])

np.concatenate((a, b), axis=None)
# array([1, 2, 3, 4, 5, 6])

np.concatenate((a, b.T), axis=1)
# array([[1, 2, 5],
#        [3, 4, 6]])

# a        +    b.T
# [[1, 2],    [[5],
# [3, 4]]     [6]]


a1 = np.array([1,3,5])
b1 = np.array([2,4,6])
c1 = np.array([7,8,9])
np.concatenate([a1,b1,c1])
# array([1, 3, 5, 2, 4, 6, 7, 8, 9])


a2 = np.array([[1,2,3],[4,5,6]])
np.concatenate([a2,a2])
# array([[1, 2, 3],
#        [4, 5, 6],
#        [1, 2, 3],
#        [4, 5, 6]])


np.concatenate([a2,a2], axis=1)
# array([[1, 2, 3, 1, 2, 3],
#        [4, 5, 6, 4, 5, 6]])

np.concatenate([a2,a2], axis=0)
# array([[1, 2, 3],
#        [4, 5, 6],
#        [1, 2, 3],
#        [4, 5, 6]])

```



## numpy.vsplit
veritcal 기준으로 ndarrray를 분할 합니다.
`numpy.vsplit(ary, indices_or_sections)`    
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.vsplit.html){:target="_blank"}    

```python
a2 = np.arange(1,10).reshape(3,3)
print(a2)
# [[1 2 3]
#  [4 5 6]
#  [7 8 9]]

b2, b3 = np.vsplit(a2, [2])
print(b2)
# [[1 2 3]
#  [4 5 6]]

print(b3)
# [[7 8 9]]


x = np.arange(16.0).reshape(4, 4)
# array([[ 0.,   1.,   2.,   3.],
#        [ 4.,   5.,   6.,   7.],
#        [ 8.,   9.,  10.,  11.],
#        [12.,  13.,  14.,  15.]])
np.vsplit(x, 2)
# [array([[0., 1., 2., 3.],
#        [4., 5., 6., 7.]]), 
#  array([[ 8.,  9., 10., 11.],
#        [12., 13., 14., 15.]])]

```



## numpy.hsplit
Horizontal 기준으로 ndarrray를 분할 합니다.
`numpy.hsplit(ary, indices_or_sections)`    
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.hsplit.html){:target="_blank"}    

```python
a2 = np.arange(1,10).reshape(3,3)
print(a2)
# [[1 2 3]
#  [4 5 6]
#  [7 8 9]]

b2, b3 = np.hvsplit(a2, [2])
print(b2)
# [[1 2]
#  [4 5]
#  [7 8]]

print(b3)
# [[3]
#  [6]
#  [9]]

```


# numpy.random
자료를 임의로 만들어야 할때 자주 사용되는 라이브러리 입니다.      

## numpy.random.rand
0~1의 균일분포 표준정규분포 난수를 생성하여 반환합니다.    
`random.rand(d0, d1, ..., dn)`    
[API 참조](https://numpy.org/doc/stable/reference/random/generated/numpy.random.rand.html){:target="_blank"}  
```python
np.random.rand(5)
# array([0.42734205, 0.95354301, 0.80731892, 0.6908605 , 0.64658099])

np.random.rand(5,2)
# array([[0.85155709, 0.25876853],
#        [0.63304735, 0.12171615],
#        [0.11996824, 0.71999629],
#        [0.45233059, 0.77861135],
#        [0.43984419, 0.69105062]])

```

## numpy.random.randn
평균`0`, 표준편차 `1`인 가우시안 표준 정규분포의 난수를 생성하여 반환합니다.    
`random.randn(d0, d1, ..., dn)`    
[API 참조](https://numpy.org/doc/stable/reference/random/generated/numpy.random.randn.html){:target="_blank"}  
```python
np.random.randn(5)
# array([ 0.74225719, -0.39754649,  0.8966088 ,  0.30346421,  0.71134092])

np.random.randn(5,2)
# array([[-0.76182035, -0.51200261],
#        [ 0.51620442,  0.77368734],
#        [-0.23963806,  0.53549214],
#        [ 1.37556231, -0.87648979],
#        [ 0.51587644, -0.93696996]])

```


## numpy.random.randint
범위내 int 타입의 난수를 생성하여 반환합니다.    
`random.randint(low, high=None, size=None, dtype=int)`    
[API 참조](https://numpy.org/doc/stable/reference/random/generated/numpy.random.randint.html){:target="_blank"}  
```python
np.random.randint(10) # 0~9 까지의 임의의 수 반환
np.random.randint(5, 10) # 5이상 ~ 10미만의 임의의 숫자 


np.random.randint(10, size=5)
# array([5, 3, 9, 1, 0])

np.random.randint(5, size=(2, 4))
# array([[2, 2, 3, 4],
#        [2, 4, 2, 4]])

```

[학습 내용 참고처](https://www.youtube.com/watch?v=mirZPrWwvao){:target="_blank"} 

{% assign c-category = 'python' %}
{% assign c-tag = 'lecture-python-basic' %}
{% include /custom-ref.html %}
