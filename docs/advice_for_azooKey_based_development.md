# azooKeyをベースとするプロダクトの開発開始時に注意すべき点

azooKeyはMIT Licenseであり、誰でもazooKeyをベースに新規プロダクト開発を行うことができます。これにより、素晴らしい日本語入力ソフトウェアが誕生することを期待しています。

一方、azooKeyを採用する上で注意していただくべき点もあります。これについて説明します。

## 不足している機能

azooKeyは優先順位などの問題から、いくつかの標準的なキーボード機能をサポートしていません。

### トグル入力 / 携帯打ち

azooKeyはトグル入力（携帯打ち）をサポートしていません。

かな漢字変換モジュールにはひらがなを渡せるので問題ありませんが、キーボードのUIの実装まで利用する場合は注意が必要です。

将来的に対応する可能性はありますし、実際に必要な方がいる場合は優先度が上がります。ご相談ください。

### 英語のなぞり入力 / グライド入力

azooKeyは英語のなぞり入力（グライド入力）をサポートしていません。

高精度なグライド入力の実現は今のところコストが高いため行えていません。将来的に対応したいですが、現状技術的に困難です。

### 再変換

azooKeyは一般の場合の再変換をサポートしていません。つまり「再変換」から「さいへんかん」という文字列を得るためのモジュール（漢字かな変換モジュール）は実装されていません。

### シフト

azooKeyのデフォルトのUIは英字のシフトに対応していませんが、`ApplicationSpecificKeyboardViewSettingProvider`を実装する際に`useShiftKey`を`true`にすることでデフォルトのローマ字キーボードでシフトキーを実装することができます。

### 「次候補」ボタン

標準キーボードは入力時に「空白」が「次候補」キーに変わり、これを押すことで変換候補を選択することができます。この機能はazooKeyでは対応していません。

## 修正されるべき実装

### データの保存

azooKeyでは歴史的事情により、データの保存がナイーブな方法で行われています。具体的には、UserDefaultsと内部ディレクトリへのファイルの保存によって管理されており、Core DataやRealmなどユーザデータを保存するのに適した仕組みは利用していません。

この点はマイグレーションの難しさなどの理由から解決されていません。azooKeyをベースにした新規開発を行う場合は、このような点を解決すると将来的に楽でしょう。

### 辞書の提供方法

azooKeyはアプリケーションと辞書をバンドルしています。しかし個別に更新できるよう、切り離したほうが開発が楽でしょう。

## その他の懸念

### ポータビリティ

azooKeyはSwiftによる実装のため、AndroidやWindowsへの移植が困難となる可能性があります。これが問題となる場合、Mozcなどの利用をおすすめします。
