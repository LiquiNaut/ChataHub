# chatahub/Dockerfile

# --- Builder Stage ---
# Použije presnú verziu Ruby z tvojho plánu
FROM ruby:3.4.4-alpine AS builder

# Inštalácia závislostí pre buildovanie gemov
RUN apk add --no-cache build-base git libpq-dev postgresql-client nodejs npm yaml-dev vips-dev

# Nastavenie pracovného adresára
WORKDIR /app

# Inštalácia gemov
COPY Gemfile Gemfile.lock ./
RUN test -f Gemfile.lock || bundle lock
RUN bundle install

# --- Runner Stage ---
# Použije rovnakú base image pre menší finálny image
FROM ruby:3.4.4-alpine AS runner

# Inštalácia run-time závislostí
RUN apk add --no-cache libpq postgresql-client tzdata

# Skopírovanie závislostí z builder stage
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app /app

# Nastavenie pracovného adresára
WORKDIR /app

# Skopírovanie zvyšku aplikácie
COPY . .

# Spustenie servera
EXPOSE 3000
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]