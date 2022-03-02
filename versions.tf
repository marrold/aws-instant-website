terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
      configuration_aliases = [ aws.us-east-1 ]
    }
    archive = {
      source = "hashicorp/archive"
    }
  }
  required_version = ">= 0.15"
}
