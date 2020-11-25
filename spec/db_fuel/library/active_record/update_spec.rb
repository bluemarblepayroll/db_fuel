# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe DbFuel::Library::ActiveRecord::Update do
  before(:each) do
    load_data
  end

  let(:output)   { make_burner_output }
  let(:register) { 'register_a' }
  let(:debug)    { false }

  let(:config) do
    {
      name: 'test_job',
      register: register,
      debug: debug,
      attributes: [
        { key: :first_name },
        { key: :last_name }
      ],
      table_name: 'patients',
      unique_keys: [
        { key: :chart_number }
      ]
    }
  end

  let(:patients) do
    [
      { chart_number: 'C0001', first_name: 'BOZZY', last_name: 'CLOWNZY' },
      { chart_number: 'R0001', first_name: 'FRANKY', last_name: 'RIZZY' }
    ]
  end

  let(:chart_numbers) { patients.map { |p| p[:chart_number] } }

  let(:payload) do
    Burner::Payload.new(
      registers: {
        register => patients
      }
    )
  end

  let(:written) { output.outs.first.string }

  subject { described_class.make(config) }

  describe '#perform' do
    before(:each) do
      subject.perform(output, payload)
    end

    it 'updates scoped records with specified attributes' do
      db_patients = Patient.order(:chart_number).where(chart_number: chart_numbers)

      expect(db_patients.count).to eq(2)

      db_patients.each_with_index do |db_patient, index|
        expect(db_patient.chart_number).to eq(patients.dig(index, :chart_number))
        expect(db_patient.first_name).to   eq(patients.dig(index, :first_name))
        expect(db_patient.last_name).to    eq(patients.dig(index, :last_name))
      end
    end

    it 'does not update outside scoped records' do
      db_patients = Patient.order(:chart_number).where.not(chart_number: chart_numbers)

      expect(db_patients.count).to eq(1)

      expect(db_patients.first.chart_number).to eq('B0001')
      expect(db_patients.first.first_name).to   eq('Bugs')
      expect(db_patients.first.last_name).to    eq('Bunny')
    end

    it 'outputs total affect row count' do
      expect(written).to include('Total Rows Affected: 2')
    end

    context 'when debug is true' do
      let(:debug) { true }

      it 'outputs sql statements' do
        expect(written).to include('Update Statement: UPDATE "patients"')
      end

      it 'outputs return objects' do
        expect(written).to include('Individual Rows Affected:')
      end
    end

    context 'when debug is false' do
      it 'does not output does sql statements' do
        expect(written).not_to include('Update Statement: UPDATE "patients"')
      end

      it 'does not output return objects' do
        expect(written).not_to include('Individual Rows Affected:')
      end
    end
  end
end
