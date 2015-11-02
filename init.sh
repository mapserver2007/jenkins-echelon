#!/bin/bash
if [ $# -ne 2 ]; then
  echo "Required two args" 1>&2
  exit 1
fi

# replace text
script1="sed -i -e 's/%REPOSITORY_URL%/$1/g' ansible/roles/applications/ruby/files/ansible/roles/settings/tasks/main.yml"
script2="sed -i -e 's/%BRANCH%/$2/g' ansible/roles/applications/ruby/files/ansible/roles/settings/tasks/main.yml"

eval ${script1}
eval ${script2}

# execte script
script="ansible-playbook -t $3 -i 'localhost,' ansible/setup.yml"
eval ${script}
