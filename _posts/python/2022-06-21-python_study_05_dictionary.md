---
title: "[Python Basic] 자료형 dictionary 타입"
categories: 
    - python
tags: 
    [python, python강좌, 초급, 'lecture-python-basic', dictionary ]
toc : true
toc_sticky  : true    
---
key, value 형태의 순서와 중복이 보장되지 않는 자료형 입니다.    

# list vs tuple vs dictionary vs set

|  | list | tuple | dictionary | set |
|:---:|:---:|:---:|:---:|:---:|
| 순서 | O | O | X | X | 
| 중복 | O | O | X | X |
| 변경 | O | X | O | O |
| 형태 | [1,2,3,4,5] | (1,2,3,4,5) | {"java":10, "key":5} | {1, 2, 3} |
| type | <class 'list'> | <class 'tuple'> | <class 'dict'> | <class 'set'> |

형태 `{key:value, key:value,....}` 의 `json` 형태의 자료형    
예)    
 `a = {"배철수": 90, "안철수": 85, "인순이": 80}`   

# 기본 사용법
## 인덱스
```python
a = {"배철수": 90, "안철수": 85, "인순이": 80}
print(a["배철수"])  # 90

# key=value형태로 생성
dic = dict(a=80, b=90, c=85)
print(dic)  # {'a': 80, 'b': 90, 'c': 85}

```

## 수정, 삭제
```python
a = {"배철수": 90, "안철수": 85, "인순이": 80}

a["배철수"]= 100
print(a)   # {'배철수': 100, '안철수': 85, '인순이': 80}

a = {'배철수': 100, '안철수': 85, '인순이': 80}
a.update({'배철수': 90, '안철수': 80})
print(a) # {'배철수': 90, '안철수': 80, '인순이': 80}

del["배철수"]
print(a)   # {'안철수': 80, '인순이': 80}

```


## 수정 삭제 예외 처리
```python

scores = {'배철수': 100, '안철수': 85, '인순이': 80}
v = scores.get("배철수")  # 100
v = scores.get("홍길동")  # None
#v = scores["홍길동"]      # 에러 발생
print(v)        # None
print(v == None )   # True

if "인순이" in scores:
    print("인순이 점수 : %d "%scores["인순이"]) # 인순이 점수 : 80 
 
scores.clear()  # 모두 삭제
print(scores) # {}

```


## 포함 판단 in
```python
a = {"배철수": 90, "안철수": 85, "인순이": 80}
"배철수" in a   # True

```


## 순회
```python
a = {"배철수": 90, "안철수": 85, "인순이": 80}
 
for key in a:
    val = a[key]
    print("%s : %d" % (key, val))

#출력
배철수 : 90
안철수 : 85
인순이 : 80

#items를 통한 순회
for k, v in a.items():
    print(k, v)

```


## keys, values
```python
a = {"배철수": 90, "안철수": 85, "인순이": 80}
 
# keys
keys = a.keys()
for k in keys:
    print(k)

# 출력
배철수
안철수
인순이


# values
values = a.values()
for v in values:
    print(v)

# 출력
90
85
80

```



## keys
```python
a = {"배철수": 90, "안철수": 85, "인순이": 80}
sort_a = sorted(a.keys())
print(sort_a) # ['배철수', '안철수', '인순이']

```

## values
```python
sort_a = sorted(a.values())
print(sort_a) # [60, 75, 80]

sort_a = sorted(a.values(), reverse=True)
print(sort_a) # [80, 75, 60]

```



## (Lambda) 정렬
```python
obj ={'배철수': 80, '안철수': 60, '인순이': 75}
sort_desc_obj = sorted(obj.items(), key=lambda x: x[0]) #x[0] key, x[1] value
print(sort_desc_obj)
# [('배철수', 80), ('안철수', 60), ('인순이', 75)]

obj = {'배철수': 80, '안철수': 60, '인순이': 75}
sort_desc_obj = sorted(obj.items(), key=lambda x: x[1]) #x[0] key, x[1] value
print(sort_desc_obj)
# [('안철수', 60), ('인순이', 75), ('배철수', 80)]

obj = {'배철수': 80, '안철수': 60, '인순이': 75}
sort_desc_obj = sorted(obj.items(), key=lambda x: x[1], reverse=True) #x[0] key, x[1] value
print(sort_desc_obj)
# [('배철수', 80), ('인순이', 75), ('안철수', 60)]
```



## dict key, value 를  value : key  형태로 변환
```python
id_name = {1: '배철수', 2: '안철수', 3: '인순이'}
name_id = {val:key for key,val in id_name.items()} 
print(name_id)  # {'배철수': 1, '안철수': 2, '인순이': 3}
```




## 두 리스트를 하나의 dict로 변환
```python
list_k = ['aaa', 'bbb', 'ccc', 'ddd']
list_v = [10, 20, 30, 40]
new_dict = {key: value for key, value in zip(list_k, list_v)}
print(type(new_dict))   # <class 'dict'>
print(new_dict)  # {'aaa': 10, 'bbb': 20, 'ccc': 30, 'ddd': 40}

```




## dict to tuple 변환
dict의 items()는 Dictonary의 키-값 쌍 Tuple 들로 구성된 dict_items 객체를 리턴     
```python
a = {'배철수': 80, '안철수': 60, '인순이': 75}
 
items = a.items()    # sorted(a.items()) 정렬지원
print(items) # dict_items([('배철수', 80), ('안철수', 60), ('인순이', 75)])

# dict_items를 리스트로 변환할 때
itemsList = list(items)
print(itemsList) # [('배철수', 80), ('안철수', 60), ('인순이', 75)]

```




## tuple to dict 변환
```python
persons = [('배철수', 80), ('안철수', 60), ('인순이', 75)]
mydict = dict(persons)
print(mydict)   # {'배철수': 80, '안철수': 60, '인순이': 75}

```



{% assign c-category = 'python' %}
{% assign c-tag = 'lecture-python-basic' %}
{% include /custom-ref.html %}