# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

ChataHub is a Rails 8 family cabin reservation system ("first come, first served" booking with Stripe
payments, Twilio SMS notifications, weather and calendar integration, and photo management). The project
is in early scaffolding stage — only the `Cabin` model exists so far.

See `docs/chatahub_project_plan.md` (feature/roadmap) and `docs/project_structure_patterns.md` (intended
architecture/design patterns) for the full target design before adding new domains.

`docs/decision_log.md` is a dated log of what was added or removed from the project and why. Check it
before re-introducing something that was dropped (e.g. Elasticsearch), and add an entry for every
notable stack/architecture decision.

## Domain Rules

Invariants every feature must respect (details and open questions in the project plan):

- **One cabin**, a closed family group of **~20 invited users**. Size solutions to that — no
  multi-tenant, search engine or scale-out machinery.
- **Invite-only**: no public sign-up and no OAuth/social login; accounts are created from invitations
  (`devise_invitable`) sent by an owner or admin.
- **Roles** (`enum :role` on `User`, enforced by Pundit): `member`, `owner` (the cabin's co-owners —
  invite people, cancel others' reservations, block dates), `admin` (also manages roles). Never name
  a role `user`.
- Reservations are **auto-confirmed** (first come, first served), **minimum 1 night**.
- Stay dates are a **half-open range `[check_in, check_out)`** — check-out day may be the next guest's
  check-in day. Overlaps are prevented by a **DB exclusion constraint**, not only a model validation.
- Price is **€5 per night**, computed server-side. Store money as **integer cents**, never floats.
- **No refunds**: a guest may cancel, but a payment is never returned.
- **Payment timing:** the guest may pay at booking but doesn't have to; payment is due **7 days after
  `check_out`**. An overdue unpaid reservation blocks creating new ones.
- **Only the system marks a payment as paid** (provider webhook / bank API, verified + idempotent) —
  no role, not even admin, has a "mark as paid" action.
- **Cancelled reservations and no-shows are not charged**; a payment already made is never refunded.
  The guest marks their own reservation `no_show` (after check-in, until the payment due date).
- **Payment providers** sit behind a strategy interface (`Payments::*Strategy`): **Stripe in test
  mode** now; later a **bank transfer to a Fio banka account**, auto-matched by variable symbol
  (= reservation ID) from the free Fio API in a Sidekiq job. Never use Stripe live keys in dev/test.
- Calendar sync is a per-user secret **iCal (.ics) feed** (`icalendar` gem), not a calendar API.

See the "Technické rozhodnutia" section of `docs/chatahub_project_plan.md` for the how.

## Tech Stack

- Ruby 3.4.4, Rails 8.1.x (do NOT upgrade to Ruby 4.0 yet — ecosystem not ready)
- PostgreSQL (primary DB), Redis (Sidekiq broker + cache)
- Hotwire (Turbo + Stimulus) + Tailwind CSS 4.x
- Propshaft asset pipeline — **no Sprockets** (sprockets-rails + Propshaft together break boot
  with a `Propshaft::Assembly` TypeError — never re-add sprockets-rails)
- Devise + Pundit for auth/authorization (invite-only; the `omniauth*` gems are not used for login)
- Active Storage + `image_processing` 2.x for photo variants — **`ruby-vips` must stay
  `require: false`**: autoloading it at boot loads libvips via FFI and crashes environments without
  it (CI runners). Active Storage requires it lazily.
- Sidekiq + sidekiq-cron for background jobs (Active Job adapter is `:sidekiq`)
- Solid Cache + Solid Cable included as Rails 8 defaults (but jobs go through Sidekiq, not Solid Queue)
- Stripe (payments), Twilio (SMS)
- RSpec + FactoryBot + Shoulda Matchers, Bullet (N+1 detection, enabled in dev **and** test)

## Commands

- **Task runner:** a `justfile` wraps the common commands (`just` lists them). Prefer it for dev work:
  `just up`, `just db-setup`, `just test [path]`, `just lint`, `just ci`, `just sh`, `just console`.
  DB-touching recipes run **inside the `app` container** (host `db` only resolves on the Docker
  network — running `bin/rails`/`rspec`/`bin/ci` on the host fails name resolution). Needs `just`
  (`sudo apt install just`). Raw equivalents below:
- Run app (Docker): `docker compose up --build`, then `docker compose exec app bin/rails db:create db:migrate`
- Run all tests: `bundle exec rspec`
- Run a single test file: `bundle exec rspec spec/models/cabin_spec.rb`
- Run a single example: `bundle exec rspec spec/models/cabin_spec.rb:14`
- Lint: `bundle exec rubocop` (Omakase style via `rubocop-rails-omakase`)
- Security scan: `bundle exec brakeman`
- Annotate model schema comments: `bin/rails annotate` (via the `annot8` gem)

## Workflow

- Default branch is **`master`** (not `main`). Follow **GitHub Flow** — no `develop` or deploy
  branch; releases are tags (`v0.x.0` per milestone). See `CONTRIBUTING.md`.
- **Always** follow the formats in `CONTRIBUTING.md` and the `.github/` templates:
  - **Issue** (one per branch/PR, in a milestone): title `<type>(<scope>): …` in English + matching
    label; body in Slovak with *Čo a prečo*, *Úlohy*, *Technológie* (new tech: what it is → how it's
    used here), *Edge cases* (bullets), *Hotovo, keď*.
  - **Branch:** `<type>/<issue-number>-<short-kebab-description>`, e.g. `feat/12-devise-auth`.
  - **PR:** same title as the issue, body in English mirroring the issue sections, `Closes #<issue>`.
  - **Commits:** Conventional Commits.
- CI (`.github/workflows/ci.yml`) runs three jobs on PRs and pushes to `master`:
  `scan_ruby` (Brakeman), `scan_js` (`bin/importmap audit`), `lint` (RuboCop). There is
  **no RSpec job in CI** — run `bundle exec rspec` locally before pushing.
- JS is wired via **importmap-rails** (`config/importmap.rb`, `app/javascript/application.js`,
  `bin/importmap`); the layout loads it with `javascript_importmap_tags`. Add packages with
  `bin/importmap pin <pkg>`, not npm/yarn.
- **Dependency updates:** green CI ≠ working app (CI runs no tests and never boots the app). For
  major-version bumps read the changelog and verify in the container (`just upd`, `just test`, boot
  `/up`). Watch for dependencies a bump silently drops from `Gemfile.lock`.
- **Language:** project docs (`docs/*.md` — plan, decision log) and issue bodies are in **Slovak**;
  code, comments, README, issue/PR titles, commit messages and PR descriptions are in **English**.

## Testing

- TDD for domain logic: write the failing spec first.
- Model specs (Shoulda Matchers for validations/associations), policy specs for Pundit, and
  **request specs** for HTTP behaviour — no controller specs.
- Test data via FactoryBot factories in `spec/factories/`.
- Run through the container: `just test [path]`.

## Architecture Patterns

`docs/project_structure_patterns.md` is **aspirational, not mandatory**. Prefer the plain Rails way;
introduce a pattern (decorator, event bus, builder, metaprogramming…) only when a real need appears,
and record it in the decision log. As features are built out, follow these conventions:

- **Service Objects** in `app/services/` for business logic (e.g. `Reservations::CreateService`,
  `Payments::ProcessService`) — keep controllers and models thin.
- **Strategy pattern** for payment processing variants (`Payments::StrategyService`).
- Background work (SMS, email, weather fetch, calendar sync) goes through Sidekiq jobs in `app/jobs/`.
- Models carry `# == Schema Information` annotation comments (kept in sync via `annot8`);
  regenerate after migrations rather than hand-editing them.

## Current State

Keep this section short and update it at every milestone.

Only the `Cabin` model is implemented (with RSpec + factory). No User/Devise, Reservation, or
Payment models exist yet. Next milestone: Devise authentication + User model (invite-only
registration, roles), then Reservation core with overlap prevention (TDD).

## Development Environment

- Docker Compose for services (Postgres, Redis) — see `compose.yml`. `app`/`sidekiq`
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
