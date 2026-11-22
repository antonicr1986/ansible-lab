.RECIPEPREFIX = >
.PHONY: deps up deploy lint down

deps:
> ansible-galaxy collection install -r requirements.yml

up:
> docker compose up -d

deploy:
> ansible-playbook site.yml

lint:
> yamllint .
> ansible-lint

down:
> docker compose down
