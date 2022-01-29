---
title: NodeJS 기초 정리 - 모듈화
categories: 
    - nodejs
tags: 
    - nodejs
toc : true    
toc_sticky  : true        
---

## 모듈 분리 방법
별도 파일을 분리하여 모듈화 함   

### 함수 분리   
exports.함수명 = 함수   

```javascript
# main.js
var module = reqire("./fn")
module.함수명1();
module.함수명2();
var obj = module.함수명3();
console.log(obj.id);
console.log(obj.name);

# fn.js
exports.함수명1 = function(){
#....
}
exports.함수명2 = function(){
#....
}
exports.함수명3 = {id:123, name:'홍길동'};
```

### 객체 분리(1)
module.exports = 객체   


```javascript
# main.js
var obj = reqire("./obj")
obj.fn1();
obj.fn2();


# obj.js
var obj = {};
obj.fn1 = function(){
#....
};

obj.fn2 = function(){
#....
};
module.exports = obj; #객체를 할당함
```

### 객체 분리(2)
module.exports = 함수   


```javascript
# main.js
var obj = reqire("./obj")
obj().id;
obj().name;


# obj.js
var obj = function(){
    return {id:123, name:'홍길동'};
};

module.exports = obj; #함수를 할당함
```






   