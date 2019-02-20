cluster_new:
  cmd.run:
  - name: 'grep -q "uuid: *00000000-0000-0000-0000-000000000000" /var/lib/mysql/grastate.dat'
  - onlyif:
    - test -f /var/lib/mysql/grastate.dat
      
