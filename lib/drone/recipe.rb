class Drone::Recipe

  DEFAULT_VIEWPORT_WIDTH = 1150
  DEFAULT_VIEWPORT_HEIGHT = 768

  DEFAULT_PAPER_FORMAT = 'Letter'
  DEFAULT_PAPER_WIDTH = nil
  DEFAULT_PAPER_HEIGHT = nil
  DEFAULT_PAPER_ORIENTATION = 'portrait'
  DEFAULT_PAPER_MARGIN = 2

  DEFAULT_OUTPUT_FILENAME = 'capture'
  DEFAULT_OUTPUT_FORMAT = 'png'

  DEFAULT_ZOOM = 1

  attr_accessor :recipe

  def initialize(recipe = {})
    self.recipe = recipe
  end

  def to_hash
    self.recipe
  end

  def self.all
    Drone.config[:recipes].keys.map { |recipe| self.from_name(recipe) }
  end

  def self.from_name(recipe)
    from_params(Drone.config[:recipes][recipe].merge({
      name: recipe
    }))
  end

  def self.from_params(params = {})
    params.stringify_keys!

    options = {
      crop: {
        height:      params['crop_height'],
        left:        params['crop_left'],
        selector:    params['crop_selector'],
        top:         params['crop_top'],
        width:       params['crop_width'],
      },
      inject: {
        css:         params['inject_css'],
        javascript:  params['inject_javascript'],
        html:        params['inject_html']
      },
      name:          params['name'],
      output: {
        filename:    params['output_filename'] || DEFAULT_OUTPUT_FILENAME,
        format:      params['output_format'] || DEFAULT_OUTPUT_FORMAT,
        height:      params['output_height'],
        quality:     params['output_quality'],
        width:       params['output_width'],
      },
      paper: {
        format:      params['paper_format'],
        height:      params['paper_height'] || DEFAULT_PAPER_HEIGHT,
        margin:      params['paper_margin'] || DEFAULT_PAPER_MARGIN,
        orientation: params['paper_orientation'] || DEFAULT_PAPER_ORIENTATION,
        width:       params['paper_width'] || DEFAULT_PAPER_WIDTH,
        header: {
          title:      params['paper_header_title'],
          subtitle:   params['paper_header_subtitle'],
          dateRange:  params['paper_header_date_range'],
          logo:       params['paper_header_logo'],
          style:      params['paper_header_style']
        },
        footer: {
          text:      params['paper_footer_text'],
          style:     params['paper_footer_style']
        }
      },
      ready:         params['ready'] || 'success',
      viewport: {
        width:       params['viewport_width'] || DEFAULT_VIEWPORT_WIDTH,
        height:      params['viewport_height'] || DEFAULT_VIEWPORT_HEIGHT
      },
      watermark: {
        text:        params['watermark_text'],
        style:       params['watermark_style']
      },
      zoom:          params['zoom'] || DEFAULT_ZOOM
    }

    self.new(options)
  end

end