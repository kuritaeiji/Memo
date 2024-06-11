# IAM

IAM には以下の 3 種類のアイデンティティーが存在する。

- IAM ユーザー: 名前を持つ
- IAM グループ: 名前を持つ
- IAM ロール: 名前・AssumeRolePolicy（誰が Role を引き受けることができるかを定義した IAM ポリシー）を持つ

上記 3 種類に対して IAM ポリシーをアタッチして権限を付与する。

![IAM3種](../image/IAM3種.png)

## IAM User

IAM User にポリシーをアタッチする際には aws_iam_user_policy と aws_iam_user_policy_attachment が使用できる

- aws_iam_user_policy: ポリシードキュメント（data aws_iam_policy_document）をアタッチするために使用される
- aws_iam_user_policy_attachment: ポリシー（resource aws_iam_policy）をアタッチするために使用される

![IAM User-ER図](../image/IAM%20User-ER図.png)

## IAM Group

IAM Group も IAM User とほぼ同じ

IAM Group にポリシーをアタッチする際には aws_iam_group_policy と aws_iam_group_policy_attachment が使用できる

- aws_iam_group_policy: ポリシードキュメントをアタッチするために使用される
- aws_iam_group_policy_attachment: ポリシーをアタッチするために使用される

![IAM Group-ER図](../image/IAM%20Group-ER図.png)

## IAM Role

EC2 の Role 引き受けの流れ

1. EC2 が AWS STS に対して IAM Role を指定してアクセスキーとシークレットアクセスキーを要求する
2. STS は指定された IAM Role の AssumeRolePolicy 見て EC2 に Role を付与できるか確認する
3. EC2 に Role を付与できることを確認したらアクセスキーとシークレットアクセスキーを返す

![STS仕組み](../image/STS仕組み.png)

IAM Role を引き受けることができるもの

- AWS のサービス(EC2・ECS など)
- OIDC プロバイダー（GitHubActions など）
- AWS アカウント

IAM Role にポリシーをアタッチする際には aws_iam_role_policy と aws_iam_role_policy_attachment が使用できる

- aws_iam_role_policy: ポリシードキュメントをアタッチするために使用される
- aws_iam_role_policy_attachment: ポリシーをアタッチするために使用される

![IRM Role-ER図](../image/IAM%20Role-ER図.png)

## IAM Policy

- data "aws_iam_policy_document": IAM ポリシーのドキュメントを作成する。ただし AWS 上にポリシーを作成するのではなくあくまでJSON文字列を作成しているだけ。
- resource "aws_iam_policy": IAM ポリシーを作成する。AWS 上に IAM ポリシーリソースを作成する。IAMポリシードキュメントを指定する必要がある。

また、IAM ポリシードキュメントは`source_policy_documents`にポリシードキュメントを指定すると指定したポリシードキュメントを継承できる。

![IAM Policy-ER図](../image/IAM%20Policy-ER図.png)
