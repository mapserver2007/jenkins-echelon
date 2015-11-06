#!/bin/bash
# usage:
# Without composer.json in user application test
# $> sudo sh php.sh https://github.com/mapserver2007/jenkins-echelon.git master php5.6
# With composer.json in user application test
# $> sudo sh php.sh https://github.com/mapserver2007/jenkins-echelon.git master php5.6 sample/php/test sample/php
#
# arg1: git repository uri
# arg2: branch name
# arg3: tag name
# arg4: test directory path
# arg5: composer.json directory path

# ansible task file
taskfile="ansible/roles/applications/php/files/ansible/roles/settings/tasks/main.yml"

# get project name
git_uri="$1"
filename=${git_uri##*/}
project=${filename%.*}

# tag
tag=$3
tag_wc=$3"_with_composer"
tag_woc=$3"_without_composer"

# test dir
testdir=$4

# get composer path
composer=""
ansible=""
if [ -n "$5" ]; then
  ansible="ansible-playbook -t $tag,$tag_wc -i 'localhost,' ansible/setup.yml"
  composer=$5
else
  ansible="ansible-playbook -t $tag,$tag_woc -i 'localhost,' ansible/setup.yml"
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

# execte script
${ansible}

# build.xml
cmd5="docker exec -t $tag sed -i -e 's@%PROJECT%@/var/tmp/$project/$testdir@' /var/tmp/build.xml"
${cmd5}

# secret files
cmd6=`sudo docker exec -t $tag bash -c 'cd /var/tmp/ && ls | grep ^upload$'`
if [ -n "${cmd6}" ]; then
  cmd7="sudo docker exec -t $tag bash -c 'cd /var/tmp/upload && cp -rf * ../$project/'"
  eval ${cmd7}
fi

# run test and get test result
runtest="docker exec -t $tag bash -c 'cd /var/tmp/ && vendor/bin/phing -f build.xml'"
dockercp="docker cp $tag:/var/tmp/result.xml ."
eval ${runtest}
eval ${dockercp}
