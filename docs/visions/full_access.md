# Full Access Vision

## 今後実現したい機能

* 擬似的な画像入力機能
* 学習の複数端末での共有、引越し機能
* キーボード内での検索機能（Gboard）
* キーボード内での「真の」設定変更
  * 擬似的に行うことは出来る
    1. 設定の名前を`setting_hoge`とする。
    1. 本体アプリ側からは、共有ストレージに`setting_hoge_container`のキーで、データと更新時刻を保存。
    1. キーボード側からは、独自ストレージに`setting_hoge_keyboard`のキーで、データと更新時刻を保存。
    1. `setting_hoge`のデータを読み出す際は、`setting_hoge_container`と`setting_hoge_keyboard`の更新時刻を比較し、新しい方を優先する。
* 強力なかな漢字変換エンジンなどを用いたオンライン変換