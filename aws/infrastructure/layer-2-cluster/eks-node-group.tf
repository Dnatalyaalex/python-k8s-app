## Node group

resource "aws_eks_node_group" "eks_names_app" {
    cluster_name = aws_eks_cluster.names_app.name 
    node_role_arn = aws_iam_role.eks_worker_nodes_role.arn
    node_group_name = "eks-names-app"

    subnet_ids = [
       data.terraform_remote_state.network.outputs.subnet1_id,
       data.terraform_remote_state.network.outputs.subnet2_id, 
    ]
    scaling_config {
        desired_size = 1
        max_size = 2
        min_size = 1
    }

    update_config {
        max_unavailable = 1
    }

    depends_on = [
        aws_iam_role_policy_attachment.worker_nodes_policy_attachment,
        aws_iam_role_policy_attachment.cni_policy_attachment,
        aws_iam_role_policy_attachment.ecr_policy_attachment,
        aws_eks_addon.pod_identity_agent,
        aws_eks_pod_identity_association.cni,
        aws_eks_addon.vpc_cni
    ]
}