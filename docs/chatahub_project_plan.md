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
| **Deploy**          | Kamal + Docker (na Fly.io alebo Railway)     |
| **Storage**         | ActiveStorage + cloud (S3/Cloudflare R2)     |
| **Auth**            | Devise + Pundit (autorizácia)                |
| **Jobs**            | Sidekiq (notifikácie, cleanup)               |
| **Payments**        | Stripe (test mód) → neskôr prevod + Fio API   |
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
- **Role**: `member` (člen rodiny), `owner` (majitelia chaty – 3 súrodenci), `admin` (správca aplikácie)
- **Registrácia len cez pozvánku** od admina/ownera, prihlásenie e-mailom + heslom (bez Google loginu)
- **Profily** s avatar, telefón, preferencie

### 📅 **Rezervácie - "First Come, First Served"**
- **Kalendárový výber** s real-time dostupnosťou
- **Automatické potvrdenie** (žiadne čakanie na schválenie)
- **Vlastné zrušenie** rezervácie (platba sa nevráti)
- **Overlapping prevention** - nemožnosť rezervovať obsadené termíny
- **Minimálna dĺžka pobytu**: 1 noc
- **Blokovanie** ďalších rezervácií pri nezaplatenej existujúcej
- **Kto ide**: k rezervácii sa dajú pridať členovia rodiny a počet ďalších dospelých hostí bez účtu, plus voliteľná poznámka
- **Mená sú viditeľné všetkým**: v kalendári je vidno, kto má termín; po kliknutí aj spolucestujúcich a poznámku

### 💳 **Platby**
- **Platobná brána**: Stripe (počas vývoja v test móde); neskôr prevod na účet vo Fio banke s automatickým párovaním cez Fio API
- **Cena**: 5 € za osobu a noc (rezervujúci + vybraní členovia + ďalší dospelí hostia); **deti zadarmo** (uvedú sa v poznámke)
- **Zaplatiť hneď** pri rezervácii je možné, ale nie povinné; **najneskôr do 7 dní po skončení pobytu**
- **Platbu označuje ako zaplatenú iba systém** (po potvrdení od platobnej brány), nikdy človek
- **Zrušená rezervácia a „no-show“ sa neplatia**; ak už bola zaplatená, peniaze sa nevracajú (no refunds)
- **Cieľový účet**: spravuje ho jedna z ownerov (banka zatiaľ neznáma)
- **Unpaid reservations** po termíne splatnosti blokujú nové rezervácie

### 🔔 **Notifikácie**
- **SMS cez Twilio** po vytvorení/zrušení rezervácie
- **Prednastavené čísla**: otec, jeho sestra, brat, rodičia
- **Email** upomienky 3 dni pred začiatkom

### 🌤️ **Weather Integration**
- **Weather API** - predpoveď počasia pre vybratý dátum
- **Lokálna predpoveď** pre lokalizáciu chaty

### 📋 **Nástenka**
- **Poznámky** – odkazy pre rodinu s menom autora a dátumom; majitelia môžu poznámku pripnúť navrch
- **Zásoby** – zoznam vecí na chatu so zaškrtnutím „donesené“ a menom, kto položku pridal
- Zatiaľ bez komentárov a reakcií

### 📸 **Photo Management**
- **Upload fotiek** pre chatu a rezervácie
- **ActiveStorage** + cloud storage
- **View & download** pre všetkých userov
- **Lazy loading** a optimalizácia

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
- **iCal (.ics) feed** – každý používateľ má tajnú URL, ktorú si raz pridá ako odber do Apple aj Google kalendára
- Bez OAuth a API kľúčov; rezervácie sa v kalendári objavia automaticky (Google obnovuje odbery raz za pár hodín)

---

## 🧭 **Technické rozhodnutia**

Ako presne dosiahneme kľúčové funkcie. Prečo sme sa rozhodli tak, ako sme sa rozhodli, je v
[decision logu](decision_log.md).

### 📅 Prekrývanie rezervácií (first come, first served)
- Termín je **polootvorený interval `[check_in, check_out)`** – deň odchodu môže byť dňom príchodu
  ďalšieho hosťa. Minimálne 1 noc (`check_out > check_in`).
- **Hlavná ochrana je v databáze** – exclusion constraint (vyžaduje rozšírenie `btree_gist`):
  `EXCLUDE USING gist (cabin_id WITH =, daterange(check_in, check_out) WITH &&) WHERE (status <> 'cancelled')`
  – zrušené rezervácie termín neblokujú.
- **Race condition** (dvaja klikli naraz): validácia v modeli prejde obom, ale DB pustí iba jednu
  rezerváciu; druhá dostane `PG::ExclusionViolation` → zachytíme ju a ukážeme „termín je už obsadený“.
- Validácia v modeli ostáva len kvôli peknej chybovej hláške, nie ako ochrana.
- Test so súbežnými vláknami, ktorý dokáže, že vznikne iba jedna rezervácia.

### 💳 Platby
- **Časovanie:** rezervácia je potvrdená hneď. Zaplatiť sa dá hneď, ale nemusí; splatnosť je
  **7 dní po `check_out`**. Po splatnosti nezaplatená rezervácia blokuje vytváranie nových.
- **Zaplatenie označuje výhradne systém** na základe potvrdenia od platobnej brány (webhook /
  bankové API) – nikto z rolí nemá tlačidlo „zaplatené“.
- **Peniaze v centoch (integer)**; sumu vždy počíta server (`500 × noci × osoby`, osoby = rezervujúci + vybraní členovia + ďalší dospelí hostia; deti sa nepočítajú). Cena za noc sa pri vytvorení skopíruje do rezervácie.
- **Spoľahlivosť potvrdení:** overenie podpisu webhooku, idempotentné spracovanie (tabuľka prijatých
  udalostí s unikátnym ID – duplicitná udalosť sa preskočí), spracovanie v Sidekiq jobe.
- **Zrušená rezervácia a „no-show“ (neprišiel) sa neplatia** – platba vzniká iba za uskutočnený
  pobyt. Ak bola zaplatená vopred, peniaze sa nevracajú (no refunds).
- **No-show označuje hosť sám:** pri vlastnej nezrušenej rezervácii môže po `check_in` až do
  splatnosti kliknúť „neprišiel som“ → stav `no_show`, platba nevzniká. (Rodinná dôvera; nejde
  o označenie platby, iba o informáciu, že pobyt sa nekonal.)
- **Platobná brána – Strategy pattern** (`Payments::*Strategy`):
  1. **`StripeStrategy`** – teraz, v **test móde** (zadarmo): Stripe Checkout, webhook
     `checkout.session.completed`.
  2. **`BankTransferStrategy`** – neskôr: prevod na účet chaty vo **Fio banke**; Sidekiq job
     pravidelne sťahuje pohyby z (bezplatného) Fio API a páruje ich podľa **variabilného symbolu**
     (= ID rezervácie). 0 € poplatky, žiadne ručné označovanie.

### ⚡ Živý kalendár obsadenosti
- Kalendár mesiaca sa vykresľuje **na serveri** (partial); Stimulus iba na výber rozsahu dátumov –
  žiadna JS knižnica na kalendár.
- Po vytvorení/zrušení rezervácie `broadcast_replace_to "calendar"` cez **Solid Cable** (Turbo
  Streams) → ostatným sa kalendár prekreslí bez reloadu.

### 👥 Používatelia, pozvánky, roly
- **`devise_invitable`** – pozvánka e-mailom (token, expirácia, prijatie); verejná registrácia vypnutá,
  žiadny OAuth/Google login.
- **Roly** ako `enum :role, { member: 0, owner: 1, admin: 2 }` na `User` + Pundit policies:

| Oprávnenie                                        | member | owner | admin |
| ------------------------------------------------- | :----: | :---: | :---: |
| vlastné rezervácie (vytvoriť, zrušiť)             |   ✅   |  ✅   |  ✅   |
| pozývať ľudí                                      |   ❌   |  ✅   |  ✅   |
| zrušiť cudziu rezerváciu, blokovať termín (údržba) |   ❌   |  ✅   |  ✅   |
| meniť roly, technická správa                      |   ❌   |  ❌   |  ✅   |
| označiť platbu ako zaplatenú                      |   ❌   |  ❌   |  ❌ (iba systém) |

- **Telefón** v E.164 formáte (pre SMS).
- **TDD poradie:** model specs → policy specs → request specs.

### 📆 Calendar sync
- Per-user **iCal feed** `/calendar/<token>.ics` (gem `icalendar`), token sa dá pregenerovať.

### ❓ Otvorené otázky
- Dohoda s ownermi: založenie účtu chaty vo Fio banke (alebo ostrý Stripe účet) – registrovať sa
  musí majiteľ účtu.

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
ReservationParticipant (kto ide – členovia rodiny)
Note (nástenka – poznámky)
SupplyItem (nástenka – zásoby)

# Analytics
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
```

### **Jobs**
```ruby
# Background processing
SendSmsNotificationJob
SyncCalendarJob
FetchWeatherJob
SendEmailReminderJob
PhotoProcessingJob
```

---

## 🎯 **Prečo je to skvelé pre junior pohovor:**

### 1. **Real-world Problem Solving**
> "Vyriešil som skutočný problém v našej rodine - plánovanie chaty bolo chaotické, teraz máme automatizovaný systém s platbami."

### 2. **Modern Rails Stack**
> "Použil som najnovší Rails 8.1 s Ruby 3.4.4, Hotwire pre reactive UI, Tailwind CSS s Flowbite komponentmi."

### 3. **Unique Features**
> "Implementoval som photo management s ActiveStorage, metaprogramovanie pre dynamické handlery a calendar sync s Apple/Google kalendárom."

### 4. **Metaprogramovanie**
> "Použil som metaprogramovanie pre dynamické notification handlery a flexible business logic, čo ukázalo schopnosť písať DRY a rozšíriteľný kód."

### 5. **Vedomé technické rozhodnutia**
> "Zvážil som Elasticsearch, ale pri jednej chate a ~20 používateľoch by priniesol viac prevádzkovej zložitosti než úžitku, tak som ho vynechal. Každé takéto rozhodnutie mám zdokumentované v decision logu."

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
- **iCal feed** (`icalendar` gem) pre kalendáre
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
- **Metaprogramovanie** pre dynamic handlers
- **Calendar sync** (Apple/Google)
- **Weather integration** pre planning
- **Nástenka** – poznámky a zásoby
- **Simple analytics** dashboard
- **SMS notifications** cez Twilio

---

## ✅ **Čo to prezentuje o tebe:**

| Skill                    | Dôkaz v projekte                           |
| ------------------------ | ------------------------------------------ |
| **Business Understanding** | Practical solution, no-refund policy     |
| **Modern Rails**         | Rails 8.1, Hotwire, Tailwind + Flowbite  |
| **Technical Judgment**   | Decision log (`docs/decision_log.md`)     |
| **Metaprogramovanie**    | Dynamic handlers, flexible architecture  |
| **File Management**      | ActiveStorage + cloud integration        |
| **API Integration**      | Stripe, Twilio, Weather, Calendar sync   |
| **Frontend Skills**      | Stimulus, Turbo, responsive design       |

---

## 🔧 **Implementácia – Milestones**

Práca je rozdelená na [GitHub milestones a issues](https://github.com/LiquiNaut/ChataHub/milestones)
(postup v `CONTRIBUTING.md`). Každý dokončený milestone = release s tagom.

| Milestone | Obsah | Release |
| --- | --- | --- |
| **M0 – Upratanie a základy** | Cabin úpravy, RSpec v CI, šablóny issues/PR | — |
| **M1 – Používatelia** | Devise User, pozvánky (`devise_invitable`), roly, Pundit | `v0.1.0` |
| **M2 – Rezervácie** | Reservation, exclusion constraint, zrušenie, no-show, kalendár | `v0.2.0` |
| **M3 – Prvý deploy** | produkčný Docker, Kamal, VPS, doména, HTTPS, zálohy, CD z tagu | `v0.3.0` |
| **M4 – Platby** | Stripe (test mód), webhooky, splatnosť, blokovanie nezaplatených | `v0.4.0` |
| **M5 – UX a notifikácie** | živý kalendár (Turbo Streams), iCal feed, e-maily | — |
| **M6 – Bonusy** | fotky, nástenka, počasie, štatistiky, PWA, Fio prevody | — |
