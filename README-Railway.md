# 🚂 N8N Railway 배포 가이드

이 가이드는 Docker Compose로 구성된 N8N + PostgreSQL 환경을 Railway 플랫폼에 배포하는 방법을 설명합니다.

## 📋 목차

1. [사전 준비사항](#사전-준비사항)
2. [Railway CLI 설치](#railway-cli-설치)
3. [프로젝트 생성 및 설정](#프로젝트-생성-및-설정)
4. [PostgreSQL 데이터베이스 설정](#postgresql-데이터베이스-설정)
5. [N8N 서비스 배포](#n8n-서비스-배포)
6. [환경변수 설정](#환경변수-설정)
7. [도메인 설정](#도메인-설정)
8. [배포 확인 및 테스트](#배포-확인-및-테스트)
9. [문제 해결](#문제-해결)

## 🎯 사전 준비사항

- Railway 계정 (https://railway.app)
- Git이 설치된 로컬 환경
- 이 저장소의 Railway 배포 파일들:
  - `Dockerfile`
  - `railway.toml`
  - `.env.railway`

## 🔧 Railway CLI 설치

### macOS (Homebrew)

```bash
brew install railway
```

### Windows (Scoop)

```bash
scoop install railway
```

### Linux/기타 OS

```bash
curl -fsSL https://railway.app/install.sh | sh
```

### CLI 로그인

```bash
railway login
```

## 🚀 프로젝트 생성 및 설정

### 1. 새 프로젝트 생성

```bash
# 프로젝트 디렉토리로 이동
cd /path/to/your/n8n-project

# Railway 프로젝트 초기화
railway init

# 프로젝트 이름 입력 (예: n8n-automation)
```

### 2. Git 저장소 연결 (선택사항)

```bash
# 기존 Git 저장소가 있는 경우
git init
git add .
git commit -m "Initial Railway setup"

# GitHub 저장소 연결 (Railway 대시보드에서도 가능)
git remote add origin https://github.com/your-username/your-repo.git
git push -u origin main
```

## 🗄️ PostgreSQL 데이터베이스 설정

### 1. Railway 대시보드에서 PostgreSQL 추가

1. Railway 대시보드 (https://railway.app/dashboard) 접속
2. 생성한 프로젝트 선택
3. "+ New" 버튼 클릭
4. "Database" → "Add PostgreSQL" 선택
5. PostgreSQL 인스턴스가 자동으로 생성됨

### 2. PostgreSQL 연결 정보 확인

Railway가 자동으로 다음 환경변수들을 생성합니다:

- `PGHOST`
- `PGPORT`
- `PGDATABASE`
- `PGUSER`
- `PGPASSWORD`
- `DATABASE_URL`

## 📦 N8N 서비스 배포

### 1. N8N 서비스 추가

```bash
# Railway CLI를 통한 배포
railway up

# 또는 GitHub 연동을 통한 자동 배포 설정
```

### 2. 대시보드에서 서비스 추가 (대안)

1. Railway 대시보드에서 프로젝트 열기
2. "+ New" → "GitHub Repo" 또는 "Empty Service"
3. 서비스 이름을 "n8n"으로 설정

## ⚙️ 환경변수 설정

### 1. Railway 대시보드에서 환경변수 설정

1. N8N 서비스 선택
2. "Variables" 탭 클릭
3. "Raw Editor" 모드로 전환
4. 다음 환경변수들을 추가:

```env
# N8N 기본 설정
N8N_PORT=${{PORT}}
N8N_PROTOCOL=https
NODE_ENV=production
N8N_ENCRYPTION_KEY=your-32-character-encryption-key-here

# PostgreSQL 연결 (Railway PostgreSQL 플러그인 참조)
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=${{Postgres.PGHOST}}
DB_POSTGRESDB_PORT=${{Postgres.PGPORT}}
DB_POSTGRESDB_DATABASE=${{Postgres.PGDATABASE}}
DB_POSTGRESDB_USER=${{Postgres.PGUSER}}
DB_POSTGRESDB_PASSWORD=${{Postgres.PGPASSWORD}}
DB_POSTGRESDB_SCHEMA=public

# 도메인은 자동 생성 후 설정
WEBHOOK_URL=https://${{RAILWAY_PUBLIC_DOMAIN}}
N8N_EDITOR_BASE_URL=https://${{RAILWAY_PUBLIC_DOMAIN}}
N8N_HOST=${{RAILWAY_PUBLIC_DOMAIN}}

# 보안 설정
N8N_SECURE_COOKIE=true
N8N_BASIC_AUTH_ACTIVE=false
N8N_USER_MANAGEMENT_DISABLED=false

# 시간대
TZ=Asia/Seoul
```

### 2. 중요한 환경변수 설명

- **N8N_ENCRYPTION_KEY**: 32자 이상의 랜덤 문자열. 한번 설정하면 변경하지 마세요!

  ```bash
  # 생성 예시
  openssl rand -base64 32
  ```

- **PostgreSQL 참조**: `${{Postgres.VARIABLE}}` 형식으로 PostgreSQL 플러그인의 변수를 참조

## 🌐 도메인 설정

### 1. Railway 자동 도메인 생성

1. N8N 서비스 선택
2. "Settings" 탭
3. "Domains" 섹션
4. "Generate Domain" 클릭
5. 생성된 도메인 확인 (예: `your-app.up.railway.app`)

### 2. 커스텀 도메인 설정 (선택사항)

1. "Add Custom Domain" 클릭
2. 도메인 입력 (예: `n8n.yourdomain.com`)
3. DNS 설정:
   - CNAME 레코드: `your-app.up.railway.app`로 지정
   - 또는 Railway가 제공하는 IP 주소로 A 레코드 설정

### 3. 도메인 환경변수 업데이트

도메인이 생성되면 환경변수 업데이트:

```env
N8N_DOMAIN=your-app.up.railway.app
WEBHOOK_URL=https://your-app.up.railway.app
N8N_EDITOR_BASE_URL=https://your-app.up.railway.app
N8N_HOST=your-app.up.railway.app
```

## ✅ 배포 확인 및 테스트

### 1. 배포 상태 확인

```bash
# CLI로 로그 확인
railway logs

# 또는 대시보드에서 "Deployments" 탭 확인
```

### 2. N8N 접속 테스트

1. 브라우저에서 `https://your-app.up.railway.app` 접속
2. N8N 로그인 페이지가 표시되는지 확인
3. 초기 사용자 계정 생성

### 3. 헬스체크

```bash
curl https://your-app.up.railway.app/healthz
```

## 🔧 문제 해결

### PostgreSQL 연결 실패

1. PostgreSQL 서비스가 실행 중인지 확인
2. 환경변수 참조가 올바른지 확인 (`${{Postgres.VARIABLE}}`)
3. PostgreSQL 플러그인이 N8N 서비스와 같은 프로젝트에 있는지 확인

### 메모리 부족 오류

Railway 대시보드에서 리소스 제한 조정:

1. 서비스 설정 → Resources
2. Memory 제한 증가 (최소 512MB 권장)

### 포트 바인딩 오류

- Railway는 자동으로 `PORT` 환경변수를 제공
- Dockerfile에서 `ENV N8N_PORT=$PORT` 설정 확인

### 로그 확인

```bash
# 실시간 로그 스트리밍
railway logs -f

# 최근 100줄 로그
railway logs -n 100
```

## 📊 모니터링 및 유지보수

### 1. Railway 대시보드 모니터링

CPU/Memory 사용량

- [ ] 네트워크 트래픽

배포 히스토리

### 2. N8N 내부 모니터링

환경변수로 메트릭 활성화:

```env
N8N_METRICS=true
```

### 3. 백업 전략

1. PostgreSQL 데이터 백업:

   ```bash
   # Railway CLI를 통한 데이터베이스 접속
   railway run pg_dump -h $PGHOST -U $PGUSER -d $PGDATABASE > backup.sql
   ```

2. N8N 워크플로우 내보내기:

   - N8N UI에서 Settings → Download Backup

## 🚨 보안 권장사항

1. **강력한 암호화 키 사용**

   ```bash
   openssl rand -base64 32
   ```

2. **사용자 관리 활성화**

   ```env
   N8N_USER_MANAGEMENT_DISABLED=false
   ```

3. **HTTPS 강제 사용**

   - Railway는 기본적으로 HTTPS를 제공

4. **정기적인 백업**

   - PostgreSQL 데이터
   - N8N 워크플로우

## 📝 추가 리소스

- [Railway 공식 문서](https://docs.railway.app)
- [N8N 공식 문서](https://docs.n8n.io)
- [Railway 커뮤니티](https://discord.gg/railway)

## 💡 팁

1. **개발/스테이징 환경 분리**: Railway의 환경 기능 활용
2. **GitHub Actions 연동**: 자동 배포 파이프라인 구성
3. **비용 모니터링**: Railway 대시보드에서 사용량 확인

---

배포 중 문제가 발생하면 Railway Discord 커뮤니티나 N8N 포럼에서 도움을 받을 수 있습니다.
