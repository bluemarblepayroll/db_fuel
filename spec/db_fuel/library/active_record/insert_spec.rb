# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe DbFuel::Library::ActiveRecord::Insert do
  let(:output)   { make_burner_output }
  let(:register) { 'register_a' }
  let(:debug)    { false }

  let(:config) do
    {
      name: 'test_job',
      register: register,
      debug: debug,
      attributes: [
        {
          key: :chart_number,
          transformers: [
            {
              type: 'r/value/resolve',
              key: :chart_number
            }
          ]
        },
        {
          key: :first_name,
          transformers: [
            {
              type: 'r/value/resolve',
              key: :first_name
            }
          ]
        },
        {
          key: :last_name,
          transformers: [
            {
              type: 'r/value/resolve',
              key: :last_name
            }
          ]
        }

      ],
      table_name: 'patients',
      primary_key: {
        key: :id
      }
    }
  end

  let(:patients) do
    [
      { chart_number: 'AB0', first_name: 'a0', last_name: 'b0' },
      { chart_number: 'AB1', first_name: 'a1', last_name: 'b1' }
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

    context 'when debug is true' do
      let(:debug)   { true }
      let(:written) { output.outs.first.string }

      it 'outputs sql statements' do
        expect(written).to include('Insert Statement: INSERT INTO "patients"')
      end

      it 'outputs return object' do
        expect(written).to include('Insert Return: {')
      end
    end

    it 'inserts records with specified attributes' do
      db_patients = Patient.order(:chart_number)

      expect(db_patients.count).to eq(2)

      db_patients.each_with_index do |db_patient, index|
        expect(db_patient.chart_number).to eq(patients.dig(index, :chart_number))
        expect(db_patient.first_name).to   eq(patients.dig(index, :first_name))
        expect(db_patient.last_name).to    eq(patients.dig(index, :last_name))
      end
    end
  end
end
