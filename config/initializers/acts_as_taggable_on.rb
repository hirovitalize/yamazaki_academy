module ActsAsTaggableOn
  class Tag < ::ActiveRecord::Base
    enum severity: ::HashUtil.from_keys(%w[primary secondary info success warning danger]), _prefix: true

    after_initialize :default_values, if: :new_record?

    def default_values
      self.severity = :info if severity.blank?
    end
  end

  class Configuration
    def self.apply_binary_collation(bincoll)
      # do nothing
      # ridgepole では不要な処理が行われていた
    end
  end
end