.PHONY: help up down restart logs ps clean backup prune

# 기본 변수 설정
DOCKER_COMPOSE = docker-compose
COMPOSE_FILE = docker-compose.yml
BACKUP_DIR = ./backups

# 현재 날짜와 시간 포맷 (백업 파일명에 사용)
DATE := $(shell date +%Y%m%d_%H%M%S)

# 기본 명령어 - 도움말 표시
help:
	@echo "n8n Docker Compose 관리를 위한 Makefile"
	@echo ""
	@echo "사용법:"
	@echo "  make up        - n8n 서비스 시작"
	@echo "  make down      - n8n 서비스 중지"
	@echo "  make restart   - n8n 서비스 재시작"
	@echo "  make logs      - n8n 로그 확인 (Ctrl+C로 종료)"
	@echo "  make ps        - 컨테이너 상태 확인"
	@echo "  make clean     - 컨테이너 중지 및 볼륨 삭제 (주의: 모든 데이터 삭제)"
	@echo "  make backup    - n8n 데이터 백업"
	@echo "  make prune     - 미사용 Docker 리소스 정리"

# n8n 서비스 시작
up:
	@echo "n8n 서비스를 시작합니다..."
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) up -d
	@echo "n8n이 http://localhost:5678 에서 실행 중입니다."

# n8n 서비스 중지
down:
	@echo "n8n 서비스를 중지합니다..."
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) down

# n8n 서비스 재시작
restart:
	@echo "n8n 서비스를 재시작합니다..."
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) restart

# n8n 서비스 로그 확인
logs:
	@echo "n8n 로그를 표시합니다... (종료: Ctrl+C)"
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) logs -f n8n

# 전체 로그 확인 (n8n + postgres)
logs-all:
	@echo "모든 서비스 로그를 표시합니다... (종료: Ctrl+C)"
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) logs -f

# 컨테이너 상태 확인
ps:
	@echo "컨테이너 상태:"
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) ps

# 서비스 중지 및 볼륨 삭제 (주의: 모든 데이터 삭제)
clean:
	@echo "주의: 이 작업은 모든 n8n 데이터를 삭제합니다!"
	@read -p "계속하시겠습니까? (y/n): " confirm && [ $$confirm = "y" ] || exit 1
	@echo "n8n 서비스를 중지하고 볼륨을 삭제합니다..."
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) down -v

# n8n 데이터 백업
backup:
	@echo "n8n 데이터를 백업합니다..."
	@mkdir -p $(BACKUP_DIR)
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) exec postgres pg_dump -U n8n n8n > $(BACKUP_DIR)/n8n_db_$(DATE).sql
	@echo "데이터베이스가 $(BACKUP_DIR)/n8n_db_$(DATE).sql 에 백업되었습니다."
	@echo "워크플로우 및 설정 데이터를 백업합니다..."
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) exec n8n mkdir -p /backup
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) exec n8n tar -czf /backup/n8n_data_$(DATE).tar.gz /home/node/.n8n
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) cp n8n:/backup/n8n_data_$(DATE).tar.gz $(BACKUP_DIR)/
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) exec n8n rm -rf /backup
	@echo "n8n 데이터가 $(BACKUP_DIR)/n8n_data_$(DATE).tar.gz 에 백업되었습니다."

# 미사용 Docker 리소스 정리
prune:
	@echo "미사용 Docker 리소스를 정리합니다..."
	docker system prune -f
	@echo "완료되었습니다."

# 데이터베이스 복원 (백업 파일 지정 필요)
restore-db:
	@echo "데이터베이스를 복원합니다..."
	@if [ -z "$(file)" ]; then \
		echo "사용법: make restore-db file=백업파일경로.sql"; \
		exit 1; \
	fi
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) exec -T postgres psql -U n8n n8n < $(file)
	@echo "데이터베이스가 복원되었습니다."