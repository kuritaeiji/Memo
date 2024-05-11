# kubectl コマンド一覧

## マニフェストファイルの適用（apply）

マニフェストファイルをもとにリソースを作成する。マニフェストファイル更新時にはリソースを更新する。

```bash
kubectl apply -f sample-pod.yaml
```

## リソースを作成する（create）

リソース作成には apply を使用する。create コマンドは--dry-run オプションを使用してマニフェストファイルのひな型を作成する際に使用する。

```bash
kubectl create deployment sample-deployment --dry-run --image=nginx:latest -o yaml > sample-deployment.yaml
```

## リソースの削除（delete）

マニフェストファイルに記載されたリソースを削除する。特定のリソースの削除も可能。

```bash
kubectl delete -f sample-pod.yaml
# 全てのpodを削除する
kubectl delete pod --all
# 特定のpodを削除する
kubectl delete pod sample-pod
# ラベルがapp:sample-podのpodを削除する
kubectl delete pod -l app=sample-pod
```

## Pod の再起動（rollout restart）

Deployment などのリソースに紐づいているすべての Pod を削除できる。Secret リソースで参照されている環境変数を更新した場合などに使用する。pod には使用できない。

```bash
kubectl rollout restart deployment sample-deployment
```

## 利用可能なリソースの一覧取得（api-resources）

リソースのバージョンを調べるときなどに使用する。

```bash
kubectl api-resources | grep deployment
```

## リソースの情報取得（get）

リソースの一覧や特定のリソースの情報だけを取得する。

```bash
# default NamespaceのPod一覧を取得する
kubectl get pod
# 特定のPodの情報だけを取得する
kubectl get pod sample-pod
```

|オプション|説明|
|-o <形式>|指定した形式で情報を表示する。yaml/json/wide などがある|
|--show-labels|ラベルも表示する|
|-l <key=value>|指定したラベルのリソースのみ取得する|
|-n <Namespace>|指定した Namespace のリソースを取得する|
|-A|全ての Namespace のリソースを取得する|
|--watch|変更があるたびに表示する|

## リソースの詳細情報の取得（describe）

リソースの詳細な情報を表示する。

```bash
kubectl describe pod sample-pod
```

## 実際のリソースの使用量の確認（top）

ノード・Pod・コンテナが使用しているリソースの使用量を取得する。top コマンドを使用するにはコントロールプレーンに metrics-server というアドオンのコンポーネントをデプロイする必要がある。

```bash
kubectl top node
kubectl top pod sample-pod
kubectl top pod --containers
```

## コンテナ上でのコンテナの実行（exec）

Pod 内のコンテナ上で特定のコマンドを実行したい場合は kubectl exec を使用する。-it を使用することで疑似端末を割り当て標準入力をパススルー出来る。

```bash
kubectl exec -it sample-pod -c nginx -- /bin/bash
```

## Pod 上にデバッグ用の一時的なコンテナを追加する（debug）

コンテナイメージとして軽量な「Distroless」や「Scratch」を使用している場合には Pod に一時的なコンテナを起動してそのコンテナを使用してデバッグを行える。

```bash
kubectl debug sample-pod --image=ubuntu:22.04 --container debug-container
kubectl exec -it sample-pod -c debug-container -- /bin/bash
```

## ポートフォワーディング（port-forward）

Pod・Service・Deployment 等にポートフォワーディングできる。

```bash
kubectl port-forward sample-pod 8080:8080
kubectl port-forward deployment/sample-deployment 8080:8080
kubectl port-forward service/sample-service 8080:8080
```

## コンテナのログ確認（logs）

コンテナの標準出力と標準エラー出力に出力されたログを取得する。通常コンテナのログは logdriver によって処理するため標準出力と標準鰓出力に出力する（logdriver は標準出力と標準エラー出力に出力されたログを処理するから）。

```bash
kubectl logs sample-pod
kubectl logs sample-pod -c nginx
```
