# 🏠 ChataHub

**A family cabin reservation system with automated payments and notifications.**

This project solves a real-world problem: the chaos of managing family cabin bookings. It replaces spreadsheets and phone calls with a modern "First Come, First Served" application built on the latest **Ruby on Rails 8.1**.

---

## 🛠 Tech Stack

- **Backend:** Ruby 3.4.4, Rails 8.1 (Service Objects, Concerns)
- **Frontend:** Hotwire (Turbo & Stimulus) via importmap, TailwindCSS 4, Propshaft asset pipeline
- **Database:** PostgreSQL, Redis (Caching/Jobs)
- **Search:** Elasticsearch + Searchkick
- **Integrations:** Stripe (Payments), Twilio (SMS), OpenWeatherMap, ActiveStorage (S3)
- **DevOps:** Docker, Kamal, GitHub Actions

---

## 🏗 Architecture & Design Patterns

The application is designed with a focus on extensibility and clean code principles (Clean Architecture), avoiding "Fat Models/Controllers" anti-patterns:

- **Service Objects:** Encapsulation of business logic (e.g., `Reservations::CreateService` for atomic reservation creation including payment).
- **Strategy Pattern:** Flexible payment processing implementation (`Payments::StrategyService`).
- **Builder Pattern:** Construction of complex Elasticsearch queries (`SearchBuilders`).
- **Metaprogramming:** Dynamic generation of notification handlers and search methods.
- **Observer Pattern:** Decoupling notifications from core business logic.

---

## ✨ Key Features

1.  **Reservations:** Real-time calendar availability, date blocking, and overlap prevention.
2.  **Payments:** Stripe integration (Apple/Google Pay) implementing a "no-refund" policy.
3.  **Notifications:** Automated SMS and emails via background jobs (Sidekiq).
4.  **Food Board:** Inventory tracking for cabin supplies.
5.  **Smart Search:** Full-text search across history and notes (Elasticsearch).

---

## 🚀 Getting Started (Docker)

The project is fully Dockerized for an easy setup.

1. Clone repository
   ```
   git clone https://github.com/LiquiNaut/ChataHub
   cd chatahub
   ```
2. Configuration
   ```
   cp .env.example .env
   ```
3. Build and Run
   ```
   docker compose up --build
   ```
4. Database Setup
   ```
   docker compose exec app bin/rails db:create db:migrate
   ```

The application runs at: `http://localhost:3000`.

> The `app` and `sidekiq` services wait for healthy `db`, `redis`, and `elasticsearch`
> containers before booting (Compose healthchecks), so the first `up` won't crash on a
> not-yet-ready database. Postgres is exposed on host port **5433** to avoid clashing
> with a local install. The `.env` file is optional for a basic boot — add it once you
> need Stripe/Twilio/weather keys (`cp .env.example .env`).

---

## 🧪 Testing

The codebase is covered by **RSpec** tests (FactoryBot, Shoulda Matchers), with a focus on
critical business logic (Service Objects). Bullet flags N+1 queries in both development and test.

```sh
bundle exec rspec                        # all specs
bundle exec rspec spec/models/cabin_spec.rb   # one file
bundle exec rubocop                      # lint (rubocop-rails-omakase)
bundle exec brakeman                     # security scan
```

---

## 🤝 Contributing

This repo follows **GitHub Flow** with Conventional Commits. Branch off `master`
(`feat/…`, `fix/…`, `chore/…`), open a PR, and merge once CI is green. See
[CONTRIBUTING.md](CONTRIBUTING.md) for the full workflow.

---

**Author:** Boris Gašparovič
