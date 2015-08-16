require 'spec_helper'

describe Drone::API do
  include Rack::Test::Methods

  before :each do
    FileUtils.rm_r(Dir.glob("#{Drone.config[:tmp_path]}/*.json"))
  end

  describe "capture resource" do
    let(:path) { "/capture.#{format}" }
    let(:format) { nil }

    let(:crop_top)           { nil }
    let(:crop_left)          { nil }
    let(:crop_width)         { nil }
    let(:crop_height)        { nil }
    let(:inject_css)         { nil }
    let(:inject_html)        { nil }
    let(:inject_javascript)  { nil }
    let(:output_format)      { nil }
    let(:output_height)      { nil }
    let(:output_width)       { nil }
    let(:paper_footer_style) { nil }
    let(:paper_footer_text)  { nil }
    let(:paper_format)       { nil }
    let(:paper_header_style) { nil }
    let(:paper_header_title) { nil }
    let(:paper_header_subtitle) { nil }
    let(:paper_height)       { nil }
    let(:paper_orientation)  { nil }
    let(:paper_width)        { nil }
    let(:ready)              { 'mock' }
    let(:url)                { 'about:blank' }
    let(:viewport_width)     { nil }
    let(:viewport_height)    { nil }
    let(:watermark_style)    { nil }
    let(:watermark_text)     { nil }
    let(:zoom)               { nil }

    def app
      Drone::API
    end

    before do
      get path, {
        crop_top: crop_top,
        crop_left: crop_left,
        crop_width: crop_width,
        crop_height: crop_height,
        inject_css: inject_css,
        inject_html: inject_html,
        inject_javascript: inject_javascript,
        output_format: output_format,
        output_height: output_height,
        output_width: output_width,
        paper_footer_style: paper_footer_style,
        paper_footer_text: paper_footer_text,
        paper_format: paper_format,
        paper_header_style: paper_header_style,
        paper_header_subtitle: paper_header_subtitle,
        paper_header_title: paper_header_title,
        paper_height: paper_height,
        paper_orientation: paper_orientation,
        paper_width: paper_width,
        ready: ready,
        url: url,
        viewport_height: viewport_height,
        viewport_width: viewport_width,
        watermark_style: watermark_style,
        watermark_text: watermark_text,
        zoom: zoom
      }
    end

    subject { last_response }

    describe "GET /capture.json" do
      let(:format) { :json }

      shared_examples_for "a valid json response" do
        it "responds with a json package" do
          expect(subject.status).to eq(200)
          expect(subject.headers['Content-Type']).to eq('application/json')
          
          response = nil

          expect { response = JSON.parse(subject.body) }.to_not raise_exception

          expect(response['params'].keys.sort).to eq(%w(
            crop_height
            crop_left
            crop_top
            crop_width
            format
            inject_css
            inject_html
            inject_javascript
            output_format
            output_height
            output_width
            paper_footer_style
            paper_footer_text
            paper_format
            paper_header_style
            paper_header_subtitle
            paper_header_title
            paper_height
            paper_orientation
            paper_width
            ready
            url
            viewport_height
            viewport_width
            watermark_style
            watermark_text
            zoom
          ))

          expect(response['identifier']).to eq('f5be0845')
          expect(response['recipe']['name'].length).to eq(8)
          expect(response['url']).to eq("/targets/f5be0845.#{output_format}?recipe=#{response['recipe']['name']}")

          expect(response['params']['ready']).to eq(ready)
          expect(response['params']['format']).to eq(format.to_s)
          expect(response['params']['url']).to eq(url)
          expect(response['params']['zoom']).to eq(zoom)

          expect(response['params']['output_format']).to eq(output_format)
          expect(response['params']['output_height']).to eq(nil)
          expect(response['params']['output_width']).to eq(nil)

          expect(response['params']['paper_footer_style']).to eq(nil)
          expect(response['params']['paper_footer_text']).to eq(nil)
          expect(response['params']['paper_format']).to eq(nil)
          expect(response['params']['paper_header_style']).to eq(nil)
          expect(response['params']['paper_header_text']).to eq(nil)
          expect(response['params']['paper_height']).to eq(nil)
          expect(response['params']['paper_orientation']).to eq(nil)
          expect(response['params']['paper_width']).to eq(nil)

          expect(response['params']['viewport_height']).to eq(nil)
          expect(response['params']['viewport_width']).to eq(nil)
        end
      end

      describe "output_format = 'png'" do
        let(:output_format) { 'png' }

        it_behaves_like "a valid json response"
      end

      describe "output_format = 'pdf'" do
        let(:output_format) { 'pdf' }

        it_behaves_like "a valid json response"
      end
    end

    describe "GET /capture.png" do
      let(:format) { :png }
      let(:output_format) { :png }

      shared_examples_for "a png capture" do
        it "responds with a png file" do
          expect(subject.status).to eq(200)
          expect(subject.headers['Content-Type']).to eq('image/png')
        end
      end

      context "defaults" do
        it_behaves_like "a png capture"
      end

      context ":crop_top, :crop_left, :crop_width and :crop_height parameters" do
        let(:crop_top) { 0 }
        let(:crop_left) { 0 }
        let(:crop_width) { 123 }
        let(:crop_height) { 456 }

        it "passes phantomjs the correct options" do
          recipe = captured_asset_options_recipe(subject)

          expect(recipe['crop']['top']).to eq('0')
          expect(recipe['crop']['left']).to eq('0')
          expect(recipe['crop']['width']).to eq('123')
          expect(recipe['crop']['height']).to eq('456')
        end

        it "sets correct dimensions" do
          asset = captured_asset_properties(subject)

          expect(asset[:width]).to eq(123)
          expect(asset[:height]).to eq(456)
        end

        it_behaves_like "a png capture"
      end

      context ":inject_css parameter" do
        let(:inject_css) { 'body { color: red; }' }

        it "passes phantomjs the correct options" do
          recipe = captured_asset_options_recipe(subject)

          expect(recipe['inject']['css']).to eq('body { color: red; }')
        end

        it_behaves_like "a png capture"
      end

      context ":inject_html parameter" do
        let(:inject_html) { 'ORLY?' }

        it "passes phantomjs the correct options" do
          recipe = captured_asset_options_recipe(subject)

          expect(recipe['inject']['html']).to eq('ORLY?')
        end

        it_behaves_like "a png capture"
      end

      context ":inject_javascript parameter" do
        let(:inject_javascript) { 'alert("ORLY?")' }

        it "passes phantomjs the correct options" do
          recipe = captured_asset_options_recipe(subject)

          expect(recipe['inject']['javascript']).to eq('alert("ORLY?")')
        end

        it_behaves_like "a png capture"
      end

      context ":output_height and :output_width parameters" do
        let(:output_width) { 100 }
        let(:output_height) { 200 }

        it "passes phantomjs the correct options" do
          recipe = captured_asset_options_recipe(subject)

          expect(recipe['output']['width']).to eq('100')
          expect(recipe['output']['height']).to eq('200')
        end

        it "sets correct dimensions" do
          asset = captured_asset_properties(subject)

          expect(asset[:width]).to eq(100)
          expect(asset[:height]).to eq(200)
        end

        it_behaves_like "a png capture"
      end

      context ":ready parameter" do
        let(:ready) { "mock" }

        it "passes phantomjs the correct options" do
          recipe = captured_asset_options_recipe(subject)

          expect(recipe['ready']).to eq('mock')
        end

        it_behaves_like "a png capture"
      end

      context ":viewport_width and :viewport_height parameter" do
        let(:viewport_width) { 999 }
        let(:viewport_height) { 888 }

        it "passes phantomjs the correct options" do
          recipe = captured_asset_options_recipe(subject)

          expect(recipe['viewport']['width']).to eq('999')
          expect(recipe['viewport']['height']).to eq('888')
        end

        it_behaves_like "a png capture"
      end

      context ":watermark_text and :watermark_style parameters" do
        let(:watermark_text) { 'Dasheroo' }
        let(:watermark_style) { 'color: red' }

        it "passes phantomjs the correct options" do
          recipe = captured_asset_options_recipe(subject)

          expect(recipe['watermark']['text']).to eq('Dasheroo')
          expect(recipe['watermark']['style']).to eq('color: red')
        end

        it_behaves_like "a png capture"
      end

      context ":zoom parameter" do
        let(:zoom) { 0.5 }

        it "passes phantomjs the correct options" do
          recipe = captured_asset_options_recipe(subject)

          expect(recipe['zoom']).to eq('0.5')
        end

        it_behaves_like "a png capture"
      end

      context "javascript error" do
        let(:url) { 'file:///' + File.join(Drone::ROOT, 'spec/fixtures/test.html') }

        it_behaves_like "a png capture"
      end
    end

    describe "GET /capture.pdf" do
      let(:url) { 'file:///' + File.join(Drone::ROOT, 'spec/fixtures/print.html') }
      let(:format) { :pdf }
      let(:output_format) { :pdf }

      shared_examples_for "a pdf capture" do
        it "responds with a pdf file" do
          expect(subject.status).to eq(200)
          expect(subject.headers['Content-Type']).to eq('application/pdf')
        end
      end

      context "defaults" do
        it_behaves_like "a pdf capture"
      end

      context ":paper_width and :paper_height parameters" do
        let(:paper_width) { '5in' }
        let(:paper_height) { '5in' }

        it "passes phantomjs the correct options" do
          recipe = captured_asset_options_recipe(subject)

          expect(recipe['paper']['width']).to eq('5in')
          expect(recipe['paper']['height']).to eq('5in')
        end

        it_behaves_like "a pdf capture"
      end

      context ":paper_format parameter" do
        let(:paper_format) { 'Tabloid' }

        it "passes phantomjs the correct options" do
          recipe = captured_asset_options_recipe(subject)

          expect(recipe['paper']['format']).to eq('Tabloid')
        end

        it_behaves_like "a pdf capture"
      end

      context ":paper_orientation parameter" do
        let(:paper_orientation) { 'landscape' }

        it "passes phantomjs the correct options" do
          recipe = captured_asset_options_recipe(subject)

          expect(recipe['paper']['orientation']).to eq('landscape')
        end

        it_behaves_like "a pdf capture"
      end

      context ":paper_header_* and :paper_footer_* parameters" do
        let(:paper_header_title) { 'Apples' }
        let(:paper_header_subtitle) { 'Pears' }
        let(:paper_header_style) { 'text-transform: uppercase;' }
        let(:paper_footer_text) { 'Oranges' }
        let(:paper_footer_style) { 'text-transform: uppercase;' }

        it "passes phantomjs the correct options" do
          recipe = captured_asset_options_recipe(subject)

          expect(recipe['paper']['header']['title']).to eq('Apples')
          expect(recipe['paper']['header']['subtitle']).to eq('Pears')
          expect(recipe['paper']['header']['style']).to eq('text-transform: uppercase;')

          expect(recipe['paper']['footer']['text']).to eq('Oranges')
          expect(recipe['paper']['footer']['style']).to eq('text-transform: uppercase;')
        end

        it_behaves_like "a pdf capture"
      end
    end

  end

  def captured_asset_options(response)
    files = Dir.glob("#{Drone.config[:tmp_path]}/*.json", 0)

    if files.length != 1
      raise "Unexpected number of capture configuration files.  Perhaps a spec is not cleaning up after itself?"
    end

    JSON.parse(File.read(files.first))
  end

  def captured_asset_options_recipe(response)
    captured_asset_options(response)['recipes'].first
  end

  def captured_asset_properties(response)
    tmp_asset = File.join('tmp', "captured_asset")

    File.open(tmp_asset, "w") { |f| f.write(response.body) }

    properties =  `#{Drone.config[:imagemagick_identify_path]} #{tmp_asset}`.split(' ')

    format = properties[1].downcase
    dimensions = properties[2].split('x')

    {
      format: format,
      width: dimensions[0].to_i,
      height: dimensions[1].to_i
    }
  end
end
