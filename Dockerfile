FROM ubuntu:14.04

RUN apt-get update
RUN apt-get install -y build-essential libssl-dev libffi-dev python-dev \
      dpkg-dev git python-pip

ADD securedrop/requirements/develop-requirements.txt .
RUN pip install -r develop-requirements.txt
ADD testinfra/requirements.txt .
RUN pip install -r requirements.txt
