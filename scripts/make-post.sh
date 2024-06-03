#!/bin/bash
set -euo pipefail

# if not first arg print usage
if [ $# -eq 0 ]; then
  echo "Usage: $0 <post-title>"
  exit 1
fi

year=$(date '+%Y')
month=$(date '+%m')

hugo new --kind post posts/$year/$month/$1/index.md

#  adapted from nice post https://gilbertdev.net/posts/2023/02/enter-automation/
