require 'spec_helper'
require 'fileutils'

describe "application configuration" do

  describe "$stdout.sync" do
    it "is true" do
     expect($stdout.sync).to eq(true)
    end
  end

  describe "$stderr.sync" do
    it "is true" do
     expect($stderr.sync).to eq(true)
    end
  end

  describe Drone.config do

    describe :capture_path do
      it "exists" do
        expect(File.exists?(Drone.config[:capture_path])).to eq(true)
      end
    end

    describe :capturejs_path do
      it "exists" do
        expect(File.exists?(Drone.config[:capturejs_path])).to eq(true)
      end
    end

    describe :cycle_count do
      it "defaults to 1" do
        expect(Drone.config[:cycle_count]).to eq(1)
      end
    end

    describe :environment do
      it "defaults to 'development'" do
        expect(Drone.config[:environment]).to eq('test')
      end
    end

    describe :imagemagick_identify_path do
      it "exists" do
        expect(File.exists?(Drone.config[:imagemagick_identify_path])).to eq(true)
      end
    end

    describe :imagemagick_convert_path do
      it "exists" do
        expect(File.exists?(Drone.config[:imagemagick_convert_path])).to eq(true)
      end
    end

    describe :log_level do
      it "defaults to debug" do
        expect(Drone.config[:log_level]).to eq(Logger::DEBUG)
      end
    end

    describe :log_device do
      it "defaults to STDOUT" do
        expect(Drone.config[:log_device]).to eq(STDOUT)
      end
    end

    describe :min_capture_interval do
      it "defaults to 1 hour" do
        expect(Drone.config[:min_capture_interval]).to eq(60 * 60)
      end
    end

    describe :params do
      it "contains 'test.test_proc_param'" do
        expect(Drone.config[:params]['test.test_proc_param']).to be_kind_of(Proc)
      end
    end

    describe :phantomjs_path do
      it "exists" do
        expect(File.exists?(Drone.config[:phantomjs_path])).to eq(true)
      end
    end

    describe :recipes do
      it "contains :thumbnail recipe" do
        expect(Drone.config[:recipes][:thumbnail]).to be_kind_of(Hash)
      end
    end

    describe :redis_key_prefix do
      it "defaults to 'drone-'" do
        expect(Drone.config[:redis_key_prefix]).to eq('drone-test-')
      end
    end

    describe :thread_count do
      it "defaults to nil" do
        expect(Drone.config[:thread_count]).to eq(nil)
      end
    end

  end
end