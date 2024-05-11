# namespace

Namespace を使用することで仮想的にクラスターを分割できる。
初期状態では以下の 4 種類の Namespace が存在する。

- kube-system
  - Kubernetes クラスターのコンポーネントやアドオンがデプロイされる Namespace
- kube-public
  - 全ユーザーが利用可能な ConfigMap などを配置する Namespace
- kube-node-lease
  - ノードのハートビート情報が保存されている Namespace
- default
  - デフォルトの Namespace

プロダクション環境/ステージング環境/開発環境は Namespace ではなくクラスタ自体を 3 種類作るべき。理由は以下の通り。

- Service の名前解決時に「Service.prd-ns.svc.cluster.local」など環境ごとに異なるドメイン名になる
- Namespace の命名規則が prd-ns/stg-ns のようになることで環境ごとに異なるマニフェストを作成する必要がある

```ns.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: sample-ns
```
