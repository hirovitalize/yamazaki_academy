# frozen_string_literal: true

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# コマンド
# whenever --update-crontab 登録
# whenever --clear-crontab クリア
# crontab -e 確認
#
# 注意事項
# EC2のTimeZoneをJSTに変更した後に以下コマンドでクーロン再起動しないと時間がずれたままになる
# sudo service crond restart
# 開発環境で試すときは下記のコメントアウトを外して試す
# set :environment, 'development'
set :output, 'log/crontab.log'

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

every 10.minute do
  runner 'User.common.first.regenerate_auth_token' # 毎10分でトークン更新
end

every 1.day, at: '8:00 pm' do
  rake 'lecture_mailer:send_daily'
end

# every 1.day, at: ['0:00 pm'] do
#   rake 'crawl_task:crawl_competitor'
# end
