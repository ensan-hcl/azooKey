# Clipboard History

azooKeyはフルアクセスが有効な場合、クリップボードの履歴を保持する機能を持っています。

## `ClipboardHistoryManager`

`ClipboardHistoryManager`はクリップボードの履歴を管理するクラスです。以下の機能を持っています。

* `UIPasteboard`にアクセスして、更新を確認する
* `UIPasteboard`の履歴を保存する
* `UIPasteboard`の履歴を編集する

更新チェックはキーボードを閉じたタイミング、開いたタイミング、ユーザが何らかのアクションを行ったタイミングなどで行い、なるべく履歴を正確に取得できるようになっています。ただしキーボードを開いていない状態では履歴を取得することができません。
