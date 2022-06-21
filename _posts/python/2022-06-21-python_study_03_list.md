---
title: Python 자료형 list 타입
categories: 
    - python
tags: 
    [python, python강좌, 초급, 'lecture-python-basic', list ]
toc : true
toc_sticky  : true    
---
순서가 있고, 중복이 허용되는 배열 형태의 자료형 입니다.    

# list vs tuple vs dictionary vs set

|  | list | tuple | dictionary | set |
|:---:|:---:|:---:|:---:|:---:|
| 순서 | O | O | X | X | 
| 중복 | O | O | X | X |
| 변경 | O | X | O | O |
| 형태 | [1,2,3,4,5] | (1,2,3,4,5) | {"java":10, "key":5} | {1, 2, 3} |
| type | <class 'list'> | <class 'tuple'> | <class 'dict'> | <class 'set'> |


형태 `[값, 값, .... 값, 값]` 의 배열 형태의 자료형    
예)
 `a = [1, 3, 5, 7, 10]`   
 `a = ['A', 'B', 'C', 'C', 'D']`   
 `a = ['A', 1, 2, True, False, 'D']`   
 
# 기본 사용법
## 연산
```python
a = [1, 2, 3, 4, 5]
b = [6, 7, 8, 9, 10]
c = a+b
d = a*3
print(c)    # [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
print(d)    # [1, 2, 3, 4, 5, 1, 2, 3, 4, 5, 1, 2, 3, 4, 5]
print(a[0]) # 1
print(a[-1])# 5
print(len(d))# 15

```

## 슬라이싱
```python
a = [1, 3, 5, 7, 10] #[이상:미만]
x = a[1:3]     # [3, 5]
x = a[:2]      # [1, 3]
x = a[3:]      # [7, 10]
x = a[:]       # 전체
x = a[:-1]
print(x)    # [1, 3, 5, 7]

# [이상:미만:스탭단계]
x = a[::2]     # [1, 3, 5]
print(x)

x = a[::-1]     # [10, 7, 5, 3, 1] Reverse
print(x)

```

## 추가, 삭제
```python
b = ["AB", 10, False]
b.append(50.5)  # 추가  ['AB', 10, False, 50.5]
b[1] = 11       # 변경  ['AB', 11, False, 50.5]
del b[2]        # 삭제  ['AB', 11, 50.5]
print(b)        # ['AB', 11, 50.5]

```

## split
```python
mylist = "Today the weather is very clear.".split()
print(mylist) # ['Today', 'the', 'weather', 'is', 'very', 'clear.']

i = mylist.index('weather')  # i = 2
n = mylist.count('very')    # n = 1
print(i, n) # 2 1
```

## [표현식 for 요소 in 컬렉션 [if 조건식]]

```python
list1 = [n ** 2 for n in range(10) if n % 3 == 0]
print(list1)    # [0, 9, 36, 81]

list2 = [n  for n in range(10) if n % 3 == 0]
print(list2)    # [0, 3, 6, 9]

```


## 배열 초기화
```python
len = 10
arr = [0] * len
print(arr)  #[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]


len = 10
arr = [1] * len
print(arr) #[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
```

## 배열 순회
```python
arr = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
for i in range(len(arr)):
    arr[i] = i * 2
print(arr) # [0, 2, 4, 6, 8, 10, 12, 14, 16, 18]

arr = [i * 2 for i in range(10)]
print(arr)  # [0, 2, 4, 6, 8, 10, 12, 14, 16, 18]

str = 'ABCDE'
print([c * 3 for c in str]) #['AAA', 'BBB', 'CCC', 'DDD', 'EEE']

```


## 배열 재선언
```python

# 1~10까지 중 2로 나눈 나머지 0인 아이템만 arr로 재선언
size = 10
arr = [n for n in range(1, 11) if n % 2 == 0]
print(arr)  # [2, 4, 6, 8, 10]

# 1부터 30 까지 2의 배수 AND 3의 배수 , 조건은 모두 AND로 이어짐.
arr = [n for n in range(1, 31) if n % 2 == 0 if n % 3 == 0]
print(arr)  # [6, 12, 18, 24, 30]

# arr = [n for n in range(1, 31) if n % 2 == 0 and if n % 3 == 0] 
# SyntaxError: invalid syntax   And를 직접 넣는 것은 허용이 되지 않음

# 1부터 30 까지 2의 배수 OR 3의 배수 
arr = [n for n in range(1, 16) if n % 2 == 0 or n % 3 == 0]
# 한 if 문 내에서 or 연산 해결
print(arr)  # [2, 3, 4, 6, 8, 9, 10, 12, 14, 15

```

## 2중 배열
```python
arr = [[1, 2, 3], 
       [4, 5, 6],
       [7, 8, 9],
       [10, 11, 12],
      ]

print(len(arr))     # 4     행
print(len(arr[0]))  # 3     열

# 1차원 배열로 변환
arr1 = [n for row in arr for n in row]
print(arr1) # [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]

arr2 = []
for row in arr:
    for n in row:
        arr2.append(n)
print(arr2)  # [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]

```

## 집계 함수
### sum, min, max
```python
arr = [1, 2, 3, 4, 5]
print(sum(arr)) # 15
print(min(arr)) # 1
print(max(arr)) # 5

```

## 정렬
```python
a = [1,2,6,3,2,6,8,9]
print(a)    # [1, 2, 6, 3, 2, 6, 8, 9]

a.sort()    
print(a)    # [1, 2, 2, 3, 6, 6, 8, 9]

a.sort(reverse = True)
print(a)    # [9, 8, 6, 6, 3, 2, 2, 1]

```

## list - set 변환(중복 제거)
```python
a = [1,2,6,3,2,6,8,9]
s = set(a) #set으로 변경함
print(type(s))  # <class 'set'>
print(s)    # {1, 2, 3, 6, 8, 9}

a2 = list(s)
print(type(a2)) # <class 'list'>
print(a2)   # [1, 2, 3, 6, 8, 9]
```

## list to string
```python
a = [1,2,6,3,2,6,8,9]
str = ''.join(str(e) for e in a)
print(str)  # 12632689
```


{% assign c-category = 'python' %}
{% assign c-tag = 'lecture-python-basic' %}
{% include /custom-ref.html %}