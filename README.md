# これは何？

- Terraformを使ってCloudTrailを設定します。

# 概要
- ログを保存するためのS3バケット`awslogs-cloudtrail-アカウント番号`が作成されます。
- 全リージョンのログは該当のバケット内に保存されます。
- S3バケット内のログの保持期間は`2557日`です。
 - 保持期間を変更する場合は、Variable:`trail-expired-day`にて上書きしてください。
- トレイルを表示するためのCloudWachLogグループ が作成されます。
 - ログの保持期間は`30日`です。
 - 保持期間を変更する場合は、Variables:`cwlogs-retention-days`にて上書きしてください。


# 使い方
```
$ terraform plan/apply
```

# 備考
- セキュリティログって大事よね。