# frozen_string_literal: true

module ModelBulkImporter
  Result = Struct.new(:success, :importeds, :row_number, :first_errored) do
    def error
      return '' if first_errored.blank?

      first_errored.errors.full_messages.join(', ')
    end
  end

  # CSVなどのデータ構造から、一括でデータをインサートします
  # Validationなどのエラー時は、そこでストップします
  # @params rows CSVなどの行データ
  # @params &block 行単位のモデル生成処理（飛ばす場合はnil)
  # @return 成否のデータ構造 Struct(:success, :datas, :row_number（エラーの）, :行データ（エラーの）)
  def self.import(rows)
    importings = []
    header_row = rows.first
    rows.each_with_index do |row, i|
      current = yield(row, importings, header_row)
      next if current.blank?

      return Result.new(false, importings, i, current) unless current.valid?

      importings << current
    end

    importings.first.class.import(importings) if importings.present?
    Result.new(true, importings, nil, nil)
  end

  def self.student_import(rows)
    importings = []
    header_row = rows.first
    rows.each_with_index do |row, i|
      current = yield(row, importings, header_row)
      next if current.blank?

      return Result.new(false, importings, i, current) unless current.valid?

      importings << current
    end

    importings_saved = importings.map do |importing|
      importing.save!(importing)
    end

    Result.new(true, importings_saved, nil, nil)
  end

  def self.update(rows, update_columns)
    importings = []
    header_row = rows.first
    rows.each_with_index do |row, i|
      current = yield(row, importings, header_row)
      next if current.blank?

      return Result.new(false, importings, i, current) unless current.valid?

      importings << current
    end
    importings.first.class.import(importings, on_duplicate_key_update: update_columns) if importings.present?
    Result.new(true, importings, nil, nil)
  end
end
