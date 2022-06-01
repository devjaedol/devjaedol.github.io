---
title: "[Java] Input값 처리" 
categories: 
    - java
    - codingtest	
tags: [Input값, 백준, 코딩테스트, Scanner, BufferedReader ]
toc : true
toc_sticky  : true        
---

백준 사이트와 같은 온라인저지 사이트에서 Input 처리시 `Scanner`를 사용하는데, `BufferedReader`를 사용할때와 성능 차이가 나는 것으로 생각됩니다.    
특히 대량 데이트 Row 전달시 성능저하 현상이 발생하것으로 판단되네요. 

## Sample Source Code
```java

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.Scanner;
import java.util.StringTokenizer;

public class InputTest {

	static void inputType1() throws Exception{
		try {
			Scanner sc = new Scanner(System.in);
			
			int N = sc.nextInt();
			int M = sc.nextInt();
			System.out.format("N: %d M: %d \n",N,M);
			
			for(int i=0;i<M;i++) {
				
				int s = sc.nextInt();
				int e = sc.nextInt();
				//System.out.format("%d %d \n",s,e);
			}
			System.out.println("End");
			
		}catch(Exception e) {
			e.printStackTrace();
		}	
		
	}
	
	static void inputType2() throws Exception{
		try {
			BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
			StringTokenizer st = new StringTokenizer(br.readLine());
			
			int N = Integer.parseInt(st.nextToken());
			int M = Integer.parseInt(st.nextToken());
			
			System.out.format("N: %d M: %d \n",N,M);
			for(int i=0;i<M;i++) {
				st 	= new StringTokenizer(br.readLine());
				int s = Integer.parseInt(st.nextToken());
				int e = Integer.parseInt(st.nextToken());
				//System.out.format("%d %d \n",s,e);
			}
			System.out.println("End");
			
		}catch(Exception e) {
			e.printStackTrace();
		}	
	}
	
	
	public static void main(String[] args) {

		try {
			// inputType2();
			// inputType2();
			
		}catch(Exception e) {
			e.printStackTrace();
		}	
		
		
	}

}


/*

4 2
4 2
3 1

*/

```
