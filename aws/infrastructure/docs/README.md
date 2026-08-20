# AWS Infrastructure (Terraform)

Terraform configuration to provision the AWS infrastructure needed to run the [Kubernetes Networking & Storage Demo](../README.md) on EKS instead of minikube. The goal isn't a production-grade, multi-environment setup — it's demonstrating how to provision a real EKS cluster, wire up IAM permissions for in-cluster workloads, and structure Terraform so that the AWS-provider and Kubernetes/Helm-provider parts of the stack don't collide.

## Architecture

The infrastructure is split into three independent layers, each with its own Terraform state. This avoids a "chicken-and-egg" problem: the Kubernetes and Helm providers need a running cluster to authenticate against, but that cluster doesn't exist yet on the first `apply` if everything lives in one configuration.

```
layer-1-network   →  VPC, public subnets, Internet Gateway, route tables
layer-2-cluster   →  EKS cluster, managed node group, IAM roles, OIDC provider, EKS access entries
layer-3-platform  →  AWS Load Balancer Controller (Helm release), its ServiceAccount + IAM role (IRSA)
```

Each layer reads the outputs of the previous one via `terraform_remote_state`, so `layer-2` never needs to know how the VPC was built, and `layer-3` never needs to know how the cluster was built — only its outputs (endpoint, name, OIDC provider ARN).

## What each layer provisions

**layer-1-network**
- VPC with public subnets across two AZs
- Internet Gateway + route table (public subnets only — no NAT Gateway, to keep the project free/cheap to run)

**layer-2-cluster**
- EKS cluster (managed control plane)
- Managed node group (EC2 worker nodes)
- IAM role for the node group (`AmazonEKSWorkerNodePolicy`, `AmazonEC2ContainerRegistryReadOnly`, `AmazonEKS_CNI_Policy`)
- IAM OIDC provider for the cluster, used for IRSA
- EKS access entries (cluster access is managed via the EKS Access Entry API, not the legacy `aws-auth` ConfigMap)

**layer-3-platform**
- AWS Load Balancer Controller, installed via the `helm_release` resource
- Dedicated `ServiceAccount` for the controller, bound to an IAM role via IRSA (OIDC-based), scoped only to `kube-system:aws-load-balancer-controller`
- CNI (`aws-node`) permissions are also being moved off the node role and onto their own identity, comparing IRSA against the newer **EKS Pod Identity** mechanism for the same purpose

## State backend

State is stored in S3, one object key per layer, with S3's native locking (`use_lockfile = true`) instead of a separate DynamoDB table — this replaced the DynamoDB-based locking approach after it was deprecated in newer Terraform versions.

## Design decisions

- **No NAT Gateway.** Worker nodes sit in public subnets instead. This is a deliberate cost trade-off for a personal project — the standard production pattern is private subnets + NAT, and that's a known next step, not an oversight.
- **No custom modules.** With a single cluster and a single environment, wrapping resources in modules would add abstraction without a second use case to justify it. Modules would make sense with multiple environments (dev/staging/prod).
- **Three separate states, not one.** Splitting by lifecycle (network and cluster change rarely, platform components change more often) and to eliminate the provider chicken-and-egg problem, rather than for team/access-boundary reasons (this is a single-person project).

## Running

```
cd layer-1-network && terraform init && terraform apply
cd ../layer-2-cluster && terraform init && terraform apply
cd ../layer-3-platform && terraform init && terraform apply
```

Tear down in reverse order:
```
cd layer-3-platform && terraform destroy
cd ../layer-2-cluster && terraform destroy
cd ../layer-1-network && terraform destroy
```

If any Kubernetes `Ingress` or `Service` of type `LoadBalancer` has been applied to the cluster, delete those first (`kubectl delete ingress/service ...`) before running `terraform destroy` — the AWS Load Balancer Controller creates a real ALB and ENIs outside of Terraform's knowledge, and those need to be cleaned up before the VPC/subnets can be destroyed.

## Next steps

- Push application images to ECR and update the app's manifests accordingly
- Add an `Ingress` resource with AWS Load Balancer Controller annotations to expose the app externally
- Deploy the existing Kubernetes manifests (from the [root README](../README.md)) to this cluster
- Add resource `requests`/`limits` to the manifests (not needed on minikube, required here)
- Set up a CI/CD pipeline (build → push to ECR → apply manifests)
- Move worker nodes to private subnets + NAT Gateway
- Finish moving CNI permissions off the node role and onto EKS Pod Identity
