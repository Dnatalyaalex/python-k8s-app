# Control Plane Settings

module "lb_role" {
    source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
    version = "~> 5.39"
    role_name = "eks-lb-controller"
    attach_load_balancer_controller_policy = true

    oidc_providers = {
        main = {
            provider_arn               = data.terraform_remote_state.eks.outputs.openid_provider_arn
            namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
        }
    }
}

resource "kubernetes_service_account_v1" "lb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
      "app.kubernetes.io/component" = "controller"
    }

   
    annotations = {
      "eks.amazonaws.com/role-arn" = module.lb_role.iam_role_arn
    }

  }

  depends_on = [
    aws_eks_access_entry.admin,
    aws_eks_access_policy_association.admin
  ]
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set = [
    {
      name  = "clusterName"
      value = data.terraform_remote_state.eks.outputs.names_app_cluster_id
    },
    {
      name  = "serviceAccount.create"
      value = "false"
    },
    {
      name  = "serviceAccount.name"
      value = kubernetes_service_account_v1.lb_controller.metadata[0].name
    },

    {
      name  = "vpcId"
      value = data.terraform_remote_state.network.outputs.vpc_id
    }
  ]

  depends_on = [kubernetes_service_account_v1.lb_controller]
}