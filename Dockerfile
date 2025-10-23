# -----------------------------
# Stage 1: Builder (gera assets)
# -----------------------------
FROM ghcr.io/fazer-ai/chatwoot:latest AS builder

# Copia o controller modificado
COPY app/controllers/api/v1/accounts/contacts_controller.rb /app/app/controllers/api/v1/accounts/contacts_controller.rb

# define variáveis “dummy” só pro build
ENV RAILS_ENV=production
ENV SECRET_KEY_BASE=dummy
ENV DATABASE_URL=postgres://dummy:dummy@localhost:5432/dummy
ENV DISABLE_AI_AGENTS=true
ENV RAILS_SKIP_ASSET_INITIALIZATION=true
ENV RAILS_SKIP_DATABASE_ENVIRONMENT_CHECK=true
ENV SKIP_AI_AGENT_SDK_INIT=true

# instala dependências e pré-compila assets
RUN apk add --no-cache nodejs npm && \
    npm install -g pnpm@10 && \
    bundle install && \
    pnpm install --frozen-lockfile --prefer-offline && \
    RAILS_ENV=production bundle exec rails assets:precompile


# -----------------------------
# Stage 2: Final (limpo)
# -----------------------------
FROM ghcr.io/fazer-ai/chatwoot:latest

# copia o controller e os assets do builder
COPY --from=builder /app/app/controllers/api/v1/accounts/contacts_controller.rb /app/app/controllers/api/v1/accounts/contacts_controller.rb
COPY --from=builder /app/public/packs /app/public/packs

# remove qualquer resquício de ENV dummy
ENV DATABASE_URL=""
ENV PGHOST=""
ENV PGUSER=""
ENV PGPASSWORD=""
ENV DISABLE_AI_AGENTS=false

# ponto de entrada padrão do Chatwoot (já incluso)
