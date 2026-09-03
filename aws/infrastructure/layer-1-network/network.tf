## VAR

locals {
    cluster_name = "names-app"
}



# VPC
resource "aws_vpc" "eks_vpc" {
    cidr_block = "10.0.0.0/16"
    
    tags = {
        Name = "eks-vpc"
    }
}

resource "aws_route_table" "eks_vpc_route_table" {
    vpc_id = aws_vpc.eks_vpc.id 
    
}

resource "aws_route" "eks_public_acces_subnet" {
    route_table_id = aws_route_table.eks_vpc_route_table.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_gateway.id 

    depends_on = [ 
        aws_internet_gateway.eks_gateway,
        aws_internet_gateway_attachment.eks_gateway_attachment
     ]
}

resource "aws_route_table_association" "eks_public_acces_subnet1" {
    subnet_id = aws_subnet.eks_subnet1.id 
    route_table_id = aws_route_table.eks_vpc_route_table.id 
}

resource "aws_route_table_association" "eks_public_acces_subnet2" {
    subnet_id = aws_subnet.eks_subnet2.id 
    route_table_id = aws_route_table.eks_vpc_route_table.id 
}


# Subnets

## AZ
data "aws_availability_zones" "available" {}

output "availability_zones" {
  value = data.aws_availability_zones.available.names
}

resource "aws_subnet" "eks_subnet1" {
    vpc_id = aws_vpc.eks_vpc.id 
    map_public_ip_on_launch = true 
    cidr_block = "10.0.1.0/24"
    availability_zone = data.aws_availability_zones.available.names[0]

    tags = {
        Name = "eks-subnet1"
        "kubernetes.io/cluster/${local.cluster_name}" = "shared"
        "kubernetes.io/role/elb"                    = "1"

    }
}

resource "aws_subnet" "eks_subnet2" {
    vpc_id = aws_vpc.eks_vpc.id 
    cidr_block = "10.0.2.0/24"
    availability_zone = data.aws_availability_zones.available.names[1]
    map_public_ip_on_launch = true 

    tags = {
        Name = "eks-subnet2"
        "kubernetes.io/cluster/${local.cluster_name}" = "shared"
        "kubernetes.io/role/elb"                    = "1"
    }
}

#API Gateway

resource "aws_internet_gateway" "eks_gateway" {
    tags = {
        Name = "eks-names-app-gateway"
    }
}

resource "aws_internet_gateway_attachment" "eks_gateway_attachment" {
    internet_gateway_id = aws_internet_gateway.eks_gateway.id 
    vpc_id = aws_vpc.eks_vpc.id 
}

