---
title: "[Java] Union-Find, 두개의 노드 연결 여부 확인" 
categories: 
    - algorithm
    - java
tags: [Union-Find, 합집합, 소로소 ]
toc : true
toc_sticky  : true        
---

여러개의 노드에서 임의의 두개의 노드가 연결되어 있는지를 판단할때 사용합니다.     

- 서로 연결되어 있는지?    

## Sample Source Code
```java
import java.util.Arrays;

public class UnionFind {

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
		//더 작은 값으로 부모를 통일함.
		if( a < b) parent[b] = a;
		else parent[a] = b;
		
		System.out.format("%d-%d  : %s \n", a, b, Arrays.toString(parent));
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
		int[] parent = new int[11];
		
		for(int i=1; i < parent.length;i++) {
			parent[i] = i;
		}
		
		System.out.format("Init : %s \n",Arrays.toString(parent));
		
		unionParent(parent, 1, 2); //1-2  연결 의미
		unionParent(parent, 2, 3);
		unionParent(parent, 3, 4);
		unionParent(parent, 5, 6);
		unionParent(parent, 6, 7);
		unionParent(parent, 7, 8);
		
		System.out.println("");
		System.out.format("1과 5는 연결 여부 확인? %d\n", findParent(parent, 1, 5));
		unionParent(parent, 1, 5);
		System.out.format("1과 5는 연결 여부 확인? %d\n", findParent(parent, 1, 5));
		
	}

}
//출력
Init : [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10] 
1-2  : [0, 1, 1, 3, 4, 5, 6, 7, 8, 9, 10] 
1-3  : [0, 1, 1, 1, 4, 5, 6, 7, 8, 9, 10] 
1-4  : [0, 1, 1, 1, 1, 5, 6, 7, 8, 9, 10] 
5-6  : [0, 1, 1, 1, 1, 5, 5, 7, 8, 9, 10] 
5-7  : [0, 1, 1, 1, 1, 5, 5, 5, 8, 9, 10] 
5-8  : [0, 1, 1, 1, 1, 5, 5, 5, 5, 9, 10] 

1과 5는 연결 여부 확인? 0
1-5  : [0, 1, 1, 1, 1, 1, 5, 5, 5, 9, 10] 
1과 5는 연결 여부 확인? 1


```

[참고 문헌 : 안경잡개발자 블로그](https://blog.naver.com/ndb796/221230967614){:target="_blank"}
