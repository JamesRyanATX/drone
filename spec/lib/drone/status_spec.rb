require 'spec_helper'

describe Drone::Status do

  subject { Drone::Status.new }

  before { subject.reset }

  describe "#log_error" do
    before do
      5.times { |i| subject.log_capture(i) }
      2.times { |i| subject.log_error }
    end

    it "increments the error count" do
      expect(subject.error_count).to eq(2)
    end

    it "enables error rate calculation" do
      expect(subject.error_rate).to eq(0.4)
    end
  end

  describe "#log_capture" do
    before do
      subject.log_capture(1.0)
      subject.log_capture(2.0)
      subject.log_capture(5.0)
    end

    it "increments the capture count" do
      expect(subject.capture_count).to eq(3)
    end

    it "enables capture average calculation" do
      expect(subject.capture_average).to eq(2.67)
    end

    it "enables captures/second rate calculation" do
      expect(subject.capture_rate).to eq(0.37)
    end
  end

  describe "#all" do
    context "with no capture data" do
      it "contains empty metrics" do
        expect(subject.all).to eq({
          capture_average: 0.0,
          capture_count: 0,
          capture_rate: 0.0,
          error_count: 0,
          error_rate: 0.0,
          target_count: 0
        })
      end
    end

    context "with capture data" do

      before do
      end

      it "contains non-empty metrics" do
        expect(subject.all).to eq({
          capture_average: 0.0,
          capture_count: 0,
          capture_rate: 0.0,
          error_count: 0,
          error_rate: 0.0,
          target_count: 0
        })
      end
    end
  end

end