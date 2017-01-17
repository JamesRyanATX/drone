require 'spec_helper'

describe Drone::Concerns::Model do

  describe '.attributes' do

    subject do
      model = model_factory

      model.class_eval do
        attributes do |r|
          { foo: :bar }
        end
      end

      model
    end

    it 'creates setters' do
      expect {
        record = subject.new
        record.foo = :baz

        expect(record.foo).to eq(:baz)
      }.to_not raise_exception
    end

    it 'created getters' do
      expect {
        record = subject.new
        record.foo
      }.to_not raise_exception
    end
  end

  def model_factory
    model = Class.new
    model.class_eval { include Drone::Concerns::Model }
    model
  end

end