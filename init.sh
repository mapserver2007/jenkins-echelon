#!/bin/bash
if [ $# -ne 2 ]; then
  echo "Required two args" 1>&2
  exit 1
fi

# replace text
sed -i -e "s/%REPOSITORY_URL%/$1/g" ansible/roles/applications/ruby/files/ansible/roles/settings/tasks/main.yml
sed -i -e "s/%BRANCH%/$2/g" ansible/roles/applications/ruby/files/ansible/roles/settings/tasks/main.yml

# execte script
script="ansible-playbook -t $3 -i 'localhost,' ansible/setup.yml"
${script}
