FROM ubuntu:14.04

RUN apt-get update
RUN apt-get install -y build-essential libssl-dev libffi-dev python-dev \
      dpkg-dev git python-pip

ADD securedrop/requirements/develop-requirements.txt .
RUN pip install -r develop-requirements.txt
ADD testinfra/requirements.txt .
RUN pip install -r requirements.txt

# Hosted docs, source interface, journalist interface
EXPOSE 8000 8080 8081

ADD . /securedrop
RUN mkdir /etc/ansible; echo "development ansible_host=127.0.0.1" >> /etc/ansible/hosts
RUN ansible-playbook --connection=local --limit development /securedrop/install_files/ansible-base/securedrop-development.yml
