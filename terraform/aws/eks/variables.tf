# ------------------------------ Security Group ---------------------------------------------
variable "public_inbound_acl_rules" {}
variable "public_outbound_acl_rules" {}
variable "private_inbound_acl_rules" {}
variable "private_outbound_acl_rules" {}
variable "new_http_https_sg_ingress_rules_with_cidr_blocks" {}
variable "new_http_https_sg_egress_rules_with_cidr_blocks" {}

# ------------------------------ EKS ---------------------------------------------
variable "eks_managed_node_groups" {}
variable "kubernetes_addons" {
  type        = any
  default     = []
  description = "Manages [`aws_eks_addon`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) resources."
}
variable "region" {
  type        = string
  description = "AWS Region"
}
variable "clusterName" {
  type        = string
  description = "name of EKS Cluster."
}
variable "env" {
  type        = string
  description = "environment"  
}