#!/bin/bash
set -euo pipefail

year=$(date '+%Y')
month=$(date '+%m')

hugo new --kind post posts/$year/$month/$1/index.md

#  adapted from nice post https://gilbertdev.net/posts/2023/02/enter-automation/
