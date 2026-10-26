#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
set -euo pipefail
here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
tree=$(cd -- "$here/../../.." && pwd)
exec python3 "$tree/vendor/sheng/integration/tools/apply-integration.py" --tree "$tree" "$@"
