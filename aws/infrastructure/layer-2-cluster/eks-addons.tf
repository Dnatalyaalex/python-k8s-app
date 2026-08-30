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

# CSI-Driver Addon for Volumes

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name = aws_eks_cluster.names_app.name
  addon_name = "aws-ebs-csi-driver"
  
}

## CNI Pod Identity Association
resource "aws_eks_pod_identity_association" "cni" {
  cluster_name    = aws_eks_cluster.names_app.id
  namespace       = "kube-system"
  service_account = "aws-node"
  role_arn        = aws_iam_role.cni_pod_identity_role.arn

  depends_on = [aws_eks_addon.pod_identity_agent]
}


resource "aws_eks_pod_identity_association" "ebs_csi" {
  cluster_name    = aws_eks_cluster.names_app.id
  namespace       = "kube-system"
  service_account = "ebs-csi-controller-sa"
  role_arn        = aws_iam_role.ebs_csi.arn
}