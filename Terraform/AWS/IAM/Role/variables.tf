variable "name" {
  type = string
  description = "ロール名"
}

variable "identifiers" {
  type = list(string)
  description = "AssumRole対象のサービス名配列 例)ec2.amazonaws.com"
}

variable "policy_name" {
  type = string
  description = "IAMポリシー名"
}

variable "policy_document_json" {
  type = string
  description = "ロールに付与したいIAMポリシーのJSON"
}