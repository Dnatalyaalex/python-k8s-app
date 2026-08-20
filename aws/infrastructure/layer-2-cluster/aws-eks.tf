## Network output data

data "terraform_remote_state" "network" {
    backend = "s3" 
    config = {
        bucket = "my-tf-state-nad"
        key = "names-app-eks/network.tfstate"
        region = "eu-central-1"
    }
}


## EKS

resource "aws_eks_cluster" "names_app" {
    name = "names-app"
    
    access_config {
        authentication_mode = "API"
        bootstrap_cluster_creator_admin_permissions = false 
    }

    role_arn = aws_iam_role.names_app_cluster_role.arn
    version = "1.35"

    vpc_config {
        subnet_ids = [
            data.terraform_remote_state.network.outputs.subnet1_id,
            data.terraform_remote_state.network.outputs.subnet2_id,
        ]
    }

    depends_on = [
        aws_iam_role_policy_attachment.names_app_clusterPolicy,
    ]
}



