
=====
Usage
=====

Galera Cluster for MySQL or Mariadb is a true Multimaster Cluster based on synchronous
replication. Galera Cluster is an easy-to-use, high-availability solution,
which provides high system uptime, no data loss and scalability for future
growth.

Sample pillars
==============

Galera cluster node

.. code-block:: yaml

    galera:
      version:
        mysql: 5.6
        galera: 3
      engine: mysql or mariadb
      enabled: true
      name: openstack
      bind:
        address: 192.168.0.1
        port: 3306
      members:
      - host: 192.168.0.1
        port: 4567
      - host: 192.168.0.2
        port: 4567
      admin:
        user: root
        password: pass
      database:
        name:
          encoding: 'utf8'
          users:
          - name: 'username'
            password: 'password'
            host: 'localhost'
            rights: 'all privileges'
            database: '*.*'


Enable TLS support:

.. code-block:: yaml

    galera:
       ssl:
        enabled: True
        ciphers:
          DHE-RSA-AES128-SHA:
            enabled: True
          DHE-RSA-AES256-SHA:
            enabled: True
          EDH-RSA-DES-CBC3-SHA:
            name: EDH-RSA-DES-CBC3-SHA
            enabled: True
          AES128-SHA:AES256-SHA:
            name: AES128-SHA:AES256-SHA
            enabled: True
          DES-CBC3-SHA:
            enabled: True
        # path
        cert_file: /etc/mysql/ssl/cert.pem
        key_file: /etc/mysql/ssl/key.pem
        ca_file: /etc/mysql/ssl/ca.pem

        # content (not required if files already exists)
        key: << body of key >>
        cert: << body of cert >>
        cacert_chain: << body of ca certs chain >>


Additional mysql users:

.. code-block:: yaml

    mysql:
      server:
        users:
          - name: clustercheck
            password: clustercheck
            database: '*.*'
            grants: PROCESS
          - name: inspector
            host: 127.0.0.1
            password: password
            databases:
              mydb:
                - database: mydb
                - table: mytable
                - grant_option: True
                - grants:
                  - all privileges

Additional mysql SSL grants:

.. code-block:: yaml

    mysql:
      server:
        users:
          - name: clustercheck
            password: clustercheck
            database: '*.*'
            grants: PROCESS
            ssl_option:
              - SSL: True
              - X509: True
              - SUBJECT: <subject>
              - ISSUER: <issuer>
              - CIPHER: <cipher>

Additional check params:
========================

.. code-block:: yaml

    galera:
      clustercheck:
        - enabled: True
        - user: clustercheck
        - password: clustercheck
        - available_when_donor: 0
        - available_when_readonly: 1
        - port 9200

Configurable soft parameters
============================

- ``galera_innodb_buffer_pool_size``
   Default is ``3138M``
- ``galera_max_connections``
   Default is ``20000``
- ``galera_innodb_read_io_threads``
   Default is ``8``
- ``galera_innodb_write_io_threads``
   Default is ``8``
- ``galera_wsrep_slave_threads``
   Default is ``8``
- ``galera_xtrabackup_parallel``
   Default is 4
- ``galera_error_log_enabled``
   Default is ``true``
- ``galera_error_log_path``
   Default is ``/var/log/mysql/error.log``

Usage:

.. code-block:: yaml

    _param:
      galera_innodb_buffer_pool_size: 1024M
      galera_max_connections: 200
      galera_innodb_read_io_threads: 16
      galera_innodb_write_io_threads: 16
      galera_wsrep_slave_threads: 8
      galera_xtrabackup_parallel: 2
      galera_error_log_enabled: true
      galera_error_log_path: /var/log/mysql/error.log

Usage
=====

MySQL/Mariadb Galera check sripts

.. code-block:: bash

    mysql> SHOW STATUS LIKE 'wsrep%';

    mysql> SHOW STATUS LIKE 'wsrep_cluster_size' ;"

Galera monitoring command, performed from extra server

.. code-block:: bash

    garbd -a gcomm://ipaddrofone:4567 -g my_wsrep_cluster -l /tmp/1.out -d


Bootstrapping a new cluster
===========================

The normal operation of a Galera cluster is that a new member
will automatically join when running the high state.

There are two special cases:

#. Bootstrapping a brand new cluster
#. Recover a stopped cluster

The first case is covered by orchestration.

.. code-block:: bash

    salt-run state.orchestrate galera.orchestrate.cluster saltenv=test pillar='{ saltenv : test, galera_cluster : cluster1 }'

Passing the pillar data is necessary to propagate the saltenv setting.
This is not required for the base environment which is the default.

The bootstrap will test (and fail) if any of the nodes already have
pre-existing cluster data, since bootstrapping over an existing cluster
is dangerous and destructive.


Read more
=========

* https://github.com/CaptTofu/ansible-galera
* http://www.sebastien-han.fr/blog/2012/04/15/active-passive-failover-cluster-on-a-mysql-galera-cluster-with-haproxy-lsb-agent/
* http://opentodo.net/2012/12/mysql-multi-master-replication-with-galera/
* http://www.codership.com/wiki/doku.php
* http://www.sebastien-han.fr/blog/2012/04/01/mysql-multi-master-replication-with-galera/

Documentation and bugs
======================

* http://salt-formulas.readthedocs.io/
   Learn how to install and update salt-formulas

*  https://github.com/salt-formulas/salt-formula-galera/issues
   In the unfortunate event that bugs are discovered, report the issue to the
   appropriate issue tracker. Use the Github issue tracker for a specific salt
   formula

* https://launchpad.net/salt-formulas
   For feature requests, bug reports, or blueprints affecting the entire
   ecosystem, use the Launchpad salt-formulas project

* https://launchpad.net/~salt-formulas-users
   Join the salt-formulas-users team and subscribe to mailing list if required

* https://github.com/salt-formulas/salt-formula-galera
   Develop the salt-formulas projects in the master branch and then submit pull
   requests against a specific formula

* #salt-formulas @ irc.freenode.net
   Use this IRC channel in case of any questions or feedback which is always
   welcome

