data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

#data "http" "ifconfig" {
#  url = "https://ifconfig.co/json"
#  request_headers = {
#    Accept = "application/json"
#  }
#}
