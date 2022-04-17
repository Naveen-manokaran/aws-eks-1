resource "aws_eks_cluster" "example1" {
  name     = "example"
  role_arn = aws_iam_role.example.arn

  vpc_config {
    subnet_ids = [aws_subnet.my-pub_subnet.id, aws_subnet.my-pri_subnet.id]
  }
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.example-AmazonEKSVPCResourceController,
    aws_iam_role_policy_attachment.example-AmazonEKSServicePolicy,
  ]
}

resource "aws_iam_role" "example" {
  name = "eks-cluster-example"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "eks.amazonaws.com",
          "ec2.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.example.name
}
resource "aws_iam_role_policy_attachment" "example-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.example.name
}
resource "aws_iam_role_policy_attachment" "example-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.example.name
}
resource "aws_iam_role_policy_attachment" "example-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.example.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.example.name
}
resource "aws_iam_role_policy_attachment" "example-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.example.name
}
resource "aws_eks_node_group" "example" {
  cluster_name    = aws_eks_cluster.example1.name
  node_group_name = "example"
  #disk_size       = 0
  node_role_arn = aws_iam_role.example.arn
  subnet_ids    = [aws_subnet.my-pub_subnet.id]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }
  /*
  release_version = ""
  lifecycle {
    create_before_destroy = true
  }

  timeouts {}
*/
  depends_on = [
    aws_eks_cluster.example1,
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKSServicePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.example-AmazonEKSVPCResourceController,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]
}
resource "aws_subnet" "my-pub_subnet" {
  vpc_id            = aws_vpc.my-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-2a"

  # tags = {
  #   "kubernetes.io/cluster/${aws_eks_cluster.example1.name}" = "owned"
  # }
}
resource "aws_subnet" "my-pri_subnet" {
  vpc_id            = aws_vpc.my-vpc.id
  cidr_block        = "10.0.2.0/25"
  availability_zone = "us-east-2b"
}

resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"

}
resource "aws_security_group" "ssh_from_office" {
  name        = "ssh_from_office"
  description = "Allow ssh from office"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_route_table" "example" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "example"
  }
}


resource "aws_route_table_association" "route_table_association_public" {
  subnet_id      = aws_subnet.my-pub_subnet.id
  route_table_id = aws_route_table.example.id
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name = "dev-IG"
  }
}
/*
resource "aws_eip" "lb" {
  depends_on    = [aws_internet_gateway.gw]
  vpc           = true
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.lb.id
  subnet_id    = aws_subnet.my-pub_subnet.id
  depends_on = [aws_internet_gateway.gw]
  tags = {
    Name = "gw NAT"
  }
}
*/