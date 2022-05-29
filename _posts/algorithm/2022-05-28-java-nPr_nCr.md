---
title: "[Java] 순열과 조합"
categories: 
    - algorithm
    - java
tags: 
    [nPr, nCr, 순열, 조합, Permutation. Combination]
toc : true
toc_sticky  : true    
---

# 순열 Permutation ( nPr )
순열이란 서로 다른 n개중에 r개를 선택하는 경우의 수(순서 상관 있음) = `n! / (n-r)!`     
[백준 순열문제](https://www.acmicpc.net/problem/15649){:target="_blank"}

# 조합 Combination ( nCr ) 	
조합이란 서로 다른 n개중에 r개를 선택하는 경우의 수(순서 상관 없음) = `n! / ((n-r)! * r!)`    
[백준 조합문제](https://www.acmicpc.net/problem/2407){:target="_blank"}


# 소스 코드

```java
package testcase;
import java.util.Arrays;
public class CP {
	
	//순열
	void p ( int[] arr, int[] out, int[] ck, int d, int n, int r) {
		
		if( d == r){
			for(int i=0;i<r;i++) {						// r 만큼
				System.out.format("%d ",out[i]);		//출력 out
			}
			System.out.format("\n");
			return;
		}
		
		for(int i=0;i<arr.length;i++) {			
			if( ck[i] == 0 ) {
				ck[i] = 1;
				
				out[d] = arr[i];						// 중요
				p ( arr, out, ck, d+1, n, r);			// d+1
				
				ck[i] = 0;
			}
		}// end for
		
	}
	
	//조합
	void c ( int[] arr,  int[] ck, int d, int n, int r) {

		if(r == 0) {
			for(int i=0 ; i<n ; i++) {  					// 시작 i < n
				if(ck[i]==1) {
					System.out.format("%d ",arr[i]);		//출력 arr
				}
			}
			System.out.format("\n");
			return;
		}
		
		for(int i = d ;i < arr.length;i++) {  				// 중요 시작점 d
			ck[i] = 1;
			
			c(arr,  ck, i+1 , n , r-1 ); 					// i+1 ,  , r-1 
			
			ck[i] = 0;
		}
		
	}
	
	public static void main(String[] args) {
		int[] arr 	= new int[] {1,2,3,4,5};
		int [] ck 	= new int[arr.length];
		int [] out 	= new int[arr.length];

		CP obj	= new CP();
		//obj.p(arr, out, ck, 0, arr.length, 5);
		
		obj.c(arr,  ck, 0, arr.length, 3);
	}

}

// 출력  obj.p(arr, out, ck, 0, arr.length, 5);
1 2 3 4 5 
1 2 3 5 4 
1 2 4 3 5 
1 2 4 5 3 
1 2 5 3 4 
1 2 5 4 3 
1 3 2 4 5 
1 3 2 5 4 
1 3 4 2 5 
1 3 4 5 2 
1 3 5 2 4 
1 3 5 4 2 
1 4 2 3 5 
1 4 2 5 3 
1 4 3 2 5 
1 4 3 5 2 
1 4 5 2 3 
1 4 5 3 2 
1 5 2 3 4 
1 5 2 4 3 
1 5 3 2 4 
1 5 3 4 2 
1 5 4 2 3 
1 5 4 3 2 
2 1 3 4 5 
2 1 3 5 4 
2 1 4 3 5 
2 1 4 5 3 
2 1 5 3 4 
2 1 5 4 3 
2 3 1 4 5 
2 3 1 5 4 
2 3 4 1 5 
2 3 4 5 1 
2 3 5 1 4 
2 3 5 4 1 
2 4 1 3 5 
2 4 1 5 3 
2 4 3 1 5 
2 4 3 5 1 
2 4 5 1 3 
2 4 5 3 1 
2 5 1 3 4 
2 5 1 4 3 
2 5 3 1 4 
2 5 3 4 1 
2 5 4 1 3 
2 5 4 3 1 
3 1 2 4 5 
3 1 2 5 4 
3 1 4 2 5 
3 1 4 5 2 
3 1 5 2 4 
3 1 5 4 2 
3 2 1 4 5 
3 2 1 5 4 
3 2 4 1 5 
3 2 4 5 1 
3 2 5 1 4 
3 2 5 4 1 
3 4 1 2 5 
3 4 1 5 2 
3 4 2 1 5 
3 4 2 5 1 
3 4 5 1 2 
3 4 5 2 1 
3 5 1 2 4 
3 5 1 4 2 
3 5 2 1 4 
3 5 2 4 1 
3 5 4 1 2 
3 5 4 2 1 
4 1 2 3 5 
4 1 2 5 3 
4 1 3 2 5 
4 1 3 5 2 
4 1 5 2 3 
4 1 5 3 2 
4 2 1 3 5 
4 2 1 5 3 
4 2 3 1 5 
4 2 3 5 1 
4 2 5 1 3 
4 2 5 3 1 
4 3 1 2 5 
4 3 1 5 2 
4 3 2 1 5 
4 3 2 5 1 
4 3 5 1 2 
4 3 5 2 1 
4 5 1 2 3 
4 5 1 3 2 
4 5 2 1 3 
4 5 2 3 1 
4 5 3 1 2 
4 5 3 2 1 
5 1 2 3 4 
5 1 2 4 3 
5 1 3 2 4 
5 1 3 4 2 
5 1 4 2 3 
5 1 4 3 2 
5 2 1 3 4 
5 2 1 4 3 
5 2 3 1 4 
5 2 3 4 1 
5 2 4 1 3 
5 2 4 3 1 
5 3 1 2 4 
5 3 1 4 2 
5 3 2 1 4 
5 3 2 4 1 
5 3 4 1 2 
5 3 4 2 1 
5 4 1 2 3 
5 4 1 3 2 
5 4 2 1 3 
5 4 2 3 1 
5 4 3 1 2 
5 4 3 2 1 


// 출력 obj.c(arr,  ck, 0, arr.length, 3);
1 2 3 
1 2 4 
1 2 5 
1 3 4 
1 3 5 
1 4 5 
2 3 4 
2 3 5 
2 4 5 
3 4 5 


```
