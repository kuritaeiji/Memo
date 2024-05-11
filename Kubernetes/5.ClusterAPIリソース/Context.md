# Context

kubectl が Kubernetes Master Node と通信する際にはクラスターの情報と認証情報が必要になる。kubectl は kubeconfig(~/.kube/config)に書かれている情報をもとに接続を行う。

- cluster
  - どのクラスターに接続をするか
- user
  - どのユーザーで kube-api-server と通信するか
- context
  - cluster と user とデフォルト Namespace の組み合わせ

| コマンド                      | 説明                                                 | 使用方法                                                                                                       |
| :---------------------------- | :--------------------------------------------------- | :------------------------------------------------------------------------------------------------------------- |
| kubectl config get-contexts   | 全ての context を取得する                            |                                                                                                                |
| kubectl config set-context    | context を作成する                                   | kubectl config set-context --cluster=kind-cluster --user=kind-user --namespace=default                         |
| kubectl config use-context    | kubectl が使用する Context を切り替える              | kubectl config use-context kind                                                                                |
| kubectl config set-cluster    | 既に存在するクラスタの定義を追加する                 | kubectl config set-cluster kind --server=<http://localhost:6643>                                               |
| kubectl config get-cluster    | クラスター一覧を取得する                             |                                                                                                                |
| kubectl config set-credential | 認証情報を追加する。クライアント証明書と秘密鍵が必要 | kubectl config set-credential admin --client-certificate=sample.crt --client-key=sample.key --embed-certs=true |
| kubectl config get-users      | 認証情報一覧を取得する                               |                                                                                                                |
