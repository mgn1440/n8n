FROM n8nio/n8n:latest

# Railway가 제공하는 PORT 환경변수 사용
ENV N8N_PORT=$PORT

# 포트 노출 (Railway는 자동으로 $PORT를 사용)
EXPOSE 5678

# N8N 실행 사용자 설정
USER node

# 헬스체크 추가
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:$PORT/healthz || exit 1

# N8N 실행
CMD ["n8n"]