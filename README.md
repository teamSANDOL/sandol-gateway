# 📌 Sandol Gateway Repository

## 📂 개요  
이 Repository는 **산돌이 프로젝트의 API Gateway** 역할을 담당합니다. 
모든 요청은 **Nginx를 통해 내부 서비스로 라우팅**되며, **사용자 인증을 위한 서명 검증(Signature Verification)**을 수행합니다. 
각 서비스는 독립적으로 운영되지만, **Nginx를 통해 트래픽을 제어하고 보안성을 강화**할 수 있습니다.

---

## 📌 프로젝트 구조  
- **주요 기술 스택:**  
  - `Nginx`
  - `Docker`
  - (필요시) `OpenResty + Lua`
  
- **역할:**  
  - 클라이언트 요청을 **Nginx에서 처리한 후 내부 MSA 서비스로 전달**  
  - `X-User-ID` 및 `X-Signature`를 검증하여 요청 무결성 유지  
  - 서명 검증을 통과한 요청만 내부 서비스로 전달  
  
- **연동 서비스:**  
  - `meal-api` (학식 API)  
  - `auth-api` (인증 API)  
  - `notice-api` (공지사항 API)  
  - `class-api` (빈 강의실 API)  
  
---

## 📌 문서  
- [📄 API 문서 (Notion)](링크)  
- [📄 서명 검증 프로세스 설명 (Notion)](링크)  

---

## 📌 환경 설정  
- **Docker 기반으로 실행되므로 로컬 환경에 의존하지 않음**  
- **환경 변수 파일 (`.env`) 필요 시, 샘플 파일 (`.env.example`) 제공**  
- **Docker Compose를 통해 서비스 간 네트워크 설정**  
- **서명 검증을 위한 비밀 키(SECRET_KEY)는 `.env` 파일에서 관리**  

### 📌 실행 방법  
#### 1. 기본 실행 (Nginx 실행)  
```bash  
docker compose up -d  
```
#### 2. 서비스 중지  
```bash  
docker compose down  
```
#### 3. 환경 변수 변경 후 재시작  
```bash  
docker compose up -d --build  
```

---

## 📌 배포 가이드  
- **GitHub Actions을 통한 CI/CD 적용 (예정)**  
- **서명 검증을 위한 비밀 키는 `.env`에서 관리되며, 배포 시 주의 필요**  
- **도메인 연결 및 리버스 프록시 설정 필요 (예: `api.sandol.com`)**  
- **SSL 적용 가능 (Let's Encrypt, Certbot 지원)**  

---

## 📌 문의  
- **디스코드 채널:** (링크 삽입)  

---  
🚀 **산돌이 프로젝트의 API Gateway를 통해 안정적인 MSA 환경을 구축합시다!**