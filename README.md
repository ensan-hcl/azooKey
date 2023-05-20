# azooKey

azooKeyはiOS / iPadOS向けの日本語キーボードアプリです。Swiftで実装され、独自開発の変換エンジン、ライブ変換、カスタムキー、カスタムタブなどのユニークなカスタマイズ機能を提供します。

azooKeyは[App Store](https://apps.apple.com/jp/app/azookey-%E8%87%AA%E7%94%B1%E8%87%AA%E5%9C%A8%E3%81%AA%E3%82%AD%E3%83%BC%E3%83%9C%E3%83%BC%E3%83%89%E3%82%A2%E3%83%97%E3%83%AA/id1542709230)で公開しています。

## 開発ガイド
* パフォーマンス改善、バグ修正、機能追加などのPull Requestを歓迎します。機能追加の場合は事前にIssueで議論した方がスムーズです。
* 開発は基本的に`develop`で行います。新規にPRを作成する場合、まずこのレポジトリをフォークし、`develop`からブランチを切ってください。

[Let's Contribute](docs/first_contribution.md)も合わせてお読みください。

### ビルド・利用方法

Apple Developer Account（無料）が必要です。開発環境は最新のXcodeを利用してください。

1. [Google DriveからazooKeyの辞書をダウンロードします](https://drive.google.com/drive/folders/1Kh7fgMFIzkpg7YwP3GhWTxFkXI-yzT9E?usp=sharing)。最新バージョンのフォルダの中にある「`Dictionary`」というフォルダを右クリックし、フォルダごとダウンロードします。ついで、`Keyboard/Converter/`配下に`Dictionary`フォルダを配置してください。上書きして構いません。

1. `azooKey.xcodeproj`を開き、Xcodeの指示に従って「Run (Command+R)」を実行してください。

1. アプリを開くとキーボードのインストール方法が説明されるので、従ってください。

### テスト方法
[Document](docs/tests.md)をご覧ください。

### さらに詳しく

`docs/`内の[Document](./docs/overview.md)をご覧ください。

不明な点は気軽にIssue等でご質問ください。

## 今後のリリース
* 現在、Version 2.2に向けた作業を行っています。

## azooKeyを支援する
GitHub Sponsorsをご利用ください。

## ライセンス
Copyright (c) 2020-2023 Keita Miwa (ensan).

azooKeyはMIT Licenseでライセンスされています。詳しくは[LICENSE](./LICENSE)をご覧ください。

