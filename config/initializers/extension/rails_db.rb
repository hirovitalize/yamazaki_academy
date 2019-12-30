module RailsDb
  class SqlQuery
    def valid?
      return false if Rails.env.production? && !safe_query?
      query.present?
    end

    def safe_query?
      qs = query.to_s.downcase.gsub(/^\s+/, '')
      ['insert', 'delete', 'update', 'replace', 'truncate', 'grant', 'revoke', 'drop', 'alter', 'create'].each do |keyword|
        return false if qs.start_with?(keyword)
      end
      true
    end
  end
end