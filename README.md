# 📌 Sandol Gateway Repository

## 📂 개요  
이 Repository는 **산돌이 프로젝트의 API Gateway**를 담당합니다.  
모든 클라이언트 요청은 **OpenResty(Nginx + Lua) 기반 Gateway**를 통해  
내부 MSA 서비스로 전달됩니다.

---

## 📦 핵심 기능  
- 요청 경로 기반 프록시 라우팅
  - `/meal/`
  - `/kakao-bot/`
  - `/notice-notification/`
  - `/classroom-timetable/`
  - `/static-info/`
  - `/studyroom/`
  - `/relay/`
  - `/grafana/`
  - `/auth/` (Keycloak reverse proxy)
- 공통 헤더 전달 (`Host`, `X-Real-IP`, `X-Forwarded-For`, `X-User-ID`, `Origin`)
- `/studyroom/`은 예외다. GET, HEAD, OPTIONS만 받고 본문은 1k까지이며 `X-User-ID`는 비워서 넘긴다.

---

## 📁 프로젝트 구조  
```
.
├── gateway/
│   ├── default.conf              # 메인 Nginx 설정
│   └── routes/                   # 각 서비스별 conf
├── test_api/                     # 테스트용 백엔드 서비스
├── docker-compose.yml            # Gateway + Backend 구성
├── README.md
└── test_client.py                # 요청 예제 스크립트
```

---

## 🛠️ 사용 기술  
- **Nginx (OpenResty 기반)**: 라우팅 및 리버스 프록시 처리
- **Docker + Docker Compose**: 컨테이너 기반 구성

---

## 🧪 실행 방법

### 1. 로컬 실행
```bash
docker compose up -d
```

### 2. 종료
```bash
docker compose down
```

### 3. 환경변수 변경 후 재시작
```bash
docker compose up -d --build
```

### 로컬 실행 범위 안내
- 현재 `docker-compose.yml`은 `gateway`와 샘플 `backend`만 포함합니다.
- 각 라우트가 가리키는 실제 서비스(`meal-service`, `kakao-bot-service` 등)는 이 저장소에서 함께 실행되지 않습니다.

---

## 🔁 Docker 서비스 구성 요약

```yaml
services:
  gateway:
    build: ./gateway
    ports:
      - "8010:80"
    volumes:
      - ./gateway/default.conf:/etc/nginx/conf.d/default.conf:ro
    command: ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]
    depends_on:
      - backend

  backend:
    build: ./test_api
    ports:
      - "8011:8011"
    command: ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8011"]
```

---

## 🚀 배포 가이드  
- CI/CD 자동 배포 예정 (예: GitHub Actions 기반)
- 도메인 연결: 예) `api.sandol.com`, `gateway.sandol.house.sio2.kr`
- SSL: `Let's Encrypt` 및 `Certbot` 기반 인증서 적용 가능
- 프록시 서버에 따라 내부 서비스 보안 정책 강화 가능

---

📡 산돌이 프로젝트의 모든 API 요청은 이 Gateway를 통해 전달됩니다.


## 외부 인증 서버 업스트림 (https)

기본값은 기존과 같다(http, Host=클라이언트 `$host`, 비밀 헤더 없음, 관리 콘솔 공개). 아래 env 는 `keycloak`(KEYCLOAK_) / `auth-relay`(AUTH_RELAY_) 접두사로 각각 설정하며, 루트 compose 의 gateway `environment`(컨테이너 env)와 command `-g "env ...;"` 양쪽에 선언해야 한다. UPSTREAM_CA_BUNDLE 만 셸 스크립트가 읽으므로 `environment` 선언만 필요.

| env | 기본 | 설명 |
|---|---|---|
| `*_UPSTREAM` | keycloak-edge:8080 / auth-relay:8000 | 업스트림 `host:port`. https 는 IP 가 아니라 공개 호스트명(예: `auth.example.com:443`) 사용 |
| `*_UPSTREAM_SCHEME` | http | `https` 면 TLS. 그 외 값은 http |
| `*_UPSTREAM_HOST_HEADER` | http: `$host` / https: 업스트림 호스트명 | 업스트림으로 보내는 Host 덮어쓰기 |
| `*_UPSTREAM_SECRET_HEADER` | (없음) | 값이 있으면 `X-Origin-Verify: <값>` 를 붙인다. 비면 헤더를 보내지 않고 클라이언트가 보낸 같은 이름 헤더도 지운다 |
| `UPSTREAM_CA_BUNDLE` | 시스템 CA 번들 | 사설 CA PEM 의 컨테이너 내 경로(파일 마운트 필요). 읽을 수 없으면 기동 중단 |
| `KEYCLOAK_ADMIN_PUBLIC` | 허용 | `off`/`false`/`0`/`no` 면 `/auth/admin*`, `/auth/realms/master*` 를 404 (대소문자·`//`·%인코딩·`..` 정규화 후 판정) |

TLS(`routes/upstream-tls.inc`): 인증서 검증 항상 on(끄는 옵션 없음), SNI 와 검증 이름 = 업스트림 호스트명, verify_depth 4, TLSv1.2/1.3. 검증 실패·이름 불일치는 502 이며 error_log 에 `upstream SSL certificate verify error` 로 남는다.

### DNS·연결
- `proxy_pass` 가 변수 기반이라 요청마다 resolver 로 해석한다(CloudFront IP 변경 추종). resolver 는 docker DNS(127.0.0.11)이고 외부 이름을 재귀 해석하며, `valid=10s` 로 캐시를 10초로 제한한다.
- 변수 `proxy_pass` 는 upstream 블록이 없어 keepalive·TLS 세션 재사용이 사실상 동작하지 않는다(요청마다 핸드셰이크). 현재 트래픽에서는 허용하고, 부하가 문제되면 고정 upstream 블록으로 바꾼다.

### 헤더 체인과 클라이언트 IP
- 게이트웨이는 `X-Forwarded-For`(=`$remote_addr`로 덮어씀), `X-Forwarded-Proto: https`, `X-Forwarded-Host`, `X-Real-IP` 를 넘긴다. CloudFront 는 origin request policy 에 따라 헤더를 버리거나 덮어쓰고 자체 `X-Forwarded-For` 에 접속 IP 를 덧붙인다.
- Keycloak 의 issuer 는 `KC_HOSTNAME` 전체 URL 로 고정이라 Host 와 무관하다. 그러나 클라이언트 IP(로그·brute force 감지)는 인증 서버 NPM 이 신뢰하는 프록시 대역(`KC_PROXY_TRUSTED_ADDRESSES` = NPM 주소)과 XFF 체인에 달려 있다. 체인(메인 게이트웨이 → CloudFront → NPM → Keycloak)의 마지막 홉이 아닌 주소가 신뢰 목록에 없으면 XFF 가 무시되어 모든 요청이 프록시 IP 로 보인다.

### CloudFront 체크리스트
- 캐시 정책 CachingDisabled, Origin request policy 는 모든 쿼리스트링·쿠키 전달, 헤더는 `Authorization`, `X-User-ID`, `Origin`, `X-Forwarded-*`, `X-Origin-Verify` 등 필요한 것 전달(Host 는 origin 호스트명 기준)
- 허용 메서드 GET/HEAD/OPTIONS/PUT/POST/PATCH/DELETE
- Origin 프로토콜 HTTPS only, origin 도메인 = 인증서 이름과 일치하는 호스트명, origin 응답 타임아웃을 로그인 흐름에 맞게 충분히
- 우회 방지: CloudFront origin custom header 또는 메인 게이트웨이의 `*_UPSTREAM_SECRET_HEADER` 값을 NPM(Advanced `if ($http_x_origin_verify != "값") { return 403; }`)에서 검사

### NPM 프록시 호스트
Websockets 불필요, SSL 강제(Force SSL), HSTS 는 도메인 전체에 영향하므로 신중히, 인증서는 공인(Let's Encrypt 등) 사용. 사설 CA 면 `UPSTREAM_CA_BUNDLE` 로 지정.
