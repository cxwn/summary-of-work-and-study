#!/bin/bash
yum -y install ansible
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py
pip install paramiko PyYAML Jinja2 httplib2 six