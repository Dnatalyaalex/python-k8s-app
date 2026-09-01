## EKS IAM Role

resource "aws_iam_role" "names_app_cluster_role" {
    name = "names-app"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = [
                    "sts:AssumeRole",
                    "sts:TagSession"
                ]
                Effect = "Allow"
                Principal = {
                    Service = "eks.amazonaws.com"
                }
            },
        ]
    })
}

resource "aws_iam_role_policy_attachment" "names_app_clusterPolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role = aws_iam_role.names_app_cluster_role.name
}

## Worker Node group IAM Role

resource "aws_iam_role" "eks_worker_nodes_role" {
    name = "names-app-node-group"

    assume_role_policy = jsonencode({
        Statement = [{
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
            Service = "ec2.amazonaws.com"
        }
        }]
        Version = "2012-10-17"
    })
}

resource "aws_iam_role_policy_attachment" "worker_nodes_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_worker_nodes_role.name
}

## Amazon ECR Role and Policy

resource "aws_iam_role_policy_attachment" "ecr_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_worker_nodes_role.name
}

## CNI_Policy and Role

resource "aws_iam_role" "cni_pod_identity_role" {
    name = "eks-cni-pod-identity" 
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Principal = { Service = "pods.eks.amazonaws.com" }
            Action = [
                "sts:AssumeRole",
                "sts:TagSession"]
        }]
    })
}


resource "aws_iam_role_policy_attachment" "cni_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.cni_pod_identity_role.name
}


# AWS ExternalDNS 

resource "aws_iam_policy" "eks_e_dns" {
    name = "eks_e_dns_policy"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                "Effect": "Allow",
                "Action": [
                    "route53:ChangeResourceRecordSets",
                    "route53:ListResourceRecordSets",
                    "route53:ListTagsForResources"
                ],
                "Resource": [
                    "arn:aws:route53:::hostedzone/*"
                ]
            },
            {
                "Effect": "Allow",
                "Action": [
                    "route53:ListHostedZones"
                ],
                "Resource": [
                    "*"
                ]
            }
        ]
    })
}

resource "aws_iam_role" "eks_e_dns" {
    name = "eks-dns-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Action = [
                "sts:AssumeRole",
                "sts:TagSession"
            ]
            Principal = {
                Service = "pods.eks.amazonaws.com"
            }
        }]
    })
}


resource "aws_iam_role_policy_attachment" "eks_e_dns" {
    policy_arn = aws_iam_policy.eks_e_dns.arn
    role       = aws_iam_role.eks_e_dns.name

}

# EBS CSI Driver Permissions

resource "aws_iam_role" "ebs_csi" {
    name = "ebs-csi-driver-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Action = [
                "sts:AssumeRole",
                "sts:TagSession"
            ]
            Principal = {
                Service = "pods.eks.amazonaws.com"
            }
        }]
    })
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
    role = aws_iam_role.ebs_csi.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}