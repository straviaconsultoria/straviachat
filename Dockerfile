# Base na imagem do fork
FROM ghcr.io/fazer-ai/chatwoot:latest

# Só o arquivo que você alterou
COPY app/controllers/api/v1/accounts/contacts_controller.rb /app/app/controllers/api/v1/accounts/contacts_controller.rb

# Node + npm + pnpm (projeto usa pnpm)
RUN apk add --no-cache nodejs npm && \
    npm install -g pnpm@9 && \
    pnpm --version

# Variáveis de build (dummy) e configs pnpm
ARG SECRET_KEY_BASE=dummy
ENV SECRET_KEY_BASE=${SECRET_KEY_BASE}
ENV RAILS_ENV=production
ENV PNPM_CONFIG_ENABLE_PRE_POST_SCRIPTS=true

# Instala deps JS e compila assets
# Nota: alguns pacotes pedem "approve-builds"; o -y aprova sem interação
RUN bundle install && \
    pnpm install --frozen-lockfile --prefer-offline && \
    pnpm approve-builds -y || true && \
    bundle exec rails assets:precompile

# Limpeza
RUN rm -rf /root/.npm /root/.cache /tmp/*
