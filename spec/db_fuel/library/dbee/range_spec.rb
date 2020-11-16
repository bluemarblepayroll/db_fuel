# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'
require 'mocks/burner_output'

describe DbFuel::Library::Dbee::Range do
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
          { key_path: :id },
          { key_path: :first }
        ],
        sorters: [
          { key_path: :first }
        ]
      },
      register: register,
      key: :fname,
      key_path: :first
    }
  end

  let(:patients) do
    [
      { 'fname' => 'Bozo' },
      { fname: 'Bugs' },
      { fname: 'DoesntExist' }
    ]
  end

  let(:payload) do
    Burner::Payload.new(
      registers: {
        register => patients
      }
    )
  end

  subject { described_class.make(config) }

  describe '#perform' do
    before(:each) do
      subject.perform(output, payload)
    end

    specify 'output contains number of records' do
      string_summary = output.outs.first

      expect(string_summary.read).to include("Loading 2 record(s) into #{register}")
    end

    specify 'payload register has data' do
      records = payload[register]

      expect(records.length).to eq(2)

      expect(records[0]).to include('first' => 'Bozo')
      expect(records[1]).to include('first' => 'Bugs')
    end
  end

  describe 'README examples' do
    specify 'basic patient query' do
      pipeline = {
        jobs: [
          {
            name: :load_firstnames,
            type: 'b/value/static',
            register: :patients,
            value: [
              { fname: 'Bozo' },
              { fname: 'Bugs' },
            ]
          },
          {
            name: 'load_patients',
            type: 'db_fuel/dbee/range',
            model: {
              name: :patients
            },
            query: {
              fields: [
                { key_path: :id },
                { key_path: :first }
              ],
              sorters: [
                { key_path: :first }
              ]
            },
            register: :patients,
            key: :fname,
            key_path: :first
          }
        ],
        steps: %w[load_firstnames load_patients]
      }

      payload = Burner::Payload.new

      Burner::Pipeline.make(pipeline).execute(output: make_burner_output, payload: payload)

      actual = payload['patients']

      expect(actual.length).to eq(2)
      expect(actual[0]).to     include('first' => 'Bozo')
      expect(actual[1]).to     include('first' => 'Bugs')
    end
  end
end
