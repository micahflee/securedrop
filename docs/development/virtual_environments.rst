Virtual Environments
====================

There are three virtual environments:

1. Development
2. Staging
3. Production

The Development environment uses Docker, and the Staging and Production
environments use Vagrant. (This means you can develop SecureDrop on a computer
where you can't easily run Vagrant, like inside a Qubes AppVM. You still need
Vagrant and VirtualBox to deploy Staging and Production.)

This document explains the purpose of, and how to get started working with, each
one.

.. note:: If you have errors with mounting shared folders in the Vagrant guest
          machine, you should look at `GitHub #1381`_.

.. _`GitHub #1381`: https://github.com/freedomofpress/securedrop/issues/1381

.. note:: If you see test failures due to ``Too many levels of symbolic links``
          and you are using VirtualBox, try restarting VirtualBox.

.. _development_vm:

Development
-----------

The Development environment uses Docker. It's intended for rapid development on
the SecureDrop web application. It syncs the top level of the SecureDrop repo to
the ``/securedrop`` directory in the container, which means you can use your
favorite editor on your host machine to edit the code. This machine has no
security hardening or monitoring.

To get started working with the development environment, first build the docker
image. This will take awhile:

.. code:: sh

   sudo docker build -t securedrop .

Create your container for the first time:

.. code:: sh
   sudo docker run -it -v $(pwd):/securedrop -p 8000:8000 -p 8080:8080 -p 8081:8081 securedrop bash

If you exit this container, run this to resume it:

.. code:: sh

   sudo docker start -ai securedrop-dev

Here are important commands while you're developing:

.. code:: sh

   cd /securedrop/securedrop
   ./manage.py run         # run development servers
   ./manage.py reset       # resets the state of the development instance
   ./manage.py add-admin   # create a user to use when logging in to the Journalist Interface
   pytest -v tests/        # run the unit and functional tests

SecureDrop consists of two separate web applications (the Source Interface and
the Journalist Interface) that run concurrently. In the Development environment
they are configured to detect code changes and automatically reload whenever a
file is saved. They are made available on your host machine by forwarding the
following ports:

* Source Interface: `localhost:8080 <http://localhost:8080>`__
* Journalist Interface: `localhost:8081 <http://localhost:8081>`__

Staging
-------

A compromise between the development and production environments. This
configuration can be thought of as identical to the production environment, with
a few exceptions:

* The Debian packages are built from your local copy of the code, instead of
  installing the current stable release packages from https://apt.freedom.press.
* The production environment only allows SSH over an Authenticated Tor Hidden
  Service (ATHS), but the staging environment allows direct SSH access so it's
  more ergonomic for developers to interact with the system during debugging.
* The Postfix service is disabled, so OSSEC alerts will not be sent via email.

This is a convenient environment to test how changes work across the full stack.

You should first bring up the VM required for building the app code
Debian packages on the staging machines:

.. code:: sh

   make build-debs
   vagrant up /staging/
   vagrant ssh app-staging
   sudo su
   cd /var/www/securedrop
   ./manage.py add-admin
   pytest -v tests/

To rebuild the local packages for the app code: ::

   make build-debs

The Debian packages will be rebuilt from the current state of your
local git repository and then installed on the staging servers.

.. note:: If you are using Mac OS X and you run into errors from Ansible
          such as ``OSError: [Errno 24] Too many open files``, you may need to
          increase the maximum number of open files. Some guides online suggest
          a procedure to do this that involves booting to recovery mode
          and turning off System Integrity Protection (``csrutil disable``).
          However this is a critical security feature and should not be
          disabled. Instead follow this procedure to increase the file limit.

          Set ``/Library/LaunchDaemons/limit.maxfiles.plist`` to the following:

          .. code:: sh

              <?xml version="1.0" encoding="UTF-8"?>
              <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
                <plist version="1.0">
                  <dict>
                    <key>Label</key>
                      <string>limit.maxfiles</string>
                    <key>ProgramArguments</key>
                      <array>
                        <string>launchctl</string>
                        <string>limit</string>
                        <string>maxfiles</string>
                        <string>65536</string>
                        <string>65536</string>
                      </array>
                    <key>RunAtLoad</key>
                      <true/>
                    <key>ServiceIPC</key>
                      <false/>
                  </dict>
                </plist>

          The plist file should be owned by ``root:wheel``:

          .. code:: sh

            sudo chown root:wheel /Library/LaunchDaemons/limit.maxfiles.plist

          This will increase the maximum open file limits system wide on Mac
          OS X (last tested on 10.11.6).

The web interfaces and SSH are available over Tor. A copy of the the Onion URLs
for Source and Journalist Interfaces, as well as SSH access, are written to the
Vagrant host's ``install_files/ansible-base`` directory, named:

* ``app-source-ths``
* ``app-journalist-aths``
* ``app-ssh-aths``

For working on OSSEC monitoring rules with most system hardening active, update
the OSSEC-related configuration in
``install_files/ansible-base/staging-specific.yml`` so you receive the OSSEC
alert emails.

A copy of the the Onion URL for SSH access to the *Monitor Server* is written to
the Vagrant host's ``install_files/ansible-base`` directory, named:

* ``mon-ssh-aths``

Direct SSH access is available via Vagrant for staging hosts, so you can use
``vagrant ssh app-staging`` and ``vagrant ssh mon-staging`` to start an
interactive session on either server.

Production
----------

This is a production installation with all of the system hardening active, but
virtualized, rather than running on hardware. You will need to
:ref:`configure prod-like secrets<configure_securedrop>`, or export
``ANSIBLE_ARGS="--skip-tags validate"`` to skip the tasks that prevent the prod
playbook from running with Vagrant-specific info.

To create only the prod servers, run:

.. code:: sh

   vagrant up /prod/
   vagrant ssh app-prod
   sudo su
   cd /var/www/securedrop/
   ./manage.py add-admin

A copy of the the Onion URLs for Source and Journalist Interfaces, as well as
SSH access, are written to the Vagrant host's ``install_files/ansible-base``
directory, named:

* ``app-source-ths``
* ``app-journalist-aths``
* ``app-ssh-aths``
* ``mon-ssh-aths``

Direct SSH access is not available in the prod environment. You will need to log
in over Tor after initial provisioning. See :ref:`ssh_over_tor` for more info.

If you plan to alter the configuration of any of these machines, make sure to
review the :ref:`config_tests` documentation.
