# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'
require 'mocks/burner_output'

describe DbFuel::Library::Dbee do
  before(:each) do
    load_data
  end

  let(:output)   { make_burner_output }
  let(:register) { 'register_a' }

  let(:config) do
    {
      name: 'test_job',
      model: {
        name: :patients
      },
      query: {
        fields: [
          {
            key_path: :id
          },
          {
            key_path: :first
          }
        ],
        sorters: [
          {
            key_path: :first
          }
        ]
      },
      register: register
    }
  end

  let(:payload) { Burner::Payload.new }

  subject { described_class.make(config) }

  describe '#perform' do
    before(:each) do
      subject.perform(output, payload)
    end

    specify 'output contains number of records' do
      string_summary = output.outs.first

      expect(string_summary.read).to include("Loading 3 record(s) into #{register}")
    end

    specify 'payload register has data' do
      records = payload[register]

      expect(records.length).to eq(3)

      expect(records[0]).to include('first' => 'Bozo')
      expect(records[1]).to include('first' => 'Bugs')
      expect(records[2]).to include('first' => 'Frank')
    end
  end
end
