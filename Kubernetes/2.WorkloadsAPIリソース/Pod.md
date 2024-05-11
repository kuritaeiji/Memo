# Pod

Pod は複数のコンテナ・複数のボリューム・1 つの NIC を持つリソース。

![Pod](../../image/Pod.png)

Pod 内のコンテナは同一ネットワーク空間（Linux の Namespace 技術がコンテナ単位でなく Pod 単位で使用されている）に存在するため、同一アドレスを持つ。そのためコンテナは互いに localhost で通信可能。

## マニフェストファイル

spec にはコンテナ配列とボリューム配列を主に記載する。

```sample-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: sample-pod
spec:
  containers:
    - name: nginx-container
      image: nginx:1.16
      # DockerfileのENTRYPOINTを上書きする
      command: ["/bin/sleep"]
      # DockerfileのCMDを上書きする
      args: ["3600"]
      # DockerfileのWORKDIRを上書きする
      workingDir: /tmp
  # restartPolicyはAlways（Podが終了コードにかかわらず停止すると再起動）・OnFailure（Podが終了コード0以外で終了すると再起動）・Never（Podが停止しても再起動しない）から選択
  restartPolicy: Always
```
