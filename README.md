# jenkins-echelon

各言語のバージョン違いのテストをdocker上で実行し、Jenkinsで集計します。

## 対応バージョン
* PHP
  * 5.4
  * 5.5
  * 5.6
* Ruby
  * 2.0
  * 2.1
  * 2.2

## 説明
jenkins-echelonを使うことで、Jenkinsから異なるバージョンの言語やフレームワークのテストができます。  
Jenkinsがインストールされているサーバに必要な環境を作る必要がありません。

## 制約事項
以下のことが現状できません。
* gitリポジトリに含まれない秘密情報系のファイル(APIキー情報など)を渡すこと
    * gitリポジトリにもし含まれていれば可能です
* DBを使用したテスト
    * `--volumes-from`を使ったマウントなど複数のコンテナをつなぎあわせた環境は用意できません

## 前提条件
以下の条件を満たしたリポジトリを用意してください
* Ruby
    * `spec`ディレクトリにRSpecのテストファイルを配置
    * プロジェクトルートに`spec`ディレクトリがない場合、実行時にディレクトリパスを指定する必要がある

## 使い方
シェルの実行で以下のコマンドを指定するとテストが実行される。  
Jenkinsで実行したときはワークスペースに`result.xml`を出力するので、JUnitテスト結果の集計で指定する。

### Ruby
```sh
sudo sh init_script/ruby.sh git://github.com/mapserver2007/jenkins-echelon.git master ruby2.2 sample/ruby/spec sample/ruby
```

* arg1: テスト対象リポジトリURI(必須)
* arg2: ブランチ(必須)
* arg3: 言語バージョン(必須)
* arg4: テストディレクトリパス(プロジェクトルートからの相対パス)(任意)
    * 省略時はプロジェクトルート直下のspecディレクトリを指定
* arg5: Gemfileパス(任意)
    * 省略時はbundle installを実行しない

### PHP
```sh
sudo sh init_script/php.sh git://github.com/mapserver2007/jenkins-echelon.git master php5.6 sample/php/test sample/php
```

* arg1: テスト対象リポジトリURI(必須)
* arg2: ブランチ(必須)
* arg3: 言語バージョン(必須)
* arg4: テストディレクトリパス(プロジェクトルートからの相対パス)(必須)
* arg5: composer.jsonパス(任意)
    * 省略時はcomposer installを実行しない

## License
MIT
