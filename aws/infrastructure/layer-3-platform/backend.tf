terraform {
    required_version = ">= 1.11.0"

    backend "s3" {
        bucket = "my-tf-state-nad"
        key = "names-app-eks/control-plane.tfstate"
        region = "eu-central-1"
        encrypt = true 
        use_lockfile = true 
    }
}