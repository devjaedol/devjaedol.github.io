---
title: "[Java] 위상정렬, 줄세우기, Topology Sort" 
categories: 
    - algorithm
    - java
tags: [Topology, 위상정렬, 줄세우기, 백준2252, 백준1516, 백준1948 ]
toc : true
toc_sticky  : true        
---

데이터의 주어진 조건만으로 특정 순서를 정렬시키는 문제들에서 사용되는 알고리즘.    
예를 들면 다음 조건이 제공될때, 주어진 조건을 조합하여 조건을 만들어 보면,    

- 줄을 세워서 정렬이 가능한지? 불가능한지?
- 가능하면 정렬을 하는 미션

[백준 2252](https://www.acmicpc.net/problem/2252){:target="_blank"}

Queue 를 사용하여 정렬하며, 정렬하는 방법    
![Topology순서](\assets/images_post/java/topology_sort_01.png)

![topology]
## Sample Source Code
```java
public class TopologySort {

	static int max = 10;
	static int n = max;
	
	static int[] inputline = new int[max+1]; // 진입하는 선의 수를 만듬
	static ArrayList<Integer>[] arr = new ArrayList[max+1];
	
	public static void topologySort() {
		
		int[] result = new int[max+1];
		
		Queue<Integer> q = new LinkedList();
		
		// 나를 향하는 input 선이 0개인 노드를 큐에 삽입합니다. 
		for(int i = 1; i <= n; i++) {
			if(inputline[i] == 0)
				q.add(i);
		}
		
		// 정렬이 완전히 수행되려면 정확히 n개의 노드를 방문합니다.		
		for(int i = 1; i <= n; i++) {
			// n개를 방문하기 전에 큐가 비어버리면 사이클이 발생한 상황
			if( q.isEmpty() ) {
				System.out.println("사이클이 발생");
				return;
			}
			
			int x = q.poll().intValue();

			result[i] = x;
			
			for(int j = 0; j < arr[x].size(); j++) {
				
				int y = arr[x].get(j).intValue();

				// 나를 향하는 input 선을 제거하고 남은 수량이 0이 된 정점을 큐에 삽입합니다. 
				if(--inputline[y] == 0)
					q.add(y);
			}
			
		}//end for
		for(int i = 1; i <= n; i++) {
			System.out.format("%d ", result[i]);
		}
	}
	
	public static void main(String[] args) {
		
		n = 5;
		for(int i = 1; i <= n; i++) {
			//arr 초기화
			arr[i] = new ArrayList();
		}
		
		arr[1].add(2);		inputline[2]++;
		arr[1].add(4);		inputline[4]++;
		arr[1].add(5);		inputline[5]++;

		arr[2].add(3);		inputline[3]++;
		arr[2].add(4);		inputline[4]++;
	
		arr[3].add(5);		inputline[5]++;
		
		topologySort();
		
	}

}

//출력
//arr[2].add(3);		inputline[3]++;
//arr[2].add(4);		inputline[4]++;
1 2 3 4 5 

//출력(순서를 변경하여 등록할 경우)
//arr[2].add(4);		inputline[4]++;
//arr[2].add(3);		inputline[3]++;
1 2 4 3 5 

```

[참고 문헌 : 안경잡개발자 블로그](https://blog.naver.com/ndb796/221236874984){:target="_blank"}
