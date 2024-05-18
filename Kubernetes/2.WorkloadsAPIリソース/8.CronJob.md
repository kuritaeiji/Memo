# CronJob

CronJob は Cron のようにスケジュールされた時間に Job を起動する。CronJob が Job を管理する。

## CronJob を任意のタイミングで実行する

```bash
kubectl create job sample-job-from-cronjob --from cronjob/sample-cronjob
```

## 同時実行に関するポリシー

古い Job がまだ実行している場合に新たな Job をどうするかを決めるポリシー。spec.concurrencyPolicy に指定する。

| ポリシー          | 説明                                         |
| :---------------- | :------------------------------------------- |
| Allow(デフォルト) | 複数の Job を同時実行可能                    |
| Forbid            | 同時実行しない                               |
| Replace           | 前の Job をキャンセルし、次の Job を実行する |

## 実行開始時期に関する制御

Kubernetes マスターノードが一時的にダウンしている場合など、Job の開始時刻が遅れた場合に許容できる秒数を指定できる。デフォルトではどんなに開始時刻が遅れても Job を作成するようになっている。spec.startingDeadlineSeconds に指定する。

## CronJob の履歴

保存しておく Job の数を指定できる。

| 設定項目                        | 説明                      |
| :------------------------------ | :------------------------ |
| spec.successfulJobsHistoryLimit | 成功した Job を保存する数 |
| spec.failedJobsHistoryLimit     | 失敗した Job を保存する数 |

## マニフェストファイル

- Cron 式
- Job テンプレート

```CronJob.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: sample-cronjob
spec:
  # Cron式
  schedule: "*/1 * * * *"
  # Jobの同時実行可能
  concurrencyPolicy: Allow
  # 開始時刻の遅延は30秒まで。30秒以上遅延した場合はJobを作成しない
  startingDeadlineSeconds: 30
  # 成功したJobの保存数は5個
  successfulJobsHistoryLimit: 5
  # 失敗したJobの保存数は3個
  failedJobsHistoryLimit: 3
  jobTemplate:
    spec:
      completions: 1
      parallelism: 1
      backoffLimit: 0
      template:
        spec:
          containers:
            - name: tools-container
              image: amsy810/random-exit:v2.0
          restartPolicy: Never
```
