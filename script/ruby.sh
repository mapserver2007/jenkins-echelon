#!/bin/bash
# usage:
# Without Gemfile in user application test
# $> sudo sh ruby.sh https://github.com/hoge/repository.git master ruby2.2
# With Gemfile in user application test
# $> sudo sh ruby.sh https://github.com/hoge/repository.git master ruby2.2 sample1/ruby/spec sample1/ruby
#
# arg1: git repository uri
# arg2: branch name
# arg3: tag name
# arg4: rspec directory path
# arg5: Gemfile path

# set language setup
taskfile_setup="ansible/setup.yml"
cmd_setup="sed -i -e 's@%LANG%@ruby@g' $taskfile_setup"
eval ${cmd_setup}

# container prefix
prefix=`cat /dev/urandom | tr -dc 'a-z' | fold -w 4 | head -n 1`

# ansible task
taskfile_local="ansible/roles/applications/ruby/tasks/main.yml"
taskfile_docker="ansible/roles/applications/ruby/files/ansible/roles/settings/tasks/main.yml"

# get project name
git_uri="$1"
filename=${git_uri##*/}
project=${filename%.*}

# tag
tag=$3
tag_wg=$3"_with_gemfile"
tag_wog=$3"_without_gemfile"


# get rspec path
rspec="spec"
if [ -n "$4" ]; then
  rspec=$4
fi

# get gemfile path
gemfile=""
ansible=""
if [ -n "$5" ]; then
  ansible="ansible-playbook -t $tag,$tag_wg,ruby -i 'localhost,' ansible/setup.yml"
  gemfile=$5
else
  ansible="ansible-playbook -t $tag,$tag_wog,ruby -i 'localhost,' ansible/setup.yml"
fi

# replace text
cmd_list=()
cmd_list[0]="sed -i -e 's@%APPLICATION%@$prefix@g' $taskfile_local"
cmd_list[1]="sed -i -e 's@%TAG%@$tag@g' $taskfile_local"
cmd_list[2]="sed -i -e 's@%REPOSITORY%@$1@g' $taskfile_docker"
cmd_list[3]="sed -i -e 's@%BRANCH%@$2@g' $taskfile_docker"
cmd_list[4]="sed -i -e 's@%PROJECT%@$project@g' $taskfile_docker"
cmd_list[5]="sed -i -e 's@%RSPEC%@$rspec@g' $taskfile_docker"
cmd_list[6]="sed -i -e 's@%GEMFILE%@$gemfile@g' $taskfile_docker"
for cmd in "${cmd_list[@]}"; do
  eval ${cmd}
done

eval ${ansible}

# secret files
cmd1=`docker exec -t $tag bash -c 'cd /var/tmp/ && ls | grep ^upload$'`
if [ -n "${cmd1}" ]; then
  cmd2="docker exec -t $tag bash -c 'cp -rf /var/tmp/upload/* /var/tmp/$project/'"
  eval ${cmd2}
fi

# run test and get test result
runtest="docker exec -t $tag bash -c 'cd /var/tmp/$project && rspec $rspec --format RspecJunitFormatter --out result.xml'"
dockercp="docker cp $tag:/var/tmp/$project/result.xml ."
eval ${runtest}
eval ${dockercp}
