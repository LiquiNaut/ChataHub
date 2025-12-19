# 🏠 ChataHub

**A family cabin reservation system with automated payments and notifications.**

This project solves a real-world problem: the chaos of managing family cabin bookings. It replaces spreadsheets and phone calls with a modern "First Come, First Served" application built on the latest **Ruby on Rails 8**.

---

## 🛠 Tech Stack

- **Backend:** Ruby 3.4.4, Rails 8 (Service Objects, Concerns)
- **Frontend:** Hotwire (Turbo & Stimulus), TailwindCSS
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
   ```bash
   cp .env.example .env
   ```
3. Build and Run
   ```
   docker compose up --build
   ```
4. Database Setup
   ```
   docker compose exec app bin/rails db:create
   docker compose exec app bin/rails db:migrate
   ```

The application runs at: `http://localhost:3000`

---

## 🧪 Testing

The codebase is covered by **RSpec** tests, with a focus on critical business logic (Service Objects).

---

**Author:** Boris Gašparovič
