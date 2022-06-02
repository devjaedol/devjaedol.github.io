---
title: "[백준 1516]게임 개발, Topology Sort" 
categories: 
    - baekjoon
    - java
tags: [Topology, 위상정렬, 줄세우기, Q1516, 백준1516 , 백준1516, 백준1948 ]
toc : true
toc_sticky  : true        
---

토플로지 관련 누적 비용 최대값 계산.         
원리 알고리즘은 알고리즘 내용 참조.    

[백준 Q1516](https://www.acmicpc.net/problem/1516){:target="_blank"}


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
			
			// N(1 ≤ N ≤ 500)
			int N = Integer.parseInt(st.nextToken());	//line수 
			
			
			
			ArrayList<Integer>[] al	= new ArrayList[N+1]; //(연결 건물) 
			for(int i=0;i<=N;i++) {
				al[i] = new ArrayList();
			}
			
			int[] result	= new int[N+1];	// 위상순서를 저장하기
			
			int[] time		= new int[N+1]; //누적 해당 건물을 짓는 시간
			int[] time_sum	= new int[N+1]; //누적 해당 건물을 짓는 시간
			int[] line		= new int[N+1]; //나를 의존하는 line
			Queue<Integer> q= new LinkedList();
		
			for(int i=1;i<=N;i++) {
				st 			= new StringTokenizer(br.readLine());
				
				int t 		= Integer.parseInt(st.nextToken());	
				time[i]		= t;
				
				//필요 건물이 여러개 나올수 있음.				
				for(;;) {
					int s 		= Integer.parseInt(st.nextToken());
					if(s == -1) {
						break;
					}else {
						al[s].add(i);
						line[i]++;
					}					
				}				
				//System.out.format("%d %d \n",s,e);
			}
			
			for(int i=1;i<=N;i++) {
				if(line[i]==0) {
					q.add(i);	
					time_sum[i] = time[i];
				}
			}
			
			
			
			//System.out.println("L : "+Arrays.toString(line));
			
			int x = 0;
			while(! q.isEmpty() ){
				int parent = q.poll().intValue();
				result[x++] = parent;
				
				for(int i=0;i<al[parent].size();i++) {
					int child = al[parent].get(i).intValue();

					time_sum[child] = Math.max(time_sum[child], time_sum[parent] + time[child]);
					
					if(--line[child]==0) {
						q.add(child);
					}
				}
				//total을 Sum처리함.
				//System.out.format("%d ->", parent);
			}

			//순서
//			for(int i=0;i<result.length-1;i++) {
//				System.out.format("%d ->", result[i]);				
//			}
//			System.out.println("");
//			
//			System.out.println("Line : "+Arrays.toString(line));
//			System.out.println("Time : "+Arrays.toString(time));
//			System.out.println("TimeS : "+Arrays.toString(time_sum));

			for(int i=1;i<time_sum.length;i++) {
				System.out.format("%d\n", time_sum[i]);				
			}
			//System.out.println("End");
			
		}catch(Exception e) {
			e.printStackTrace();
		}
	
	
	}
}

/*
입력
5
10 -1
10 1 -1
4 1 -1
4 3 1 -1
3 3 -1

출력
10
20
14
18
17

*/

```
