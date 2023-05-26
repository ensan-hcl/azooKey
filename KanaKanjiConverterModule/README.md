# KanaKanjiConverterModule

かな漢字変換を受け持つモジュールです。

## KanaKanjiConverterModule

変換関係のソースコードを含むモジュールです。

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

## KanaKanjiConverterResource

変換に必要な辞書ファイルへのurlを返すモジュールです。

以下のAPIのみを提供します。

```swift
enum KanaKanjiConverterResourceURL {
    /// provide URL for resource
    static var url: URL
}
```

利用時は、`KanaKanjiConverterResource/Dictionary/`配下に辞書データを配置してください。[Google DriveからazooKeyの辞書をダウンロードします](https://drive.google.com/drive/folders/1Kh7fgMFIzkpg7YwP3GhWTxFkXI-yzT9E?usp=sharing)。最新バージョンのフォルダの中にある「`Dictionary`」というフォルダを右クリックし、フォルダごとダウンロードします。ついで、`Source/KanaKanjiConverterResource/`配下に`Dictionary`フォルダを配置してください。上書きして構いません。

アプリケーションでの利用時、`KanaKanjiConverterResource`をターゲットに追加することで、辞書データもアプリケーションに同梱されます。

```swift
import KanaKanjiConverterModule
import KanaKanjiConverterResource

// ...
let results = converter.requestCandidates(c, options: ConvertRequestOptions(
   ...
   dictionaryResourceURL: KanaKanjiConverterResourceURL.url.appendingPathComponent("Dictionary", isDirectory: true),
   ...
))
```

かな漢字変換モジュールの持つ型などにアクセスしたいだけの場合はこのモジュールは不要です。
