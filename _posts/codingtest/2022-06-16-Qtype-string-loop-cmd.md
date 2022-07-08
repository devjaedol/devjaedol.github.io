---
title: "[문제 유형 분석]문자열 구문 분석을 통한 반복 출력 문제" 
categories: 
    - codingtest
tags: [문자열 구문 분석, 반복 출력, 재귀함수]
toc : true
toc_sticky  : true        
---

# 문제 조건
- `()` 묶여진 구문에서 첫번째 숫자 (0~9)까지의 숫자 만큼 `()`로 묶여진 글자를 출력해라.    
- `()` 는 여러 단계로 묶일수 있다. `(()())`
- 가장 밖에는 하나의 `()`로 묶여있다.

예)    
`(4k)` -> `kkkk`     
`(3a(2b)c)` -> `abbcabbcabbc`     

# 접근 방법
1. 문제의 입력 조건 문자열을 char 로 분리함.
1. 위치 변수를 `_p` 초기화 하여, 문자열을 처음부터 순회함
1. 순회중 '('를 만나면 다시 시작의 의미 이므로 재귀호출을 진행

위치값을 재귀 함수에 전달하여 유지하며 검색하는 것이 착안점

```java

char[] loop;
loop = sc.next().toCharArray();	// `(3a(2b)c)` 

exec( loop, 0);


int exec(char[] loop, int idx){

	int _p = idx; //

			int cnt = loop[_p + 1] - '0'; //반복 횟수 찾기
			
			while( cnt-- > 0 ){ 	// 반복 횟수를 줄여가며, 반복 조건을 찾음
				_p = idx + 2;		// 검색 포인터를 +2 ( `(` + `숫자` 2자리 의미 ) 자리 만큼 이동
				while( loop[_p] != ')' ){ // 종료 전까지
					if( loop[_p] == '(<)' ){
						_p = solve(loop,_p);	//다시 `(` 시작 조건이 나온다면 재귀 호출
					}else{
						System.out.print(loop[_p]); //출력
					}
					_p++; // 위치를 한칸씩 이동시키며 문자를 출력하는 일을 함
				}
				
			}// while				
	return _p;
}
```
