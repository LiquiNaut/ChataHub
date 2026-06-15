# Contributing to ChataHub

## Branching strategy — GitHub Flow

`master` is always deployable. All work happens on short-lived branches off `master`,
goes through a Pull Request, and is merged back once CI is green.

```
master ──●──●──●──●──►  (always deployable)
            \      /
             feat/devise-auth
```

1. Branch off the latest `master`.
2. Make small, focused commits.
3. Open a PR early; let CI (Brakeman, importmap audit, RuboCop) run.
4. Merge to `master` after review + green CI. Deploy from `master`.

### Branch naming

`<type>/<short-kebab-description>` — the `<type>` matches the Conventional Commit type:

| Prefix      | Use for                                  | Example                     |
| ----------- | ---------------------------------------- | --------------------------- |
| `feat/`     | New feature                              | `feat/devise-auth`          |
| `fix/`      | Bug fix                                  | `fix/reservation-overlap`   |
| `chore/`    | Tooling, deps, config                    | `chore/bump-rails-8-1`      |
| `refactor/` | Code change without behaviour change     | `refactor/payments-service` |
| `docs/`     | Documentation only                       | `docs/readme-setup`         |
| `test/`     | Tests only                               | `test/cabin-validations`    |

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
