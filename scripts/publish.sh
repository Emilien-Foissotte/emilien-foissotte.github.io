# bash shebang
#!/bin/bash
set -euo pipefail

# bash, unix, macos
# get the most recent post under content/posts
# and sed the date and publish date to the current date
# content/posts/YYYY/MM/slug/index.md
file=$(ls -t content/posts/*/*/*/index.md | head -n 1)
file_list=($file)
# if a file index.fr.md is found under same directory, use it also
file_directory=$(dirname $file)
# if a file is found under the same directory, with name index.fr.md, add it
if [[ -f $file_directory/index.fr.md ]]; then
  file_list+=($file_directory/index.fr.md)
fi
# time format: 2024-05-10T14:45:59+02:00
for file_to_update in "${file_list[@]}"; do
  sed -i '' 's/date: .*/date: '"$(date '+%Y-%m-%dT%H:%M:%S%z')"'/g' $file_to_update
  sed -i '' 's/publishDate: .*/publishDate: '"$(date '+%Y-%m-%dT%H:%M:%S%z')"'/g' $file_to_update
  # change the draft from true to false
  sed -i '' 's/draft: true/draft: false/g' $file_to_update
done
