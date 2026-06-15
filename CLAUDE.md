# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

ChataHub is a Rails 8 family cabin reservation system ("first come, first served" booking with Stripe
payments, Twilio SMS notifications, weather and calendar integration, photo management, and Elasticsearch
search). The project is in early scaffolding stage — only the `Cabin` model exists so far.

See `docs/chatahub_project_plan.md` (feature/roadmap) and `docs/project_structure_patterns.md` (intended
architecture/design patterns) for the full target design before adding new domains.

## Tech Stack

- Ruby 3.4.4, Rails 8.1.x (do NOT upgrade to Ruby 4.0 yet — ecosystem not ready)
- PostgreSQL (primary DB), Redis (Sidekiq broker + cache)
- Hotwire (Turbo + Stimulus) + Tailwind CSS 4.x
- Propshaft asset pipeline — **no Sprockets** (sprockets-rails + Propshaft together break boot
  with a `Propshaft::Assembly` TypeError — never re-add sprockets-rails)
- Devise + Pundit for auth/authorization
- Sidekiq + sidekiq-cron for background jobs (Active Job adapter is `:sidekiq`)
- Solid Cache + Solid Cable included as Rails 8 defaults (but jobs go through Sidekiq, not Solid Queue)
- Stripe (payments), Twilio (SMS), Searchkick + Elasticsearch (search)
- RSpec + FactoryBot + Shoulda Matchers, Bullet (N+1 detection, enabled in dev **and** test)

## Commands

- Run app (Docker): `docker compose up --build`, then `docker compose exec app bin/rails db:create db:migrate`
- Run all tests: `bundle exec rspec`
- Run a single test file: `bundle exec rspec spec/models/cabin_spec.rb`
- Run a single example: `bundle exec rspec spec/models/cabin_spec.rb:14`
- Lint: `bundle exec rubocop` (Omakase style via `rubocop-rails-omakase`)
- Security scan: `bundle exec brakeman`
- Annotate model schema comments: `bin/rails annotate` (via the `annot8` gem)

## Workflow

- Default branch is **`master`** (not `main`). Follow **GitHub Flow**: branch off `master`
  (`feat/…`, `fix/…`, `chore/…`, `docs/…`), open a PR, merge once CI is green. Branch names
  and commit messages follow **Conventional Commits**. See `CONTRIBUTING.md`.
- CI (`.github/workflows/ci.yml`) runs three jobs on PRs and pushes to `master`:
  `scan_ruby` (Brakeman), `scan_js` (`bin/importmap audit`), `lint` (RuboCop). There is
  **no RSpec job in CI** — run `bundle exec rspec` locally before pushing.
- JS is wired via **importmap-rails** (`config/importmap.rb`, `app/javascript/application.js`,
  `bin/importmap`); the layout loads it with `javascript_importmap_tags`. Add packages with
  `bin/importmap pin <pkg>`, not npm/yarn.

## Architecture Patterns (per docs/project_structure_patterns.md)

As features are built out, follow these conventions:

- **Service Objects** in `app/services/` for business logic (e.g. `Reservations::CreateService`,
  `Payments::ProcessService`) — keep controllers and models thin.
- **Strategy pattern** for payment processing variants (`Payments::StrategyService`).
- **Builder pattern** for constructing Elasticsearch queries (`SearchBuilders`).
- **Searchable concern** (metaprogramming-based) for adding Elasticsearch indexing/search methods
  to models — see the `Searchable` concern example in `docs/project_structure_patterns.md`.
- Background work (SMS, email, weather fetch, calendar sync, search indexing) goes through
  Sidekiq jobs in `app/jobs/`.
- Models carry `# == Schema Information` annotation comments (kept in sync via `annot8`);
  regenerate after migrations rather than hand-editing them.

## Current State

Only the `Cabin` model is implemented (with RSpec + factory). No User/Devise, Reservation, or
Payment models exist yet. Next milestone: Devise authentication + User model (invite-only
registration), then Reservation core with overlap prevention (TDD).

## Development Environment

- Docker Compose for services (Postgres, Redis, Elasticsearch) — see `compose.yml`. `app`/`sidekiq`
  wait for healthy dependencies. Postgres is on host port **5433** (dev DB `chata_hub_development`);
  `bundle exec rspec`/`bin/rails` outside the containers need that DB running or they fail with a
  Postgres connection/auth error.
- App code lives in WSL2 filesystem (`~/projects/chatahub`), NOT in `/mnt/c/` — critical for
  I/O performance
- VSCode + Remote WSL as primary editor
- Dockerfile uses `ruby:3.4.4-alpine`; if native gem build issues arise, switch to
  `ruby:3.4.4-slim` (Debian-based)

## Mobile Strategy

Hotwire web app + PWA (manifest already in `app/views/pwa/`). Hotwire Native for iOS/Android
app-store presence planned as a later milestone — no React, no separate SPA frontend.
