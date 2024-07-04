## WanderBoard


```
📸 여행을 기록하고 공유하는, 여행 매니아를 위한 필수 앱
🏞 WanderBoard에서 나만의 여행기록을 작성하고, 다른 사람들과 공유해보세요.
🌟 다른 사람들의 여행 기록을 보며 당신의 다음 여행을 계획할수 있습니다.


🍎 App Store : https://apps.apple.com/kr/app/wanderboard/id6504566967
```

<img width="200" src="https://github.com/WanderBoard/WanderBoard/assets/158182449/47ec6dec-2c12-4079-aa00-8fdcf308bf12"/> <img width="200" src="https://github.com/WanderBoard/WanderBoard/assets/158182449/d88df906-d7af-4ca2-a240-61b6997201b0"/> <img width="200" src="https://github.com/WanderBoard/WanderBoard/assets/158182449/3e301e77-12bd-4cf5-ad4c-dc9bcc01ce37"/> <img width="200" src= "https://github.com/WanderBoard/WanderBoard/assets/158182449/68fb801b-bd9a-42b0-9a92-203886125b72"> 


## Table of Contents
1. [Description](#description)
2. [Stacks](#%EF%B8%8F-stacks)
3. [Requirements](#-requirements)
4. [Demo](#-demo)
5. [Main Feature](#-main-feature)
6. [Developer](#-developer)

</br>

## Description

`TEAM` : Team WanderBoard

`Period` : 24.05.27 ~ 24.07.05

다녀온 여행 기록을 남길 수 있는 어플리케이션, 내 기록만 남기는 것이 아닌 유저가 올린 여행 기록도 확인하여 여행 기록을 공유할 수 있습니다.

</br>

## 🛠️ Stacks
**Environment**

| 범위 | 기술 이름 |
| --- | --- |
| **의존성 관리 도구** | SPM |
| **형상 관리 도구** | GitHub, Git |
| **아키텍처** | MVC |
| **디자인 패턴** | Singleton, Delegate |
| **인터페이스** | UIKit, SwiftUI |
| **레이아웃 구성** | SnapKit 5.7.1, Then 3.0.0 |
| **내부 저장소** | firebase 10.26.0, CoreData, UserDefaults |
| **외부 인증** | GoogleSignIn 7.1.0, KakaoOpenSDK 2.22.2 |
| **이미지 처리** | Kingfisher 7.12.0 |
| **코드 스타일** | swiftStyleGuide, SwiftAPI  |
| **네트워킹** | Concurrent, Alamofire  |

<img src="https://img.shields.io/badge/-Xcode-147EFB?style=flat&logo=xcode&logoColor=white"/> <img src="https://img.shields.io/badge/-git-F05032?style=flat&logo=git&logoColor=white"/> <img src="https://img.shields.io/badge/-github-181717?style=flat&logo=github&logoColor=white"/> <img src="https://img.shields.io/badge/-firebase-DD2C00?style=flat&logo=firebase&logoColor=white"/>

**Language**

<img src="https://img.shields.io/badge/-swift-F05138?style=flat&logo=swift&logoColor=white"/> <img src="https://img.shields.io/badge/-swiftUI-2379F4?style=flat&logo=swift&logoColor=white"/> 

**Communication**

<img src="https://img.shields.io/badge/-slack-4A154B?style=flat&logo=slack&logoColor=white"/> <img src="https://img.shields.io/badge/-notion-000000?style=flat&logo=notion&logoColor=white"/>  <img src="https://img.shields.io/badge/-figma-609926?style=flat&logo=figma&logoColor=white"/>

</br>

## 🔧 Requirements
- App requires **iOS 16 or above**


</br>


## 📺 Demo

<img width="800" alt="image" src="https://github.com/WanderBoard/WanderBoard/assets/158182449/4418ee8a-82d0-4d00-9b86-f90f6465c612">

</br></br>

---

## 🎯 Main Feature
### 1) Login & Sign In
<img width="800" src ="https://github.com/WanderBoard/WanderBoard/assets/158182449/cd5fa882-e264-4a6c-b667-8fde0aac0216">

- 애플, 구글, 카카오 소셜 로그인 기능 구현 완료
- 로그인 이후 WanderBoard 내 사용할 회원 정보 가입

</br>

### 2) Home
<img width="800" src ="https://github.com/WanderBoard/WanderBoard/assets/158182449/364cb921-fa69-43f7-992f-ed56404f96c5">
<img width="800" src ="https://github.com/WanderBoard/WanderBoard/assets/158182449/ca04fa5d-0c34-47a0-831a-5a2648973871">

- 버튼을 활용해 메인 페이지 이동 구현
- 유저가 올린 핀 로그와 내가 올린 핀 로그 실시간 확인, 소셜 기능 구현
- 원하지 않은 핀 로그 차단 및 숨기기 기능 구현
- 핀 로그 공개 여부 구현

</br>

### 3) Detail
<img width="800" src ="https://github.com/WanderBoard/WanderBoard/assets/158182449/2b5fac70-203f-41df-afcd-c37f76b4a085">
<img width="800" src ="https://github.com/WanderBoard/WanderBoard/assets/158182449/f7b89ef6-a143-4305-ba74-7be56ea56bbc">
<img width="800" src ="https://github.com/WanderBoard/WanderBoard/assets/158182449/03e71bff-7c66-40c1-b459-49f47e65bbca">
<img width="800" src ="https://github.com/WanderBoard/WanderBoard/assets/158182449/85fd6d9b-7d19-4d1d-bd21-d34f6ee4a862">

- firebase를 통해 데이터를 저장 후 불러오기 기능 구현
- 유저 혹은 내가 올린 여행의 사진, 장소, 지출 내역 등 확인
- 핀 로그를 저장해 별도 관리 가능
- 지도를 통해 사진을 클릭 시 사진의 장소 확인 가능하며, 로드 뷰, 위성 사진 등 맵 기능 구현
- 메이트를 추가해 같이 다녀온 일행 추가 기능 구현

</br>

### 4) MyPage
<img width="800" src ="https://github.com/WanderBoard/WanderBoard/assets/158182449/d148f0dd-d77e-4d87-9bb0-6aaf0920f4f3">

- 내가 올린 핀 로그, 태그 된 핀 로그, 저장한 핀 로그 갯수 확인
- 다크모드 기능 구현
- 차단 친구 목록 관리 기능 구현
- 회원 탈퇴 기능 구현
- 프로필 이미지, 닉네임 변경 기능 구현

</br>

## 👨‍👩‍👧‍👦 Developer

*  **김시종** ([SijongKim93](https://github.com/SijongKim93))
    - DetailView , DetailInputView 구현
    - 핀 로그 저장, 수정, 삭제 기능 구현
    - Mate 목록, 수정, 삭제, 차단 기능 구현
      
*  **장진영** ([mgynsz](https://github.com/mgynsz))
    - Firebase 서버 구현 담당
    - 데이터 모델링
    - 로그인 / 회원가입 기능 구현
    - SwiftUI를 활용한 애니메이션 효과 등
    
*  **김한빛** ([gksqlc7386](https://github.com/gksqlc7386))
    - MainPageView, MyBoard, Search Page 구현
    - 핀 상태 별 정렬 및 회원 탈퇴 구현
    - 화면 이동, 데이터 전달 구현
    - 앱 디자인
 
*  **이시안** ([DDattj](https://github.com/DDattj))
   - MyPage, 환경설정 구현
   - 유저 프로필 구현
   - 다크모드 최적화
   - 앱 디자인

*  **금세미** ([pond1225](https://github.com/pond1225))
   - 지출 페이지 구현
   - 기본 프로필 상태 업데이트
   - QA 담당
    
<br>
