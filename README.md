![memorable_image](https://github.com/hgkim215/Memorable_iOS/assets/61077215/14e4138e-14af-4bbf-a419-021bd2a83c35)

> **_키워드 암기학습을 도와주고📚 학습자료 암기에 효율을 높여주는📑 iOS 앱서비스🍎_** <br/><br/>
> **Development Period: 2024.06.24 ~ 2024.07.12**

<br/>

## ⭐️ Memorable 소개

시험 기간에 셀 수 없는 정리본을 외우시나요?  
백지 복습을 수없이 해본 적 있나요?  
키워드 추출, 시험지/오답 노트 자동 생성으로 학습 효율을 높이세요!  
Learn more, Be memorable 당신의 기억에 남게  

<br/>

## 📢 🦅 팀 오조사마 👸 📢

|               PM 봉민석                |              Design 김규희               |                iOS 김민혁                |                      iOS 김현기                      |                Back 오성진                |
| :------------------------------------: | :------------------------------------: | :--------------------------------------: | :--------------------------------------------------: | :--------------------------------------: |
|  <img src="https://github.com/hgkim215/Memorable_iOS/assets/61077215/f338d45d-63a6-4fae-80e1-997136260681" style="width: 150px; height: 150px; object-fit: fill;">  |  <img src="https://github.com/hgkim215/Memorable_iOS/assets/61077215/2a1397e5-9763-496a-a4af-a92caff04921" style="width: 150px; height: 150px; object-fit: fill;">   | <img src="https://github.com/hgkim215/Memorable_iOS/assets/61077215/cf5c1120-c00e-4e32-9ae8-1762636ddd89" style="width: 150px; height: 150px; object-fit: fill;"> |  <img src="https://github.com/hgkim215/Memorable_iOS/assets/61077215/f31dfc8e-8a3e-4bd3-960c-2acdcd1f9e97" style="width: 150px; height: 150px; object-fit: fill;">  |  <img src="https://github.com/hgkim215/Memorable_iOS/assets/61077215/04414605-813d-4aed-8920-bd6bca724029" style="width: 150px; height: 150px; object-fit: fill;">  |
| [@_dave_bong](https://instagram.com/_dave_bong) | [@9ooig2](https://instagram.com/9ooig2) | [@Kim-Min-Hyeok](https://github.com/Kim-Min-Hyeok) | [@hgkim215](https://github.com/hgkim215) | [@xxjiinn](https://github.com/xxjiinn) |

<br/>

## ⚙️ 개발환경 및 언어

### 프론트
![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)
![Swift](https://img.shields.io/badge/swift-F54A2A?style=for-the-badge&logo=swift&logoColor=white)
### 백
![MySQL](https://img.shields.io/badge/mysql-4479A1.svg?style=for-the-badge&logo=mysql&logoColor=white)
![Spring](https://img.shields.io/badge/spring-%236DB33F.svg?style=for-the-badge&logo=spring&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
### API
![ChatGPT](https://img.shields.io/badge/chatGPT-74aa9c?style=for-the-badge&logo=openai&logoColor=white)
### 디자인
![Figma](https://img.shields.io/badge/figma-%23F24E1E.svg?style=for-the-badge&logo=figma&logoColor=white)

<br/>

## 🌟 Memorable 주요 기능들

> 🔑 You can sign up and log in via Google Sign-in and email!

<img src="https://github.com/nth221/videx/assets/64348852/0138fc52-d0f8-488e-a2cd-ccc77b74a17b" width=30%> <img src="https://github.com/nth221/videx/assets/64348852/28189d4f-bea6-49ff-b0fb-9a4bf505c416" width=30%> <img src="https://github.com/nth221/videx/assets/64348852/41593a3e-718c-466a-8476-8db9cf90dc0e" width=30%>


> 1️⃣ Shoot a simple shortform ad in under a minute!

<img src="https://github.com/snackads/SnackAds/assets/64348852/87400302-c3a8-4d7c-acc5-452ddd958667" width="30%"> <img src="https://github.com/nth221/videx/assets/64348852/e1cdc9b2-d47c-41ea-aca7-a83e03afc129" width=30%> <img src="https://github.com/nth221/videx/assets/64348852/d7f86f6a-3b04-4154-b3fb-a09bc785d715" width="30%">

> 📍 Check out the map to see what restaurants are near you!

<img src="https://github.com/nth221/videx/assets/64348852/101dbd88-1e92-49ef-9271-cfa4f1b839c4" width=30%>

> 👍 If there's a restaurant you want to try, give it a thumbs up!

<img src="https://github.com/nth221/videx/assets/64348852/36525b76-8ece-46cf-af58-9d105e9d2b0a" width=30%>

> 🤝 If you have a favorite restaurant you'd like to try with your friends, share it!

<img src="https://github.com/nth221/videx/assets/64348852/bb69d390-8185-49d5-bd2f-dbec84cb229a" width=30%>

> 👤 You can see the videos you've uploaded and the videos you've liked on Profile!

<img src="https://github.com/nth221/videx/assets/64348852/307d61b4-cf1f-41f2-9e63-69978d68324e" width=30%>

<br/>

## ⚒ Architecture

### ⏺ MVC Architecture/Design Pattern

<img width="994" alt="2024-06-06_05-12-06" src="https://github.com/snackads/SnackAds/assets/61077215/fe7c8d02-4e0d-4b09-a825-9ee0bdeb54e3">

> **MVC Pattern Description**

- SnackAds is developed using the MVC architecture. This architecture divides the application into three components - Model, View, and Controller - to enable efficient development and maintenance.

- Model manages the shortform (ad video) and user data. The shortform data model includes the shortform's title, description, URL, and number of likes, while the user data model includes the user's profile and the shortforms they have liked. Firebase is responsible for storing and retrieving this data in the database.

- View manages the user interface. The Home screen displays a list of Short Form ads, and the Play Ads screen plays the current turn of ads. The User Profile screen displays the user's information, and the Map screen displays the location of the store currently listed in the app.

<br/>

## 🔥 Managing Tasks within our Development Team

### ⏺ Weekly Scrum

- Last week's work retrospective: Each team member gives a brief description of the work they completed in the past week. This is an opportunity to see how the project is progressing and share the results of the work completed.

- This week's work plan: Each team member shares a list of tasks they'll be focusing on this week. This helps team members understand each other's work and plan for collaboration if needed.

- Share obstacles and find solutions: Team members share any problems or obstacles they've encountered in their work, and work together to find solutions. This is essential for the smooth progress of the project.

### ⏺ Write Backlog

- Gather requirements: Identify the goals and needs of the project. This can be done through customer needs, market research, internal goals, etc.

- Define work items: Based on the requirements gathered, define specific work items. Each item should be small enough that one person or a small team can complete it within one sprint.

- Set priorities: Determine the priority of the work items. This is done by considering the project's goals, customer needs, technical difficulty, etc.

- Organize and update the backlog: Review the backlog regularly as the project progresses and add, modify, or delete items as needed.

### ⏺ Totally Agile

- Iterative and incremental development: Break your project into smaller steps, each of which produces a viable product. This allows for continuous improvement and adaptation.

- Openness to change: Recognize that goals and requirements may change during the course of a project, and have the flexibility to respond.

- Close collaboration among team members: Emphasize communication and cooperation, and clarify the roles and responsibilities of each team member so they can support each other and work toward a common goal.

<br/>

## 🧑‍💻 How to Collaborate by Using Git

- First, we created a Snack Ads Organization and invited everyone on the team to join it.

- Under that organization, we created a Snack Ads flutter project, and each developer forked that project and worked in their own repository. We found that this approach significantly reduced the number of conflicts that arose during collaboration.

- When sending pull requests, we made sure that the other developer reviewed the code and went through a code review process, rather than just merging it themselves. This ensured that the developers were constantly sharing each other's code as they developed.
