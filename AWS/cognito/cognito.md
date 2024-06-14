# Cognito

## AWS::Cognito::UserPool

- ユーザーディレクトリの管理
- サインアップとログイン
- パスワードリセット
- メールアドレス・電話番号に認証コード送信

## AWS::Cognito::UserPoolClient

- ウェブアプリケーションがユーザープールにアクセスするためのエンドポイントを提供する
- ユーザーに対して認証トークン(ID トークン・アクセストークン・リフレッシュトークン)を発行する
- リフレッシュトークンなどのセキュリティー管理を行う

## ユーザー属性

必須属性

- username: イミュータブルな値

標準属性(OpenID Connect に準拠)

- address
- birthdate
- email
- family_name
- gender
- given_name
- locale
- middle_name
- name
- nickname
- phone_number
- picture
- preferred_username
- profile
- sub
- updated_a
- website
- zoneinfo

## ログイン

デフォルトでは username を指定してログインする。標準属性をエイリアスに指定することでエイリアスを使用してログインできる。
例）メールアドレスをエイリアスとして指定するとメールアドレスをログイン情報として使用可能

## ログイン時に返却するトークン

- idToken: OpenID Connect 仕様
- アクセストークン: OAuth2 仕様
- リフレッシュトークン: OAuth2 仕様

## 認証・認可の流れ

1. メールアドレス・パスワードでユーザープールにユーザー登録
2. 認証コードを受け取りユーザープールに送信
3. メールアドレス・パスワードでログイン（idToken・アクセストークン・リフレッシュトークンを受け取る）
4. idToken を使用して APIGateway と通信する
5. ローカルストレージから idToken・アクセストークン・リフレッシュトークンを削除してログアウトする
