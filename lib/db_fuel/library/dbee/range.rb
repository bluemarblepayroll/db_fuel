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
    module Dbee
      # This Burner Job does the same data query and loading as the Query Job with the addition
      # of the ability to dynamically add an IN filter for a range of values.  The values are
      # retrieved from the register's array of records using the defined key.
      #
      # Expected Payload[register] input: array of objects.
      # Payload[register] output: array of objects.
      class Range < Base
        attr_reader :key,
                    :key_path,
                    :resolver

        def initialize(
          name:,
          key:,
          key_path: '',
          model: {},
          query: {},
          register: Burner::DEFAULT_REGISTER,
          separator: ''
        )
          raise ArgumentError, 'key is required' if key.to_s.empty?

          @key      = key.to_s
          @key_path = key_path.to_s.empty? ? @key : key_path.to_s
          @resolver = Objectable.resolver(separator: separator)

          super(
            model: model,
            name: name,
            query: query,
            register: register
          )
        end

        def perform(output, payload)
          records = execute(sql(payload))

          load_register(records, output, payload)
        end

        private

        def map_values(payload)
          array(payload[register]).map { |o| resolver.get(o, key) }.compact
        end

        def dynamic_filter(payload)
          values = map_values(payload)

          {
            type: :equals,
            key_path: key_path,
            value: values,
          }
        end

        def compile_dbee_query(payload)
          ::Dbee::Query.make(
            fields: query.fields,
            filters: query.filters + [dynamic_filter(payload)],
            limit: query.limit,
            sorters: query.sorters
          )
        end

        def sql(payload)
          ::Dbee.sql(model, compile_dbee_query(payload), provider)
        end
      end
    end
  end
end
