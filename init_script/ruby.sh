#!/bin/bash
# usage:
# $> sudo sh init.sh https://github.com/rankforce/infrastructure.git master ruby2.2
# arg1: git repository uri
# arg2: branch name
# arg3: tag name
# arg4: rspec directory path
# arg5: Gemfile path

# ansible task
taskfile="ansible/roles/applications/ruby/files/ansible/roles/settings/tasks/main.yml"

# get project name
git_uri="$1"
filename=${git_uri##*/}
project=${filename%.*}

# tag
tag=$2

# get rspec path
rspec="spec"
if [ -n "$4" ]; then
  rspec=$4
fi

# get gemfile path
gemfile=""
if [ -n "$5" ]; then
  gemfile=$5
fi

# replace text
cmd1="sed -i -e 's@%REPOSITORY%@$1@g' $taskfile"
cmd2="sed -i -e 's@%BRANCH%@$tag@g' $taskfile"
cmd3="sed -i -e 's@%PROJECT%@$project@g' $taskfile"
cmd4="sed -i -e 's@%RSPEC%@$rspec@g' $taskfile"
cmd5="sed -i -e 's@%GEMFILE%@$gemfile@g' $taskfile"
eval ${cmd1}
eval ${cmd2}
eval ${cmd3}
eval ${cmd4}
eval ${cmd5}

# execte script
ansible="ansible-playbook -t $3 -i 'localhost,' ansible/setup.yml"
eval ${ansible}

# run test and get test result
runtest="docker exec -t $tag rspec /var/tmp/$project/$rspec --format RspecJunitFormatter --out /var/tmp/$project/result.xml"
dockercp="docker cp $tag:/var/tmp/$project/result.xml ."
eval ${runtest}
eval ${dockercp}
