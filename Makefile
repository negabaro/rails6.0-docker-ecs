REPO_NAME="negabaro"
SERVICE="base"
NAME="rails"
CONTAINER_NAME=${SERVICE}-${NAME}


help:
		@echo "Makefile for ${SERVICE}."
		@echo "available options:"
		@echo "- make test"
		@echo "- make build-push"
		@echo "- make build-run"
		@echo "- make run"
		@echo "- make build"
		@echo "- make push"

build-push:
	make bb
	make pp

build-run:
	make bb
	make rr

rr:
	docker run -i -t --rm --name ${CONTAINER_NAME} -p 3001:3000 -e "ROOT_PATH=/rails_sample" -e "RUN_MODE=development"  ${REPO_NAME}/${CONTAINER_NAME}

bb:
	docker build -t ${REPO_NAME}/${CONTAINER_NAME} --file Dockerfile .

pp:
	docker push ${REPO_NAME}/${CONTAINER_NAME}:latest

b:
	bundle exec bin/webpack

s:
	bundle exec rails s

c:
	bundle exec rails c

w:
	bin/webpack-dev-server

test-setup:
		if [ `docker ps -q -f name=${CONTAINER_NAME}` ]; then docker rm -f ${CONTAINER_NAME}; fi
			docker build -t test/${CONTAINER_NAME} --file Dockerfile .
			docker run -d --rm --name ${CONTAINER_NAME} -p 3001:3000 -p 8082:80 -e "ROOT_PATH=/rails_sample" -e "RUN_MODE=development"  test/${CONTAINER_NAME}

test:
		docker exec ${CONTAINER_NAME} curl localhost:3000 -Ss -o /dev/null # health check against rails