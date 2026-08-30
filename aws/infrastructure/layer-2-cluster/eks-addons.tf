## CNI Addon

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.names_app.name 
  addon_name   = "vpc-cni"

  depends_on = [ aws_eks_cluster.names_app]
}

resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name = aws_eks_cluster.names_app.name
  addon_name   = "eks-pod-identity-agent"

  depends_on = [ aws_eks_cluster.names_app]
}

## CNI Pod Identity Association
resource "aws_eks_pod_identity_association" "cni" {
  cluster_name    = aws_eks_cluster.names_app.id
  namespace       = "kube-system"
  service_account = "aws-node"
  role_arn        = aws_iam_role.cni_pod_identity_role.arn

  depends_on = [aws_eks_addon.pod_identity_agent]
}


