Getting Started
===============

.. note:: SecureDrop maintains two branches of documentation, `stable
          <https://docs.securedrop.org/en/stable/development/getting_started.html>`_
          and `latest
          <https://docs.securedrop.org/en/latest/development/getting_started.html>`_,
          the former being the default used by our Read the Docs powered site.
          ``stable`` is built from our latest signed git tag, while ``latest``
          is built from the head of the ``develop`` git branch.  In almost all
          cases involving development work, you'll want to make sure you have
          the ``latest`` version selected by clicking the appropriate link
          above, or by using the menu in the bottom left corner.

Prerequisites
-------------

SecureDrop is a multi-machine design. To make development and testing easy, we
provide a set of virtual environments, each tailored for a specific type of
development task. We use Vagrant, VirtualBox, and Docker to conveniently
develop with a set of virtual environments, and our Ansible playbooks can
provision these environments on either virtual machines or physical hardware.

To get started, you will need to install Vagrant, VirtualBox, Docker, and
Ansible on your development workstation.


Ubuntu/Debian
~~~~~~~~~~~~~

.. note:: Tested on: Ubuntu 16.04 and Debian Stretch

.. code:: sh

   sudo apt-get install -y build-essential libssl-dev libffi-dev python-dev \
       dpkg-dev git

We recommend using the stable version of Docker CE (Community Edition) which can
be installed via the official documentation links:

* `Docker CE for Ubuntu`_
* `Docker CE for Debian`_

.. _`GitHub #932`: https://github.com/freedomofpress/securedrop/pull/932
.. _`Docker CE for Ubuntu`: https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/
.. _`Docker CE for Debian`: https://docs.docker.com/engine/installation/linux/docker-ce/debian/

Finally, install Ansible so it can be used with Vagrant to automatically
provision VMs. We recommend installing Ansible from PyPi with ``pip`` to ensure
you have the latest stable version.

.. code:: sh

    sudo apt-get install python-pip

The version of Ansible recommended to provision SecureDrop VMs may not be the
same as the version in your distro's repos, or may at some point flux out of
sync. For this reason, and also just as a good general development practice, we
recommend using a Python virtual environment to install Ansible and other
development-related tooling. Using `virtualenvwrapper
<http://virtualenvwrapper.readthedocs.io/en/stable/>`_:

.. code:: sh

    sudo apt-get install virtualenvwrapper
    source /usr/share/virtualenvwrapper/virtualenvwrapper.sh
    mkvirtualenv -p /usr/bin/python2 securedrop

.. note:: You'll want to add the command to source ``virtualenvwrapper.sh``
          to your ``~/.bashrc`` (or whatever your default shell configuration
          file is) so that the command-line utilities ``virtualenvwrapper``
          provides are automatically available in the future.

Mac OS X
~~~~~~~~

Install the dependencies for the development environment:

#. Ansible_
#. Docker_
#. rsync >= 3.1.0

.. note:: Note that the version of rsync installed by default on macOS is
          extremely out-of-date, as is Apple's custom. We recommend using
          Homebrew_ to install a modern version (3.1.0 or greater):
          ``brew install rsync``.

There are several ways to install Ansible on a Mac. We recommend installing it
to a virtual environment using ``virtualenvwrapper`` and ``pip``, so as not to
install the older version we use system-wide. The following commands assume your
default Python is the Python2 that ships with macOS. If you are using a
different version, the path to ``virtualenvwrapper.sh`` will differ. Running
``pip show virtualenvwrapper`` should help you find it.

.. code:: sh

    sudo easy_install pip # if you don't already have pip
    pip install -U virtualenvwrapper
    source /usr/local/bin/virtualenvwrapper.sh
    mkvirtualenv -p python2 securedrop

.. note:: You'll want to add the command to source ``virtualenvwrapper.sh``
          to your ``~/.bashrc`` (or whatever your default shell configuration
          file is) so that the command-line utilities ``virtualenvwrapper``
          provides are automatically available in the future.

.. _Ansible: http://docs.ansible.com/intro_installation.html
.. _Homebrew: https://brew.sh/
.. _Docker: https://store.docker.com/editions/community/docker-ce-desktop-mac

Fork & Clone the repository
---------------------------

Now you are ready to get your own copy of the source code.
Visit our repository_ fork it and clone it on you local machine:


.. code:: sh

   git clone git@github.com:<your_github_username>/securedrop.git

.. _repository: https://github.com/freedomofpress/securedrop

Install python requirments
--------------------------

SecureDrop uses many 3rd party open source packages from the python community.
Ensure your virtualenv is activated and install the packages.

.. code:: sh

    pip install -r securedrop/requirements/develop-requirements.txt
    pip install -r testinfra/requirements.txt

.. note:: You will need to run this everytime new packages are added.
