k# Base na imagem oficial do fork do Chatwoot
FROM ghcr.io/fazer-ai/chatwoot:latest

# Copia apenas o arquivo de controller alterado
COPY app/controllers/api/v1/accounts/contacts_controller.rb /app/app/controllers/api/v1/accounts/contacts_controller.rb

# Instala Node.js + npm + pnpm (Chatwoot usa pnpm 10.x)
RUN apk add --no-cache nodejs npm && \
    npm install -g pnpm@10 && \
    pnpm --version

# Define variáveis de ambiente para evitar inicializações de banco e IA durante o build
ENV RAILS_ENV=production
ENV SECRET_KEY_BASE=dummy
ENV DATABASE_URL=postgres://dummy:dummy@localhost:5432/dummy
ENV DISABLE_AI_AGENTS=true
ENV SKIP_AI_AGENT_SDK_INIT=true
ENV RAILS_SKIP_ASSET_INITIALIZATION=true
ENV RAILS_SKIP_DATABASE_ENVIRONMENT_CHECK=true
ENV PNPM_CONFIG_ENABLE_PRE_POST_SCRIPTS=true

# Instala dependências e compila os assets sem inicializar módulos que dependem de banco
RUN bundle install && \
    pnpm install --frozen-lockfile --prefer-offline && \
    pnpm approve-builds -y || true && \
    RAILS_ENV=production bundle exec rake assets:precompile

# Limpeza final para reduzir o tamanho da imagem
RUN rm -rf /root/.npm /root/.cache /tmp/*

