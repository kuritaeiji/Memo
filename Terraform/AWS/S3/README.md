# AWS S3

## バケット

バケット名を指定してバケットを作成する。バケットは世界中で一意の名前にする必要がある。

```main.tf
resource "aws_s3_bucket" "private" {
  bucket = "private-kuritaeiji"
}
```

## ACL とバケットポリシー

ACL とバケットポリシーの 2 つでバケットへのアクセスを管理する。ACL でアカウント A に対して許可し、バケットポリシーでアカウント B,C に対して許可した場合、アカウント A,B,C に対してアクセスが許可される。  
デフォルトでは ACL は`private`が適用され、バケット所有者の AWS アカウント以外はアクセスできない。バケットポリシーは空として設定されている。

```main.tf
# ACL
resource "aws_s3_bucket_acl" "public" {
  bucket = aws_s3_bucket.public.id

  acl = "public-read"

  depends_on = [ aws_s3_bucket_ownership_controls.public, aws_s3_bucket_public_access_block.public ]
}

# バケットポリシー
resource "aws_s3_bucket_policy" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id
  policy = data.aws_iam_policy_document.alb_log.json
}

data "aws_iam_policy_document" "alb_log" {
  statement {
    effect = "Allow"
    actions = ["s3:PutObject"]
    # リソース="arn:aws:s3:::<バケット名>/AWSLogs/<AWSアカウントID>/*"
    resources = ["arn:aws:s3:::${aws_s3_bucket.alb_log.id}/AWSLogs/838135940574/*"]
    principals {
      type = "AWS"
      # identifiers=["arn:aws:iam::<LBのアカウント名>:root"]
      # 東京リージョンのLBのアカウントID=582318560864
      identifiers = ["arn:aws:iam::582318560864:root"]
    }
  }
}
```

## パブリックアクセスブロック

パブリックアクセス可能な ACL とバケットポリシーを適用することができなくすることができるリソース。s3 のデフォルトではパブリックアクセスブロックが適用されているためパブリックアクセス可能な ACL やバケットポリシーを適用できない。

```main.tf
# デフォルトのパブリックアクセスブロックリソース
resource "aws_s3_bucket_public_access_block" "private" {
  bucket = aws_s3_bucket.private.id

  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}
```

## オブジェクト所有者

`aws_s3_bucket_ownership_controls`でオブジェクト所有者を設定できる。

- BucketOwnerEnforced（デフォルト）: バケットの所有者がバケット内のすべてのオブジェクトの所有権を持つ。バケットの所有者はバケット内の全てのオブジェクトを管理し、アクセス制御することが可能。BucketOwnerEnforced を指定すると、ACL が無効になる。
- BucketOwnerPreferred: バケットの所有者が、バケット内の新しいオブジェクトの所有権を優先的に取得する。ただし、オブジェクトのアップロード時に、オブジェクトの所有権をアップロードしたアカウントに設定するオプションを選択することも可能。public-read ACL を適用する場合はこの設定を適用する必要がある。
- ObjectWriter: ケット内のオブジェクトに対して、そのオブジェクトをアップロードした AWS アカウントが所有権を持つ。これにより、アップロードしたアカウントがオブジェクトを管理できるようになる。

## バージョニング

バージョニングを適用するとファイルのバージョンを複数持つことができる。

```main.tf
resource "aws_s3_bucket_versioning" "private" {
  bucket = aws_s3_bucket.private.id

  versioning_configuration {
    status = "Enabled"
  }
}
```

## サーバーサイド暗号化

バケットのオブジェクトを暗号化できる。s3 が管理する aws/s3 という CMK を使用するか、KMS で自分で作成した CMK を使用するか選択可能。

```main.tf
resource "aws_s3_bucket_server_side_encryption_configuration" "private" {
  bucket = aws_s3_bucket.private.id

  rule {
    apply_server_side_encryption_by_default {
      # アルゴリズムにAES256を指定するとaws/s3 CMKを使用する
      sse_algorithm = "AES256"
      # アルゴリズムにaws:kmsを指定し、CMKを指定すると自分で作成したCMKを使用する
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.mykey.arn
    }
  }
}
```

## ライフサイクル

s3 内のオブジェクトを一定期間後に削除したり、より安価な S3 Glacier などに移行させることができる。

```main.tf
resource "aws_s3_bucket_lifecycle_configuration" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id

  rule {
    id = "delete-in-180"
    status = "Enabled"

    expiration {
      days = 180
    }
  }
}
```

## ACL 例

public-read

```json
{
  "Owner": {
    // 所有者の表示名
    "DisplayName": "owner-display-name",
    // 所有者のCanonical ID。これはAWSによって割り当てられた一意の識別子であり、S3の内部で使用される。
    "ID": "owner-id"
  },
  // アクセス権を付与するエンティティ（グランティ）と権限を定義する
  "Grants": [
    // 所有者はオブジェクトに対して完全な権限を持つ
    {
      // アクセス権を付与するエンティティー
      "Grantee": {
        "Type": "CanonicalUser",
        "ID": "owner-id",
        "DisplayName": "owner-display-name"
      },
      // 許可するアクション
      "Permission": "FULL_CONTROL"
    },
    // 全ユーザーは読み取り可能
    {
      "Grantee": {
        "Type": "Group",
        "URI": "http://acs.amazonaws.com/groups/global/AllUsers"
      },
      "Permission": "READ"
    }
  ]
}
```
