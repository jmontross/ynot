# frozen_string_literal: true
#
# Production Puma config for YNOT Fitness on the "djpk" server.
#
# This lives under deploy/ on purpose: a bare `bundle exec puma` in the repo
# root will NOT auto-load it (Puma only auto-loads ./puma.rb or ./config/puma.rb),
# so local dev stays on port 9292. The systemd unit points at this file
# explicitly with `-C .../deploy/puma.rb`.

environment ENV.fetch("RACK_ENV", "production")

# Canonical app location on the server (see deploy.sh / update.sh).
directory "/var/www/ynotfitness/app"

threads 0, 8
workers 1

# Nginx reverse-proxies ynot.fitness -> here. Loopback only; never public.
bind "tcp://127.0.0.1:4568"

preload_app!

stdout_redirect "/var/log/ynotfitness/puma.stdout.log",
                "/var/log/ynotfitness/puma.stderr.log",
                true # append

plugin :tmp_restart
