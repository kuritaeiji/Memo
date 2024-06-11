# Route53

- Route53 は DNS サービス
- ホストゾーンを作成することで指定したドメイン名(example.com など)の権威サーバーを作成できる
- ホストゾーンには指定したドメイン名やそのサブドメインの A レコードや MX レコードなどを登録できる

![Route53-ER図](../image/Route53-ER図.png)

## エイリアスレコード

- ALB などの DNS 名を持つ AWS サービスを指定することで、CNAME レコードではなく A レコードを直接作成できる
- エイリアスレコードでない場合は、「ドメイン名 → CNAME レコードのドメイン名 → A レコードの IP アドレス」になる
- エイリアスレコードの場合は、「ドメイン名 → A レコードの IP アドレス」になる

以下にエイリアスレコードの作成方法を示す

```main.tf
resource "aws_route53_zone" "ec_site" {
  name = "ec-site.shop"
}

resource "aws_route53_record" "ec_site" {
  zone_id = aws_route53_zone.ec_site.id
  name = aws_route53_zone.ec_site.name
  type = "A"

  alias {
    name = aws_lb.alb.dns_name
    # ALBが配置されているRoute53のホストゾーンID
    # ホストゾーンとはaws_route53_zoneリソースのidのこと
    zone_id = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}
```
