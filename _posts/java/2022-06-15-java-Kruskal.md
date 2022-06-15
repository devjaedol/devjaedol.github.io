---
title: "[Java] Kruskal, 최소 비용 신장 트리" 
categories: 
    - algorithm
    - java
tags: [Kruskal Algorithm, Union-Find, MST, Spannig Tree]
toc : true
toc_sticky  : true        
---

최소 비용으로 모든 노드를 연결하기 위해서 사용함.(최소 비용 신장 트리)   
두 노드의 거리를 오름차순으로 정렬하여, 노드 리스트를 순회하며, 최소 거리 노드를 연결함.    
연결시 사이틀이 발생되지 않는지를 점검함.   

- 연결된 선의 합이 최소 비용인가?

## MST(Minimum Spanning Tree) 
`MST`란 최소의 비용으로 모든 노드가 연결된 트리를 의미함.   
`Spanning Tree` 란 모든 노드가 연결된 트리를 의미함.    


최소 비용 신장 트리 검색 알고리즘
- 크루스칼 알고리즘(Kruskal) : 전체 간선 중 작은것 부터 연결(Union-Find사용)
- 프림 알고리즘 (Prim) : 현재 연결된 트리에 이어진 간선중 가장 작은것을 추가(Heap사용)    
Prim 관련 문제 최소 스패닝 트리 [백준 Q1197](https://www.acmicpc.net/problem/1197){:target="_blank"}    

## Sample Source Code
```java


import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.Vector;

public class KruskalAlgorithm {
	/**
	 * 재귀 호출로 최종 부모 번호를 반환
	 */
	public static int getParent(int[] parent, int x) {
		if(parent[x] == x ) return x;
		parent[x] = getParent(parent, parent[x]);		
		return parent[x];
	}

	/**
	 * 두 노드에서서 작은 부모의 값으로 병합함.
	 */
	public static void unionParent(int[] parent, int a, int b) {
		a = getParent(parent, a);
		b = getParent(parent, b);
		if( a < b) parent[b] = a;
		else parent[a] = b;
	}
	
	/**
	 * a, b가 같은 부모인지 확인
	 * 0 다른 부모, 1 같은 부모
	 */
	public static int findParent(int[] parent, int a, int b) {
		a = getParent(parent, a);
		b = getParent(parent, b);
		if( a == b) return 1;
		else return 0;
	}
	
	public static void main(String[] args) {
		
		//	간선을 거리가 짧은 순서대로 그래프에 포함
		//	사이클발생시 포함 시키지 않음
		// 	최소 비용 신장 트리
		int n = 7; // node수
		int m = 11; // 간선 수
		
		Vector<Edge> v = new Vector<Edge>();
		v.add(new Edge(1, 7, 12));
		v.add(new Edge(1, 4, 28));
		v.add(new Edge(1, 2, 67));
		v.add(new Edge(1, 5, 17));
		v.add(new Edge(2, 4, 24));
		v.add(new Edge(2, 5, 62));
		v.add(new Edge(3, 5, 20));
		v.add(new Edge(3, 6, 37));
		v.add(new Edge(4, 7, 13));
		v.add(new Edge(5, 6, 45));
		v.add(new Edge(5, 7, 73));
		
		
		System.out.println("==[정렬전]============");
		for(int i = 0;i<v.size();i++) {
			Edge e = v.get(i);
			System.out.println(e.distance);
		}
		
		
		System.out.println("==[정렬후]============");
		// 간선의 비용으로 오름차순 정렬 
		Collections.sort(v, new Comparator<Edge>() {
			@Override
			public int compare(Edge o1, Edge o2) {
				return (o1.distance - o2.distance);
			}
		});		
		for(int i = 0;i<v.size();i++) {
			Edge e = v.get(i);
			System.out.println(e.distance);
		}
		
		
		// 각 정점이 포함된 그래프가 어디인지 저장 (부모 초기화, 자기가 자신이 부모로 설정함)
		int[] set = new int[v.size()+1];
		for(int i = 1; i < v.size()+1 ; i++) {
			set[i] = i;
		}
		
		
		// 거리의 합을 0으로 초기화
		System.out.println("==[로직]============");
		int sum = 0;
		for(int i = 0; i < v.size(); i++ ) {
			// 동일한 부모를 가르키지 않는 경우(이미 연결됨)
			// 즉, 사이클이 발생하지 않을 때만 선택 
			
			System.out.format("%5d %5d (%5d)",v.get(i).node[0], v.get(i).node[1],  findParent(set, v.get(i).node[0], v.get(i).node[1]) );
			
			if( findParent(set, v.get(i).node[0], v.get(i).node[1]) == 0 ) { //다른 부모일 경우
				sum += v.get(i).distance; 
				unionParent(set, v.get(i).node[0], v.get(i).node[1]);
				
				System.out.format(" uinion %d-%d %s",v.get(i).node[0], v.get(i).node[1], Arrays.toString(set));
			}
			System.out.println("");
			
//			if( findParent(set, v.get(i).node[0], v.get(i).node[1]) == 0 ) {
//				sum += v.get(i).distance; 
//				unionParent(set, v.get(i).node[0], v.get(i).node[1]);
//			}
		}
		
		System.out.println("==[결과]============");
		System.out.format("%s \n",Arrays.toString(set));
		
		System.out.format("최소 비용 : %d \n", sum);
		for(int i = 0; i < v.size(); i++) {
			System.out.format("[%2d] Node : %d , Parent : %d \n",i , v.get(i).node[0], set[i]);
		}
		
		
	}
}

class Edge{
	public int[] node;
	public int distance;
	public Edge(int a, int b, int distance) {
		this.node = new int[2];
		this.node[0] = a;
		this.node[1] = b;
		this.distance = distance;
	}

	public int getDistance() {
		return this.distance;
	}
}

//출력
==[정렬전]============
12
28
67
17
24
62
20
37
13
45
73
==[정렬후]============
12
13
17
20
24
28
37
45
62
67
73
==[로직]============
    1     7 (    0) uinion 1-7 [0, 1, 2, 3, 4, 5, 6, 1, 8, 9, 10, 11]
    4     7 (    0) uinion 4-7 [0, 1, 2, 3, 1, 5, 6, 1, 8, 9, 10, 11]
    1     5 (    0) uinion 1-5 [0, 1, 2, 3, 1, 1, 6, 1, 8, 9, 10, 11]
    3     5 (    0) uinion 3-5 [0, 1, 2, 1, 1, 1, 6, 1, 8, 9, 10, 11]
    2     4 (    0) uinion 2-4 [0, 1, 1, 1, 1, 1, 6, 1, 8, 9, 10, 11]
    1     4 (    1)
    3     6 (    0) uinion 3-6 [0, 1, 1, 1, 1, 1, 1, 1, 8, 9, 10, 11]
    5     6 (    1)
    2     5 (    1)
    1     2 (    1)
    5     7 (    1)
==[결과]============
[0, 1, 1, 1, 1, 1, 1, 1, 8, 9, 10, 11] 
최소 비용 : 123 
[ 0] Node : 1 , Parent : 0 
[ 1] Node : 4 , Parent : 1 
[ 2] Node : 1 , Parent : 1 
[ 3] Node : 3 , Parent : 1 
[ 4] Node : 2 , Parent : 1 
[ 5] Node : 1 , Parent : 1 
[ 6] Node : 3 , Parent : 1 
[ 7] Node : 5 , Parent : 1 
[ 8] Node : 2 , Parent : 8 
[ 9] Node : 1 , Parent : 9 
[10] Node : 5 , Parent : 10 


```
[참고 문헌 : 안경잡개발자 블로그](https://blog.naver.com/ndb796/221230994142){:target="_blank"}
