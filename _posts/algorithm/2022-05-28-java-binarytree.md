---
title: "[JAVA] 이진 트리"
categories: 
    - algorithm
    - java
tags: 
    [트리, Tree, 이진트리, BinaryTree]
toc : true
toc_sticky  : true    
---

# 이진트리
접근 순회 방식에 따라서 아래와 같이 나뉨.
## 전위 순회(Preorder Traversal)
(부) - L - R
## 중위 순회(Inorder Traversal)
L - (부) - R
## 후위 순회(Postorder Traversal)
L - R - (부)


# 소스 코드

```java
package tree;

public class BinaryTree {
	
	public Node root;
	
	public void setRoot(Node n) {
		this.root = n;
	}
	public Node getRoot() {
		return root;
	}
	public Node makeNode(Node left, int data, Node right) {
		Node n = new Node();
		n.data = data;
		n.left = left;
		n.right = right;
		return n;
	}
	
	
	//① 전위 순회(Preorder Traversal)	(부) - L - R
	public void preOrder(Node n) {
		if(n != null ) {
			System.out.format(" %d ", n.data);
			preOrder(n.left);
			preOrder(n.right);			
		}
	}	
	//② 중위 순회(Inorder Traversal)		L - (부) - R
	public void inOrder(Node n) {
		if(n != null ) {
			inOrder(n.left);
			System.out.format(" %d ", n.data);
			inOrder(n.right);			
		}
	}
	//③ 후위 순회(Postorder Traversal)	L - R - (부)
	public void postOrder(Node n) {
		if(n != null ) {
			postOrder(n.left);
			postOrder(n.right);			
			System.out.format(" %d ", n.data);
		}
	}
	
	public static void main(String[] args) {
	/*
	① 전위 순회(Preorder Traversal)	(부) - L - R
	② 중위 순회(Inorder Traversal)		L - (부) - R
	③ 후위 순회(Postorder Traversal)	L - R - (부)
	 	1
	   /  \
	  2   3
	 / \
	4   5
	
	 */
		BinaryTree t = new BinaryTree();
		Node n4 = t.makeNode(null, 4, null);
		Node n5 = t.makeNode(null, 5, null);
		Node n2 = t.makeNode(n4, 2, n5);
		Node n3 = t.makeNode(null, 3, null);
		Node n1 = t.makeNode(n2, 1, n3);
		
		t.setRoot(n1);
		System.out.println("inOrder:");
		t.inOrder(t.getRoot()); //4  2  5  1  3 
		System.out.println("");
		
		System.out.println("preOrder:");
		t.preOrder(t.getRoot()); // 1  2  4  5  3 
		System.out.println("");
		
		System.out.println("postOrder:");
		t.postOrder(t.getRoot()); // 4  5  2  3  1 
		System.out.println("");
		
	}
}

class Node{
	int data;
	Node left;
	Node right;
	
}



// 출력 obj.c(arr,  ck, 0, arr.length, 3);
inOrder:
 4  2  5  1  3 
preOrder:
 1  2  4  5  3 
postOrder:
 4  5  2  3  1 


```
