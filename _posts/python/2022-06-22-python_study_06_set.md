---
title: "[Python Basic] 자료형 set 타입"
categories: 
    - python
tags: 
    [python, python강좌, 초급, 'lecture-python-basic', set ]
toc : true
toc_sticky  : true    
---
순서와 중복이 보장되지 않는 자료형 입니다.    

# list vs tuple vs dictionary vs set

|  | list | tuple | dictionary | set |
|:---:|:---:|:---:|:---:|:---:|
| 순서 | O | O | X | X | 
| 중복 | O | O | X | X |
| 변경 | O | X | O | O |
| 형태 | [1,2,3,4,5] | (1,2,3,4,5) | {"java":10, "key":5} | {1, 2, 3} |
| type | <class 'list'> | <class 'tuple'> | <class 'dict'> | <class 'set'> |

형태 `{값, 값,...., 값}` 의 형태의 자료형    
예)    
 `a = {1, 2, 3, 4, 5}`   
 `a = {1, 2, 3, 3, 4, 5}` - 중복 `3` 값 포함 불가능   

# 기본 사용법
## 선언
```python
a = {1, 2, 3, 4, 5}
print(a)  # {1, 2, 3, 4, 5}


s = {i for i in range(10)}
print(s) # {0, 1, 2, 3, 4, 5, 6, 7, 8, 9}

```

## 추가, 삭제
```python
a = {1, 2, 3, 4, 5}
a.add(6)
print(a)  # {1, 2, 3, 4, 5, 6}

#여러개 추가
a.update({7, 8, 9})
print(a)  # {1, 2, 3, 4, 5, 6, 7, 8, 9}

#한개 삭제
a.remove(2)
print(a)  # {1, 2, 4, 5, 6, 7, 8, 9}

#모두 삭제
a.clear()
print(a)  # {}
```


## 연산
```python
a = {1, 2, 3, 4, 5}
b = {3, 4, 5, 6, 7}

# 합집합
u = a | b
# u = a.union(b)
print(u) # {1, 2, 3, 4, 5, 6, 7}

# 교집합
i = a & b
# i = a.intersection(b)
print(i) #  {3, 4, 5}
  
# 차집합
d = a - b
# d = a.difference(b)
print(d) # {1, 2}

```

## set 의 길이 len
```python
a = {1, 2, 3, 4, 5}
print(len(a)) # len

```

## list to set 변환
```python
list = [1, 2, 3, 4, 5]
s = set(list)
print(a)   # {1, 2, 3, 4, 5}

```

## string to set
```python
str = 'ABCDE'
s = set(str) # {'C', 'E', 'B', 'D', 'A'}


```



## list to set
```python
list = ['a','b','c','d']
print(list) # ['a','b','c','d']

s = set(list) # {'a','b','c','d'}
print(s)

```




{% assign c-category = 'python' %}
{% assign c-tag = 'lecture-python-basic' %}
{% include /custom-ref.html %}