# Ansible Lab

[![CI](https://github.com/antonicr1986/ansible-lab/actions/workflows/ci.yml/badge.svg)](https://github.com/antonicr1986/ansible-lab/actions/workflows/ci.yml)

<details open>
<summary><strong>🇬🇧 English</strong></summary>

<br>

Hands-on **configuration management** lab with Ansible. An `nginx` role is deployed from a WSL (Ubuntu) control node to two Docker containers that act as servers, and every push is validated by a CI pipeline.

![Ansible Lab architecture](docs/architecture-en.png)

### What it covers

- **Inventory** with two hosts (`web1`, `web2`) using the Docker connection plugin, no SSH needed
- **`ansible.cfg`** with project defaults (inventory, roles path, YAML output, vault password file)
- **Variables and precedence**: role `defaults` → `group_vars` → `host_vars` → `-e`
- **Two roles** applied in order:
  - `common`: base packages, timezone and users
  - `nginx`: installs nginx, renders the welcome page from a **Jinja2 template** using facts and makes sure nginx is running
- **Loops**: users created from a list (`loop` + `loop_control`)
- **Conditionals**: debug tools installed only on the staging host (`when`), and an `assert` that checks the OS family with facts
- **Tags**: run only part of the playbook (`--tags usuarios`, `--skip-tags nginx`)
- **Handlers**: nginx is reloaded only when the page actually changes
- **Ansible Vault**: an encrypted secret (`app_token`) stored in the repo and deployed with `no_log: true` and `0600` permissions
- **Idempotency**: a second run reports `changed=0` (checked automatically in CI)
- **Code quality**: `yamllint` + `ansible-lint` passing the `production` profile

### CI pipeline (GitHub Actions)

| Job | What it does |
|---|---|
| `lint` | Runs `yamllint` and `ansible-lint` |
| `deploy-test` | Installs `ansible-core` + collections from `requirements.yml`, starts `web1` and `web2` with Docker Compose, runs the playbook twice, fails if the second run is not idempotent and checks nginx responds on both hosts |

The vault password is provided to the pipeline as the `ANSIBLE_VAULT_PASSWORD` repository secret.

### Structure

```
ansible-lab/
├── .github/workflows/ci.yml   # CI pipeline
├── ansible.cfg                # project settings
├── .yamllint                  # yamllint rules (compatible with ansible-lint)
├── requirements.yml           # required collections
├── compose.yaml               # test servers (web1, web2)
├── Makefile                   # shortcuts: deps, up, deploy, lint, down
├── inventory.ini              # hosts
├── site.yml                   # main playbook (common + nginx)
├── group_vars/
│   └── webservers.yml         # connection vars, group message and vaulted secret
├── host_vars/
│   └── web2.yml               # per-host override (staging)
├── roles/
│   ├── common/
│   │   ├── defaults/main.yml  # packages, timezone, users
│   │   └── tasks/main.yml     # assert · packages · timezone · users
│   └── nginx/
│       ├── defaults/main.yml  # default variables
│       ├── tasks/main.yml     # install · template · start · secret
│       ├── handlers/main.yml  # reload nginx
│       └── templates/
│           └── index.html.j2  # welcome page
└── docs/                      # diagrams
```

### Requirements

- Linux or WSL (Ubuntu) with Ansible (`pipx install --include-deps ansible`)
- Docker (Docker Desktop with WSL integration enabled)
- `make`

### Run it

The vault password is not in the repo. To run it locally, create your own password and replace `app_token` in `group_vars/webservers.yml` with your own encrypted value:

```bash
echo 'your-password' > .vault_pass && chmod 600 .vault_pass
ansible-vault encrypt_string 'your-token' --name 'app_token'
```

Then:

```bash
make deps     # install collections
make up       # start web1 and web2
make deploy   # run the playbook

docker exec web1 curl -s localhost
docker exec web2 curl -s localhost
```

Expected output:

```
Hola desde web1. Mensaje del grupo webservers
Sistema: Debian 13.x
Hola desde web2. Soy el servidor de staging
Sistema: Debian 13.x
```

`web1` takes its message from `group_vars` and `web2` from `host_vars`, which has higher precedence.

Run only part of the playbook with tags:

```bash
ansible-playbook site.yml --list-tags
ansible-playbook site.yml --tags usuarios
ansible-playbook site.yml --skip-tags nginx
```

### Lint

```bash
make lint
```

### Clean up

```bash
make down
```

</details>

<details>
<summary><strong>🇪🇸 Español</strong></summary>

<br>

Laboratorio práctico de **gestión de configuración** con Ansible. Se despliega un rol `nginx` desde un nodo de control en WSL (Ubuntu) a dos contenedores Docker que hacen de servidores, y cada push se valida con un pipeline de CI.

![Arquitectura de Ansible Lab](docs/architecture-es.png)

### Qué incluye

- **Inventario** con dos hosts (`web1`, `web2`) usando el plugin de conexión Docker, sin necesidad de SSH
- **`ansible.cfg`** con la configuración del proyecto (inventario, ruta de roles, salida en YAML, fichero de contraseña del vault)
- **Variables y prioridad**: `defaults` del rol → `group_vars` → `host_vars` → `-e`
- **Dos roles** aplicados en orden:
  - `common`: paquetes base, zona horaria y usuarios
  - `nginx`: instala nginx, genera la página de bienvenida con una **plantilla Jinja2** que usa facts y se asegura de que nginx esté en marcha
- **Bucles**: usuarios creados a partir de una lista (`loop` + `loop_control`)
- **Condicionales**: herramientas de depuración solo en el servidor de staging (`when`) y un `assert` que comprueba la familia del sistema con facts
- **Tags**: ejecutar solo una parte del playbook (`--tags usuarios`, `--skip-tags nginx`)
- **Handlers**: nginx solo se recarga cuando la página cambia de verdad
- **Ansible Vault**: un secreto cifrado (`app_token`) guardado en el repo y desplegado con `no_log: true` y permisos `0600`
- **Idempotencia**: una segunda ejecución da `changed=0` (se comprueba automáticamente en el CI)
- **Calidad de código**: `yamllint` + `ansible-lint` superando el perfil `production`

### Pipeline de CI (GitHub Actions)

| Job | Qué hace |
|---|---|
| `lint` | Ejecuta `yamllint` y `ansible-lint` |
| `deploy-test` | Instala `ansible-core` + las colecciones de `requirements.yml`, levanta `web1` y `web2` con Docker Compose, ejecuta el playbook dos veces, falla si la segunda ejecución no es idempotente y comprueba que nginx responde en los dos hosts |

La contraseña del vault llega al pipeline mediante el secret del repositorio `ANSIBLE_VAULT_PASSWORD`.

### Estructura

```
ansible-lab/
├── .github/workflows/ci.yml   # pipeline de CI
├── ansible.cfg                # configuración del proyecto
├── .yamllint                  # reglas de yamllint (compatibles con ansible-lint)
├── requirements.yml           # colecciones necesarias
├── compose.yaml               # servidores de prueba (web1, web2)
├── Makefile                   # atajos: deps, up, deploy, lint, down
├── inventory.ini              # hosts
├── site.yml                   # playbook principal (common + nginx)
├── group_vars/
│   └── webservers.yml         # conexión, mensaje del grupo y secreto cifrado
├── host_vars/
│   └── web2.yml               # variables propias de web2 (staging)
├── roles/
│   ├── common/
│   │   ├── defaults/main.yml  # paquetes, zona horaria, usuarios
│   │   └── tasks/main.yml     # assert · paquetes · zona horaria · usuarios
│   └── nginx/
│       ├── defaults/main.yml  # variables por defecto
│       ├── tasks/main.yml     # instalar · plantilla · arrancar · secreto
│       ├── handlers/main.yml  # recargar nginx
│       └── templates/
│           └── index.html.j2  # página de bienvenida
└── docs/                      # diagramas
```

### Requisitos

- Linux o WSL (Ubuntu) con Ansible (`pipx install --include-deps ansible`)
- Docker (Docker Desktop con la integración WSL activada)
- `make`

### Cómo ejecutarlo

La contraseña del vault no está en el repo. Para ejecutarlo en local, crea tu propia contraseña y sustituye `app_token` en `group_vars/webservers.yml` por tu propio valor cifrado:

```bash
echo 'tu-contraseña' > .vault_pass && chmod 600 .vault_pass
ansible-vault encrypt_string 'tu-token' --name 'app_token'
```

Después:

```bash
make deps     # instala las colecciones
make up       # levanta web1 y web2
make deploy   # ejecuta el playbook

docker exec web1 curl -s localhost
docker exec web2 curl -s localhost
```

Resultado esperado:

```
Hola desde web1. Mensaje del grupo webservers
Sistema: Debian 13.x
Hola desde web2. Soy el servidor de staging
Sistema: Debian 13.x
```

`web1` toma el mensaje de `group_vars` y `web2` de `host_vars`, que tiene más prioridad.

Ejecutar solo una parte del playbook con tags:

```bash
ansible-playbook site.yml --list-tags
ansible-playbook site.yml --tags usuarios
ansible-playbook site.yml --skip-tags nginx
```

### Lint

```bash
make lint
```

### Limpiar

```bash
make down
```

</details>
