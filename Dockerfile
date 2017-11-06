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

# Add a new user
RUN groupadd user && \
    useradd -r -u 1000 -g user user && \
    usermod -a -G sudo user && \
    mkdir /home/user && \
    chown -R user:user /home/user && \
    sed -i 's/sudo\tALL=(ALL:ALL) ALL/sudo ALL=\(ALL\) NOPASSWD:ALL/g' /etc/sudoers

# Add source to /securedrop
ADD . /securedrop

# Run the securedrop-development ansible playbook
RUN mkdir /etc/ansible && \
    echo "development ansible_host=127.0.0.1" >> /etc/ansible/hosts

RUN sudo service supervisor start && \
    ansible-playbook --connection=local --limit development /securedrop/install_files/ansible-base/securedrop-development.yml

USER user
WORKDIR /securedrop/securedrop
ENTRYPOINT ["/securedrop/entrypoint.sh"]
