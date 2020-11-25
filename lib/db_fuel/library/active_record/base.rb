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
      class Base < Burner::JobWithRegister
        CREATED_AT = :created_at
        NOW_TYPE   = 'r/value/now'
        UPDATED_AT = :updated_at

        attr_reader :arel_table,
                    :attribute_renderers,
                    :debug,
                    :resolver

        def initialize(
          name:,
          table_name:,
          attributes: [],
          debug: false,
          register: Burner::DEFAULT_REGISTER,
          separator: ''
        )
          super(name: name, register: register)

          @arel_table = ::Arel::Table.new(table_name.to_s)
          @debug      = debug || false

          # set resolver first since make_attribute_renderers needs it.
          @resolver = Objectable.resolver(separator: separator)

          @attribute_renderers = Burner::Modeling::Attribute
                                 .array(attributes)
                                 .map { |a| Burner::Modeling::AttributeRenderer.new(a, resolver) }
        end

        private

        def timestamp_attribute(key)
          Burner::Modeling::Attribute.make(
            key: key,
            transformers: [
              { type: NOW_TYPE }
            ]
          )
        end

        def debug_detail(output, message)
          return unless debug

          output.detail(message)
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
