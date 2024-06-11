# ロードバランサー

- ロードバランサーは TCP/IP 層で動作する NLB とアプリケーション層で動作する ALB がある
- ロードバランサーは指定した AZ に負荷が高まると自動的にスケールアウトする

## ロードバランサーの構成

![LB構成](../image/LB構成.png)

- ロードバランサー本体: サブネットに配置する
- リスナー: 特定のポートとプロトコルでリッスンする
- リスナールール: リスナーに対するアクセスを受け取り、特定のパスやホスト名に一致したリクエストを指定したターゲットグループに送る
- ターゲットグループ: ローロバランサーからリクエストを受け取るサーバー群。サーバーに対するヘルスチェックも行う。

![LB-ER図](../image/LB-ER図.png)

## リダイレクト

HTTP にアクセスすると HTTPS にリダイレクトさせられる。リスナーのデフォルトアクションにリダイレクトを指定して実現する。

```main.tf
resource "aws_lb_listener" "redirect_http_to_https" {
  load_balancer_arn = aws_lb.alb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port = 443
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
```

## アクセスログ

アクセスログを S3 に保存できる。S3 のバケットポリシーを設定して ALB がログを出力できる権限を付与する必要がある。

```main.tf
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
