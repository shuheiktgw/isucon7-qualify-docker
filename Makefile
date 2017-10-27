DOCKER=$(shell which docker)
DOCKER_COMPOSE := docker-compose -f ./docker-compose.yml
DOCKER_EXEC := $(DOCKER) exec -it

CONTAINER_FOR_DB_SETUP := isucon7-app03
DB_HOST := localhost
DB_USER := root

ps:
	$(DOCKER_COMPOSE) ps

up:
	$(DOCKER_COMPOSE) up -d
	@echo 'Waiting for mysql to start up...'
	@sh -c 'until ($(DOCKER_EXEC) $(CONTAINER_FOR_DB_SETUP) mysqladmin ping -h$(DB_HOST) -u$(DB_USER)) do sleep 1; done' > /dev/null
	$(DOCKER_EXEC) $(CONTAINER_FOR_DB_SETUP) sh -x /home/isucon/isubata/docker/setup.sh


clean: stop rmi

stop:
	$(DOCKER_COMPOSE) stop

rm:
	$(DOCKER_COMPOSE) rm -f

rmi:
	$(eval IMAGES := $(shell $(DOCKER_COMPOSE) images -s))
	echo $(IMAGES)
	# $(DOCKER) rmi -f $(IMAGES)

logs/%:
	$(DOCKER_COMPOSE) logs $*

images:
	$(DOCKER_COMPOSE) images

attach/%:
	$(DOCKER_EXEC) isucon7-$* /bin/bash

