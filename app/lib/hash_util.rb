# frozen_string_literal: true

module HashUtil
  def self.from_keys(array)
    kv = [array, array].transpose
    Hash[*kv.flatten]
  end
end
