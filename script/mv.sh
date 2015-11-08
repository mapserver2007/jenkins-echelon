#!/bin/bash
# usage:
# $> sudo sh mv.sh config.yml sample/php/config/

# ansible task file
langs=("php" "ruby")
for lang in ${langs[@]}; do
  upload_dir="ansible/roles/applications/$lang/files/upload/upload/$2"
  mkdir="mkdir -p $upload_dir"
  mv="cp -f $1 ${upload_dir}$1"

  eval ${mkdir}
  eval ${mv}
done
