FROM ubuntu:14.04

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      libssl-dev \
      libffi-dev \
      python-dev \
      dpkg-dev \
      python-pip \
      aptitude \
      supervisor && \
    apt-get clean && \           
    rm -rf /var/lib/apt/lists/* \
      /tmp/* \                   
      /var/tmp/*                 

# Install ansible from pip
RUN pip install --upgrade setuptools
RUN pip install ansible==2.3.2.0

# Add source to /securedrop
ADD . /securedrop

# Run the securedrop-development ansible playbook
RUN mkdir /etc/ansible && \
    echo "development ansible_host=127.0.0.1" >> /etc/ansible/hosts

RUN chown -R www-data:www-data /securedrop
RUN sudo service supervisor start && \
    ansible-playbook --connection=local --limit development /securedrop/install_files/ansible-base/securedrop-development.yml

WORKDIR /securedrop/securedrop
ENTRYPOINT ["/securedrop/entrypoint.sh"]
