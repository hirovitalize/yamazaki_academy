# frozen_string_literal: true

module HasDateRange
  extend ActiveSupport::Concern

  module ClassMethods
    # 日付期間を生成します (scope/ransack名: xxx_range_included)
    # from: 開始日
    # to: 終了日
    # as: 表示列名
    # nil_as_infinity: 全期間 if nil
    # include_from: 同時刻を含む
    # include_to: 同時刻を含む
    #
    # 日付の大小 validation有
    def acts_as_daterange(
      from, to,
      as: 'date', nil_as_infinity: true,
      include_from: true, include_to: true
    )
      singleton_class.send(:define_method, "#{as}_range_overlaps", lambda { |d1, d2|
        d1 = [d1, d2].min
        d2 = [d1, d2].max

        from_arel = arel_table[from]
        to_arel = arel_table[to]
        from_query = include_from ? from_arel.lteq(d2) : from_arel.lt(d2)
        to_query = include_to ? to_arel.gteq(d1) : to_arel.gt(d1)

        if nil_as_infinity
          where(from_arel.eq(nil).or(from_query))
          .where(to_arel.eq(nil).or(to_query))
        else
          where(from_query.and(to_query))
        end
      })
      singleton_class.send(:define_method, "#{as}_range_included", lambda { |date|
        send("#{as}_range_overlaps", date, date)
      })

      validates to, timeliness: { on_or_after: from.to_sym, type: :date },
                    allow_blank: true,
                    if: proc { |model| model.send(from).present? }
      validates from, timeliness: { type: :date }, allow_blank: true
    end
  end
end
