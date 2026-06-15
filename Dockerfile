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
# vips = runtime knižnica pre image_processing/ruby-vips (ActiveStorage varianty fotiek).
# Builder má vips-dev (na build gemu), runner potrebuje runtime vips, inak spracovanie fotiek spadne.
RUN apk add --no-cache libpq postgresql-client tzdata vips

# Skopírovanie závislostí z builder stage
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app /app

# Nastavenie pracovného adresára
WORKDIR /app

# Skopírovanie zvyšku aplikácie
COPY . .

# Fix line endings for Windows
RUN sed -i 's/\r$//' bin/* && chmod +x bin/*

# Spustenie servera
EXPOSE 3000
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]