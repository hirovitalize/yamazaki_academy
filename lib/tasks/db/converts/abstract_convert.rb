# frozen_string_literal: true

module Tasks
  module Db
    module Converts
      class AbstractConvert
        def src_schema
          'coach_20190331'
        end

        def truncate
          target_tables.each do |model|
            User.connection.execute("truncate table #{model.table_name}")
          end
        end

        def fetch_table(table)
          User.connection.select_all("SELECT * FROM #{src_schema}.#{table}")
        end
      end
    end
  end
end
