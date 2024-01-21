# azooKey

azooKeyはiOS / iPadOS向けの日本語キーボードアプリです。Swiftで実装され、独自開発の変換エンジン、ライブ変換、カスタムキー、カスタムタブなどのユニークなカスタマイズ機能を提供します。

azooKeyは[App Store](https://apps.apple.com/jp/app/azookey-%E8%87%AA%E7%94%B1%E8%87%AA%E5%9C%A8%E3%81%AA%E3%82%AD%E3%83%BC%E3%83%9C%E3%83%BC%E3%83%89%E3%82%A2%E3%83%97%E3%83%AA/id1542709230)で公開しています。

azooKeyの変換エンジンについては[AzooKeyKanaKanjiConverter](https://github.com/ensan-hcl/AzooKeyKanaKanjiConverter)を参照ください。

## コミュニティ＆β版

azooKeyの開発に参加したい方、使い方に質問がある方、要望や不具合報告がある方は、ぜひ[azooKeyのDiscordサーバ](https://discord.gg/dY9gHuyZN5)にご参加ください。

開発中のベータ版は[TestFlight](https://testflight.apple.com/join/x6TKEeB2)で利用できます。フィードバックをDiscordやIssue等でお寄せください。

## 開発ガイド
* パフォーマンス改善、バグ修正、機能追加などのPull Requestを歓迎します。機能追加の場合は事前にIssueで議論した方がスムーズです。
* 開発は基本的に`develop`で行います。新規にPRを作成する場合、まずこのレポジトリをフォークし、`develop`からブランチを切ってください。

[Let's Contribute](docs/first_contribution.md)も合わせてお読みください。

### ビルド・利用方法

Apple Developer Account（無料）が必要です。開発環境は最新のXcodeを利用してください。

1. `setup.sh`を実行してください。[Google Drive](https://drive.google.com/drive/folders/1Kh7fgMFIzkpg7YwP3GhWTxFkXI-yzT9E?usp=sharing)から辞書ファイルがダウンロードされます。

   ```bash
   sh setup.sh
   ```

1. `azooKey.xcodeproj`を開き、Xcodeの指示に従って「Run (Command+R)」を実行してください。

1. アプリを開くとキーボードのインストール方法が説明されるので、従ってください。

### テスト方法
[Document](docs/tests.md)をご覧ください。

### 辞書の変更

azooKeyの辞書ファイルは任意に置き換えることができます。過去のバージョンの辞書を利用するには、[Google DriveからazooKeyの辞書をダウンロードします](https://drive.google.com/drive/folders/1Kh7fgMFIzkpg7YwP3GhWTxFkXI-yzT9E?usp=sharing)。任意のバージョンのフォルダの中にある「`Dictionary`」というフォルダを右クリックし、フォルダごとダウンロードします。ついで、`Keyboard/`配下に`Dictionary`フォルダを配置してください。上書きして構いません。

### さらに詳しく

`docs/`内の[Document](./docs/overview.md)をご覧ください。

不明な点は気軽にIssue等でご質問ください。

## 今後のリリース
* 現在、Version 2.3に向けた作業を行っています。

## azooKeyを支援する
GitHub Sponsorsをご利用ください。

## ライセンス
Copyright (c) 2020-2023 Keita Miwa (ensan).

azooKeyはMIT Licenseでライセンスされています。詳しくは[LICENSE](./LICENSE)をご覧ください。

