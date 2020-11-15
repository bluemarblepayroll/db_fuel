# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module DbFuel
  module Library
    module Dbee
      # Common code shared between all Dbee subclasses.
      class Base < Burner::JobWithRegister
        attr_reader :model,
                    :provider,
                    :query

        def initialize(
          name:,
          model: {},
          query: {},
          register: Burner::DEFAULT_REGISTER
        )
          super(name: name, register: register)

          @model    = ::Dbee::Model.make(model)
          @provider = ::Dbee::Providers::ActiveRecordProvider.new
          @query    = ::Dbee::Query.make(query)

          freeze
        end

        protected

        def execute(sql)
          ::ActiveRecord::Base.connection.exec_query(sql).to_a
        end

        def load_register(records, output, payload)
          output.detail("Loading #{records.length} record(s) into #{register}")

          payload[register] = records
        end
      end
    end
  end
end
