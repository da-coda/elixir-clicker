#!/usr/bin/env bash
set -o errexit
git pull
mix deps.get --only prod
MIX_ENV=prod mix compile
MIX_ENV=prod mix assets.deploy
MIX_ENV=prod mix release --overwrite
./_build/prod/rel/clicker/bin/clicker eval "ElixirClicker.Release.migrate"
