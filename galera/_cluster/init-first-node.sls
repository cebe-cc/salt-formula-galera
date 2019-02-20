{%- from "galera/map.jinja" import galera with context %}
{%- if galera.members[0].host == galera.bind.address %}


bootstrap_cluster:
  cmd.run:
    - name: galera_new_cluster

{%- else %}

skip_bootstrap:
  cmd.run:
    - name: /bin/true
  
{%- endif %}
