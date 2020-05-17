#CONFIG_ENV := ../make/config.env
#include $(CONFIG_ENV)
TERRAFORM_VERSION := 0.12.25
#TERRAFORM_VERSION := 0.11.8
CURRENT_PATH := $(shell pwd)
CONTAINER_PATH := /opt/app
ENVIRONMENT := dev
WORK_DIR := /opt/app

CMD := --version
AWS_DEFAULT_PROFILE ?= default
AWS_DEFAULT_REGION ?= ap-northeast-1

#export AWS_DEFAULT_REGION = 'ap-northeast-1'
export AWS_ACCESS_KEY_ID ?= $(shell aws configure get \
	    "$(AWS_DEFAULT_PROFILE).aws_access_key_id")
export AWS_SECRET_ACCESS_KEY ?= $(shell aws configure get \
	    "$(AWS_DEFAULT_PROFILE).aws_secret_access_key")



define TERRAFORM_DOCKER_RUN_SH
  docker run --entrypoint '' -ti \
	  -v $(CURRENT_PATH):$(CONTAINER_PATH) \
	  -e ENVIRONMENT=$(ENVIRONMENT) \
	  -e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
	  -e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY)\
	  -e AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) \
	  --workdir=$(WORK_DIR)\
	  hashicorp/terraform:$(TERRAFORM_VERSION)  sh
endef
export TERRAFORM_DOCKER_RUN_SH

define TERRAFORM_DOCKER_RUN_BASE_CMD
  docker run --rm  -ti \
	  -v $(CURRENT_PATH):$(CONTAINER_PATH) \
		-e ENVIRONMENT=$(ENVIRONMENT) \
		-e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
		-e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY)\
		-e AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) \
		--workdir=$(WORK_DIR)\
		hashicorp/terraform:$(TERRAFORM_VERSION)
endef
export TERRAFORM_DOCKER_RUN_BASE_CMD



run-test:
	$(TERRAFORM_DOCKER_RUN_SH)

custom-cmd:
	$(TERRAFORM_DOCKER_RUN_BASE_CMD) $(CMD)

init:
	$(TERRAFORM_DOCKER_RUN_BASE_CMD) init

plan: init
	$(TERRAFORM_DOCKER_RUN_BASE_CMD) plan

apply: init plan
	$(TERRAFORM_DOCKER_RUN_BASE_CMD) apply

destroy:
	$(TERRAFORM_DOCKER_RUN_BASE_CMD) destroy

#build-sns-slack:
#	docker run --entrypoint '' --rm -v $(CURRENT_PATH)/$(SNS_SLACK_MODULE_PATH):/var/task lambci/lambda:build-python2.7 ./build-function.sh

#build-clamav:
#	cd modules/clamav/src && make all