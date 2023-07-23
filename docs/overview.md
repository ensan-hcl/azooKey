# Overview

azooKeyは以下のような構成になっています。

```
AzooKeyCore: azooKey全体で共有するモジュール
MainApp: 本体アプリの実装
Keyboard: キーボードアプリの実装
azooKeyTests: MainAppとKeyboardのテスト
DictionaryDebugger: 辞書のデバッグツール
Resources: MainAppとKeyboardで共有されるリソース
```

## MainApp

MainAppはazooKeyの種々の設定を行うためのアプリです。

SwiftUIを用いて実装しています。

## Keyboard

Keyboardはキーボード本体の実装です。

`Keyboard/Display/KeyboardViewController.swift`の`viewDidLoad`が実質的なエントリーポイントです。`viewDidLoad`が呼ばれると、`KeyboardActionManager`のインスタンスが1つ生成され、ユーザの操作を管理するようになります。また、KeyboardのUIの読み込みが行われます。KeyboardのUIはSwiftUIで実装されていますが、実装をMainAppと共有するためShared配下に存在します。

`KeyboardActionManager`は`InputManager`を用いて変換状態を管理します。`InputManager`は変換器である`KanaKanjiConverter`のAPIを呼び出したり、`LiveConversionManager`を通してライブ変換に関する処理を行ったり、`DisplayedTextManager`を通してディスプレイされるテキストの管理を行ったりします。

### かな漢字変換モジュール

かな漢字変換モジュールはazooKeyとは独立のパッケージ「AzooKeyKanaKanjiConverter」として切り出されています。以下を参照してください。

https://github.com/ensan-hcl/AzooKeyKanaKanjiConverter

### キーボードの拡張

カスタムタグ及び一部の機能はazooKeyと独立したパッケージ「CustardKit」として切り出されています。以下を参照してください。

https://github.com/ensan-hcl/CustardKit

## AzooKeyCore

`AzooKeyCore`は全体で共有すべき実装を記述したSwift Packageです。詳しくは[README](../AzooKeyCore/README.md)を参照してください。

## Resources

SharedはazooKey全体で共有されるリソースです。主に以下のものなどを含みます。

* 絵文字の生データ
* Localization.strings
* フォント
* 色データ

## azooKeyTests

主にKeyboardの実装のテストが含まれています。

## 用語

| 英語           | 日本語         | 備考                                                       |
| -------------- | -------------- | ---------------------------------------------------------- |
| Action         | ユーザの操作   |                                                            |
| Candidate      | 変換候補       |                                                            |
| Composing      | 編集中         | 変換対象のテキストになっている、との意味。                 |
| Custard        | カスタード     | **Cust**om Keybo**ard**の略。カスタムタブに関わる機能。    |
| Dicdata        | 辞書データ     |                                                            |
| Displayed      | 表示されている | 内部状態ではなく、ユーザに見えている状態である、との意味。 |
| InputStyle     | 入力方法       | ローマ字入力、ダイレクト入力など、入力方式を意味する。     |
| Learning       | 学習           | 専ら学習機能を意味する。                                   |
| LiveConversion | ライブ変換     |                                                            |
| LOUDS          | LOUDS          | データ構造の名。                                           |

