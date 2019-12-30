# frozen_string_literal: true
Kaminari.configure do |config|
  config.default_per_page = 50
  # config.max_per_page = nil
  config.window = 2
  # config.outer_window = 0
  # config.left = 0
  # config.right = 0
  config.page_method_name = :page
  # config.param_name = :page
  # config.params_on_first_page = false
end

module Kaminari
  module ActionViewExtension
    def page_entries_info(collection, options = {})
      count = collection.total_count
      entry_name = options[:entry_name] || collection.model_name.human(count: count)

      if collection.total_pages < 2
        t('helpers.page_entries_info.one_page.display_entries',
          entry_name: entry_name,
          count: count)
      else
        first = collection.offset_value + 1
        last = collection.last_page? ? count : collection.offset_value + collection.limit_value
        t('helpers.page_entries_info.more_pages.display_entries',
          entry_name: entry_name,
          first: first,
          last: last,
          total: count)
      end.html_safe
    end
  end
end