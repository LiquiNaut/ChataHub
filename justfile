# ChataHub task runner — run `just` to list recipes.
# DB-dependent commands run inside the `app` container because config/database.yml
# uses host `db` (a Docker-network name that doesn't resolve on the host).

# Show all recipes
default:
    @just --list

# --- Docker lifecycle ---

# Build + start all services (foreground)
up:
    docker compose up --build

# Build + start all services (detached)
upd:
    docker compose up --build -d

# Stop services (keep data)
down:
    docker compose down

# Stop services + wipe volumes (full reset)
reset:
    docker compose down -v

# Tail logs of all services
logs:
    docker compose logs -f

# Open a shell in the app container
sh:
    docker compose exec app bash

# --- Rails ---

# Rails console
console:
    docker compose exec app bin/rails console

# Create + migrate the database
db-setup:
    docker compose exec app bin/rails db:create db:migrate

# Run pending migrations
migrate:
    docker compose exec app bin/rails db:migrate

# Refresh model schema annotations (annot8)
annotate:
    docker compose exec app bin/rails annotate

# --- Tests & checks (mirrors CI) ---

# Run the RSpec suite (pass a path to scope, e.g. `just test spec/models`)
test *args:
    docker compose exec app bundle exec rspec {{ args }}

# RuboCop lint
lint:
    docker compose exec app bundle exec rubocop

# RuboCop autocorrect
lint-fix:
    docker compose exec app bundle exec rubocop -a

# Brakeman security scan
brakeman:
    docker compose exec app bundle exec brakeman

# Importmap vulnerability audit
audit:
    docker compose exec app bin/importmap audit

# Full CI bundle (runs inside the container so the DB host resolves)
ci:
    docker compose exec app bin/ci
