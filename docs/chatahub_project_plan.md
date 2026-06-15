# 🏠 **ChataHub - Rodinný Rezervačný Systém**

## 📋 **Projekt Overview**

**ChataHub** je jednoduchý rezervačný systém pre správu jednej rekreačnej chaty pre rodinnú skupinu s automatickými rezerváciami (prvý príde, prvý má) a integrovanými platbami.

---

## 🎯 **Hlavný cieľ projektu**

Ukázať schopnosť navrhnúť, implementovať a nasadiť produkčne pripravenú webovú aplikáciu s moderným fullstack stackom, TDD prístupom, CI/CD pipeline, integráciou platieb a škálovateľnou architektúrou.

---

## 🛠️ **Tech Stack**

| Vrstva              | Technológia                                   |
| ------------------- | --------------------------------------------- |
| **Ruby/Rails**      | Ruby 3.4.4 + Rails 8.1                       |
| **Frontend**        | Hotwire (Turbo + Stimulus) + Tailwind CSS    |
| **UI Components**   | Flowbite + TailwindUI                        |
| **Database**        | PostgreSQL (primárna) + Redis (cache/jobs)   |
| **Search**          | Elasticsearch + Searchkick gem               |
| **Deploy**          | Kamal + Docker (na Fly.io alebo Railway)     |
| **Storage**         | ActiveStorage + cloud (S3/Cloudflare R2)     |
| **Auth**            | Devise + Pundit (autorizácia)                |
| **Jobs**            | Sidekiq (notifikácie, cleanup)               |
| **Payments**        | Stripe (Apple Pay + Google Pay)              |
| **Testing**         | RSpec + FactoryBot + SimpleCov               |
| **CI/CD**           | GitHub Actions                               |
| **Dev tooling**     | just (task runner) + Docker Compose          |

---

## ✨ **Core Features**

### 🏠 **Chata Management**
- **Jedna chata** s fotkami, popisom, pravidlami
- **Lokalizácia** pre weather API

### 👨‍👩‍👧‍👦 **User Management**
- **Rodinná skupina** - pozvaní členovia cez email
- **Role**: Admin (ty) + Family Members
- **Profily** s avatar, telefón, preferencie

### 📅 **Rezervácie - "First Come, First Served"**
- **Kalendárový výber** s real-time dostupnosťou
- **Automatické potvrdenie** (žiadne čakanie na schválenie)
- **Vlastné zrušenie** rezervácie (platba sa nevráti)
- **Overlapping prevention** - nemožnosť rezervovať obsadené termíny
- **Minimálna dĺžka pobytu** (napr. min. 2 dni)
- **Blokovanie** ďalších rezervácií pri nezaplatenej existujúcej

### 💳 **Platby**
- **Stripe integrácia** pre Apple Pay + Google Pay
- **Pevná cena**: 5€ za noc
- **No refunds** - platba ostáva na účte chaty
- **Revolut** ako cieľový účet
- **Unpaid reservations** blokujú nové rezervácie

### 🔔 **Notifikácie**
- **SMS cez Twilio** po vytvorení/zrušení rezervácie
- **Prednastavené čísla**: otec, jeho sestra, brat, rodičia
- **Email** upomienky 3 dni pred začiatkom

### 🌤️ **Weather Integration**
- **Weather API** - predpoveď počasia pre vybratý dátum
- **Lokálna predpoveď** pre lokalizáciu chaty

### 📋 **Food Board (Nástenka)**
- **Potraviny** - čo sa donieslo/zjedlo/treba dokúpiť
- **Jednoduchý CRUD** s checkboxmi
- **Per-reservation** tracking

### 📸 **Photo Management**
- **Upload fotiek** pre chatu a rezervácie
- **ActiveStorage** + cloud storage
- **View & download** pre všetkých userov
- **Lazy loading** a optimalizácia

### 🔍 **Elasticsearch Search**
- **Full-text search** cez rezervácie, userrov, poznámky
- **Faceted search** - filtrovanie podľa dátumu, usera
- **Autocomplete** suggestions
- **Search analytics** pre admin

### 🧩 **Metaprogramovanie**
- **Dynamic notification handlers** pre rôzne typy eventov
- **Flexible pricing rules** system
- **Auto-generated API endpoints**
- **Dynamic validation rules**

### 📊 **Simple Analytics**
- **Základné štatistiky**: počet rezervácií, revenue, top users
- **Mesačné prehľady** pre admin
- **Jednoduché grafy** (Chart.js)

### 📅 **Calendar Sync**
- **Apple Calendar** sync pre iOS users
- **Google Calendar** sync pre Android users
- **Automatic event creation** po potvrdení rezervácie

---

## 🏗️ **Architektúra**

### **Models**
```ruby
# Core models
User (Devise)
Cabin (singleton - jedna chata)
Reservation 
Payment (Stripe)
Photo (ActiveStorage attachments)
FoodItem (nástenka)

# Search & Analytics
SearchableRecord (metaprogramming base)
SearchAnalytics
EventLog

# Support models
Notification
WeatherCache
CalendarSync
```

### **Services**
```ruby
# Business logic v service objektoch
Reservations::CreateService
Reservations::CancelService
Payments::ProcessService
Notifications::SendSmsService
Weather::FetchService
Calendar::SyncService
Photos::ProcessService
Search::IndexService
```

### **Jobs**
```ruby
# Background processing
SendSmsNotificationJob
SyncCalendarJob
FetchWeatherJob
SendEmailReminderJob
PhotoProcessingJob
SearchIndexJob
```

---

## 🎯 **Prečo je to skvelé pre junior pohovor:**

### 1. **Real-world Problem Solving**
> "Vyriešil som skutočný problém v našej rodine - plánovanie chaty bolo chaotické, teraz máme automatizovaný systém s platbami."

### 2. **Modern Rails Stack**
> "Použil som najnovší Rails 8.1 s Ruby 3.4.4, Hotwire pre reactive UI, Tailwind CSS s Flowbite komponentmi a Elasticsearch pre pokročilé vyhľadávanie."

### 3. **Unique Features**
> "Implementoval som photo management s ActiveStorage, metaprogramovanie pre dynamické handlery, Elasticsearch search a calendar sync s Apple/Google kalendárom."

### 4. **Metaprogramovanie**
> "Použil som metaprogramovanie pre dynamické notification handlery a flexible business logic, čo ukázalo schopnosť písať DRY a rozšíriteľný kód."

### 5. **Full-text Search**
> "Implementoval som Elasticsearch s autocomplete a faceted search, čo bola skvelá praktika s NoSQL databázou a search engineom."

---

## 📊 **Jednoduché Technické Riešenie**

### **Database Design**
- **Základné Postgres** setup
- **Foreign keys** a jednoduché indexy
- **Štandardné Rails migrations**

### **Security**
- **Devise** pre authentication
- **Pundit** pre basic authorization
- **Rails defaults** pre CSRF a basic security

### **Simple Testing**
- **RSpec** - model + request tests
- **FactoryBot** pre test data
- **Fokus na business logic**, nie edge cases

### **Integrácie**
- **Stripe** pre platby
- **Twilio** pre SMS
- **OpenWeatherMap** pre počasie
- **Apple/Google Calendar APIs**
- **Elasticsearch** pre search
- **ActiveStorage** + cloud storage

---

## 🚀 **Deployment & DevOps**

### **Docker Setup**
```dockerfile
# Multi-stage build
FROM ruby:3.4.4-alpine AS builder
# optimized layers
FROM ruby:3.4.4-alpine AS runner
```

### **Kamal Configuration**
```yaml
# deploy.yml
service: chatahub
image: chatahub
servers:
  - your-server.com
registry:
  server: ghcr.io
```

### **CI/CD Pipeline**
```yaml
# .github/workflows/ci.yml
- RSpec tests
- Security scan (brakeman)
- Code quality (rubocop)
- Build & deploy
```

---

## 💡 **BONUS Features**

- **Dark mode** support s Tailwind
- **Photo management** s ActiveStorage
- **Elasticsearch** search s autocomplete
- **Metaprogramovanie** pre dynamic handlers
- **Calendar sync** (Apple/Google)
- **Weather integration** pre planning
- **Food board** pre household management
- **Simple analytics** dashboard
- **SMS notifications** cez Twilio

---

## ✅ **Čo to prezentuje o tebe:**

| Skill                    | Dôkaz v projekte                           |
| ------------------------ | ------------------------------------------ |
| **Business Understanding** | Practical solution, no-refund policy     |
| **Modern Rails**         | Rails 8.1, Hotwire, Tailwind + Flowbite  |
| **Search & NoSQL**       | Elasticsearch implementation              |
| **Metaprogramovanie**    | Dynamic handlers, flexible architecture  |
| **File Management**      | ActiveStorage + cloud integration        |
| **API Integration**      | Stripe, Twilio, Weather, Calendar sync   |
| **Frontend Skills**      | Stimulus, Turbo, responsive design       |

---

## 🔧 **Implementácia Timeline**

### **Week 1-2: Core Setup**
- Rails 8.1 + Ruby 3.4.4 setup
- Basic models + migrations
- Devise authentication
- Basic UI s Tailwind

### **Week 3-4: Core Features**
- Reservation system + calendar UI
- Payment integration (Stripe)
- SMS notifications (Twilio)
- Photo upload + management

### **Week 5-6: Advanced Features**
- Elasticsearch setup + search
- Metaprogramovanie patterns
- Weather API integration
- Calendar sync (Apple/Google)

### **Week 7-8: Polish & Deploy**
- Food board functionality
- Dark mode + UI polish
- Simple analytics dashboard
- Docker + Kamal deployment

---

**Chceš začať s implementáciou? Môžem ti pripraviť initial Rails setup s všetkými gemami a Docker konfiguráciou!** 🚀