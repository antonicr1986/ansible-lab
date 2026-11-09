# Ansible Lab

Hands-on Ansible lab using Docker containers as managed hosts.

- **Inventory** with two hosts (`web1`, `web2`) using the Docker connection plugin
- **Role `nginx`**: installs nginx, deploys a templated welcome page and reloads via handler
- **Variables**: role defaults overridden per host with `host_vars`
- **Idempotent**: re-running the playbook reports `changed=0`

## Run it

```bash
docker run -d --name web1 python:3.12-slim sleep infinity
docker run -d --name web2 python:3.12-slim sleep infinity
ansible-playbook -i inventory.ini site.yml
docker exec web1 curl -s localhost
```
