# 📝 **ChataHub - Decision Log**

Datovaný záznam toho, čo sme do projektu **pridali**, **odstránili**, **ponechali** alebo vedome
**zamietli** — a hlavne **prečo**. Najnovšie záznamy sú hore.

Pred tým, než sa niečo zamietnuté vráti späť, si prečítaj pôvodný dôvod. Ak sa okolnosti zmenili,
pridaj nový záznam (starý nemaž ani neprepisuj).

**Šablóna záznamu:**

```markdown
## RRRR-MM-DD — Krátky názov
**Typ:** Pridané | Odstránené | Ponechané | Zamietnuté | Rozhodnuté · **PR:** #

**Kontext:** aká bola situácia / problém.
**Rozhodnutie:** čo sme urobili.
**Dôvod:** prečo práve takto (trade-offy).
**Kedy prehodnotiť:** čo by muselo nastať, aby sme rozhodnutie zmenili.
```

---

## 2026-10-24 — Farby cez `light-dark()`, vlastné hostovanie písma, Tailwind watcher ako služba
**Typ:** Rozhodnuté · **PR:** _doplniť_ (issue #88)

**Kontext:** Prenos schváleného dizajnu do kódu. Tailwind, Turbo ani Stimulus neboli nainštalované.

**Rozhodnutie:**
- Farby sú Tailwind `@theme` tokeny s hodnotou `light-dark(svetlá, tmavá)`. Režim určuje
  `color-scheme` – podľa systému, prepísateľný cez `data-theme` na `<html>`. Jedna trieda (`bg-surface`)
  funguje v oboch režimoch, bez `dark:` variantov.
- Písmo Plus Jakarta Sans je **hostované v aplikácii** (`app/assets/fonts`), nie z Google Fonts.
- Tailwind sa v dev kompiluje v samostatnej compose službe `css` (`tailwindcss:watch[always]`);
  `bin/dev` + foreman z inštalátora sme nepoužili. CI kompiluje Tailwind pred testami.
- UI stavebné bloky ako helpery a partials (bez ViewComponent, bez Flowbite) + stránka `/styleguide`.

**Dôvod:** `light-dark()` odstraňuje duplicitu svetlých/tmavých tried. Google Fonts posiela IP
návštevníkov Googlu (v EÚ posudzované ako problém GDPR) a vlastné hostovanie je rýchlejšie.
Všetko ostatné beží v Dockeri, tak aj Tailwind watcher. ViewComponent by bol pri pár komponentoch YAGNI.

**Kedy prehodnotiť:** `light-dark()` vyžaduje Safari 17.5+ / Chrome 123+ / Firefox 120+;
`allow_browser :modern` púšťa aj Safari 17.2–17.4, kde by tokeny nefungovali. Ak by sa ozval niekto
so starším iPhonom, zvýšiť požiadavku v `allow_browser` alebo pridať záložné farby.

## 2026-10-24 — Schválený dizajn: mobile-first, pastelové farby, svetlý aj tmavý režim
**Typ:** Rozhodnuté · **PR:** _doplniť_ (issue #88)

**Kontext:** Pred prvou obrazovkou (#72) sme chceli jednotný vzhľad. Väčšina používateľov bude na mobile.

**Rozhodnutie:** Návrh na plátne „ChataHub UI“: písmo Plus Jakarta Sans, šalviovo zelená (primárna),
levanduľová (obsadené), broskyňová (upozornenia), chladné neutrálne pozadie; každá obrazovka na mobile
aj desktope, svetlý aj tmavý režim. Navigácia dole (mobil) / hore (desktop). Farby sa prenesú do
Tailwind 4 `@theme` tokenov. Čistý Tailwind + vlastné partials, bez TailwindUI (platený) a zatiaľ bez Flowbite.

**Dôvod:** Jednotný vzhľad od začiatku je lacnejší než prerábanie. Pastelové farby s tmavým textom
spĺňajú kontrast WCAG AA (≥ 4.5:1).

**Kedy prehodnotiť:** po prvom použití rodinou na mobile.

## 2026-10-24 — Cena 2,50 € za osobu a noc, deti zadarmo
**Typ:** Rozhodnuté · **PR:** _doplniť_ (issue #91)

**Kontext:** Pôvodne 5 € za noc za celú rezerváciu. Na chatu však často ide viac ľudí.

**Rozhodnutie:** Cena = **2,50 €** × noci × osoby (`price_per_night_cents` = 250). Osoby = rezervujúci + vybraní členovia rodiny + počet
ďalších dospelých hostí bez účtu. **Deti sa neplatia** – uvedú sa v poznámke, samostatné počítadlo nie je.

**Dôvod:** Férovejšie rozdelenie nákladov. Počítadlo hostí je nutné, inak by sa ľudia bez účtu
do ceny nezapočítali. Samostatná evidencia detí by bola YAGNI.

**Kedy prehodnotiť:** ak by sa mali deti platiť (napr. znížená cena) alebo by sa cena menila podľa sezóny.

## 2026-10-24 — Spolucestujúci a poznámka pri rezervácii, mená viditeľné všetkým
**Typ:** Rozhodnuté · **PR:** _doplniť_ (issue #91)

**Kontext:** V kalendári bolo vidno iba „Obsadené“. Rodina chce vedieť, kto je na chate a s kým.

**Rozhodnutie:** V kalendári je meno rezervujúceho; po kliknutí detail so spolucestujúcimi
(členovia + „+ N hostia“) a voliteľnou poznámkou. Viditeľné pre všetkých členov.

**Dôvod:** Uzavretá rodinná skupina (~20 ľudí) – súkromie medzi členmi nie je problém, prehľad je užitočný.

**Kedy prehodnotiť:** ak by sa skupina rozšírila mimo užšej rodiny.

## 2026-10-24 — Pridaná Nástenka: poznámky a zásoby
**Typ:** Pridané · **PR:** _doplniť_ (issue #92)

**Kontext:** Plán mal „Food board“ (zoznam potravín). Pribudol nápad na poznámky s menom autora.

**Rozhodnutie:** Nástenka s dvoma časťami: **Poznámky** (autor, dátum, majitelia môžu pripnúť) a
**Zásoby** (zaškrtávací zoznam s menom, kto pridal). Najnovšie poznámky aj nad kalendárom (desktop).
Bez komentárov a reakcií. Milestone M6.

**Dôvod:** Nahrádza odkazy v rodinnom chate, ktoré sa strácajú; zásoby pokrývajú pôvodný Food board.

**Kedy prehodnotiť:** ak by ľudia chceli na poznámky reagovať.

## 2026-10-24 — Upgrade Ruby 3.4.4 → 4.0.9
**Typ:** Rozhodnuté · **PR:** #90

**Kontext:** Projekt začínal na Ruby 3.4.4 s poznámkou „Ruby 4.0 zatiaľ nie, ekosystém nie je
pripravený“ (krátko po vydaní 4.0 v 12/2025). Medzitým vyšlo 9 opravných verzií 4.0.x.

**Rozhodnutie:** Prechod na **Ruby 4.0.9** (`.ruby-version`, Dockerfile). Alternatíva bola 3.4.9
(len opravy, podpora približne do jari 2028).

**Dôvod:** Skúšobný beh na 4.0.9 prešiel (bundle install, testy, boot Rails). Upgrade je najlacnejší
teraz, keď má aplikácia jeden model; neskôr by sa preverovalo oveľa viac. Pre nový portfóliový
projekt je aktuálna stabilná verzia lepší signál.

**Kedy prehodnotiť:** ak by niektorý gem zapájaný v M1/M4 (Devise, Sidekiq joby, Stripe) na 4.0
nefungoval – CI to ukáže pri danom issue; návrat = zmena `.ruby-version` a Dockerfile.

## 2026-10-24 — Platobná brána: teraz Stripe (test mód), neskôr prevod + Fio API
**Typ:** Rozhodnuté · **PR:** #67

**Kontext:** Hľadali sme bránu bez poplatkov s automatickým potvrdením platby. Prieskum: Stripe
1,5 % + 0,25 € (pri 5 € ≈ 6,5 %), Revolut Merchant (len Revolut Business), SK brány (spravidla pre
podnikateľov), open-banking „pay by bank“ (pre firmy), BTCPay (iba bitcoin). Nulové poplatky
s automatickým potvrdením ponúka len **prevod na účet v banke s bezplatným API (Fio)**.

**Rozhodnutie:** Strategy pattern `Payments::*Strategy`. Teraz `StripeStrategy` v **test móde**
(zadarmo, na naučenie webhookov, podpisov a idempotencie). Neskôr `BankTransferStrategy` – prevod na
účet chaty vo Fio banke, párovanie cez variabilný symbol z Fio API v Sidekiq jobe.

**Dôvod:** Stripe má najlepšiu dokumentáciu a test mód bez nákladov; Fio dáva 0 € poplatky bez
ručného označovania. Strategy pattern tu má reálny dôvod – vymeniteľný poskytovateľ.

**Kedy prehodnotiť:** keď sa owneri dohodnú na účte – ak nebude vo Fio, ostáva Stripe live (alebo
Revolut Merchant pri Revolut Business účte). Treba overiť dostupnosť Stripe pre súkromnú osobu v SR.

## 2026-10-24 — Platba: zaplatiť hneď alebo do 7 dní po pobyte, „zaplatené“ označuje iba systém
**Typ:** Rozhodnuté · **PR:** #67

**Kontext:** Pôvodný plán mal Stripe, „nezaplatená blokuje ďalšie“ a nebolo jasné, kedy sa platí.
Zvažované: (a) platba hneď s dočasným držaním termínu, (b) do termínu pred príchodom, (c) po pobyte,
(d) periodické vyúčtovanie, (e) predplatený kredit.

**Rozhodnutie:** Rezervácia je potvrdená hneď. Zaplatiť sa dá hneď, ale nemusí; splatnosť je
**7 dní po `check_out`**. Po splatnosti nezaplatená rezervácia blokuje nové. Platbu ako zaplatenú
označuje **výhradne systém** (webhook / bankové API) – žiadna rola na to nemá oprávnenie.
**Zrušená rezervácia a no-show sa neplatia**; vopred zaplatená suma sa však nevracia (no refunds).
No-show si označuje **hosť sám** (stav `no_show`, po `check_in` až do splatnosti) – systém inak
nevie rozlíšiť uskutočnený pobyt od neuskutočneného. Prípadná strata pri zrušení vopred zaplatenej
rezervácie je akceptovaná (peniaze ostávajú na účte rodiny, stáva sa zriedka).

**Dôvod:** Rodinné prostredie – platí sa za skutočne využitý pobyt, nikto nie je tlačený platiť
vopred. Automatické potvrdenie odstraňuje ručnú evidenciu a spory „zaplatil/nezaplatil“.

**Kedy prehodnotiť:** ak by sa hromadili nezaplatené pobyty, alebo ak zvolená brána neumožní
automatické potvrdenie, alebo ak by sa no-show zneužíval.

## 2026-10-24 — Zamietnutý PAY by square s ručným označovaním platieb
**Typ:** Zamietnuté · **PR:** #67

**Kontext:** Ako bezpoplatková alternatíva k Stripe bol navrhnutý QR prevod (PAY by square) s tým,
že owner platbu ručne označí ako zaplatenú.

**Rozhodnutie:** Nepoužijeme.

**Dôvod:** Ručné odškrtávanie platieb nechceme – zaplatenie má potvrdiť systém.

**Kedy prehodnotiť:** ak by cieľový účet bol v banke s bezplatným API na výpisy (napr. Fio) –
vtedy by išlo o prevod s **automatickým** párovaním cez variabilný symbol, bez ručného označovania.

## 2026-10-24 — Roly `member` / `owner` / `admin`
**Typ:** Rozhodnuté · **PR:** #67

**Kontext:** Chatu vlastnia 3 súrodenci, aplikáciu spravuje admin, ostatní sú pozvaní členovia rodiny.

**Rozhodnutie:** `enum :role, { member: 0, owner: 1, admin: 2 }` na `User` + Pundit. Owner smie
pozývať, rušiť cudzie rezervácie a blokovať termíny; admin navyše mení roly. Rola sa nevolá `user`
(kolízia s modelom `User` – `user.user?`).

**Dôvod:** Jedna chata → globálna rola stačí; tabuľka `cabin_memberships` (rola per chata) by bola YAGNI.

**Kedy prehodnotiť:** ak by aplikácia mala spravovať viac chát.

## 2026-10-24 — Odstránený Google login a Google Calendar API, calendar sync cez iCal feed
**Typ:** Odstránené · **PR:** #66

**Kontext:** V `Gemfile` boli `omniauth`, `omniauth-google-oauth2`, `omniauth-rails_csrf_protection`
a `google-apis-calendar_v3` – na Google login a synchronizáciu s Google kalendárom.

**Rozhodnutie:** Gemy odstránené. Registrácia iba cez pozvánky, prihlásenie e-mail + heslo.
Calendar sync = tajná per-user URL s **iCal feedom** (`icalendar` gem), ktorú si používateľ pridá
ako odber do Apple aj Google kalendára.

**Dôvod:** Pri pozvánkach OAuth komplikuje kontrolu, kto sa smie prihlásiť. iCal feed funguje na
iOS aj Androide bez OAuth a API kľúčov – je to jeden endpoint.

**Kedy prehodnotiť:** ak by bola potrebná obojsmerná synchronizácia alebo okamžité zobrazenie
v Google kalendári (odbery sa obnovujú raz za pár hodín).

## 2026-10-24 — Prekrývanie rezervácií cez DB exclusion constraint, minimum 1 noc
**Typ:** Rozhodnuté · **PR:** #67

**Kontext:** „First come, first served“ – dvaja ľudia môžu rezervovať ten istý termín naraz.

**Rozhodnutie:** Polootvorený interval `[check_in, check_out)`, `EXCLUDE USING gist` constraint
(`btree_gist`) ignorujúci zrušené rezervácie; validácia v modeli len kvôli hláške. Minimálna dĺžka
pobytu znížená z 2 na **1 noc**.

**Dôvod:** Validácia v modeli race condition nezachytí – iba databáza vie garantovať, že prejde
jedna z dvoch súbežných rezervácií.

**Kedy prehodnotiť:** —

## 2026-10-24 — Automatické mazanie vetiev po merge
**Typ:** Pridané · **PR:** —

**Kontext:** Na GitHube aj lokálne sa hromadili vetvy zmergovaných PR.

**Rozhodnutie:** V repozitári zapnuté „Automatically delete head branches“, lokálne
`git config --global fetch.prune true`.

**Dôvod:** Zmaže sa iba názov vetvy – commity ostávajú v histórii `master` (merge commity) a celý
diff ostáva v PR; vetva sa dá obnoviť tlačidlom „Restore branch“.

**Kedy prehodnotiť:** —

## 2026-10-24 — Ponechaný `image_processing` (bump na 2.2) + explicitný `ruby-vips`
**Typ:** Ponechané · **PR:** #65

**Kontext:** Dependabot #51 navrhol `image_processing` 1.14 → 2.0. Verzia 2.0 už neťahá backendy
(`ruby-vips`, `mini_magick`) ako závislosti — po merge by z `Gemfile.lock` zmizli a prvé vytvorenie
variantu fotky by spadlo na `LoadError` (CI ani testy by to nezachytili).

**Rozhodnutie:** Ponechať gem (photo management je v pláne), bump na 2.2 a do `Gemfile` explicitne
pridať `ruby-vips` (Rails default `variant_processor = :vips`; systémový `vips` je už v Dockerfile).
`mini_magick` sa nepoužíva, odpadol. #51 zatvorený.

**Dôvod:** Fotky z mobilov majú 4–12 MB — bez zmenšených variantov je galéria nepoužiteľná. 2.0.x
opravuje viaceré RCE zraniteľnosti. Nepribúda žiadna služba (Active Storage je súčasť Rails).

**Kedy prehodnotiť:** ak by sa photo management z plánu vypustil. Pozor: od 2.0 vips blokuje
„unfuzzed“ loadery — pri HEIC fotkách z iPhonu to bude treba riešiť.

## 2026-10-24 — Odstránený Elasticsearch + Searchkick
**Typ:** Odstránené · **PR:** #64

**Kontext:** Elasticsearch bol v pláne na full-text, faceted search, autocomplete a search analytics.
Hlavný dôvod bol portfóliový („skúsenosť s search enginom“), nie potreba domény. ChataHub je
**jedna chata a ~20 pozvaných používateľov** — dát budú rádovo stovky záznamov.

**Rozhodnutie:** Odstránená služba `elasticsearch` z `compose.yml` (vrátane volume), gemy `searchkick`
a `elasticsearch` a s nimi aj na ES postavené návrhové vzory `SearchBuilders` (Builder) a `Searchable`
concern (metaprogramovanie) z dokumentácie. Zatvorený Dependabot PR #57 (elasticsearch gem 8 → 9).

**Dôvod:**
- Vyhľadávanie nemá reálny use case — rezervácie sa zobrazujú v kalendári a filtrujú bežným `where`,
  20 používateľov sa zmestí na jednu obrazovku.
- ES stál ~1 GB RAM (viac ako celá Rails appka), pridával synchronizáciu indexu s DB, ďalšiu službu
  v compose a pri deployi by vyžadoval drahší server.
- Verzie klienta (gem) a servera sa musia držať zosúladené — klient 9 so serverom 8 nefunguje (#57).
- Metaprogramovanie ostáva v pláne cez dynamické notification handlery, Builder sa doplní, keď
  vznikne reálna potreba.

**Kedy prehodnotiť:** keď vznikne konkrétna potreba vyhľadávať v dátach, ktorých je toľko, že sa
nedajú rozumne prezrieť/filtrovať. Prvá voľba je potom PostgreSQL full-text (`pg_search`), nie
samostatný search engine.

## 2026-10-24 — Nepridávame ani `pg_search`
**Typ:** Zamietnuté · **PR:** #64

**Kontext:** Ako náhrada za Elasticsearch sa zvažoval `pg_search` (full-text, prefix/autocomplete,
trigram na preklepy, `unaccent` na diakritiku — všetko priamo v PostgreSQL, bez ďalšej služby).

**Rozhodnutie:** Zatiaľ nepridávame žiadne full-text vyhľadávanie.

**Dôvod:** YAGNI — pri 1 chate a ~20 ľuďoch neexistuje funkcia, ktorá by vyhľadávanie potrebovala.
Doplnenie neskôr je lacné (jedna migrácia na extensions + jeden `pg_search_scope`).

**Kedy prehodnotiť:** napr. pri väčšom množstve fotiek s popismi alebo poznámok, v ktorých by sa
reálne hľadalo.

## 2026-10-24 — Odstránený `logstash-event`
**Typ:** Odstránené · **PR:** #64

**Kontext:** Gem bol v `Gemfile` s komentárom „Logging with Logstash to Elasticsearch“, ale nikde
v konfigurácii sa nepoužíval.

**Rozhodnutie:** Odstránený spolu s Elasticsearchom.

**Dôvod:** Nepoužitá závislosť; bez ES (a Logstashu) nemá zmysel.

**Kedy prehodnotiť:** ak bude v produkcii potrebné centralizované/štruktúrované logovanie — vtedy
skôr `lograge` + JSON logy do služby, ktorú bude hosting ponúkať.

## 2026-10-24 — Ponechaný `--ensure-latest` v `bin/brakeman`
**Typ:** Ponechané · **PR:** #63

**Kontext:** CI job `scan_ruby` začal padať na `master` (exit code 5), lebo vyšiel Brakeman 8.1.0
a `bin/brakeman` beží s `--ensure-latest` (Rails default). Opravené bumpom na 8.1.0 v #63.

**Rozhodnutie:** Flag ponechávame.

**Dôvod:** CI tak vždy skenuje najnovšími bezpečnostnými pravidlami. Cena je, že CI občas spadne pri
novom vydaní Brakemanu — Dependabot (daily) však zvyčajne do dňa otvorí PR s novou verziou, stačí ho
mergnúť.

**Kedy prehodnotiť:** ak by nečakané pády CI kvôli novým verziám začali brzdiť prácu.
