# YNOT Fitness — Custom Gyms (Sinatra)

One-page landing site for **YNOT Fitness — Custom Gyms**, built on Sinatra so it
can grow into a business-operations app (leads, projects, quotes, scheduling).
See [`BUSINESS.md`](BUSINESS.md) for the business brief and roadmap.

## Quick start

```sh
./bin/setup          # checks Ruby, installs gems, prepares data/
bundle exec puma     # → http://localhost:9292
```

`bin/setup` is idempotent — safe to run any time. It won't install Ruby for you;
if something's missing it prints the exact command to run.

## Requirements / your environment

This project is pinned to **Ruby 3.2.0** via [`.ruby-version`](.ruby-version)
(the Gemfile floor is `>= 3.0`). Dependencies: Sinatra 4, Puma 6, Rackup 2.

> **Heads-up about this machine.** You have **both rvm and rbenv** installed:
>
> | Manager | Default Ruby | Has 3.2.0? |
> |---------|--------------|------------|
> | rvm (currently active) | 3.2.0 | yes |
> | rbenv   | 3.0.0 (global) | yes |
>
> Because both are on PATH, a fresh shell could hand you rbenv's 3.0.0 instead
> of rvm's 3.2.0 depending on shell-init order. The `.ruby-version` file fixes
> this: **either manager** will select 3.2.0 for this project, and `bin/setup`
> warns you if the active Ruby doesn't match. No action needed unless setup
> flags it.

## Day-to-day

```sh
./bin/setup            # one-time (or after pulling new gems)
bundle exec puma       # run the app
./bin/dev              # run with auto-reload (restarts on file changes)
curl localhost:9292/health   # → {"status":"ok"}
```

## Project layout

```
bin/setup          # environment check + install (run this first)
bin/dev            # run locally with auto-reload
app.rb             # Sinatra app: routes (/, POST /leads, /health)
config.ru          # Rack entry point (used locally and on AWS)
views/index.erb    # the landing page
public/css/        # styles
public/images/     # build-out photos → "Our work" gallery
public/images/transformations/  # before/after pairs → "Before & After" section
data/leads.jsonl   # lead-form submissions (v1 storage; replace with RDS later)
.ruby-version      # pins Ruby 3.2.0 for rvm/rbenv
```

## Adding gallery photos

Drop `.jpg` / `.png` / `.webp` files into `public/images/`. They're picked up
automatically (sorted by filename) and rendered in the **Our work** section.
The numeric prefixes (`01-…`, `02-…`) control display order.

The gallery ships with 8 real customer build-outs that were cropped out of the
Facebook photo-grid screenshots in this folder. The widest finished interior is
also used as the hero backdrop (`public/images/hero/hero-gym.jpg`). To refresh
the showcase, drop higher-resolution originals over these files — the layout
needs no changes.

## Deploying to AWS

Standard Rack/Sinatra app served by Puma — fits several AWS paths:

- **Elastic Beanstalk** (Ruby platform) — push the repo; EB runs `config.ru`.
  Match the platform Ruby to `.ruby-version` (3.2.x).
- **App Runner / ECS** — containerize from a `ruby:3.2` image, `CMD bundle exec puma`.
- **EC2** — Puma behind Nginx with a systemd unit.

`GET /health` returns `{"status":"ok"}` for load-balancer health checks.

## Roadmap (operations app)

Leads/CRM → Projects → Quotes & invoices → Scheduling → Gallery CMS.
Details in [`BUSINESS.md`](BUSINESS.md).
