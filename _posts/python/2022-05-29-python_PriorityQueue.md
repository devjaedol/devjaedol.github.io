---
title: Python - PriorityQueue, Heapq
categories: 
    - python
tags: 
    - PriorityQueue
    - queue
    - FIFO
    - 우선순위큐
    - 자료구조
    - Heapq 
toc : true
toc_sticky  : true    
---

FIFO에서 우선순위 가중치를 주어 출력시키는 자료 구조 입니다.   
Java에서도 동일한 형태의 자료 구조가 존재 합니다.   

# PriorityQueue 사용예
```python

from queue import PriorityQueue
pq = PriorityQueue()        
#pq = PriorityQueue(maxsie=10)   #초기; 사이즈 정의 가능함.

pq.put(9)
pq.put(2)
pq.put(4)
pq.put(7)
pq.put(1)
pq.put(6)

while pq.empty() == False :
    print(pq.get())

#출력
1
2
4
6
7
9
```

# Tuble 을 통한 정렬 순서 변경
`(우선순위, 값)` 의 튜플 형태로, 우선순위를 튜플의 첫번째로 입력처리하 하면 됩니다.

```python
from queue import PriorityQueue
pq = PriorityQueue()        

pq.put((9,'이승환'))
pq.put((2,'이미자'))
pq.put((4,'조용필'))
pq.put((7,'아이유'))
pq.put((1,'배철수'))
pq.put((6,'이승철'))

while pq.empty() == False :
    print(pq.get()[0], pq.get()[1])

#출력
(1, '배철수')
(2, '이미자')
(4, '조용필')
(6, '이승철')
(7, '아이유')
(9, '이승환')

```

# 리스트를 통한 정렬 사용예
```python
# 리스트 을 통한 정렬 순서 변경

arr = []
arr.append((1, "배철수"))
arr.append((4, "이미자"))
arr.append((3, "조용필"))
arr.append((2, "아이유"))
arr.append((9, "이승환"))

arr.sort(reverse = True)

while arr:
    print(arr.pop())

#출력
(1, '배철수')
(2, '아이유')
(3, '조용필')
(4, '이미자')
(9, '이승환')
```

```python
# 리스트 을 통한 정렬 순서 변경

arr = []
arr.append((1, "배철수"))
arr.append((4, "이미자"))
arr.append((3, "조용필"))
arr.append((2, "아이유"))
arr.append((9, "이승환"))

arr.sort(reverse = False)

while arr:
    print(arr.pop())

#출력
(9, '이승환')
(4, '이미자')
(3, '조용필')
(2, '아이유')
(1, '배철수')
```

# Heapq 
힙에 대해서 알아야 알아야 되는데 완전 이진트리로 최상위 부모를 최대값(max heap), 최소값(min heap) 형태로 구성하는 자료 구조 형태를 사용한다.

주요 사용 메소드는
- heapq.heappush(heap, item): item 추가
- heapq.heappop(heap): heap에서 최소값 pop return
- heapq.heapify(x): 리스트 x를 즉각적으로 heap으로 변환

```python
import heapq

pq = []

heapq.heappush(pq, 1)
heapq.heappush(pq, 4)
heapq.heappush(pq, 3)
heapq.heappush(pq, 2)
heapq.heappush(pq, 9)

print(pq)
#출력
> [1, 2, 3, 4, 9]

print(pq.)
```

사전 list를 통해서 정렬하는 방식 `heapify`   
```python
import heapq
d = [1,4,3,2,9]
heapq.heapify(d)

print(d)
#출력
> [1, 2, 3, 4, 9]

while pq:
    print(pq.pop())

#출력
9
4
3
2
1

```

