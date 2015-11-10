#!/bin/bash
# usage:
# Without composer.json in user application test
# $> sudo sh php.sh https://github.com/mapserver2007/jenkins-echelon.git master php5.6
# With composer.json in user application test
# $> sudo sh php.sh https://github.com/mapserver2007/jenkins-echelon.git master php5.6 sample1/php/test sample1/php
#
# arg1: git repository uri
# arg2: branch name
# arg3: tag name
# arg4: test directory path
# arg5: composer.json directory path

# set language setup
taskfile_setup="ansible/setup.yml"
cmd_setup="sed -i -e 's@%LANG%@php@g' $taskfile_setup"
eval ${cmd_setup}

# container prefix
prefix=`cat /dev/urandom | tr -dc 'a-z' | fold -w 4 | head -n 1`

# ansible task file
taskfile_application_local="ansible/roles/applications/php/tasks/main.yml"
taskfile_middleware_local="ansible/roles/middlewares/php/tasks/main.yml"
taskfile_docker="ansible/roles/applications/php/files/ansible/roles/settings/tasks/main.yml"

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
  ansible="ansible-playbook -t $tag,$tag_wc,php -i 'localhost,' ansible/setup.yml"
  composer=$5
else
  ansible="ansible-playbook -t $tag,$tag_woc,php -i 'localhost,' ansible/setup.yml"
fi

# replace text
cmd_list=()
cmd_list[0]="sed -i -e 's@%APPLICATION%@$prefix@g' $taskfile_application_local"
cmd_list[1]="sed -i -e 's@%TAG%@$tag@g' $taskfile_application_local"
cmd_list[2]="sed -i -e 's@%TAG%@$tag@g' $taskfile_middleware_local"
cmd_list[3]="sed -i -e 's@%REPOSITORY%@$1@g' $taskfile_docker"
cmd_list[4]="sed -i -e 's@%BRANCH%@$2@g' $taskfile_docker"
cmd_list[5]="sed -i -e 's@%PROJECT%@$project@g' $taskfile_docker"
cmd_list[6]="sed -i -e 's@%COMPOSER%@$composer@g' $taskfile_docker"
for cmd in "${cmd_list[@]}"; do
  eval ${cmd}
done

# execte ansible
eval ${ansible}

container_name=${prefix}_${tag}

# build.xml
cmd1="docker exec -t ${container_name} sed -i -e 's@%PROJECT%@/var/tmp/$project/$testdir@' /var/tmp/build.xml"
eval ${cmd1}

# secret files
cmd2=`docker exec -t ${container_name} bash -c 'cd /var/tmp/ && ls | grep ^upload$'`
if [ -n "${cmd2}" ]; then
  cmd3="docker exec -t ${container_name} bash -c 'cp -rf /var/tmp/upload/* /var/tmp/$project/'"
  eval ${cmd3}
fi

# run test and get test result
runtest="docker exec -t ${container_name} bash -c 'cd /var/tmp/ && vendor/bin/phing -f build.xml'"
dockercp="docker cp ${container_name}:/var/tmp/result.xml ."
eval ${runtest}
eval ${dockercp}
