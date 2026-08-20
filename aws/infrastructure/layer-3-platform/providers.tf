terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 6.0"
        }


        kubernetes = {
            source  = "hashicorp/kubernetes"
            version = "~> 2.0"
        }

        helm = {
            source  = "hashicorp/helm"
            version = "~> 3.0"
        }
    }
}

provider "aws" {
    region = "eu-central-1"   
}

ephemeral "aws_eks_cluster_auth" "names_app" {
    name = data.terraform_remote_state.eks.outputs.names_app_cluster_id
}

provider "kubernetes" {
    host = data.terraform_remote_state.eks.outputs.cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.certificate_authority_data)
    token = ephemeral.aws_eks_cluster_auth.names_app.token 
}

provider "helm" {
    kubernetes = {
        host = data.terraform_remote_state.eks.outputs.cluster_endpoint
        cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.certificate_authority_data)
        token = ephemeral.aws_eks_cluster_auth.names_app.token
    }
}
