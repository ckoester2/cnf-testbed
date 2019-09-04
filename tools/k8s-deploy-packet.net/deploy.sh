#!/bin/sh

if [ -d env ]
then
  echo Virtualenv exists, re-using
else
  echo Creating virtualenv
  virtualenv env
  env/bin/pip install -r requirements.txt
fi

# Needed when running on a MAC. See https://github.com/ansible/ansible/issues/32499
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

exec env/bin/ansible-playbook -i inventory.yml main.yml
