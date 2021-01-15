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

        attr_reader :attribute_renderers,
                    :db_provider,
                    :debug,
                    :resolver,
                    :attribute_renderers_set

        def initialize(
          name:,
          table_name:,
          attributes: [],
          debug: false,
          register: Burner::DEFAULT_REGISTER,
          separator: ''
        )
          super(name: name, register: register)

          @resolver = Objectable.resolver(separator: separator)
          @attribute_renderers_set = Modeling::AttributeRendererSet.new(attributes: attributes,
                                                                        resolver: resolver)
          @db_provider = DbProvider.new(table_name)
          @debug = debug || false
        end

        protected

        def debug_detail(output, message)
          return unless debug

          output.detail(message)
        end
      end
    end
  end
end
