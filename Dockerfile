# Baseia-se na imagem oficial atual do fork
FROM ghcr.io/fazer-ai/chatwoot:latest

# Copia apenas o arquivo que você modificou
COPY app/controllers/api/v1/accounts/contacts_controller.rb /app/app/controllers/api/v1/accounts/contacts_controller.rb

# Instala Node.js e npm, ativa o Corepack e prepara o Yarn moderno (v4+)
RUN apk add --no-cache nodejs npm && \
    npm install -g corepack && \
    corepack enable && \
    corepack prepare yarn@stable --activate && \
    yarn --version

# Recompila o app para garantir que tudo funcione
RUN bundle install && \
    yarn install --check-files --frozen-lockfile || yarn install --force && \
    RAILS_ENV=production bundle exec rails assets:precompile

# Mantém a imagem leve
RUN rm -rf /root/.npm /root/.cache /tmp/*
