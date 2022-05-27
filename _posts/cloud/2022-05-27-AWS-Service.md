---
title: "[AWS] 자주 쓰는 서비스"
categories: 
    - cloud
tags: 
    - AWS
    - Cloud
    - IasS
    - PaaS
    - SaaS
    - Region
    - AZ
    - ARN
toc : true
toc_sticky  : true    
---

AWS에서 너무 많은 서비스가 있는데, 자주 쓰이는 것들과 어떤 서비스를 제공하는지 정도를 틈틈이 정리해보려고 합니다.

## IAM (Identity and Access Management)
![IAM](/assets/images_post/cloud/aws/Arch_AWS-Identity-and-Access-Management_64.png){: width="48px", height="48px"}
AWS의 사용자 생성 그룹, 역할 등 서비스 및 리소스 접근 권한을 관리.

## EC2 (Elastic Compute Cloud)
![EC2](/assets/images_post/cloud/aws/Arch_Amazon-EC2_64.png){: width="48px", height="48px"}
클라우드에서 인스턴스로 부르는 가상 컴퓨터(리눅서, window 등 다양한 OS 이미지로 생성이 가능함.)

## S3 (Simple Storage Service)
![S3](/assets/images_post/cloud/aws/Arch_Amazon-S3-on-Outposts_64.png){: width="48px", height="48px"}
데이터 저장소로 File, image, movie등 무제한 확장이 가능한 저장소

## S3 Glacier
![S3 Glacier](/assets/images_post/cloud/aws/Arch_Amazon-Simple-Storage-Service-Glacier_64.png){: width="48px", height="48px"}
저비용, 장기 백업 서비스로 S3와 함께 사용하여 백업 등의 최적화 구성

## DynamoDB
![DynamoDB](/assets/images_post/cloud/aws/Arch_Amazon-DynamoDB_64.png){: width="48px", height="48px"}
Key, Value 형태의 NOSQL Database 서비스

## RDS (Relational Database Service)
![RDS](/assets/images_post/cloud/aws/Arch_Amazon-RDS_64.png){: width="48px", height="48px"}
R-DBMS 를 Cloud로 서비스하는 것으로 사용 및 오픈소스 대부분의 RDBMS를 선택 가능함.    
MySQL, Oracle, SQL Server, PostgreSQL, Maria DB

## Aurora 
![RDS](/assets/images_post/cloud/aws/Arch_Amazon-Aurora_64.png){: width="48px", height="48px"}
클라우드 전용을  아마존의 관계형 데이터 베이스로 MySQL, PostgreSQL 두개의 오픈소스를 지원

## API Gateway
![API Gateway](/assets/images_post/cloud/aws/Arch_Amazon-API-Gateway_64.png){: width="48px", height="48px"}
웹어플리케이션 백엔드 구현에 필요한 API개발을 지원하고 ,  Lamdba, EC2기반 앱 개발 등을 지원

## CloudTrail
![CloudTrail](/assets/images_post/cloud/aws/Arch_AWS-CloudTrail_64.png){: width="48px", height="48px"}
계정 내 API호출 내역과 사요자 액티비티 기록 서비스로 S3를 통해서 로그 파일을 제공함.

## CloudWatch
![CloudWatch](/assets/images_post/cloud/aws/Arch_Amazon-CloudWatch_64.png){: width="48px", height="48px"}
AWS 리소스와 애플리케이션을 모니터링 서비스, 각종 로그를 수집 분석하고 경고를 설정 가능함.

## Lambda
![Lambda](/assets/images_post/cloud/aws/Arch_AWS-Lambda_64.png){: width="48px", height="48px"}

## SES (Simple Email Service)
![SES](/assets/images_post/cloud/aws/Arch_Amazon-Simple-Email-Service_64.png){: width="48px", height="48px"}
이메일 설정 및 운영, 발송 등의 서비스를 제공.

## Amazon MQ
![Amazon MQ](/assets/images_post/cloud/aws/Arch_Amazon-MQ_64.png){: width="48px", height="48px"}
아마존의 메세지 큐 서비스.

## Route 53
![Route 53](/assets/images_post/cloud/aws/Arch_Amazon-Route-53_64.png){: width="48px", height="48px"}
DNS의 역할로 Domain 정보를 AWS 서비스로 전달함.

## Cloud Front
![Cloud Front](/assets/images_post/cloud/aws/Arch_Amazon-CloudFront_64.png){: width="48px", height="48px"}
글로벌 서비스를 위한 CDN(Content Delivery Network)서비스 제공.

## IoT Core
![IoT Core](/assets/images_post/cloud/aws/Arch_AWS-IoT-Core_64.png){: width="48px", height="48px"}
사물인터넷에 사용되며 디바이스와 클라우드의 연결을 위한 플랫폼(MQTT 등의 방법 제공)

## VPC (Virtual Private Cloud)
![Virtual Private Cloud](/assets/images_post/cloud/aws/Arch_Amazon-Virtual-Private-Cloud_64.png){: width="48px", height="48px"}
VPC를 통해서만 가상 네트워크에서만 클라으드에 접근 할 수 있게 하는 기술.

## ELB (Elastic Load Balancing)
![Elastic Load Balancing](/assets/images_post/cloud/aws/Arch_Elastic-Load-Balancing_64.png){: width="48px", height="48px"}
부하를 분산하는 L4 기능을 제공함.

## KMS (Key Management Service)
![KMS](/assets/images_post/cloud/aws/Arch_AWS-Key-Management-Service_64.png){: width="48px", height="48px"}
암호화 작업에 사용되는 키생성 및 통합 환경에서의 키관리 및 정책 정의.


## EBS (Elastic Block Store)
![EBS](/assets/images_post/cloud/aws/Arch_Amazon-Elastic-Block-Store_64.png){: width="48px", height="48px"}
EC2 인스턴스를 위한 스토리리 서비스로 마그네틱 또는 SSD 를 선택 가능함.

## EFS (Elastic File System)
![EFS](/assets/images_post/cloud/aws/Res_Amazon-Elastic-File-System_Standard_48_Light.png){: width="48px", height="48px"}
EC2 인스턴스를 활용하기 위해서, 확정성이 높은 공유 스토리지 서비스로, 다수의 EC2에서 동시에 접속 할수 있다.

## Elastic-Transcoder
![Elastic-Transcoder](/assets/images_post/cloud/aws/Arch_Amazon-Elastic-Transcoder_64.png){: width="48px", height="48px"}
비디오 및 오디를 디바이스에 적합한 형태로 파일을 포멧을 변환하기 위한 서비스

## Snowball
![Snowball](/assets/images_post/cloud/aws/Arch_AWS-Snowball_64.png){: width="48px", height="48px"}
클라우드 안팎에서 페타바이트 규모의 데이터를 전송 할수 있는 기능 제공. 클라우드 백업 및 온프레미스 전송 등에 사용.


## AWS 아키텍처 아이콘 다운로드
간혹 아키텍처 자료를 만들때 있어보이게 만들수 있는 꿀 템플릿 입니다.   
[서비스 아이콘 다운르도](https://aws.amazon.com/ko/architecture/icons/){:target="_blank"}

