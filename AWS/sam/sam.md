# SAM（Serverless Application Model）

Lambda や API Gateway などを組み合わせてサービスを作成するのを効率化するツール。

## SAM の仕組み

1. S3 に lambda 関数のランタイムとアプリケーションをまとめた zip ファイルをアップロードする
2. CloudFormation のテンプレートを SAM 用に拡張した template.yaml ファイルを CloudFormation のスタックとして作成する
3. CloudFormation が各リソースをプロビジョニングする

## SAM のファイル

- template.yaml: CloudFormation のテンプレートファイルを SAM 用に拡張したファイル
- samconfig.toml: sam コマンドオプションのデフォルト値を設定するファイル 例）stack_name = "<スタック名>"など
- lambda 関数を記述した各言語ファイル: lambda 関数を記述したファイル

## AWS SAM CLI

### sam init

新しいサーバーレスアプリケーションのひな型ファイルを作成する。

```bash
sam init
```

### sam build

1. .aws-sam ディレクトリを作成する
2. Go が依存しているライブラリーを.aws-sam/build ディレクトリにインストールする
3. lambda コードのコンパイル・実行可能バイナリの作成・コンテナイメージの作成（ランタイムとしてコンテナを先手くした場合のみ）が実行される。zip パッケージタイプを選択した場合、まだ圧縮されておらず sam deploy 実行時に圧縮される。
4. template.yaml ファイルを.aws-sam ディレクトリにコピーする

```bash
sam build --parallel
```

### sam package

コードと依存関係の.zip ファイルを作成し、そのファイルを Amazon S3 にアップロードする。テンプレートファイルの各 Lambda 関数の CodeUri を S3 の URL に置き換えた新しいテンプレートファイルを作成する

```bash
sam package --template-file template.yaml --s3-bucket <S3バケット名> --output-template-file packaged.yaml
```

### sam deploy

リソースを AWS にプロビジョニングする。deploy コマンド時に template.yaml で定義したパラメーターの値を渡す。

1. ~/.aws/config と~/.aws/credentials から使用する IAM ユーザーを決定する
2. samconfig.toml ファイルの設定ファイルから読みとった CloudFormation のスタック名やリージョンのデフォルト値を設定する（スタック名やリージョン名は CloudFormation のパラメーターと同じもの）
3. アプリケーションを AWS にデプロイする
4. .aws-sam/build 内のパッケージを圧縮して zip ファイルを作成し S3 バケットにアップロードする。S3 バケットが存在しない場合は、新しいバケットを作成する。
5. AWS CloudFormation 変更セットを作成し、アプリケーションをスタックとして AWS CloudFormation にデプロイする
6. CloudFormation がリソースを作成する

```bash
sam deploy --template-file packaged.yaml --stack-name <スタック名> --s3-bucket <S3バケット名> --capabilities CAPABILITY_NAMED_IAM --confirm-changeset
```

### sam local genrate-event

S3 にオブジェクトがアップロードされると lambda 関数を実行するアプリケーションを作成する場合はテストするために Event が必要になる。S3 の Put のサンプルイベントを作成することができる。

```bash
sam local generate-event s3 put > events/s3-put.json
# サンプルイベントを作成可能なAWSサービス一覧を表示する
sam local generate-event -h
# アクション一覧を返却する(put,getなど)
sam local generate-event s3 -h
# イベントに設定可能なパラメータ一覧を表示する
sam local generate-event s3 put -h
```

### sam local invoke

ローカル環境で lambda 関数を呼び出す。Docker コンテナ上で動作する。

```bash
sam local invoke HelloWorldFunction
sam local invoke --event events/s3.json S3JsonLoggerFunction
sam local invoke --env-var Locals.json
```

### sam local start-api

HTTP サーバーをローカルで実行する。Docker 上で動作する。

```bash
sam local start-api
```

### sam remote invoke

AWS 上の lambda,kinesis data streams,SQS,Step Functions を呼び出す。

lambda 関数を呼び出す

```bash
sam remote invoke HelloWorldFunction --stack-name sam-app
sam remote invoke HelloWorldFunction --stack-name sam-app --event-file demo-event.json
# EventBridgeスキーマレジストリにアップロードしたイベントを利用する
sam remote invoke HelloWorldFunction --stack-name sam-app --test-event-name demo-event
```

SQS にメッセージを送信する

```bash
sam remote invoke MySqsQueue --stack-name sqs-example -event hello
```

Step Functions を呼び出す

```bash
sam remote invoke HelloWorldStateMachine --stack-name state-machine-example --event '{"is_developer": true}'
```

### sam remote test-event

共有可能なテストイベントを EventBridge イベントレジストリにアップロードしたり取得したりする。

- list
- get
- put
- delete

```bash
# イベントをアップロードする
sam remote test-event put HelloWorldFunction --stack-name sam-app --name demo-event --file demo-event.json --force
# イベントを使用してlambda関数を実行する
sam remote invoke HelloWorldFunction --stack-name sam-app --test-event-name demo-event
```

### sam sync

ローカルの変更を自動的に AWS と同期する

```bash
sam sync
```

### sam validate

テンプレートファイルが文法的に正しいか検証する

```bash
sam validate
```

### sam delete

スタックを削除することでアプリケーションを AWS から削除する。
ただしテンプレートファイルと lambda 関数の zip ファイルを保存する S3 バケットを作成するよう定義したスタックが別に作成されているのでそちらを手動で削除する必要がある。

```bash
sam delete
```

## デプロイの流れ

1. テンプレートファイルと Lambda 関数の zip ファイルを保管する S3 バケットを作成する
2. `sam package --template-file template.yaml --s3-bucket serverless-app-sam-kurita --output-template-file packaged.yaml`コマンドで Lambda 関数の zip ファイルを S3 にアップロードし、テンプレートファイルの CodeUri 値を S3 バケット+キー名に置き換えた packaged.yaml を出力する
3. `sam deploy --template-file packaged.yaml --stack-name serverless-app-sam-kurita --s3-bucket serverless-app-sam-kurita --capabilities CAPABILITY_NAMED_IAM --confirm-changeset`コマンドで S3 にテンプレートファイルをアップロードし、スタックを作成・更新する

## テンプレートファイル

```YAML
AWSTemplateFormatVersion: "2010-09-09"
Transform: AWS::Serverless-2016-10-31
Globals:
  # SAM固有のセクション
  # Globalsで定義されるプロパティーはAWS::Serverless::Function、AWS::Serverless::StateMachine、AWS::Serverless::Api、、AWS::Serverless::HttpApi、AWS::Serverless::SimpleTable リソースで継承される
Descriptions:
  # テンプレートファイルの説明
Metadata:
  # TODO 不明
Parameters:
  # スタック作成時、SAMの場合はsam deploy時に渡すことができるパラメータ
Mappings:
  # TODO: 不明
  # キーと関連する値のマッピング
Conditions:
  # TODO: 不明
Resources:
  # 作成したいAWSリソース
Outputs:
  # 出力したい値
```

### Globals

SAM テンプレートで宣言するリソースにきょうつうの設定がある場合は Globals セクションで 1 度だけ宣言し、リソースに継承させることができる。同一の Runtime、Memory、VPCConfig、Environment、Cors 設定などを継承させられる。Globals セクジョンは以下の AWS SAM リソースをサポートする。

- AWS::Serverless::Api
- AWS::Serverless::Function
- AWS::Serverless::HttpApi
- AWS::Serverless::SimpleTable
- AWS::Serverless::StateMachine

```YAML
Globals:
  Function:
    Runtime: nodejs12.x
    Timeout: 180
    Handler: index.handler
    Environment:
      Variables:
        TABLE_NAME: data-table

Resources:
  HelloWorldFunction:
    Type: AWS::Serverless::Function
    Properties:
      Environment:
        Variables:
          MESSAGE: "Hello From SAM"

  ThumbnailFunction:
    Type: AWS::Serverless::Function
    Properties:
      Events:
        Thumbnail:
          Type: Api
          Properties:
            Path: /thumbnail
            Method: POST
```

## IAM Role の管理

- AWS SAM コネクタ
- AWS SAM ポリシーテンプレート

### AWS SAM コネクタ

- コネクタは、AWS::Serverless::Connector として識別される SAM リソース
- AWS::Serverless:Function などに Connectors 属性を定義する
- Connectors 属性が AWS::Serverless::Connector に返還される

Lambda 関数に DynamoDB への書き込み権限を付与する

```YAML
AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::Serverless-2016-10-31

Resources:
  MyTable:
    Type: 'AWS::Serverless::SimpleTable'
  MyFunction:
    Type: 'AWS::Serverless::Functions'
    Connectors:
      MyConn:
        Properties:
          Destination:
            Id: MyTable
          Permissions:
            - Write
```

[送信元リソースと送信先リソースの組み合わせ](https://docs.aws.amazon.com/ja_jp/serverless-application-model/latest/developerguide/reference-sam-connector.html#supported-connector-resource-types)

## AWS SAM ポリシーテンプレート

Lambda 関数と AWS Step Functions ステートマシンへのアクセス許可をポリシーテンプレートのリストから選択することができる。

Lambda 関数に SQS をポーリングするポリシーをアタッチする

```YAML
Resources:
  MyFunction:
    Type: 'AWS::Serverless::Functions'
    CodeUri: ${codeuri}
    Handler: hello.handler
    Runtime: python2.7
    Policies:
      - SQSPollerPolicy:
          QueueName:
            !GetAttr MyQueue.QueueName
```

[ポリシーテンプレート一覧](https://docs.aws.amazon.com/ja_jp/serverless-application-model/latest/developerguide/serverless-policy-templates.html)

## EventBridge との連携

Lambda 関数と AWS Step Functions を EventBrdge からイベントを発行して呼び出す SAM の記述方法がある。
AWS::Serverless::Function と AWS::Serverless::StateMachine リソースの Events プロパティーに Schdule プロパティーを定義することで EventBridge と連携させる。

```YAML
Resources:
  MyLambdaFunction:
    Type: AWS::Serverless:Function
    Properties:
      Handler: index.handler
      Events:
        Schedule:
          Type: ScheduleV2
          Properties:
            ScheduleExpression: rate(1 minute)
            Input: '{"hello": "simple"}'
  StateMachine:
    Type: AWS::Serverless::StateMachine
    Properties:
      Type: STANDARD
      Definition:
        StartAt: MyLambdaState
        States:
          MyLambdaState:
            Type: Task
            Resource: !GetAtt MyLambdaFunction
            End: true
        # ポリシーテンプレートでLambda関数を呼び出すポリシーをアタッチ
        Policies:
          - LambdaInvokePolicy:
              FunctionName: !Ref MyLambdaFunction
        # 1分おきにこのStepFunctionを実行する
        Events:
          Schedule:
            Type: ScheduleV2
            Properties:
              ScheduleExpression: rate(1 minute)
              Input: '{"hello": "simple"}'
```

## Amazon Cognito との連携

API のクライアント（Vue.js）がユーザーを Amazon Cognite 内のユーザープールにサインインし、ユーザーのアクセストークンを取得する。その後返されたトークンを使用して API を呼び出す。API Gateway と Amazon Cognite と連携させることでトークンの有効性を確認する機能を実現する。

```YAML
Resources:
  MyApi:
    Type: AWS::Serverless::Api
    Properties:
      StageName: Prod
      Cors: "'*'"
      Auth:
        DefaultAuthorizer: MyCogniteAuthorizer
        Authorizers:
          MyCogniteAuthorizer:
            UserPoolArn: !GetAtt MyCogniteUserPool.Arn

  MyFunction:
    Type: AWS::Serverless:Function
    Properties:
      CodeUri: ./src
      Handler: lambda.handler
      Runtime: nodejs12.x
      Events:
        Root:
          Type: API
          Properties:
            RestApiId: !Ref MyApi
            path: /
            Method: GET

  MyCogniteUserPool:
    Type: AWS::Cognite::UserPool
    Properties:
      UserPoolName: !Ref CogniteUserPoolName
      Policies:
        PasswordPolicy:
          MinimumLength: 8
      UsernameAttributes:
        - email
      Schema:
        - AttributeDateType: String
          Name: email
          Required: false

  MyCognitoUserPoolClient:
    Type: AWS::Cognite::UserPoolClient
    Properties:
      UserPoolId: !Ref MyCognitoUserPool
      ClientName: !Ref CognitoUserPoolClientName
      GenerateSecret: false
```

## カスタムランタイム

sam build コマンドで lambda 関数の実行に必要なオリジナルのカスタムランタイムを構築できる。
Runtime には proided を指定し、Metadata には makefil を指定し、lambda 関数のビルド方法を Makefile に build-\<lambda 関数の論理名>で記述する必要がある。

```YAML
Resources:
  MyFunc:
    Type: AWS::Serverless::Function
    Properties:
      Handler: bootstrap
      Runtime: provided
      # Makefileの場所をCodeUriで指定する
      CodeUri: .
    Metadata:
      # ビルド方法をmakefileで指定
      BuildMethod: makefile
```

```Makefile
build-MyFunc:
  go build main.go
```

## vscode でのデバッグ方法

- 左サイドバーのデバッグマークをクリックし、launch.json ファイルを作成しますをクリックする
- AWS SAM: Debug...を選択して launch.json を作成する
- launch.json に各関数ごと・lambda 関数として実行するパターンと API として実行するパターンの 2 通りの構成が作成される
- sam local generate-event でイベントを指定して実行する
