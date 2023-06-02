#!/bin/bash
set -euo pipefail
printf -v year '%(%Y)T' -1
printf -v month '%(%m)T' -1

hugo new --kind post posts/$year/$month/$1/index.md

# borrowed from nice post https://gilbertdev.net/posts/2023/02/enter-automation/
