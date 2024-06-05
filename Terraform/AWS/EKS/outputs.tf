output "cluster_endpoint" {
  value = aws_eks_cluster.cluster.endpoint
  description = "EKSクラスターのエンドポイント（kube-apiserverのドメイン名）"
}

output "cluster_certificate_authority" {
  value = aws_eks_cluster.cluster.certificate_authority
  description = "EKSクラスターに接続するためのクライアント証明書やトークンなどの情報"
}