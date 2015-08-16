require 'spec_helper'

describe Drone::API do
  include Rack::Test::Methods

  describe "targets resource" do

    let(:target_without_id) do
      target = Drone::Target.from_url('http://www.google.com/')
      target.save
    end

    let(:target_with_id) do
      target = Drone::Target.from_url('http://www.dasheroo.com/', {
        id: 'bananas',
        url: 'http://www.dasheroo.com/'
      })
      target.save
    end

    let(:path) { nil }
    let(:method) { 'get' }
    let(:post_data) { nil }

    def app
      Drone::API
    end

    before do
      Drone::Target.reset({ queues: %w( pending completed processing error ) })

      target_without_id.save
      target_with_id.save

      self.send(method.to_sym, path, post_data)
    end

    subject { last_response }

    describe "GET /" do
      let(:path) { '/' }

      it "redirects to /targets.html" do
        expect(subject.status).to eq(302)
        expect(subject.headers['Location']).to eq('/targets.html')
      end
    end

    describe "GET /targets.html" do
      let(:path) { '/targets.html' }

      it "returns an html page" do
        expect(subject.status).to eq(200)
        expect(subject.headers['Content-Type']).to eq('text/html')
      end
    end

    describe "GET /targets.json" do
      let(:path) { '/targets.json' }

      it "returns an array" do
        expect(subject.status).to eq(200)
        expect(subject.headers['Content-Type']).to eq('application/json')
        expect(JSON.parse(subject.body).length).to eq(2)
      end
    end

    describe "GET /targets/:target_id.json" do
      let(:path) { "/targets/#{target_with_id.id}.json" }

      it "returns an array" do
        expect(subject.status).to eq(200)
        expect(subject.headers['Content-Type']).to eq('application/json')

        response = JSON.parse(subject.body)

        expect(response['url']).to eq('http://www.dasheroo.com/')
        expect(response['id']).to eq('bananas')
      end
    end

    describe "GET /targets/:target_id.png" do
      let(:path) { "/targets/#{target_with_id.id}.png?recipe=thumbnail" }

      it "returns an array" do
        expect(subject.status).to eq(404)
        expect(subject.headers['Content-Type']).to eq('image/png')
      end
    end

    describe "GET /targets/:target_id.pdf" do
      let(:path) { "/targets/#{target_with_id.id}.pdf?recipe=thumbnail" }

      it "returns an array" do
        expect(subject.status).to eq(404)
        expect(subject.headers['Content-Type']).to eq('application/pdf')
      end
    end

    describe "POST /targets.json" do
      let(:method) { 'post' }
      let(:path) { '/targets.json' }
      let(:post_data) { { url: 'http://www.google2.com' } }

      it "returns a new target" do
        expect(subject.status).to eq(201)
        expect(subject.headers['Content-Type']).to eq('application/json')

        response = JSON.parse(subject.body)

        expect(response['id']).to eq('ebc49705')
        expect(response['url']).to eq('http://www.google2.com')
      end
    end

    describe "PUT /targets/:target_id.json" do
      let(:method) { 'put' }
      let(:path) { "/targets/#{target_with_id.id}.json" }
      let(:post_data) { { url: 'http://fake.com/foo' } }

      it "returns a saved target" do
        expect(subject.status).to eq(200)
        expect(subject.headers['Content-Type']).to eq('application/json')

        response = JSON.parse(subject.body)

        expect(response['id']).to eq(target_with_id.id)
        expect(response['url']).to eq('http://fake.com/foo')
      end
    end

    describe "DELETE /targets/:target_id.json" do
      let(:method) { 'delete' }
      let(:path) { "/targets/#{target_with_id.id}.json" }

      it "returns a saved target" do
        expect(subject.status).to eq(200)
        expect(subject.headers['Content-Type']).to eq('application/json')

        response = JSON.parse(subject.body)

        expect(response['result']).to eq(true)
      end
    end

  end
end