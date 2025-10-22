# Baseia-se na imagem oficial atual do fork
FROM ghcr.io/fazer-ai/chatwoot:latest

# Copia apenas o arquivo modificado
COPY app/controllers/api/v1/accounts/contacts_controller.rb /app/app/controllers/api/v1/accounts/contacts_controller.rb

# Instala Node.js, npm e pnpm (requerido pelo package.json)
RUN apk add --no-cache nodejs npm && \
    npm install -g pnpm && \
    pnpm --version

# Recompila o app para garantir que tudo funcione
RUN bundle install && \
    pnpm install --frozen-lockfile && \
    RAILS_ENV=production bundle exec rails assets:precompile

# Mantém a imagem leve
RUN rm -rf /root/.npm /root/.cache /tmp/*
