# 📝 **ChataHub - Decision Log**

Datovaný záznam toho, čo sme do projektu **pridali**, **odstránili**, **ponechali** alebo vedome
**zamietli** — a hlavne **prečo**. Najnovšie záznamy sú hore.

Pred tým, než sa niečo zamietnuté vráti späť, si prečítaj pôvodný dôvod. Ak sa okolnosti zmenili,
pridaj nový záznam (starý nemaž ani neprepisuj).

**Šablóna záznamu:**

```markdown
## RRRR-MM-DD — Krátky názov
**Typ:** Pridané | Odstránené | Ponechané | Zamietnuté · **PR:** #

**Kontext:** aká bola situácia / problém.
**Rozhodnutie:** čo sme urobili.
**Dôvod:** prečo práve takto (trade-offy).
**Kedy prehodnotiť:** čo by muselo nastať, aby sme rozhodnutie zmenili.
```

---

## 2026-10-24 — Ponechaný `image_processing` (bump na 2.2) + explicitný `ruby-vips`
**Typ:** Ponechané · **PR:** _doplniť_

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
