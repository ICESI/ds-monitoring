### TICK stack
Telegraph, InfluxDB, Chronograph, Kapacitor

### Ansible
```
vagrant up
ansible-playbook -i hosts playbooks/mirror.yml
ansible-playbook -i hosts playbooks/tick.yml
```

### References
https://www.influxdata.com/time-series-platform/
