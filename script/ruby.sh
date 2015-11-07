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

# ansible task
taskfile="ansible/roles/applications/ruby/files/ansible/roles/settings/tasks/main.yml"

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
  ansible="ansible-playbook -t $tag,$tag_wg -i 'localhost,' ansible/setup.yml"
  gemfile=$5
else
  ansible="ansible-playbook -t $tag,$tag_wog -i 'localhost,' ansible/setup.yml"
fi

# replace text
cmd1="sed -i -e 's@%REPOSITORY%@$1@g' $taskfile"
cmd2="sed -i -e 's@%BRANCH%@$2@g' $taskfile"
cmd3="sed -i -e 's@%PROJECT%@$project@g' $taskfile"
cmd4="sed -i -e 's@%RSPEC%@$rspec@g' $taskfile"
cmd5="sed -i -e 's@%GEMFILE%@$gemfile@g' $taskfile"
eval ${cmd1}
eval ${cmd2}
eval ${cmd3}
eval ${cmd4}
eval ${cmd5}

# execte script
eval ${ansible}

# secret files
cmd6=`docker exec -t $tag bash -c 'cd /var/tmp/ && ls | grep ^upload$'`
if [ -n "${cmd6}" ]; then
  cmd7="docker exec -t $tag bash -c 'cp -rf /var/tmp/upload/* /var/tmp/$project/'"
  eval ${cmd7}
fi

# run test and get test result
runtest="docker exec -t $tag bash -c 'cd /var/tmp/$project && rspec $rspec --format RspecJunitFormatter --out result.xml'"
dockercp="docker cp $tag:/var/tmp/$project/result.xml ."
eval ${runtest}
eval ${dockercp}
