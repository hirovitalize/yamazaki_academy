# frozen_string_literal: true

require 'benchmark'

module TaskUtil
  module_function

  def profile
    starting.each { |key, val| STDOUT.puts format('---- %-12s : %s', key, val) }
    result = Benchmark.realtime { yield }
    finished(result).each { |key, val| STDOUT.puts format('---- %-12s : %s', key, val) }
  rescue StandardError => e
    handle_error(e)
  end

  def handle_error(err)
    Raven.capture_exception(err)
    # Notice.staffs '@here 定期処理が失敗しました…ごめんなさい…orz'
    # ErrorMailer.template(e, Settings.mail.address.developer, nil, nil).do_delivery
    warn  err.message
    warn  err.backtrace
  rescue StandardError => ignore
    warn  ignore.message
  end

  def starting
    {
      '' => '',
      'Caller' => caller(2..2).first.match(/(\A.*:)/),
      'Start At' => Time.zone.now.strftime('%Y/%m/%d %H:%M:%S')
    }
  end

  def finished(result)
    {
      'Used Time' => Time.zone.at(result).utc.strftime('%Hh %Mmin %S.%Lsec'),
      'Used Memory' => "#{`ps -o rss= -p #{Process.pid}`.to_i / 1000} MB",
      'Finish At' => Time.zone.now.strftime('%Y/%m/%d %H:%M:%S'),
      '' => ''
    }
  end
end
