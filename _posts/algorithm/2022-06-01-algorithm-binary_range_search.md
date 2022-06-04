---
title: "[Java][Python] 범위 줄이기"
categories: 
    - algorithm
    - codingtest
tags: 
    [Binary, "슬라이딩 윈도우"]
toc : true
toc_sticky  : true    
---

이진 검색 알고리즘 (Binary search algorithm)또는 슬라이딩 윈도우 방법을 활용하여, 시작과 끝 범위를 좁히는 알고리즘 입니다.    
다음은 중간 값을 비교해서 이상, 이하로 검색 범위를 좁히는 방식(이진 검색)에서 착한한 문제 풀이 패턴 입니다.     


# 범위 검색 패턴
시작 범위, 종료 범위 중 조건을 검사하여 좁히는 문제에 사용하는 방식,
이중 For문 출제 문제에서 O(N^2) 을 O(N) 수준으로 복잡도를 졸이기 위해서 사용됩니다.

```java
int s = 0;
int e = 10000; // 종료 지점

int m = -1; 

while ( s <= e ){
    m = (s+2)/2; // 중간 값
    if( check_function(m) ){
        s = m+1;
    }else{
        e = m-1;
    }
}

// check_function 
//s 값을 조정할지, e 값을 조정할지 판단하는 함수를 구현
```

```python
s = 0
e = 10000

while  s <= e :
    m = (s+2)//2; 
    if check_function(m):
        s = m+1
    else
        e = m-1
    
# check_function 
#s 값을 조정할지, e 값을 조정할지 판단하는 함수를 구현
```

