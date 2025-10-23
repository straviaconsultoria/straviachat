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
ENV RAILS_ENV=production \
    NODE_ENV=production \
    LOG_LEVEL=debug \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true \
    SECRET_KEY_BASE=1I5hjKlNPW2k2p2jzhMG4YnkAdkhyrybBBfIgaAxKU8gbXhBx7E20K21fM1Y8YaU \
    DATABASE_URL=postgres://MW7vPG17HjwCCQaK:ssjU8fOcsjl3xTvzoJASS8ZGIcy1S8lu@postgres:5432/chatwoot_production \
    REDIS_URL=redis://default:muJaC79tReLegzdZnfwfzGs1SznC5Y4O@redis:6379 \
    FRONTEND_URL=https://jhorplay.straviachat.com \
    SERVICE_URL_RAILS=https://jhorplay.straviachat.com \
    SERVICE_FQDN_RAILS=jhorplay.straviachat.com \
    ENABLE_CUSTOM_CSS=true \
    CUSTOM_CSS_URL=http://72.60.255.85:8081/hide-phone.css \
    DISABLE_AI_AGENTS=true \
    SKIP_AI_AGENT_SDK_INIT=true

# -----------------------------
# Correção de variáveis PG*
# -----------------------------
ENV PGHOST=postgres \
    PGPORT=5432 \
    PGUSER=MW7vPG17HjwCCQaK \
    PGPASSWORD=ssjU8fOcsjl3xTvzoJASS8ZGIcy1S8lu \
    POSTGRES_HOST=postgres \
    POSTGRES_PORT=5432 \
    POSTGRES_USERNAME=MW7vPG17HjwCCQaK \
    POSTGRES_PASSWORD=ssjU8fOcsjl3xTvzoJASS8ZGIcy1S8lu \
    POSTGRES_DB=chatwoot_production

# -----------------------------
# Ponto de entrada padrão
# -----------------------------
CMD ["/app/docker/entrypoints/rails.sh"]
