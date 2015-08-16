require 'spec_helper'

describe Drone::Phantom do
  let(:recipes) { Drone::Recipe.all.map(&:to_hash) }
  let(:url) { 'about:blank' }
  let(:target) { Drone::Target.from_url(url).transient }
  let(:output) { '/dev/null' }
  let(:options) { { recipes: recipes, test: 'a b c d e f' } }

  subject { Drone::Phantom.new(target, output, options) }

  describe "#phantomjs_command" do

    it "builds a command with encoded options" do
      command_parts = subject.send(:phantomjs_command, options).split(' ')

      expect(command_parts.shift).to eq(Drone.config[:phantomjs_path])

      expect(command_parts.shift).to eq("--ignore-ssl-errors=true")
      expect(command_parts.shift).to eq("--disk-cache=false")
      expect(command_parts.shift).to eq("--load-images=true")
      expect(command_parts.shift).to eq("--local-to-remote-url-access=true")

      expect(command_parts.shift).to eq(Drone.config[:capturejs_path])
      expect(File.exists?(command_parts.shift)).to eq(true)

      expect(command_parts.shift).to eq('2>&1')
    end
  end
end