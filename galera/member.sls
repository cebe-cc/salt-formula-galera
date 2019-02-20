{%- from "galera/map.jinja" import galera with context %}
{% set engine = pillar.galera.get('engine', 'mysql') %}
{%- if galera.get('enabled', False) %}

{%-   if galera.get('ssl', {}).get('enabled', False) %}
include:
  - galera._ssl
{%-   endif %}

{%-   if grains.os_family == 'RedHat' %}
xtrabackup_repo:
  pkg.installed:
  - sources:
    - percona-release: {{ galera.xtrabackup_repo }}
  - require_in:
    - pkg: galera_packages

# Workaround https://bugs.launchpad.net/percona-server/+bug/1490144
xtrabackup_repo_fix:
  cmd.run:
    - name: |
        sed -i 's,enabled\ =\ 1,enabled\ =\ 1\nexclude\ =\ Percona-XtraDB-\*\ Percona-Server-\*,g' /etc/yum.repos.d/percona-release.repo
    - unless: 'grep "exclude = Percona-XtraDB-\*" /etc/yum.repos.d/percona-release.repo'
    - watch:
      - pkg: xtrabackup_repo
    - require_in:
      - pkg: galera_packages
{%-   endif %}{# red hat #}

galera_packages:
  pkg.installed:
  - names: {{ galera.pkgs }}
  - refresh: true
  - force_yes: True

{%-    if engine == 'mysql'  %}
galera_dirs:
  file.directory:
  - names: ['/var/log/mysql', '/etc/mysql']
  - makedirs: true
  - mode: 755
  - require:
    - pkg: galera_packages

{%-     if grains.os_family == 'Debian' %}

galera_run_dir:
  file.directory:
  - name: /var/run/mysqld
  - makedirs: true
  - mode: 755
  - user: mysql
  - group: root
  - require:
    - pkg: galera_packages

{%-       if grains.get('init', None) == "upstart" %}

galera_purge_init:
  file.absent:
  - name: /etc/init.d/mysql
  - require:
    - pkg: galera_packages

galera_overide:
  file.managed:
  - name: /etc/init/mysql.override
  - contents: |
      limit nofile 102400 102400
      exec /usr/bin/mysqld_safe
  - require:
    - pkg: galera_packages

{%-       elif grains.get('init', None) == "systemd" %}

galera_systemd_directory_present:
  file.directory:
  - name: /etc/systemd/system/mysql.service.d
  - user: root
  - group: root
  - mode: 755
  - require:
    - pkg: galera_packages

galera_override_limit_no_file:
  file.managed:
  - name: /etc/systemd/system/mysql.service.d/override.conf
  - contents: |
      [Service]
      LimitNOFILE=1024000
  - require:
    - pkg: galera_packages
    - file: galera_systemd_directory_present
  - watch_in:
    - service: galera_service

mysql_restart_systemd:
  module.wait:
  - name: service.systemctl_reload
  - watch:
    - file: /etc/systemd/system/mysql.service.d/override.conf
  - require_in:
    - service: galera_service

{%-       endif %}{# upstart/systemd #}

galera_conf_debian:
  file.managed:
  - name: /etc/mysql/debian.cnf
  - template: jinja
  - source: salt://galera/files/debian.cnf
  - mode: 640
  - require:
    - pkg: galera_packages

{%-     endif %}{# debian #}


{%-    endif %}{# engine == 'mysql' #}


galera_config:
  file.managed:
  - name: {{ galera.config }}
  - source: salt://galera/files/my.cnf
  - mode: 644
  - template: jinja

{#   if grains.get('galera_bootstrap_done', '') == True #}

galera_service:
  service.running:
  - name: {{ galera.service }}
  - enable: true
  - require:
    - galera_packages
    - galera_config

{#-   else #}
{# galera_service:
  service.dead:
  - name: {{ galera.service }}
  - enable: False
  - require:
    - galera_packages
    - galera_config
#}
{#-   endif #}

{%- endif %}
