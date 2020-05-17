provider "aws" {
  version = "~> 2.0"
  region  = "ap-northeast-1"
}

module "ecs" {
  source = "terraform-aws-modules/ecs/aws"
  name = "kim-ecs-test"
}