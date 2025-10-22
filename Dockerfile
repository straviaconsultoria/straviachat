# Baseia-se na imagem oficial atual do fork
FROM ghcr.io/fazer-ai/chatwoot:latest

# Copia apenas o arquivo que você modificou
COPY app/controllers/api/v1/accounts/contacts_controller.rb /app/app/controllers/api/v1/accounts/contacts_controller.rb

# Instala o Yarn (necessário para compilar os assets do Rails)
RUN apt-get update && apt-get install -y yarn && rm -rf /var/lib/apt/lists/*

# Recompila o app para garantir que tudo funcione
RUN bundle install && \
    yarn install --frozen-lockfile && \
    RAILS_ENV=production bundle exec rails assets:precompile
