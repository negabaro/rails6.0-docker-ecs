RAILS_CONTAINER_ID=`docker ps | grep rails | awk '{print $$1}'`

ENV_MODE="prd"
SERVICE="handson"
CONTAINER_NAME=${ENV_MODE}-${SERVICE}
IMG_NAME="rails"

ECR_HOST="xxx.dkr.ecr.ap-northeast-1.amazonaws.com"
STG_PRD_ECR_IMG_NAME="univas-rails-prd"
ECR_IMG_TAG="latest"
AWS_PROFILE="default"

define DOCKER_RUN_FOR_TEST
docker run \
	--rm --name $(CONTAINER_NAME) \
  -p 3002:3000 	$(IMG_NAME)/$(CONTAINER_NAME) tail -f /dev/null
endef
export DOCKER_RUN_FOR_TEST

define DOCKER_RUN
docker run \
	--rm --name $(CONTAINER_NAME) \
  -p 3002:3000 	$(IMG_NAME)/$(CONTAINER_NAME)
endef
export DOCKER_RUN

define DOCKER_BUILD
docker build -t ${IMG_NAME}/${CONTAINER_NAME} --file Dockerfile .
endef

define DOCKER_PUSH
#docker commit ${RAILS_CONTAINER_ID} ${IMG_NAME}/${CONTAINER_NAME}
docker tag ${IMG_NAME}/${CONTAINER_NAME} ${ECR_HOST}/${STG_PRD_ECR_IMG_NAME}:${ECR_IMG_TAG}
docker push ${ECR_HOST}/${STG_PRD_ECR_IMG_NAME}:${ECR_IMG_TAG}
endef

define DOCKER_RM_IF_CONTAINER_IS_ALIVE
if [ `docker ps -q -f name=${CONTAINER_NAME}` ]; then docker rm -f ${CONTAINER_NAME}; fi
endef

ecr-login:
	aws ecr get-login --no-include-email --region ap-northeast-1 --profile ${AWS_PROFILE} | sh -

push: ecr-login
	$(DOCKER_BUILD)
	$(DOCKER_PUSH)

# rails dockerイメージをbuildする
build:
	$(DOCKER_RM_IF_CONTAINER_IS_ALIVE)
	$(DOCKER_BUILD)

# rails dockerイメージをbuild & runする
build-run:
	$(DOCKER_RM_IF_CONTAINER_IS_ALIVE)
	$(DOCKER_BUILD)
	$(DOCKER_RUN)

tt:
	$(DOCKER_RUN_FOR_TEST)
# railsコンテナーログ確認(tail -f)
rails-log:
	docker logs $(RAILS_CONTAINER_ID) -f

# railsコンテナーに接続
exec-rails:
	docker exec -it $(RAILS_CONTAINER_ID) bash

bundle:
	bundle install --path vendor/bundle


build-push:
	make bb
	make pp

rr:
	docker run -i -t --rm --name ${CONTAINER_NAME} -p 3001:3000 -e "ROOT_PATH=/app" -e "RUN_MODE=development"  ${REPO_NAME}/${CONTAINER_NAME}

bb:
	docker build -t ${REPO_NAME}/${CONTAINER_NAME} --file Dockerfile .

pp:
	docker push ${REPO_NAME}/${CONTAINER_NAME}:latest

bundle:
	bundle install --path vendor/bundle

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

#test:
#		docker exec ${CONTAINER_NAME} curl localhost:3000 -Ss -o /dev/null # health check against rails