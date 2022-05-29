---
title: "[Python] deque (stack, queue) 구현"
categories: 
    - codingtest
    - python
tags: 
    [queue, stack]
toc : true
toc_sticky  : true    
---

Python에서 list형태로 queue를 구현시 성능이슈로 인해서 deque 사용을 권장합니다.   

# list vs deque 성능 문제
index 0번째 추가와 출력시 성능 
- list   

| 작업 | 명령어 | 시간복잡도 | 
|---|:---:|:---:|
| 출력 |  pop(0) | O(n) |
| 입력 | Insert(0,value) | O(n) |

- deque    

| 작업 | 명령어 | 시간복잡도 | 
|---|:---:|:---:|
| 출력 |  popleft() | O(1) |
| 입력 | appendleft(value) | O(1) |



# deque 기본 사용법
입출력이 양방향 모두 지원하는 메소드가 존재하여, Queue, Stack을 모두 구현할 수 있습니다.

- append() : 배열뒤로 추가됨
- pop() : 오른쪽부터 출력
- popleft() : 왼쪽부터 출력
- len(q) : 수를 반환 if len(q)==0 : # Empty 조건 

```python

#리스트 타입
a = [1, 3, 5, 7, 10]
print(a.pop())
print(a.pop())
print(a)
#출력 pop은 뒤에서 부터 출력됨
10
7
[1, 3, 5]

# deque
from collections import deque

# deque([iterable, [maxlen])
q = deque()
q.append(1)
q.append(3)
q.append(5)
q.append(7)
print(q)
> deque([1, 3, 5, 7])

q.appendleft(0)
q.append(9)
print(q)

> deque([0, 1, 3, 5, 7, 9])

print(q.pop())
print(q.pop())
print(q)
print(q.popleft())

print(q.pop())
print(q.pop())
print(q)
print(q.popleft())

print(q.pop())
print(q.pop())
print(q)
print(q.popleft())
​
# pop() 오른쪽부터 출력됨
# popleft() 왼쪽부터 출력됨

> 9
> 7
> deque([0, 1, 3, 5])
> 0


q=deque(range(1,11))
for i in q:
    print(i, end=' , ')
print("len=", len(q))

> 1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9 , 10 , len= 10


q=deque(range(1,11))
print(q)
while q:
    print(q.pop(), end=' , ')
print("len=", len(q))

> deque([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
> 10 , 9 , 8 , 7 , 6 , 5 , 4 , 3 , 2 , 1 , len= 0

q=deque(range(1,11))
print(q)
while q:
    print(q.popleft(), end=' , ')
print("len=", len(q))

> deque([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
> 1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9 , 10 , len= 0

```

# deque - Stack FILO
```python

# Stack FILO
st = deque()
st.append(1)
st.append(2)
st.append(3)
st.append(4)
st.append(5)

## peek
print('peek :',st[-1])
print(st.pop())
print(st.pop())
print(st.pop())
print(st.pop())
print(st.pop())

#출력
> peek : 5
> 5
> 4
> 3
> 2
> 1
```


# deque - Queue FIFO
```python

# Queue FIFO
q = deque()
q.append(1)
q.append(2)
q.append(3)
q.append(4)
q.append(5)

## peek
print('peek :',q[0])
print(q.popleft())
print(q.popleft())
print(q.popleft())
print(q.popleft())
print(q.popleft())


#출력
> peek : 1
> 1
> 2
> 3
> 4
> 5
```