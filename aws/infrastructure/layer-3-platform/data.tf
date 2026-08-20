
data "terraform_remote_state" "eks" {
    backend = "s3" 
    config = {
        bucket = "my-tf-state-nad"
        key = "names-app-eks/eks.tfstate"
        region = "eu-central-1"
    }
}

data "terraform_remote_state" "network" {
    backend = "s3" 
    config = {
        bucket = "my-tf-state-nad"
        key = "names-app-eks/network.tfstate"
        region = "eu-central-1"
    }
}