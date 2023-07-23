# AzooKeyCore

azooKeyの開発に必要なモジュールをまとめたライブラリです。

## SwiftUtils
Swift一般に利用できるユーティリティのモジュールです。

## SwiftUIUtils
SwiftUIで利用できるユーティリティのモジュールです。

## KanaKanjiConverterModule
かな漢字変換を受け持つモジュールです。

```swift
import KanaKanjiConverterModule

// 変換器を初期化する
let converter = KanaKanjiConverter()
// 入力を初期化する
var c = ComposingText()
// 変換したい文章を追加する
c.insertAtCursorPosition("あずーきーはしんじだいのきーぼーどあぷりです", inputStyle: .direct)
// 変換のためのオプションを指定して、変換を要求
let results = converter.requestCandidates(c, options: ConvertRequestOptions(...))
// 結果の一番目を表示
print(results.mainResults.first!.text)  // azooKeyは新時代のキーボードアプリです
```

`ConvertRequestOptions`は、変換リクエストに必要な情報を指定します。詳しくはコードに書かれたドキュメントコメントを参照してください。

利用時は、辞書データのディレクトリを別個に指定する必要があります。

辞書データは、以下の構造である必要があります。詳しくはドキュメントを参照してください。

```
- Dictionary/
  - louds/
    - charId.chid
    - X.louds
    - X.loudschars2
    - X.loudstxt3
    - ...
  - p/
    - X.csv
  - cb/
    - 0.binary
    - 1.binary
    - ...
  - mm.binary
```


## KeyboardThemes

Keyboardの着せ替えデータ(`ThemeData`)に関するモジュールです。

## KeyboardViews

KeyboardのViewを実装したモジュールです最小で以下のように利用できます。

```swift
var body: some View {
    KeyboardView<AppSpecificExtension>()
        .themeEnvironment(theme)
        .environment(\.userActionManager, KeyboarActionManager())
        .environmentObject(variableStates)
}
```

### `UserActionManager`

`UserActionManager`はキーボード上でユーザが行った操作によって発火したアクションを管理するマネージャクラスです。このクラスを継承し、任意の操作を実装します。azooKeyでは`KeyboardActionManager`として実装されています。

### `VariableStates`

`VariableStates`は`KeyboardView`全体で共有される状態をまとめたObservable Objectです。

```swift
private static let variableStates = VariableStates(
    clipboardHistoryManagerConfig: ClipboardHistoryManagerConfig(),
    tabManagerConfig: TabManagerConfig(),
    userDefaults: UserDefaults.standard
)

```

初期化には`any ClipboardHistoryManagerConfiguration`と`any TabManagerConfiguration`の値が必要になります。azooKeyではそれぞれ`ClipboardHistoryManagerConfig`と`TabManagerConfig`として実装しています。

### `AppSpecificExtension`

`AppSpecificExtension`は、`KeyboardView`にアプリケーション固有の振る舞いを持たせるために注入する型で、`ApplicationSpecificKeyboardViewExtension`というプロトコルに準拠しています。azooKeyでは`AzooKeyKeyboardViewExtension`として実装しています。

この型を通じてKeyboardViewにユーザ設定を注入したり、お知らせのデータを注入したりすることができます。

