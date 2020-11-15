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
      # Execute a Dbee Query against a Dbee Model and store the resulting records in the designated
      # payload register.
      class Query < Burner::JobWithRegister
        attr_reader :model, :provider, :query

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

        def perform(output, payload)
          records = ::ActiveRecord::Base.connection.exec_query(sql).to_a

          output.detail("Loading #{records.length} record(s) into #{register}")

          payload[register] = records
        end

        private

        def sql
          ::Dbee.sql(model, query, provider)
        end
      end
    end
  end
end
