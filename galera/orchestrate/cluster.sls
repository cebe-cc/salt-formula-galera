{%- if pillar.saltenv is not defined %}
{{ salt.test.exception("saltenv pillar not set") }}
{%- endif %}

{# Set up a new cluster #}


{# test if a previous cluster was defined on any of the machines #}

cluster_uninitialized:
  salt.state:
    - tgt: 'I@galera:name:{{ pillar.galera_cluster }}'
    - tgt_type: compound
    - sls: galera._cluster.uninitialized
    - saltenv: {{ pillar.saltenv }}      

{# kill all hanging mysqld daemons #}

kill_mysqld:
  salt.function:
    - name:
        cmd.run
    - tgt: 'I@galera:name:{{ pillar.galera_cluster }}'
    - tgt_type: compound
    - arg:
      - killall -9 mysqld
    - require:
      - cluster_uninitialized

{# bootstrap the first node #}

first_node_init:
  salt.state:
    - tgt: 'I@galera:name:{{ pillar.galera_cluster }}'
    - tgt_type: compound
    - sls: galera._cluster.init-first-node
    - saltenv: {{ pillar.saltenv }}
    - require:
      - cluster_uninitialized
      - kill_mysqld

{# bootstrap the slaves #}

slave_init:
  salt.state:
    - tgt: 'I@galera:name:{{ pillar.galera_cluster }}'
    - tgt_type: compound
    - sls: galera._cluster.init-secondary-nodes
    - saltenv: {{ pillar.saltenv }}
    - require:
      - cluster_uninitialized
      - first_node_init

