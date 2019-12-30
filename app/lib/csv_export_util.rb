# frozen_string_literal: true

require 'csv'

module CsvExportUtil
  def self.export(models, header: column_names, columns: column_names, row_sep: "\r\n", encoding: Encoding::UTF_8, search_params: nil)
    records = CSV.generate(row_sep: row_sep, encoding: encoding) do |csv|
      csv << header
      models.find_each { |record| csv << extract_values(record, columns, search_params) }
    end
    records.encode(encoding, invalid: :replace, undef: :replace)
  end

  def self.extract_values(record, columns, _search_params)
    columns.map do |col|
      p = col.is_a?(Proc) ? col : col.to_proc
      p.call(record)
    end
  end
end
