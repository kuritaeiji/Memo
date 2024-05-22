# ServiceAccount

- ServiceAccount は Pod で実行されるプロセスのために割り当てるもの
- Namespace に紐づくリソース
- Pod 起動時には必ず ServiceAccount を割り当てる必要がある（指定しない場合は default ServiceAccount が割り当てられる）
- kube-api-server とは ServiceAccount ベースで認証・認可を行っている

## ServiceAccount と kubeconfig の User の違い

- ServiceAccount
  - Pod が使用するアカウント
- User(kubeconfig)
  - kubectl を使用するエンドユーザー（人間）や外部アプリケーションが使用するアカウント

## マニフェストファイル

```ServiceAccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: sample-serviceaccount
  namespace: default
imagePullSecrets:
  - name: ghcr-secret

---
apiVersion: v1
kind: Pod
metadata:
  name: sample-serviceaccount-pod
spec:
  serviceAccount: sample-serviceaccount
  containers:
    - name: nginx
      image: nginx:1.16
```

## ServiceAccount とトークン

- ServiceAccount はクライアント証明書とトークンの Secret を作成する
- kube-api-server と通信する場合はクライアント証明書とトークンを使用して通信する
- トークンとクライアント証明書は自動的に Pod のボリュームとしてコンテナにマウントされる

## Docker レジストリ認証情報の自動設定

imagePullSecrets を指定した ServiceAccount を割り当てた Pod が起動した場合、自動的に Pod の imagePullSecrets として利用される。
