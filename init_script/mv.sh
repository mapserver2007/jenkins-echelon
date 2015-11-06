#!/bin/bash
# usage:
# $> sudo sh mv.sh config.yml sample/php/config/

# ansible task file
upload_dir="ansible/roles/applications/php/files/upload/$2"
mkdir="mkdir -p $upload_dir/upload"
mv="mv $1 $upload_dir/upload/$1"

# taskfile2="ansible/roles/applications/tasks/main.yml"

eval ${mkdir}
eval ${mv}
