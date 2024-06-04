# AWS プロバイダー

プロビジョニングするリージョンや認証情報を設定する。

## AWS プロバイダーの属性値

- region: 指定したリージョンにプロビジョニングする

## 認証情報の渡し方

- 環境変数
- ~/.aws/config と~/.aws/credentials
- 任意の config ファイルと credentials ファイル
- aws-vault exec コマンド

環境変数として渡す

```bash
export AWS_ACCESS_KEY_ID="accesskey"
export AWS_SECRET_ACCESS_KEY="secretkey"
```

```main.tf
provider "aws" {
  region = "us-east-1"
  # 自動的に環境変数を読み込むので認証情報を記述する必要なし
}
```

~/.aws/config と~/.aws/credentials

```main.tf
provider "aws" {
  # defaultプロファイルを使用する
  profile = "default"
  # configファイルからリージョンが、credentialsファイルから認証情報が自動的に読み込まれる
}
```

任意の config ファイルと credentials ファイル

```main.tf
provider "aws" {
  shared_config_files      = ["/Users/tf_user/.aws/conf"]
  shared_credentials_files = ["/Users/tf_user/.aws/creds"]
  profile                  = "default"
}
```

aws-vault exec コマンド

```bash
# defaultプロファイルでterraform applyを実行する
aws-vault exec default -- terraform apply
```

## Assume Role

スイッチロール設定ができる

```main.tf
provider "aws" {
  assume_role {
    role_arn = "arn:aws:iam::<アカウントID>:role/OrganizationAccountAccessRole"
  }
}
```
