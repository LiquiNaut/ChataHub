# Contributing to ChataHub

## Branching strategy — GitHub Flow

`master` is always deployable. All work happens on short-lived branches off `master`,
goes through a Pull Request, and is merged back once CI is green.

```
master ──●──●──●──●──►  (always deployable, releases are tags: v0.1.0, v0.2.0 …)
            \      /
             feat/12-devise-auth
```

1. **Start from an issue** (create one if it doesn't exist) — see [Issues](#issues).
2. Branch off the latest `master`, named after the issue — see [Branch naming](#branch-naming).
3. Make small, focused commits.
4. Open a PR early with `Closes #<issue>`; let CI run.
5. Merge to `master` after green CI **and after the change was tested locally and approved**. The branch is deleted automatically on merge
   (commits stay in `master` history, the diff stays in the PR).

There is no `develop` or deploy branch — see [Releases](#releases--deploys).

## Issues

Work is split into **GitHub Issues**, grouped into **milestones** (M0, M1, …). One issue = one
branch = one PR. Use the **Task** issue template; it pre-fills this format:

- **Title** in Conventional Commits style, in English, with the **type in UPPERCASE** (scope and
  description lowercase) so it stands out in lists: `TYPE(scope): <what changes>`,
  e.g. `FEAT(reservations): prevent overlapping bookings`. Commit messages, branch names and labels
  stay lowercase (`feat(...)`, `feat/12-...`, `feat`).
- **Label** matching the type (`feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `ci`) and a
  **milestone**.
- **Body** in Slovak, short and plain, with these sections (drop the ones that don't apply):
  - **Čo a prečo** — 1–3 sentences.
  - **Úlohy** — checklist of concrete steps.
  - **Technológie** — only when something new is added: what it is in one sentence → how it is
    used in this case.
  - **Edge cases** — bullet list, `situation → expected behaviour`.
  - **Hotovo, keď** — verifiable acceptance criteria.

### Branch naming

`<type>/<issue-number>-<short-kebab-description>` — the `<type>` matches the Conventional Commit
type and the issue label; the description says in a few words what the branch changes or adds:

| Prefix      | Use for                                  | Example                          |
| ----------- | ---------------------------------------- | -------------------------------- |
| `feat/`     | New feature                              | `feat/12-devise-auth`            |
| `fix/`      | Bug fix                                  | `fix/31-reservation-overlap`     |
| `chore/`    | Tooling, deps, config                    | `chore/40-bump-rails-8-1`        |
| `refactor/` | Code change without behaviour change     | `refactor/27-cabin-price-cents`  |
| `docs/`     | Documentation only                       | `docs/26-issue-pr-docs`          |
| `test/`     | Tests only                               | `test/45-cabin-validations`      |
| `ci/`       | CI / CD pipeline                         | `ci/28-rspec-job`                |

Work without an issue (e.g. Dependabot bumps) may omit the number.

Keep branches short-lived — rebase or merge `master` in frequently to avoid drift.

## Commit messages — Conventional Commits

Format: `<type>(<optional scope>): <description>`

```
feat(reservations): prevent overlapping bookings
fix(payments): handle declined Stripe charge
chore(deps): bump Rails to 8.1.3
docs: document branching strategy
```

Allowed types: `feat`, `fix`, `chore`, `refactor`, `docs`, `test`, `perf`, `style`, `ci`, `build`.

- Use the imperative mood ("add", not "added").
- Keep the subject ≤ 72 chars; add a body for the "why" when it isn't obvious.
- One logical change per commit.

## Before opening a PR

```sh
bundle exec rspec        # tests pass
bundle exec rubocop      # no new offenses
bundle exec brakeman     # no new warnings
```

## Pull requests

The PR template mirrors the issue format and is written **in Slovak**: `Closes #<issue>`,
**Čo a prečo**, **Zmeny**, **Technológie** (if new), **Edge cases**, **Ako otestovať lokálne**
(concrete steps on localhost with expected results), **Kontrola**. The PR title equals the issue
title (English, type in UPPERCASE). No tool/AI attribution lines in the description, and no `Co-Authored-By` AI trailers in commits. If a stack/architecture decision was made, add an entry to `docs/decision_log.md`.

## Releases & deploys

`master` is always deployable; there is no separate deploy branch. A release is a **git tag**
(`v0.1.0`, `v0.2.0`, … — one per milestone) published as a GitHub Release with notes generated
from the merged PRs:

```sh
gh release create v0.1.0 --generate-notes
```

Deploys will be triggered from tags (planned: GitHub Actions → `kamal deploy`), so production
always runs a known version and `kamal rollback` returns to the previous one.
