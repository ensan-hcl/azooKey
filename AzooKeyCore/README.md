# AzooKeyCore

azooKeyの開発に必要なモジュールをまとめたライブラリです。

## SwiftUIUtils
SwiftUIで利用できるユーティリティのモジュールです。

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

