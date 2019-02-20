{%- from "galera/map.jinja" import galera with context %}
{%- if galera.members[0].host != galera.bind.address %}

join_cluster:
  service.running:
  - name: {{ galera.service }}
  - enable: true

{%- else %}

skip_join:
  cmd.run:
    - name: /bin/true
  
{%- endif %}
 