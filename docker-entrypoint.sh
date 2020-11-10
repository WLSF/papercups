#!/bin/bash
set -euo pipefail

set -e

if [[ "$1" = 'run' ]]; then
      exec MIX_ENV=prod mix phx.server
elif [[ "$1" = 'setup' ]]; then
      exec mix ecto.setup
elif [[ "$1" = 'migrate' ]]; then
      exec mix ecto.migrate
else
      exec "$@"
fi

exec "$@"
