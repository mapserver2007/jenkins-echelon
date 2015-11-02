#!/bin/bash
# usage:
# $> sudo sh init.sh https://github.com/rankforce/infrastructure.git master ruby2.2

# ansible task
taskfile="ansible/roles/applications/ruby/files/ansible/roles/settings/tasks/main.yml"

# get project name
git_uri="$1"
filename=${git_uri##*/}
project=${filename%.*}

# get gemfile path
gemfile=""
if [ -n "$4" ]; then
  gemfile=$4
fi

# get rspec path
rspec=""
if [ -n "$5" ]; then
  rspec=$5
fi

# replace text
cmd1="sed -i -e 's@%REPOSITORY%@$1@g' $taskfile"
cmd2="sed -i -e 's@%BRANCH%@$2@g' $taskfile"
cmd3="sed -i -e 's@%PROJECT%@$project@g' $taskfile"
cmd4="sed -i -e 's@%GEMFILE%@$gemfile@g' $taskfile"
cmd5="sed -i -e 's@%RSPEC%@$rspec@g' $taskfile"
eval ${cmd1}
eval ${cmd2}
eval ${cmd3}
eval ${cmd4}
eval ${cmd5}

# execte script
script="ansible-playbook -t $3 -i 'localhost,' ansible/setup.yml"
eval ${script}
