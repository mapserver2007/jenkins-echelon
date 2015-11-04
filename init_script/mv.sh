#!/bin/bash
# usage:
# $> sudo sh mv.sh config.yml sample/php/config/

# ansible task file
upload_dir="ansible/roles/applications/php/files/upload/$2"
mkdir="mkdir -p $upload_dir"
cp="cp $upload_dir/$1"

eval ${mkdir}
eval ${cp}
