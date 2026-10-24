Closes #

<!--
Title: rovnaký ako issue – TYPE veľkými písmenami, po anglicky, napr. `FEAT(reservations): prevent overlapping bookings`.
Vetva: `<type>/<číslo-issue>-<krátky-popis>`, napr. `feat/12-reservation-overlap`.
Popis po slovensky. Sekcie, ktoré nedávajú zmysel, vymaž.
-->

## Čo a prečo

<!-- 1–3 vety v ľudskej reči. -->

## Zmeny

-

## Technológie

<!-- Iba ak pridávame niečo nové: **názov** – čo to je jednou vetou → ako to použijeme práve tu -->

- **** –  →

## Edge cases

<!-- situácia → ako sa systém zachová (a kde je to otestované) -->

- →

## Ako otestovať lokálne

<!-- Konkrétne kroky: príkazy, čo otvoriť na http://localhost:3000/…, čo spustiť v `just console`, aký je očakávaný výsledok. -->

```sh
git fetch && git switch <vetva>
just upd
just test
```

## Kontrola

- [ ] `just test` prechádza (nové správanie pokryté testami)
- [ ] `just lint` – žiadne nové nálezy RuboCop
- [ ] `bundle exec brakeman` – žiadne nové varovania
- [ ] Anotácie pregenerované, ak sa menili migrácie (`bin/rails annotate`)
- [ ] Záznam v decision logu, ak padlo rozhodnutie o stacku/architektúre
