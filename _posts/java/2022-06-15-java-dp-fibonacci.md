---
title: "[Java] Fibonacci, DP" 
categories: 
    - algorithm
    - java
tags: [Fibonacci, DP, '다이나믹 프로그래밍', 'Dynamic Programming' ]
toc : true
toc_sticky  : true        
---

피보나치 수열을 만드는 함수를 만들어보기.   
`1, 1, 2, 3, 5, 8, 13, 21, 34, 55 `    
이전 2개의 값을 더해서 현재 값이 되는 패턴.    
`점화식: D[i] = D[i - 1] + D[i - 2]`   

- 재귀 호출에서 성능을 개선 할수 있는지?

## Sample Source Code
```java
public class Fibonacci{
	static double[] storedValue = new double[100];
	
	public static double dp(int x) {
		if( x == 1 || x == 2 ) return 1;

		//한번 구한 값을 저장하여 반환함
		if(storedValue[x] != 0 ) 
			return storedValue[x];
		
		//새로 구하는 수는 계산 후 재 사용을 위해서 저장해놓음
		storedValue[x] = dp(x-1) + dp(x-2);
		return storedValue[x];
	}
	
	
	public static void main(String[] args) {
		
		System.out.println(dp(50)); 
	}	
}
```
