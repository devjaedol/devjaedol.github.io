---
title: "[백준 1948]임계경로, Topology Sort" 
categories: 
    - baekjoon
    - java
tags: [Topology, 위상정렬, 줄세우기, 임계 경로, Q1948, 백준2252 , 백준1516, 백준1948 ]
toc : true
toc_sticky  : true        
---

토플로지 관련 줄세우기 문제.     
원리 알고리즘은 알고리즘 내용 참조.    

임계경로를 구하는 문제로, 임계 경로란 A에서 B지점 까지 가는 최대 소요 시간이 걸리는 경로를 임계경로라고 한다.(최대값이 소모되는 길)     

[백준 Q1948](https://www.acmicpc.net/problem/1948){:target="_blank"}


## Sample Source Code
```java

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.Queue;
import java.util.StringTokenizer;

public class Main {

	public static void main(String[] args) {
		try {
			BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
			StringTokenizer st = new StringTokenizer(br.readLine());
			
			int N = Integer.parseInt(st.nextToken());
			int M = Integer.parseInt(st.nextToken());
			
			int[] line 		= new int[N+1];
			Queue<Integer> q= new LinkedList();
			ArrayList<Integer>[] al	= new ArrayList[N+1];
			for(int i=0;i<=N;i++)
				al[i] = new ArrayList();
			
			//System.out.format("N: %d M: %d \n",N,M);
			for(int i=0;i<M;i++) {
				st 	= new StringTokenizer(br.readLine());
				int s = Integer.parseInt(st.nextToken());
				int e = Integer.parseInt(st.nextToken());
				//System.out.format("%d %d \n",s,e);
				al[s].add(e);
				line[e]++; 
			}
			
			//line 이 0인 item을 q에 넣는다.
			for(int i=1;i<=N;i++) {
				if(line[i]==0) {
					q.add(i);
				}
			}
			
			while(!q.isEmpty()){
				int t = q.poll().intValue();
				
				//연결 선을 빼면서 line을 제거, 제거후에 0인경우 q에 입력
				for(int i=0; i < al[t].size() ; i++ ) {
					int sub = al[t].get(i).intValue();
					if(--line[sub] == 0 ){
						q.add(sub);
					}
				}				
				System.out.format("%d ", t);
			}
			
			//System.out.println(Arrays.toString(line));
			//System.out.println("End");
			
			
		}catch(Exception e) {
			e.printStackTrace();
		}	
	
	
	}
}

/*
입력
4 2
4 2
3 1

출력
3 4 1 2 

*/

```
