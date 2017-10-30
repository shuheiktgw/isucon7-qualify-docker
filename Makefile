.DEFAULT_GOAL := help
help:
	@echo ''
	@echo '  isucon7-qualify-docker'
	@echo ''
	@echo '  see: https://github.com/at-grandpa/isucon7-qualify-docker'
	@echo ''
	@grep -E '^[%/a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}'
	@echo ''

DOCKER=$(shell which docker)
DOCKER_COMPOSE := docker-compose -f ./docker-compose.yml
DOCKER_EXEC := $(DOCKER) exec -it

# ==========================
# コンテナ操作
# ==========================

up: ## buildからup、nginxとmysqlの起動までを全て行う
	$(DOCKER_COMPOSE) up -d
	$(MAKE) nginx/start
	$(MAKE) mysql/start

stop: ## コンテナを停止する
	$(DOCKER_COMPOSE) stop

rm: ## コンテナを削除する
	$(DOCKER_COMPOSE) rm -f

clean: stop rm ## コンテナを停止し削除する

ps: ## コンテナの一覧と状態を表示する
	$(DOCKER_COMPOSE) ps

logs/%: ## '%'にapp01/app02/app03/benchを指定すると、指定されたコンテナの直近のlogを表示する
	$(DOCKER_COMPOSE) logs $*

attach/%: ## '%'にapp01/app02/app03/benchを指定すると、指定されたコンテナにattachする
	$(DOCKER_EXEC) isucon7-$* /bin/bash


# ==========================
# nginx
# ==========================

nginx/start: ## 全Webサーバーのnginxを起動する
	@$(MAKE) nginx/start/app01 nginx/start/app02

nginx/start/%: ## '%'にapp01/app02を指定すると、指定されたWebサーバーでnginxを起動する
	@echo '$* nginx start.'
	@$(DOCKER_EXEC) isucon7-$* sudo /etc/init.d/nginx start

nginx/restart: ## 全Webサーバーのnginxを再起動する
	@$(MAKE) nginx/restart/app01 nginx/restart/app02

nginx/restart/%: ## '%'にapp01/app02を指定すると、指定されたWebサーバーでnginxを再起動する
	@echo '$* nginx restart.'
	@$(DOCKER_EXEC) isucon7-$* sudo /etc/init.d/nginx restart

nginx/stop: ## 全Webサーバーのnginxを停止する
	@$(MAKE) nginx/stop/app01 nginx/stop/app02

nginx/stop/%: ## '%'にapp01/app02を指定すると、指定されたWebサーバーでnginxを停止する
	@echo '$* nginx stop.'
	@$(DOCKER_EXEC) isucon7-$* sudo /etc/init.d/nginx stop

nginx/status: ## 全Webサーバーのnginxのstatusを表示する
	@$(MAKE) nginx/status/app01 nginx/status/app02

nginx/status/%: ## '%'にapp01/app02を指定すると、指定されたWebサーバーでnginxのstatusを見る
	@echo '$* nginx status:'
	@$(DOCKER_EXEC) isucon7-$* sudo /etc/init.d/nginx status || true

# ==========================
# mysql
# ==========================

mysql/start: ## app03でmysqlを起動する
	@echo 'app03 mysql start.'
	@$(DOCKER_EXEC) isucon7-app03 sudo /etc/init.d/mysql start

mysql/restart: ## app03でmysqlを再起動する
	@echo 'app03 mysql restart.'
	@$(DOCKER_EXEC) isucon7-app03 sudo /etc/init.d/mysql restart

mysql/stop: ## app03でmysqlを停止する
	@echo 'app03 mysql stop.'
	@$(DOCKER_EXEC) isucon7-app03 sudo /etc/init.d/mysql stop

mysql/status: ## app03でmysqlのstatusを見る
	@echo 'app03 mysql status.'
	@$(DOCKER_EXEC) isucon7-app03 sudo /etc/init.d/mysql status || true

# ==========================
# webapp
# ==========================

app/start/python: ## 全Webサーバーでpythonのwebappが起動する
	$(MAKE) -j app/start/python/app01 app/start/python/app02

app/start/python/%: ## '%'にapp01/app02を指定すると、指定されたWebサーバーでpythonのwebappが起動する
	$(DOCKER_EXEC) isucon7-$* sh -x /home/isucon/isubata/docker/app/setup_python.sh

app/start/go: ## 全Webサーバーでgoのwebappが起動する
	$(MAKE) -j app/start/go/app01 app/start/go/app02

app/start/go/%:  ## '%'にapp01/app02を指定すると、指定されたWebサーバーでgoのwebappが起動する
	$(DOCKER_EXEC) isucon7-$* sh -x /home/isucon/isubata/docker/app/setup_go.sh

# ==========================
# bench
# ==========================

BENCH_TARGET_HOSTS := app01,app02
bench/start: ## BENCH_TARGET_HOSTSで指定したhostに対してベンチマークを走らせる  ex) $ make bench/start BENCH_TARGET_HOSTS=app01,app02
	$(DOCKER_EXEC) isucon7-bench sh -c 'cd /tmp/isubata/bench && ./bin/bench -remotes=$(BENCH_TARGET_HOSTS) -output result.json'

JQ_QUERY := .
bench/result: ## 直近のベンチマークの result.json を jq コマンドで見る
	@$(DOCKER_EXEC) isucon7-bench sh -c 'jq $(JQ_QUERY) < /tmp/isubata/bench/result.json'

bench/score: ## 直近のベンチマークのスコアを見る
	@echo 'recent benchmark score:'
	@$(MAKE) bench/result JQ_QUERY=.score

# ==========================
# other
# ==========================

.PHONY: help \
	up \
	stop \
	rm \
	clean \
	ps \
	logs/% \
	attach/% \
	nginx/start \
	nginx/start/% \
	nginx/restart \
	nginx/restart/% \
	nginx/stop \
	nginx/stop/% \
	nginx/status \
	nginx/status/% \
	mysql/start \
	mysql/restart \
	mysql/stop \
	mysql/status \
	app/start/python \
	app/start/python/% \
	app/start/go \
	app/start/go/% \
	bench/start \
	bench/result \
	bench/score
