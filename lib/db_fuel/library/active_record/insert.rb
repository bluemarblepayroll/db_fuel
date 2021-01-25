# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'upsert'

module DbFuel
  module Library
    module ActiveRecord
      # This job can take the objects in a register and insert them into a database table.
      #
      # Expected Payload[register] input: array of objects
      # Payload[register] output: array of objects.
      class Insert < Upsert
        # attr_reader :primary_key

        # Arguments:
        #   name: name of the job within the Burner::Pipeline.
        #
        #   table_name [required]: name of the table to use for the INSERT statements.
        #
        #   attributes:  Used to specify which object properties to put into the
        #                SQL statement and also allows for one last custom transformation
        #                pipeline, in case the data calls for SQL-specific transformers
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
        #               and updated_at columns will automatically have their values set
        #               to the current UTC timestamp.
        def initialize(
          table_name:,
          name: '',
          attributes: [],
          debug: false,
          primary_key: nil,
          register: Burner::DEFAULT_REGISTER,
          separator: '',
          timestamps: true
        )

          attributes = Burner::Modeling::Attribute.array(attributes)

          super(
            name: name,
            table_name: table_name,
            attributes: attributes,
            debug: debug,
            primary_key: primary_key,
            register: register,
            separator: separator,
            timestamps: timestamps
          )
        end

        def perform(output, payload)
          payload[register] = array(payload[register])

          payload[register].each { |row| insert_record(output, row, payload.time) }
        end
      end
    end
  end
end
