# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module DbFuel
  module Library
    module ActiveRecord
      # This job can take the objects in a register and insert them into a database table.
      #
      # Expected Payload[register] input: array of objects
      # Payload[register] output: array of objects.
      class Insert < Burner::JobWithRegister
        attr_reader :arel_table,
                    :attribute_renderers,
                    :debug,
                    :primary_key,
                    :resolver

        # Arguments:
        #   name [required]: name of the job within the Burner::Pipeline.
        #
        #   table_name [required]: name of the table to use for the INSERT statements.
        #
        #   attributes:  Used to specify which object properties to put into the
        #                SQL statement and also allows for one last custom transformation
        #                pipeline, in case the data calls for sql-specific transformers
        #                before insertion.
        #
        #   debug: If debug is set to true (defaults to false) then the SQL statements and
        #          returned objects will be printed in the output.  Only use this option while
        #          debugging issues as it will fill up the output with (potentially too much) data.
        #
        #   primary_key: If primary_key is present then it will be used to set the object's
        #                property to the returned primary key from the INSERT statement.
        #
        #   separator: Just like other jobs with a 'separator' option, if the objects require
        #              key-path notation or nested object support, you can set the separator
        #              to something non-blank (like a period for notation in the
        #              form of: name.first).
        #
        #   timestamps: If timestamps is true (default behavior) then both created_at
        #               and updated_at columns will  automatically have their values set
        #               to the current UTC timestamp.
        def initialize(
          name:,
          table_name:,
          attributes: [],
          debug: false,
          primary_key: nil,
          register: Burner::DEFAULT_REGISTER,
          separator: '',
          timestamps: true
        )
          super(name: name, register: register)

          # set resolver first since make_attribute_renderers needs it.
          @resolver = Objectable.resolver(separator: separator)

          @arel_table          = ::Arel::Table.new(table_name.to_s)
          @attribute_renderers = make_attribute_renderers(attributes, timestamps)
          @debug               = debug || false
          @primary_key         = Modeling::KeyedColumn.make(primary_key, nullable: true)

          freeze
        end

        def perform(output, payload)
          payload[register] = array(payload[register])

          payload[register].each do |row|
            arel_row = make_arel_row(transform(row, payload.time))

            insert_manager = ::Arel::InsertManager.new
            insert_manager.insert(arel_row)

            output.detail("Insert Statement: #{insert_manager.to_sql}")

            id = ::ActiveRecord::Base.connection.insert(insert_manager)

            resolver.set(row, primary_key.key, id) if primary_key

            output.detail("Insert Return: #{row}")
          end
        end

        private

        def timestamp_renderers
          Burner::Modeling::Attribute.array(
            [
              {
                key: :created_at,
                transformers: [
                  { type: 'r/value/now' }
                ]
              },
              {
                key: :updated_at,
                transformers: [
                  { type: 'r/value/now' }
                ]
              }
            ]
          ).map { |a| Burner::Modeling::AttributeRenderer.new(a, resolver) }
        end

        def make_attribute_renderers(attributes, timestamps)
          renderers = Burner::Modeling::Attribute
                      .array(attributes)
                      .map { |a| Burner::Modeling::AttributeRenderer.new(a, resolver) }

          timestamps ? renderers + timestamp_renderers : renderers
        end

        def make_arel_row(row)
          row.map { |key, value| [arel_table[key], value] }
        end

        def transform(row, time)
          attribute_renderers.each_with_object({}) do |attribute_renderer, memo|
            value = attribute_renderer.transform(row, time)

            resolver.set(memo, attribute_renderer.key, value)
          end
        end
      end
    end
  end
end
