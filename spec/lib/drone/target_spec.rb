require 'spec_helper'
require 'fileutils'

describe Drone::Target do

  let(:target) do
    target = Drone::Target.from_url('http://www.dasheroo.com/', {
      id: 'bananas',
      url: 'http://www.dasheroo.com/'
    })
    target.save
  end

  subject { target }

  shared_examples_for "a valid format" do
    context "when present" do
      let(:captured_path) { subject.captured_path(format, :thumbnail) }

      before { touch_file(captured_path) }
      after { delete_file(captured_path) }

      it "returns the path" do
        expect(subject.send("to_#{format}", :thumbnail)).to eq(captured_path)
      end
    end

    context "when not present" do
      it "returns nil" do
        expect(subject.send("to_#{format}", :thumbnail)).to eq(nil)
      end
    end
  end

  describe "#to_png" do
    let(:format) { :png }

    it_behaves_like "a valid format"
  end

  describe "#to_pdf" do
    let(:format) { :pdf }

    it_behaves_like "a valid format"
  end

  describe ".reset" do
    before do
      target.save
    end

    it "erases targets from redis" do
      expect(Drone::Target.count).to eq(1)
      Drone::Target.reset
      expect(Drone::Target.count).to eq(0)
    end
  end

  def delete_file(path)
    File.delete(path)
  end

  def touch_file(path)
    FileUtils.touch(path)
  end

end