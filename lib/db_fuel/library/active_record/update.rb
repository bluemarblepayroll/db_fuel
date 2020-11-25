# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'base'

module DbFuel
  module Library
    module ActiveRecord
      # This job can take the objects in a register and updates them within database table.
      # The attributes translate to SQL SET clauses and the unique_keys translate to
      # WHERE clauses.
      #
      # Expected Payload[register] input: array of objects
      # Payload[register] output: array of objects.
      class Update < Base
        attr_reader :unique_keys

        # Arguments:
        #   name [required]: name of the job within the Burner::Pipeline.
        #
        #   table_name [required]: name of the table to use for the INSERT statements.
        #
        #   attributes:  Used to specify which object properties to put into the
        #                SQL statement and also allows for one last custom transformation
        #                pipeline, in case the data calls for sql-specific transformers
        #                before mutation.
        #
        #   debug: If debug is set to true (defaults to false) then the SQL statements and
        #          returned objects will be printed in the output.  Only use this option while
        #          debugging issues as it will fill up the output with (potentially too much) data.
        #
        #   separator: Just like other jobs with a 'separator' option, if the objects require
        #              key-path notation or nested object support, you can set the separator
        #              to something non-blank (like a period for notation in the
        #              form of: name.first).
        #
        #   timestamps: If timestamps is true (default behavior) then the updated_at column will
        #               automatically have its value set to the current UTC timestamp.
        #
        #   unique_keys: Each key will become a WHERE clause in order to only update specific
        #                records.
        def initialize(
          name:,
          table_name:,
          attributes: [],
          debug: false,
          register: Burner::DEFAULT_REGISTER,
          separator: '',
          timestamps: true,
          unique_keys: []
        )
          explicit_attributes = Burner::Modeling::Attribute.array(attributes)

          attributes = timestamps ? timestamp_attributes + explicit_attributes : explicit_attributes

          super(
            name: name,
            table_name: table_name,
            attributes: attributes,
            debug: debug,
            register: register,
            separator: separator
          )

          @unique_keys = Modeling::KeyedColumn.array(unique_keys)

          freeze
        end

        def perform(output, payload)
          total_rows_affected = 0

          payload[register] = array(payload[register])

          payload[register].each do |row|
            update_manager = make_update_manager(row, payload.time)

            debug_detail(output, "Update Statement: #{update_manager.to_sql}")

            rows_affected = ::ActiveRecord::Base.connection.update(update_manager)

            debug_detail(output, "Individual Rows Affected: #{rows_affected}")

            total_rows_affected += rows_affected
          end

          output.detail("Total Rows Affected: #{total_rows_affected}")
        end

        private

        def make_update_manager(row, time)
          arel_row       = make_arel_row(transform(row, time))
          unique_values  = make_unique_column_values(row)
          update_manager = ::Arel::UpdateManager.new.set(arel_row).table(arel_table)

          apply_where(unique_values, update_manager)
        end

        def make_unique_column_values(row)
          unique_keys.each_with_object({}) do |unique_key, memo|
            memo[unique_key.column] = resolver.get(row, unique_key.key)
          end
        end

        def apply_where(hash, manager)
          (hash || {}).inject(manager) do |memo, (key, value)|
            memo.where(arel_table[key].eq(value))
          end
        end

        def timestamp_attributes
          [timestamp_attribute(UPDATED_AT)]
        end
      end
    end
  end
end
