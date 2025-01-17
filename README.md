# 트립록(TripLog)

// 추후 섬네일 추가

**🎯프로젝트 목적**: 해외여행/출장 시 환율을 적용하여 지출을 관리하고 분석하는 가계부 앱

**⏰프로젝트 일정**: 2025.01.16(목) ~ 2025.02.26(수) 12:00

**🔗Figma**: [Figma](https://www.figma.com/design/X6Lpqz7xRJ7zH5FgbcqDvI/%EC%B5%9C%EC%A2%85%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B8-2%EC%A1%B0-%EC%99%80%EC%9D%B4%EC%96%B4-%ED%94%84%EB%A0%88%EC%9E%84?node-id=0-1&p=f&t=kL471GHADO3N4ebX-0)

**🔗Reperance**: // 환율 API 링크

***

## ⚒️ Tech Stack
<div>
  <a href="https://developer.apple.com/xcode/" target="_blank">
    <img src="https://img.shields.io/badge/Xcode_16.1-147EFB?style=for-the-badge&logo=xcode&logoColor=white" alt="Xcode">
  </a>
  <a href="https://swift.org/" target="_blank">
    <img src="https://img.shields.io/badge/Swift_5-F05138?style=for-the-badge&logo=swift&logoColor=white" alt="Swift">
  </a>
  <a href="https://developer.apple.com/documentation/uikit" target="_blank">
    <img src="https://img.shields.io/badge/UIKit-2396F3?style=for-the-badge&logo=uikit&logoColor=white" alt="UIKit">
  </a>
  <a href="https://github.com/SnapKit/SnapKit" target="_blank">
    <img src="https://img.shields.io/badge/SnapKit-00aeb9?style=for-the-badge&logoColor=white" alt="SnapKit">
  </a>
  <a href="https://github.com/devxoul/Then" target="_blank">
    <img src="https://img.shields.io/badge/Then-00aeb9?style=for-the-badge&logoColor=white" alt="Then">
  </a>
  <br> 
  <a href="https://github.com/ReactiveX/RxSwift" target="_blank">
    <img src="https://img.shields.io/badge/reactivex-B7178C?style=for-the-badge&logoColor=white" alt="reactivex">
  </a>
  <a href="https://github.com/RxSwiftCommunity/RxDataSources" target="_blank">
    <img src="https://img.shields.io/badge/rxdatasources-B7178C?style=for-the-badge&logoColor=white" alt="rxdatasources">
  </a>
    <a href="https://github.com/RxSwiftCommunity/RxKeyboard" target="_blank">
    <img src="https://img.shields.io/badge/rxkeyboard-B7178C?style=for-the-badge&logoColor=white" alt="rxkeyboard">
  </a>
  <br>
  <a href="https://www.gitkraken.com/" target="_blank">
    <img src="https://img.shields.io/badge/gitkraken-179287?style=for-the-badge&logo=gitkraken&logoColor=white" alt="GitKraken">
  </a>
  <a href="https://github.com/" target="_blank">
    <img src="https://img.shields.io/badge/github-181717?style=for-the-badge&logo=github&logoColor=white" alt="GitHub">
  </a>
  <br>
</div>

## 📱 Preview

// 추후 업데이트

***

## 🍆 Git Flow

### 브랜치 구조
- `main`: 제품 출시 브랜치
    - 예: `main` (v1.0.0, v1.1.0)
    - 실제 운영 환경에 배포되는 안정화된 코드
- `develop`: 개발 브랜치
    - 예: `develop`
    - 다음 출시 버전을 개발하는 브랜치
- `feature/*`: 기능 개발 브랜치
    - 예: `feature/123-user-login`
    - 예: `feature/124-user-signup`
    - 각각의 기능은 별도의 브랜치에서 개발
- `hotfix/*`: 긴급 버그 수정 브랜치
    - 예: `hotfix/128-login-crash`
    - 운영 환경에서 발생한 긴급 버그 수정용
- `release/*`: 출시 준비 브랜치
    - 예: `release/v1.1.0`
    - QA 및 출시 준비를 위한 브랜치
 
### 브랜치 네이밍 규칙
- 기능 개발: `feature/{번호}-{작업내용}`
    - 예: `feature/123-user-authentication`
- 핫픽스: `hotfix/{번호}-{버그내용}`
    - 예: `hotfix/456-login-crash`
- 릴리즈: `release/v{버전}`
    - 예: `release/v1.2.0`

<img width="300" alt="Untitled" src="https://github.com/user-attachments/assets/e63197fa-15d0-4211-b105-b340c4438b3c" />

***

## 📓 Pull Request 작성 규칙

### 1. 리뷰어 역할

- 코드 품질 검토
- 비즈니스 로직 검증
- 코딩 컨벤션 준수 여부 확인

### 2. 리뷰 우선순위

1. 로직 오류
2. 성능 이슈
3. 코드 컨벤션
4. 기타 개선사항

### 3. 리뷰 커뮤니케이션

- 건설적인 피드백 제공
- 칭찬할 부분은 적극적으로 칭찬
- 변경이 필요한 부분은 명확한 이유와 함께 제시
- 토론이 필요한 부분은 오프라인 미팅 활용

### 4. PR 템플릿
```swift
Title: [Type] 제목

내용:

이슈 번호: #1

## 요약
작업에 대한 요약을 적어주세요

## 작업 상세 내용


## 리뷰어 공유사항

## 스크린샷(선택)
```

### 5. 커밋 컨벤션

  - ✨ `[feat]` 새로운 기능 추가
  - 🐛 `[fix]` 버그 수정
  - 📝 `[docs]` 문서 수정
  - 💄 `[style]` 코드 포맷팅, 세미콜론 누락, 코드 변경이 없는 경우
  - ♻️ `[refactor]` 코드 리팩토링
  - ✅ `[test]` 테스트 코드 추가/수정
  - 🎨 `[chore]` 빌드 업무 수정, 패키지 매니저 수정
  - 🔧 `[conf]` 설정 파일 수정
  - 🚀 `[deploy]` 배포 관련 수정
   
***

## Project Structure

### 프로젝트 플로우
<img width="1000" alt="최종 프로젝트 2조 브레인 스토밍 (1)" src="https://github.com/user-attachments/assets/67b0fa0d-f26a-4e1b-800d-a2f4b136b83d" />


### 프로젝트 구조도
<img width="1000" alt="최종 프로젝트 2조 브레인 스토밍" src="https://github.com/user-attachments/assets/d227948c-164e-4556-b4b8-d51649fc6b7b" />


***

## 💡 주요 기능

1. 해외여행/출장 시 사용할 가계부 생성하기

2. 오늘의 지출 내역 추가/수정하기

3. 전체 지출내역 관리하기

***
