---
title: NodeJS 기초 정리 - 모듈화
categories: 
    - nodejs
tags: 
    - nodejs
    - CommonJS (CJS)
    - ES Module (ESM)
toc : true    
toc_sticky  : true        
---
## JavaScript 모듈 시스템 비교: CommonJS vs ES Module
JavaScript의 모듈 시스템은 코드를 독립적인 단위로 나누어 관리하고 재사용하기 위해 사용됩니다.     
가장 대표적인 두 가지 방식인 **CommonJS(CJS)**와 **ES Module(ESM)**을 사칙연산 예제를 통해 비교합니다.    


| 구분 | CommonJS (CJS) | ES Module (ESM) |
| :--- | :--- | :--- |
| **표준 여부** | Node.js 독자 표준 (Legacy) | JavaScript 공식 표준 (Modern) |
| **키워드** | `require()` / `module.exports` | `import` / `export` |
| **로딩 방식** | **동기(Synchronous)** 로딩 | **비동기(Asynchronous)** 로딩 |
| **분석 시점** | 실행 시점 (Runtime) | 빌드 및 해석 시점 (Static) |
| **트리 쉐이킹** | 지원이 어려움 (정적 분석 불가) | **강력 지원** (최적화 성능 우수) |
| **파일 확장자** | 기본적으로 `.js` 사용 | `.mjs` 또는 `package.json` 내 `"type": "module"` 설정 |
| **주요 환경** | 서버 사이드 (Node.js) | 브라우저 및 현대적 JS 프로젝트 |

**결론:** 현대적인 웹 개발이나 성능 최적화가 중요한 대규모 프로젝트에서는 정적 분석이 가능하고 표준을 따르는 **ES Module** 사용이 권장됩니다.


## 1. CommonJS (CJS)
Node.js의 기본 모듈 시스템으로 오랫동안 사용되어 왔습니다.

### 특징
* **키워드:** `require`, `module.exports`
* **로딩 방식:** 동기적(Synchronous) 로딩
* **실행 시점:** 런타임에 모듈을 평가하고 로드합니다.

### ➕ 사칙연산 예시

```javascript
// math.js (모듈 생성)
const add = (a, b) => a + b;
const subtract = (a, b) => a - b;

// 객체 형태로 내보내기
module.exports = {
  add,
  subtract
};

// main .js
const math = require('./math.js');

console.log('더하기:', math.add(10, 5));      // 15
console.log('빼기:', math.subtract(10, 5));  // 5

```

### 함수 분리   
exports.함수명 = 함수   

```javascript
# fn.js
exports.함수명1 = function(){
#....
}
exports.함수명2 = function(){
#....
}
exports.함수명3 = {id:123, name:'홍길동'};

# main.js
var module = reqire("./fn")
module.함수명1();
module.함수명2();
var obj = module.함수명3();
console.log(obj.id);
console.log(obj.name);

```

### 객체 분리(1)
module.exports = 객체   
```javascript

# obj.js
var obj = {};
obj.fn1 = function(){
#....
};

obj.fn2 = function(){
#....
};
module.exports = obj; #객체를 할당함

# main.js
var obj = reqire("./obj")
obj.fn1();
obj.fn2();

```

### 객체 분리(2)
module.exports = 함수   

```javascript
# obj.js
var obj = function(){
    return {id:123, name:'홍길동'};
};

module.exports = obj; #함수를 할당함

# main.js
var obj = reqire("./obj")
obj().id;
obj().name;
```



## 2. ES Module (ESM)
ECMAScript(JS 표준)에서 정의한 공식 표준 모듈 시스템입니다.    
* 키워드: import, export
* 로딩 방식: 비동기적(Asynchronous) 로딩
* 실행 시점: 빌드 및 해석 시점에 정적으로 의존성을 분석합니다 (Tree Shaking에 유리).


```javascript
//math.js (모듈 생성)
// 개별 함수 내보내기 (Named Export)
export const multiply = (a, b) => a * b;
export const divide = (a, b) => a / b;
export const add = (a, b) => a + b;

// 기본값으로 내보내기 (Default Export - 선택 사항)
export default { multiply, divide };


// main.js (모듈 호출)
// Named Export를 구조 분해 할당으로 호출
import { multiply, divide } from './math.js'; //주의 .js 까지 모두 붙여야함.

console.log('곱하기:', multiply(10, 5)); // 50
console.log('나누기:', divide(10, 5));   // 2
```



```javascript
//math.js (모듈 생성)
// 개별 함수 내보내기 (Named Export)
export const multiply = (a, b) => a * b;
export const divide = (a, b) => a / b;
export const add = (a, b) => a + b;

// 기본값으로 내보내기 (Default Export - 선택 사항)
export default multiply;


// main.js (모듈 호출)
// Named Export를 구조 분해 할당으로 호출
import mp,{ divide, add } from './math.js'; //주의 .js 까지 모두 붙여야함.
//export default 로 출력한 모듈은 사용시 이름 변경이 가능함

console.log('곱하기:', multiply(10, 5)); // 50
console.log('나누기:', divide(10, 5));   // 2
```


