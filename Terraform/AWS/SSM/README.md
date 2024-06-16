# SSM (Systems Manager)

パラメータストアやセッションマネージャーなどを提供している

## SSM パラメータストア

- インフラシークレットを管理する集中型サービス
  - 競合として AWS Secret Manager がある
- パラメータを暗号化することもできる
  - 自分で作成した CMK を指定して暗号化する
  - SSM パラメータストアが管理する CMK`alias/aws/ssm`で暗号化する（デフォルト）
- ECS タスク定義のコンテナ定義に環境変数として埋め込むことができる
  - ssm パラメーター名を記述する

```Terraform
resource "aws_ssm_parameter" "db_password" {
  name = "/db/password"
  value = "dammy"
  type = "SecureString"
  description = "データベースのパスワード"

  lifecycle {
    # 秘密情報をTerraformファイルに記述できないので、リソース作成後にマネジメントコンソールからvalueを修正する必要がある。
    # よってvalueがTerraform外で変更されても影響されないようignore_changesにvalueを指定する
    ignore_changes = [ value ]
  }
}

resource "aws_ecs_task_definition" "backend" {
  # familyにはタスク定義のプレフィックスを指定する
  # タスク定義名はファミリーにリビジョンを付与したもの 例) backend:1
  family = "backend"
  cpu = "256"
  memory = "512"
  # awsvpcはタスクごとに個別のENIが付与される
  # 配置されるサブネットのIPアドレスが付与される
  network_mode = "awsvpc"
  # タスクを起動可能な起動タイプ（FARGATEまたはEC2を選択できる）
  # 実際にタスクを起動するタイプの選択はServiceで実施する。ここではServiceで選択できる起動タイプを指定する
  requires_compatibilities = ["FARGATE"]
  # コンテナ定義
  container_definitions = jsonencode([
    {
      name = "backend"
      image = "nginx:latest"
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region = "ap-northeast-1"
          awslogs-stream-prefix = "nginx"
          awslogs-group = "/ecs/examples"
        }
      },
      # SSMパラメータの値を環境変数としてコンテナに渡す
      secrets = [
        {
          name = "DB_USERNAME"
          valueFrom = data.terraform_remote_state.ssm.outputs.db_username_ssm_name # "/db/username"
        },
        {
          name = "DB_PASSWORD"
          valueFrom = data.terraform_remote_state.ssm.outputs.db_password_ssm_name # "/db/password"
        }
      ]
      portMappings = [
        {
          protocol = "tcp"
          containerPort = 80
        }
      ],
      # DockerfileのCMDを上書き
      command = ["/usr/bin/env"]
    }
  ])

  # ECSコンテナエージェントのRole
  execution_role_arn = module.ecs_task_execution_role.iam_role_arn
}
```
