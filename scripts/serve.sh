#!/usr/bin/env bash
# Preview the whole site locally, drafts included.
set -euo pipefail
cd "$(dirname "$0")/.."
exec hugo server -s site -D --navigateToChanged "$@"
