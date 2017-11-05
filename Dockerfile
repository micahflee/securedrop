FROM ubuntu:14.04

# Install ansible from pip
RUN apt-get update
RUN apt-get install -y build-essential libssl-dev libffi-dev python-dev dpkg-dev python-pip aptitude supervisor
RUN pip install --upgrade setuptools
RUN pip install ansible==2.3.2.0

# Forward ports for hosted docs, source interface, journalist interface
EXPOSE 8000 8080 8081

# Add source to /securedrop
ADD . /securedrop

# Run the securedrop-development ansible playbook
RUN mkdir /etc/ansible && echo "development ansible_host=127.0.0.1" >> /etc/ansible/hosts
RUN ansible-playbook --connection=local --limit development /securedrop/install_files/ansible-base/securedrop-development.yml

WORKDIR /securedrop/securedrop
