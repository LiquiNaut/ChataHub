Closes #

<!--
Title: Conventional Commits style, same as the issue, e.g. `feat(reservations): prevent overlapping bookings`.
Branch: `<type>/<issue-number>-<short-kebab-description>`, e.g. `feat/12-reservation-overlap`.
Delete sections that don't apply.
-->

## What & why

<!-- 1–3 sentences in plain language. -->

## Changes

-

## Technologies

<!-- Only if something new is added: **name** – what it is in one sentence → how it is used here -->

- **** –  →

## Edge cases

<!-- situation → how the system behaves (and where it is tested) -->

- →

## Test plan

- [ ] `just test` passes (new behaviour covered by specs)
- [ ] `just lint` — no new RuboCop offenses
- [ ] `bundle exec brakeman` — no new warnings
- [ ] Schema annotations regenerated if migrations changed (`bin/rails annotate`)
- [ ] Decision log entry added if a stack/architecture decision was made
