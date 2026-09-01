# DNS Service Account
resource "kubernetes_service_account_v1" "external_dns" {
    metadata {
        name = "external-dns"
        namespace = "kube-system"
    }
}

# DNS Pod Identity Association

resource "aws_eks_pod_identity_association" "eks_e_dns" {
  cluster_name = data.terraform_remote_state.eks.outputs.names_app_cluster_id 
  namespace = "kube-system"
  service_account = kubernetes_service_account_v1.external_dns.metadata[0].name
  role_arn = data.terraform_remote_state.eks.outputs.e_dns_role_arn

  depends_on = [ kubernetes_service_account_v1.external_dns ]
}

# External DNS deployment

resource "helm_release" "external_dns" {
    name       = "external-dns"
    repository = "https://kubernetes-sigs.github.io/external-dns/"
    chart      = "external-dns"
    namespace  = "kube-system"

    set = [
        {
        name  = "serviceAccount.create"
        value = "false"
        },

        {
            name  = "serviceAccount.name"
            value = kubernetes_service_account_v1.external_dns.metadata[0].name
        },

        {
            name  = "provider"
            value = "aws"
        },

        {
            name  = "txtOwnerId"
            value = "names-app"
        }
    ]

    depends_on = [aws_eks_pod_identity_association.eks_e_dns]
}