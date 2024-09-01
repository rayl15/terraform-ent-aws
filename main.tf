variable "vcs_repo" {
  type = object({ identifier = string, branch = string })
}

provider "aws" {
  region  = "us-west-2"
  profile = "default"
}

module "s3backend" {
  source         = "git@github.com:rayl15/aws-tf-backend.git"
  principal_arns = [module.codepipeline.deployment_role_arn]
}

module "codepipeline" {
  source   = "./modules/codepipeline"
  name     = "terraform-enterprise"
  vcs_repo = var.vcs_repo
  auto_apply = false
  environment = {
    CONFIRM_DESTROY = 0
  }

  deployment_policy = file("./policies/policy.json") #C
  s3_backend_config = module.s3backend.config
}

terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = "~> 5.0"
  }
}
