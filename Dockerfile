# Baseia-se na imagem oficial atual do fork
FROM ghcr.io/fazer-ai/chatwoot:latest

# Copia apenas o arquivo que você modificou
COPY app/controllers/api/v1/accounts/contacts_controller.rb /app/app/controllers/api/v1/accounts/contacts_controller.rb

# Instala Node.js, npm e Yarn 3 (sem Corepack)
RUN apk add --no-cache nodejs npm && \
    npm install -g yarn@3.6.4

# Recompila o app para garantir que tudo funcione
RUN bundle install && \
    yarn install --frozen-lockfile && \
    RAILS_ENV=production bundle exec rails assets:precompile
