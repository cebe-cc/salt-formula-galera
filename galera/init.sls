{% set engine = pillar.galera.get('engine', 'mysql') %}
{%- if pillar.galera is defined %}
include:
- galera.member
{%- if pillar.galera.clustercheck is defined %}
- galera.clustercheck
{%- endif %}
{%- if pillar.galera.monitor is defined %}
- galera.monitor
{%- endif %}
{%- endif %}
