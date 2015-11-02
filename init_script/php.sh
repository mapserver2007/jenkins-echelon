#!/bin/bash
# usage:
# $> sudo sh php.sh https://github.com/mapserver2007/jenkins-echelon.git master php5.6
# arg1: git repository uri
# arg2: branch name
# arg3: tag name
# arg4: rspec directory path
# arg5: Gemfile path

# ansible task file
taskfile="ansible/roles/applications/php/files/ansible/roles/settings/tasks/main.yml"

# get project name
git_uri="$1"
filename=${git_uri##*/}
project=${filename%.*}

# tag
tag=$3

# get composer path
composer=""
ansible="ansible-playbook -t $tag -i 'localhost,' ansible/setup.yml"

if [ -n "$4" ]; then
  ansible="ansible-playbook -t $tag,composer -i 'localhost,' ansible/setup.yml"
  composer=$4
fi

# replace text
cmd1="sed -i -e 's@%REPOSITORY%@$1@g' $taskfile"
cmd2="sed -i -e 's@%BRANCH%@$2@g' $taskfile"
cmd3="sed -i -e 's@%PROJECT%@$project@g' $taskfile"
cmd4="sed -i -e 's@%COMPOSER%@$composer@g' $taskfile"
eval ${cmd1}
eval ${cmd2}
eval ${cmd3}
eval ${cmd4}

# build.xml
cmd5="sed -i -e 's@PROJECT@$project@' /var/tmp/build.xml"
eval ${cmd5}

# execte script
eval ${ansible}

# run test and get test result
# runtest="docker exec -t $tag /var/tmp/$project/vendor/bin/phing -f /var/tmp/$project/build.xml --format RspecJunitFormatter --out /var/tmp/$project/result.xml"
# dockercp="docker cp $tag:/var/tmp/$project/result.xml ."
# eval ${runtest}
# eval ${dockercp}
