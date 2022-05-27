---
title: "[AWS S3] Simple Storage Service 서비스 사용"
categories: 
    - cloud
tags: 
    - AWS
    - Simple Storage Service
    - S3
    - File
    - S3 Static Hosting
toc : true
toc_sticky  : true    
---

# S3란 (Simple Storage Service)
Cloud내 File를 저장하기 위해서 사용함.    
특징  
- 99.999999999% 내구성
- 객체 스토리지 서비스
    - 반대 서비스, Block Storage Serivce (EBS, EFS등)
- 무제한 확장 가능
    - 객체 한개는 (0byte~5TB 이내 조건)
- Static web 서비스 기능 제공
    - 서비스 도메인과 Buket명과 같음
- 암호화 및 보안 적용 지원
    - SSE S3(S3서비스가 알아서 암호화)
    - SSE KMS(KMS 서비스를 토해서 암호화)
    - SSE C (클라이언트가 제공한 암호 방식 사용)
- Bucket 단위로 사용
    - Buket이름은 Unique함

# S3 구성
- key : 파일이름
- Value : 파일데이터
- Version id : 파일 버전
- ACL :  : 접근 권한
- Metadata :  파일 메타 정보

# S3의 정적 호스팅 주소 형태
주소 구조
- https://Bucket이름.s3.리전명.amazoneaws.com/키이름
- https://s3.리전명.amazoneaws.com/Bucket이름/키이름

# S3 - Glacier
- 아카이브용 저장소
- 가격이 저렴함
- 데이터 가져오는데 시간이 소요됨.

# S3 보안
정책 적용 설정   
![bucket 생성](/assets/images_post/cloud/aws_s3/aws_s3_12.png)
[AWS Policy Generator](https://awspolicygen.s3.amazonaws.com/policygen.html){:target="_blank"}    
[AWS Policy Sample](https://docs.aws.amazon.com/AmazonS3/latest/userguide/example-bucket-policies.html){:target="_blank"}

## Bucket policy
- Bucket 단위로 정책이 적용됨
- Version 문법의 작성 버전 ( 2008-10-17 or 2012-10-17 )
- Id : 아이디
- Statement
    - Sid : 구별을 위한 아이디
    - Effect : 허가 여부 Allow or Deny
    - Principal : 권한의 이용을 위한 Target을 선택함
    - Action : 사용할 권한에 대한 동작
    - Resource : 동작에 대상이 되는 리소스
    - Condition : 동작에 대한 조건을 설정

## ACL(Access Control List)
- 파일 단위로 정책이 적용됨


```json
<Sample>
{
  "Id": "PolicyXXXXXXX",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "StmtXXXXXXXXXX",
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::버킷이름/*",
      "Principal": "*"
    }
  ]
}
```

# S3 Static Hosting 실습
## 버킷 생성
### S3 > Create Bucket 화면
- 버킷 이름을 입력합니다.
- 퍼블릭 엑세스가 가능하도록 보안을 해제 합니다.
- 생성을 실행합니다.
![bucket 생성](/assets/images_post/cloud/aws_s3/aws_s3_1.png)

## 버킷 권한 설정
- Amazon S3 > 버킷 > (버킷이름) 을 선택합니다.
- `권한` 탭에서 `버킷정책` 편집을 실행 후 위 정책을 적용 합니다.
![bucket 생성](/assets/images_post/cloud/aws_s3/aws_s3_13.png)
![bucket 생성](/assets/images_post/cloud/aws_s3/aws_s3_4.png)
![bucket 생성](/assets/images_post/cloud/aws_s3/aws_s3_5.png)
- 정책 수정시 주의 사항
    - Actions를 GetObject로 선택합니다.
    - ARN이름은 버킷 초기 화면 속성에서 확인합니다.
    - Principal을 모두 접근이 가능하도록 `*` 로 입력합니다.
![bucket 생성](/assets/images_post/cloud/aws_s3/aws_s3_11.png)
![bucket 생성](/assets/images_post/cloud/aws_s3/aws_s3_12.png)


## 정적 웹 사이트 호스팅
- `속성` 탭으로 이동 후 정적 웹사이트 호스팅으로 진입 합니다.
- `정적 웹 사이트 호스팅`을 활성화를 선택합니다.
- 인덱스 문서 항목에 진입시 페이지 `index.html`를 입력 합니다.
- 저장 후 `엔드포인트 주소`를 선택하면 정적 웹 호스팅이 된 것을 알 수 있습니다.
![bucket 생성](/assets/images_post/cloud/aws_s3/aws_s3_16.png)

## 엔드포인트 주소를 도메인으로 연결
`Roue53 > 호스팅영역 > yourdomain > 레코드 생성` 위치에서 하기 입력으로 subdomain 연결함
- 트레픽 라우팅 대상에서 `별칭` 사용 선택
- S3 웹 사이트 엔드포인트에 대한 별칭
- 사용 리전 선택 (예) `아시아 태평양(서울) [ap-northeast-2]`
- 생성한 S3 엔드포인트 선택    
![bucket 생성](/assets/images_post/cloud/aws_s3/aws_s3_17.png)

일정시간 후 연결됨을 확인 할 수 있습니다.    
