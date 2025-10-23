# -----------------------------
# Stage 1: Builder (gera assets)
# -----------------------------
FROM ghcr.io/fazer-ai/chatwoot:latest AS builder

# Copia o controller modificado
COPY app/controllers/api/v1/accounts/contacts_controller.rb /app/app/controllers/api/v1/accounts/contacts_controller.rb

# Define variáveis temporárias (apenas para build)
ENV RAILS_ENV=production \
    SECRET_KEY_BASE=dummy \
    DATABASE_URL=postgres://dummy:dummy@localhost:5432/dummy \
    DISABLE_AI_AGENTS=true \
    RAILS_SKIP_ASSET_INITIALIZATION=true \
    RAILS_SKIP_DATABASE_ENVIRONMENT_CHECK=true \
    SKIP_AI_AGENT_SDK_INIT=true

# Instala dependências e pré-compila os assets
RUN apk add --no-cache nodejs npm && \
    npm install -g pnpm@10 && \
    bundle install && \
    pnpm install --frozen-lockfile --prefer-offline && \
    RAILS_ENV=production bundle exec rails assets:precompile


# -----------------------------
# Stage 2: Final (runtime)
# -----------------------------
FROM ghcr.io/fazer-ai/chatwoot:latest

# Copia o controller e os assets do builder
COPY --from=builder /app/app/controllers/api/v1/accounts/contacts_controller.rb /app/app/controllers/api/v1/accounts/contacts_controller.rb
COPY --from=builder /app/public/packs /app/public/packs

# -----------------------------
# Variáveis de ambiente reais
# -----------------------------

# Configurações básicas
ENV RAILS_ENV=production \
    NODE_ENV=production \
    LOG_LEVEL=debug \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true \
    DISABLE_AI_AGENTS=false \
    SKIP_AI_AGENT_SDK_INIT=true \
    RAILS_SKIP_ASSET_INITIALIZATION=false \
    RAILS_SKIP_DATABASE_ENVIRONMENT_CHECK=false

# Banco de dados
ENV PGHOST=postgres \
    PGPORT=5432 \
    PGUSER=${SERVICE_USER_POSTGRES} \
    PGPASSWORD=${SERVICE_PASSWORD_POSTGRES} \
    POSTGRES_DB=chatwoot_production \
    DATABASE_URL=postgres://${SERVICE_USER_POSTGRES}:${SERVICE_PASSWORD_POSTGRES}@postgres:5432/chatwoot_production

# Redis
ENV REDIS_URL=redis://default:${SERVICE_PASSWORD_REDIS}@redis:6379

# Rails secrets
ENV SECRET_KEY_BASE=${SERVICE_PASSWORD_64_SECRETKEYBASE}

# URLs principais
ENV FRONTEND_URL=https://jhorplay.straviachat.com \
    SERVICE_URL_RAILS=https://jhorplay.straviachat.com \
    ASSET_CDN_HOST=https://jhorplay.straviachat.com

# Configurações adicionais
ENV ENABLE_CUSTOM_CSS=true \
    CUSTOM_CSS_URL=http://72.60.255.85:8081/hide-phone.css \
    BAILEYS_LOG_LEVEL=error \
    BAILEYS_PROVIDER_DEFAULT_CLIENT_NAME=Chatwoot \
    BRAND_ASSETS_URL= \
    MAILER_SENDER_EMAIL= \
    RESEND_API_KEY=

# Entrypoint padrão do Chatwoot já incluso
