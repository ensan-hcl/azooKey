# Dicdata Format

azooKeyの辞書データは次のようなフォーマットになっています。

NOTE: LOUDSそのものに関する解説は行いません。

## DicdataElement型

```swift
struct DicdataElement {
    // 単語の表記
    var word: String
    // 単語のルビ（カタカナ）
    var ruby: String
    // 単語の左連接ID
    var lcid: Int
    // 単語の右連接ID
    var rcid: Int
    // 単語のMID
    var mid: Int
    // 単語の基礎コスト (PValue = Float16)
    var baseValue: PValue
    // コストの動的調整
    var adjust: PValue
}
```

注意すべき点は次のとおりです。

* 連語などの場合、`lcid`と`rcid`が異なる値を取ることがあります。
* 単語の基礎コストは、歴史的な事情によって負の小数です。大きいほど頻出する単語でus。
* コストの動的調整は、誤り訂正などのためにコストを調整したい場合に使います。例えば「大学生」の基礎コストを「-10」としたとき、「たいがくせい」と入力した誤り訂正の結果として「大学生」が得られている場合は、`adjust`を-3のような値として、合計コストが-13であるかのように振る舞わせます。

`DicdataElement`は`DicdataStore`で辞書データファイルから生成されます。

## 辞書データファイル

辞書データは次の4つの種類のファイルからなります。

* `.louds`
* `.loudschars2`
* `.charID`
* `.loudstxt3`

まず、`.louds`のファイルがLOUDS Trieをバイナリ形式で保存したものです。

次に、`.loudschars2`は各ノードに割り当てられた文字を記録するものです。ただしUnicode文字列の代わりに、1バイトのCharacter IDで表現されています。このため、`.loudschars2`は1バイトずつ処理できます。`.charID`がCharacterをIDに割り当てるためのデータを格納します。

最後に、`.loudstxt3`に各ノードに割り当てられたエントリーのデータが記録されています。

azooKeyの辞書ルックアップは次のように進みます。

1. 起動時に一度だけ`charID`が読み込みます。以降はこれを参照してクエリをID列に変換します。
1. クエリを受け取ったら、ID列に変換します。クエリの先頭の文字に対応する`louds`と`loudschars2`を読み込みます。Swift側ではこの2つをセットにして`LOUDS`構造体が作られ、キャッシュされます。
1. `LOUDS`を検索し、必要なノードの番号を列挙します。
1. クエリの先頭の文字に対応する`loudstxt3`を読み込み、必要な番号のノードに記録されたデータを読み出します。読み出したデータを`DicdataElement`形式に変換し、以降の処理で利用します。なお、`loudstxt3`の方はキャッシュしないので、必要になるたびにIOが走ります。

### `.louds`の構造

`.louds`ファイルはLOUDSのbit列を保存したものです。

### `.loudschars2`の構造

TBW

### `.charID`の構造

TBW

### `.loudstxt3`の構造

TBW

## 重みデータ（CID）

品詞バイグラムの重み行列が疎行列になることから、CIDの重みデータはフォーマットを工夫しています。

TBW

## 重みデータ（MID）

こちらは疎行列ではないため、重み行列をそのままバイナリ化したものが`mm.binary`として保存されています。

TBW
