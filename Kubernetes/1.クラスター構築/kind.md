# kind（kubernetes in docker）

Docker コンテナを複数起動しそのコンテナを Kubernetes Node として利用することで複数台構成の Kubernetes クラスタを構築する。マスターノードとしての役割を持つコンテナは etcd・スケジューラーなどがインストールされている。ワーカーノードとしての役割を持つコンテナはコンテナランタイムや kubelet がインストールされている。

![kind](image/kind.png)

以下が kind のインストール方法

```bash
# kindのインストール
go install sigs.k8s.io/kind@v0.22.0
echo 'source <(kind completion bash)' >> ~/.bashrc
sudo mv ~/go/bin/kind /usr/local/bin

# kubectl（kube-api-serverに命令するためのコマンドツール）のインストール
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo chown root:root kubelet
sudo chmod 755 kubelet
sudo mv kubelet /usr/local/bin
echo 'source <(kubelet completion bash)' >> ~/.bashrc
```

kind.yaml を作成し複数台構成の Kubernetes クラスターを作成する。

```kind.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
```

```bash
kind create cluster --name kind-cluster --config kind.yaml
```
