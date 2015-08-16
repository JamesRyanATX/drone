require 'spec_helper'

describe Drone::API do
  include Rack::Test::Methods

  describe "status resource" do

    def app
      Drone::API
    end

    before do
      get '/status.json'
    end

    subject { last_response }

    describe "GET /status.json" do
      let(:format) { :png }

      it "responds with an image" do
        expect(subject.status).to eq(200)
        expect(subject.headers['Content-Type']).to eq('application/json')

        response = JSON.parse(subject.body)

        expect(response).to eq({
          'completed' => 0,
          'error' => 0,
          'pending' => 0,
          'processing' => 0,
          'targets' => 0
        })
      end
    end

  end
end
