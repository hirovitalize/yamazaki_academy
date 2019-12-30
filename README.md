coach2

行知学園様案件　ERPシステムです。

システム概要 AP: ruby ruby 2.4.1, rails 5.2 (AmazonEC2) DB: MySQL (AmazonRDS)

後述の手順で、環境設定・開発を行ってください。

開発環境設定
run setup commands.

 $ bin/setup
Start the Rails development server:

 $ bundle exec rails server
If you use croud9, run following command.

 $ bundle exec rails s -b $IP
Open http://127.0.0.1:3000/ in a web browser to view your application.

開発手順
設計

 1. ユースケース検討
 2. 主たるデータのライフサイクル、CRUD確認
 3. 実装方針比較・選定
 4. WBS作成
     https://docs.google.com/spreadsheets/d/1D99zbdvR7Xk7YtvvyJJt4KjjKYH2o4An9qjaleU2lWQ/edit#gid=0
     https://tech.nikkeibp.co.jp/it/article/COLUMN/20100603/348828/?P=1
モデル生成

 $ rails g model new_model(単数形)
スキーマ修正

 $ vim db/schemas/{テーブル名}.schema # 列・インデクス情報の設定
 $ vim db/schemas/Schemafile # テーブル情報の登録
 $ bundle exec rails db:apply # DBへの反映
一括自動生成

 $ bundle exec rails g scaffold_controller new_model(複数形)
views/new_model/index.html.slim内にいくつかTODOがあるので対応すること。（viewの分割、searchのコピー実装）

ルーティング

 $ vim config/routes.rb
文言設定

 $ vim config/locale/translation_ja.yml
メニューを追加

 $ vim app/views/layouts/_navigation.html.slim
service restart

画面を見ながら、各種修正 レイアウト(slimのdom構成) バリデーション(model)

共通手順
データを同期する 開発環境の場合
  $ bundle exec rake db:drop; bundle exec rake db:create; bundle exec rake db:apply; bundle exec rake db:seed
本番(staging)の場合

    # $ bundle exec rake db:drop db:create RAILS_ENV=production DISABLE_DATABASE_ENVIRONMENT_CHECK=1
    # $ mysqldump -h aa1cf1lo20067xm.ckinz9qsuqgc.us-west-2.rds.amazonaws.com coach2_development_ryotaichikawa -u vitalize -p | mysql -h aa1cf1lo20067xm.ckinz9qsuqgc.us-west-2.rds.amazonaws.com 自分の開発用DB名(.env参照) -u vitalize -p
    $ bundle install
    $ bundle exec yarn
    $ bundle exec rails tmp:clear
    $ sudo bundle exec rake assets:precompile RAILS_ENV=production
    $ sudo service httpd restart
push前の静的・動的チェック
MUST $ bundle exec rubocop # syntax および エラーっぽい実装の検知。デバッグコードなど $ bundle exec rubocop -a # 同　自動修正 $ bundle exec rake test # テスト実行

WANT $ bundle exec rails_best_practices # Rails特化の静的解析 (未使用メソッド・DB物理設計など) $ bundle exec slim_lint # slim版のrubocop

システム俯瞰のコードレビュー（危な箇所を見つけて、Webで眺める）
  $ bundle exec rubycirtic app/ db/ config -p public/rubycritic
  その後、browser で /rubycritic/overview.html にアクセス
  読み方: http://hoppie.hatenablog.com/entry/2016/12/02/102208
  公式: https://github.com/whitesmith/rubycritic