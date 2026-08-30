output "openid_provider_arn" {
    value = aws_iam_openid_connect_provider.eks.arn
}

output "cluster_endpoint" {
    value = aws_eks_cluster.names_app.endpoint
}

output "certificate_authority_data" {
    value = aws_eks_cluster.names_app.certificate_authority[0].data
}  

output "names_app_cluster_id" {
    value = aws_eks_cluster.names_app.id 
}

output "names_app_cluster_name" {
    value = aws_eks_cluster.names_app.name 
}

output "e_dns_role_arn" {
    value = aws_iam_role.eks_e_dns.arn
}
