#!/bin/bash

# Some code I wrote about working with completions in gitbash. I stopped in the
# middle and lost related PowerShell code I worked on. Throw away if it is not
# important, can't tell right now if the quality was any good.

c_dir="$HOME/.local/share/bash-completion/completions"

mapfile -t arr_1 < <(grep -v '^#' "${BASH_SOURCE[0]%.sh}.allowlist.cfg")
readonly arr_1

count=$(wc -l < <(grep -v '^#' "${BASH_SOURCE[0]%.sh}.allowlist.cfg"))
counter=0

# shellcheck disable=SC2068
for i in ${arr_1[@]}; do

  #sed --in-place \
  sed \
    "s/\(complete -F _${i//-/_}\) \(.*\)/\1 \2 ${i}.exe/" \
    "${c_dir}/${i}" > "${c_dir}/${i}.exe"
  #cp "${c_dir}/${i}" "${c_dir}/${i}.exe"

  #sleep .25
  ((counter++))
  echo -en "\b\b\b\b\b\b\b$counter/$count"

done
