# SDK (Software Development Kit)

以下 AWS SDK for Go V2 について解説する  
[AWS SDK for Go 解説記事](https://aws.github.io/aws-sdk-go-v2/docs/configuring-sdk/)

## SDK の設定方法

1. 認証情報・リージョン・ロガー・再試行設定・HTTP クライアントなどを設定した aws.Config 構造体を作成する
2. S3・DynamoDB などの各 AWS サービスのクライアントを aws.Config を使用して作成する

```Go
import "context"
import "github.com/aws/aws-sdk-go-v2/config"
import "github.com/aws/aws-sdk-go-v2/service/s3"

// 認証情報などを設定したaws.Configを作成する
cfg, err := config.LoadDefaultConfig(context.Background())
panic(err)
// s3サービスクライアントを作成する
s3Client := s3.NewFromConfig(cfg)
// dynamodbサービスクライアントを作成する
dynamodbClient := dynamodb.NewFromConfig(cfg)
```

## 認証情報

`config.LoadDefaultConfig`を使用して`aws.Config`を作成すると SDK はデフォルトの認証情報チェーンを使用して AWS 認証情報を検索する。いかにデフォルトの認証情報チェーンを示す。

1. 環境変数: `AWS_ACCESS_KEY_ID`、`AWS_SECRET_ACCESS_KEY`
2. 共有構成ファイル: `~/.aws/credintials` ファイル、`~/.aws/config`ファイルのデフォルトプロファイル
3. Lambda 関数や ECS タスクの IAM ロール

```Go
import "context"
import "github.com/aws/aws-sdk-go-v2/config"

// 認証情報などを設定したaws.Configを作成する
cfg, err := config.LoadDefaultConfig(context.Background())
panic(err)
```

## HTTP クライアント

カスタム HTTP クライアントを作成して SDK に使用させることができる。

```Go
import "github.com/aws/aws-sdk-go-v2/aws/transport/http"
import "context"
import "github.com/aws/aws-sdk-go-v2/config"

// カスタムHTTPクライアントを作成する
httpClient := http.NewBuildableClient().WithTimeout(time.Second * 5)
// LoadDefaultConfigにカスタムHTTPクライアントを提供する
cfg, err := config.LoadDefaultConfig(context.background(), config.WithHTTPClient(httpClient))
```

## ロガー

ロガーもカスタム可能

```Go
// HTTPリクエストのログ、リトライした場合のログを出力する
cfg, err := config.LoadDefaultConfig(context.TODO(), config.WithClientLogMode(aws.LogRetries | aws.LogRequest))
```

## リトライ

リトライもカスタム可能

```Go
config.WithRetryer(func() aws.Retryer {
  // 最大試行回数を1回にする
	return retry.AddWithMaxAttempts(retry.NewStandard(), 1)
})
cfg, err := config.LoadDefaultConfig(ctx)
```

## context を利用ししたタイムアウト

`context.WithTimeout`などを使用してサービスクライアント操作レベルでタイムアウトさせることができる。  
いかに s3 のタイムアウト方法を示す。

```Go
cfg, err := config.LoadDefaultConfig(context.Background())
client := s3.NewFromConfig(cfg)

ctx := context.Background()
// タイムアウトを5秒に設定する
ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
defer cancel

// 5秒以内にレスポンスしないとキャンセルされる。
resp, err := client.GetObject(ctx, &s3.GetObjectInput{})
```

## サービスクライアント

aws.Config を使用してサービスクライアントを作成する。クライアント作成時にオプションを渡すことで aws.Config の設定情報を上書きできる。

```Go
cfg, err := config.LoadDefaultConfig(context.TODO())
if err != nil {
	panic(err)
}
client := s3.NewFromConfig(cfg, func(o *s3.Options) {
  // 大阪リージョンと接続するs3クライアントを作成する
	o.Region = "ap-northeast-2"
	o.UseAccelerate = true
})
```
