# Kubernetes 環境種別

- ローカル Kubernetes
  - ユーザーの手元のマシン一台に構築して使用する
  - kind・Docker Desktop・Minikube
- Kubernetes 構築ツール
  - ツールを使用して任意の環境（オンプレミス・クラウド）に構築して使用する
  - kubeadm・Rancher
- マネージド Kubernetes サービス
  - パブリッククラウド上のマネージドサービスとして提供されるクラスタを使用する
  - GKE・EKS・AKS

ローカル Kubernetes は kind を使用し、マネージド Kubernetes は EKS を使用すればよい。
