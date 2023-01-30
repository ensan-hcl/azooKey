# Conversion Algorithms

azooKey内部で用いられている複雑な実装を大まかに説明します。

## かな漢字変換

変換処理では基盤としてViterbiアルゴリズムを用いています。

入力中には「1文字追加する」「1文字消す」「1文字置き換える」など、差分を利用しやすい場面が多いため、それぞれの場面に最適化したアルゴリズムを選択出来るようになっています。

アルゴリズムに特徴的な点として、文節単位に分割したあと、「内容語バイグラム」とでもいうべき追加のコストを計算します。このコスト計算により、「共起しやすい語」が共起している場合により評価が高く、「共起しづらい語」が共起している場合に評価が低くなります。

## 入力管理

入力管理は簡単に見えて非常に複雑な問題です。azooKeyでは`ComposingText`の内部で管理されています。

典型的なエッジケースは「ローマ字入力中に英語キーボードに切り替えて英字を打ち、日本語キーボードに戻って入力を続ける」という操作です。つまり、次の2つは区別できなければいけません。

```
入力 k (日本語) // →k
入力 a (日本語) // →か
```

```
入力 k (英語)   // →k
入力 a (日本語) // →kあ
```

azooKeyの`ComposingText`は、次のような構造になっています。このように`input`を持つことによって、この問題に対処しています。

```swift
struct ComposingText {
    // 入力の記録
	var input: [InputElement]
    // ローマ字変換などを施した結果の文字列
    var convertTarget: String
    // 結果文字列内のカーソル位置(一番左にある場合、0)
    var convertTargetCursorPosition: Int
}

struct InputElement {
    // 入力した文字
    var character: Character
    // 入力方式
    var inputStyle: InputStyle
}

enum InputStyle {
    // 直接入力
    case direct
    // ローマ字入力
    case roman2kana
}
```

しかし、カーソルを考慮すると、問題はさらに複雑になります。これは、UIの表面からは想像もつかないほど複雑です！

例えば、以下の状態を考えます。

```swift
ComposingText(
    input: [
        InputElement("j", .roman2kana),
        InputElement("a", .roman2kana),
    ],
    convertTarget: "じゃ",
    // 重要: カーソルの位置は「じ|ゃ」となっている。
    convertTargetCursorPosition: 1
)
```

ここで、「u」をローマ字入力した場合、どういう挙動になるでしょうか。ここにはデザインスペースがあります。

1. じうゃ
1. じゃう
1. じゅあ
1. 諦めて編集状態を解除する

1は最も直感的で、azooKeyはこの方式をとっています。この場合、`input`を修正する必要があります。そこでazooKeyでは、「u」をローマ字入力した場合に`ComposingText`が次のように変化します。

```swift
ComposingText(
    input: [
        InputElement("じ", .direct),
        InputElement("u", .roman2kana),
        InputElement("ゃ", .direct),
    ],
    convertTarget: "じうゃ",
    convertTargetCursorPosition: 2
)
```

一方でiOSの標準ローマ字入力では、「2」が選ばれています。これはある意味で綺麗な方法で、ローマ字入力時に「一度に」入力された単位は不可侵にしてしまう、という方法で上記の変化を無くしています。もしazooKeyがこの方式をとっているのであれば、以下のように変化することになります。しかし、このような挙動は非直感的でもあります。

```swift
ComposingText(
    input: [
        InputElement("j", .roman2kana),
        InputElement("a", .roman2kana),
        InputElement("u", .roman2kana),
    ],
    convertTarget: "じゃう",
    convertTargetCursorPosition: 3
)
```

「3」の「じゅあ」を選んでいるシステムは知る限りありません。この方式は「ja / じゃ」の間に「u」を入れる場合はうまくいきますが、「cha / ちゃ」の「ち」と「ゃ」の間に「u」を入れる場合は入れる位置をどのように決定するのかという問題が残ります。（chua、とすることになるのでしょうか）

「4」はある意味素直な立場で、「そんなんどうでもええやろ」な実装はしばしばこういう形になっています。合理的です。azooKeyも、ライブ変換中はカーソル移動を諦めているため、このように実装しています。

このように、入力にはさまざまなエッジケースがあります。こうした複雑なケースに対応していくため、入力の管理は複雑にならざるを得ないのです。

## 誤り訂正

誤り訂正は、上記の`ComposingText`を基盤とした非常にアドホックな実装になっています。

TBW

## 学習

TBW

## 変換候補の並び順

TBW

## ライブ変換

TBW