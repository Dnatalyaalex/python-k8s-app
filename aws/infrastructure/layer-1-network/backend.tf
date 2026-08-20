terraform {
    required_version = ">= 1.11.0"

    backend "s3" {
        bucket = "my-tf-state-nad"
        key = "names-app-eks/network.tfstate"
        region = "eu-central-1"
        encrypt = true 
        use_lockfile = true 
    }
}