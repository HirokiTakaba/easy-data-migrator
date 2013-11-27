# EasyDataMigrator

CSV定義からテーブル作成、データアップロードをするツールです。

## 概要

マスタデータをCSV形式で保持しGitでバージョン管理します。<br>
管理されたCSVデータを元に「テーブルの作成」「データアップロード」を行うことで、<br>
データ管理の信頼性を高めると同時に開発の高速化を実現します。<br>

## 当プロジェクトは下記を実現します
1. データ管理の信頼性
  * 全ての環境で親となるデータ（「STGが正」からの移行）
  * データの保存
  * 変更履歴管理
2. 開発効率を上げる
  * CSVからテーブル作成、データアップロードを行う 
  * 各環境のデータ最新化を容易にする
  * データ設計と同時にテーブル作成とデータ生成ができる
  * SQL要らず、速攻テーブル作成とデータ生成ができる

## 開発現場への導入

### 全体的な流れ

#### 新規開発のとき
1. データ設計
  * テーブル定義を入力する
  * データを入力する
2. テーブル作成（クライアントかJenkins）
3. データアップロード（クライアントかJenkins）
4. コミット（Jenkinsでテーブル作成・データアップロードをする場合はコミットが先）
5. 本番への反映はSTGから差分アップデートする

※データをコミットすれば、2と3をJenkinsに任せることも可<br>
※ER図が必要な場合はDBからジェネレートする

#### データ更新だけのとき
1. データの編集
2. データアップロード（クライアントかJenkins）
3. コミット（Jenkinsでデータアップロードをする場合はコミットが先）

### CSVの編集

#### CSV定義の例
ファイル名: users.csv
```csv
"user_id/ユーザID","name/名前","age/年齢"
"INTEGER(10)","VARCHAR(255)","INTEGER(10)"
"PRIMARY_KEY","DEFAULT NULL",
1,"高場大樹",27
2,"小泉純一郎",71
3,"バラク・オバマ",52
```
* テーブル定義（1-3行目）
  * 1行目: カラム名/コメント
  * 2行目: データ型 - [is_support_column_type](/script/modules/mysql/sql_util_module.rb#L3)
  * 3行目: オプション（「/」区切りで複数指定可能） - [is_support_table_option_type](/script/modules/mysql/sql_util_module.rb#L65)と[is_support_column_option_type](/script/modules/mysql/sql_util_module.rb#L46)
* データ（4行目以降）
  * 4行目以降は全てデータとして扱われる
* その他
  * ファイル名がテーブル名
  * 文字列は必ず「""」で括る

#### CSV編集ツール
* [OpenOffice](http://www.openoffice.org/)を利用する（Excelは改行コードが特殊なため）
* ファイルを開く際の設定
  * 区切りのオプション > 区切る > コンマにチェック
  * 他のオプション > フィールドをテキストとして引用するにチェック

### クライアントからテーブル作成・データアップロード

※クライアントツールを使った方が便利ですが、必須ではありません。

#### 動作環境

* Ruby 1.8.7以上
* MySQL 5以上
* MySQLのモジュールをいくつか入れる必要がある


#### コマンドのマニュアルを参照する
```
hiroki_takaba$ ruby cli/mysql_migrator
Commands:
  mysql_migrator create_table [env] [import_file_path]  # create table
  mysql_migrator upload [env] [import_file_path]        # upload data
```

#### テーブル作成（create_table）
```
hiroki_takaba$ ruby cli/mysql_migrator create_table local import-file/mysql/master/users.csv
------------------------------
---
---  Drop and Create table
---  users
---
------------------------------
DROP TABLE IF EXISTS users;
CREATE TABLE users (
  user_id INTEGER(10) COMMENT 'ユーザID',
	name VARCHAR(255) DEFAULT NULL COMMENT '名前',
	age INTEGER(10) COMMENT '年齢',
	upd_datetime DATETIME NOT NULL COMMENT 'AUTO ADD DATETIME COLUMN',
	ins_datetime DATETIME NOT NULL COMMENT 'AUTO ADD DATETIME COLUMN',
PRIMARY KEY (user_id)) CHARACTER SET utf8 COLLATE utf8_general_ci;
```
* upd_datetimeとins_datetimeは自動で追加されるようにしてある

#### データアップロード（upload）
```
hiroki_takaba$ ruby cli/mysql_migrator upload local import-file/mysql/master/users.csv
------------------------------
---
---  Upload data
---  users
---
------------------------------
DELETE FROM users;
INSERT INTO users (user_id, name, age, upd_datetime, ins_datetime) VALUES
(1, '高場大樹', 27, sysdate(), sysdate()),
(2, '小泉純一郎', 71, sysdate(), sysdate()),
(3, 'バラク・オバマ', 52, sysdate(), sysdate())
```