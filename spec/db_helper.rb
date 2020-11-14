# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

# Enable logging using something like:
# ActiveRecord::Base.logger = Logger.new(STDERR)

require 'file_helper'

class Patient < ActiveRecord::Base
end

def connect_to_db(name)
  config = read_yaml_file('spec', 'config', 'database.yaml')[name.to_s]
  ActiveRecord::Base.establish_connection(config)
end

def load_schema
  ActiveRecord::Schema.define do
    create_table :patients do |t|
      t.string :chart_number
      t.string :first
      t.string :middle
      t.string :last
      t.timestamps
    end
  end
end

def clear_data
  Patient.delete_all
end

def load_data
  Patient.create!(
    first: 'Bozo',
    middle: 'The',
    last: 'Clown'
  )

  Patient.create!(
    first: 'Frank',
    last: 'Rizzo'
  )

  Patient.create!(
    first: 'Bugs',
    middle: 'The',
    last: 'Bunny'
  )
end
