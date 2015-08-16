/* global module */

module.exports = (function () {

  var formatMap = {
        A3:      { dpi: 72, width: 11.7, height: 16.5 },
        A4:      { dpi: 72, width:  8.3, height: 11.7 },
        A5:      { dpi: 72, width:  5.8, height:  8.3 },
        Letter:  { dpi: 72, width:  8.5, height: 11.0 },
        Legal:   { dpi: 72, width:  8.5, height: 14.0 },
        Tabloid: { dpi: 72, width: 11.0, height: 17.0 },
      },
      defaultPaperSize = {
        format: 'Letter',
        margin: 0.5
      },

      // DPI bug in PhantomJS
      dpiBase = 142,
      dpiCorrectionCoefficient = 1,

      obj = { name: 'paper_size' };

  obj.introspectedPaper = function () {
    var paper = this.recipe.paper,
        format = paper.format || defaultPaperSize.format;

    return {
      width: obj.width.call(this, paper.width, format)    + 'in',
      height: obj.height.call(this, paper.height, format) + 'in',
      margin: (paper.margin || defaultPaperSize.margin)   + 'in',
      dpi: this.page.settings.dpi
    };
  };

  obj.isEnabled = function () {
    return this.recipe.output.format == 'pdf';
  };

  obj.width = function (width, format) {
    return obj.adjustedDimension.call(this, width || formatMap[format].width);
  };

  obj.height = function (height, format) {
    return obj.adjustedDimension.call(this, height || formatMap[format].height);
  };

  obj.adjustedDimension = function (value) {
    return value;//(Number(value) / dpiCorrectionCoefficient);
  };

  obj.enable = function (callback) {
    var paper = obj.introspectedPaper.call(this);

    // Adjust zoom/scale to account for DPI bug
    if (dpiCorrectionCoefficient !== 1) {
      this.recipe.inject.css = this.recipe.inject.css || '';
      this.recipe.inject.css += ".report { " +
        "        transform-origin: top center;\n" +
        "-webkit-transform-origin: top center;\n" +
        "-webkit-transform: scale(" + dpiCorrectionCoefficient + ");\n" +
        "        transform: scale(" + dpiCorrectionCoefficient + ");\n" +
      "}";
    }

    this.setPageProperty('paperSize', function (paperSize) {
      paperSize.margin = paper.margin;
      paperSize.dpi = paper.dpi;

      if (paper.format) {
        paperSize.format = paper.format;
      }
      else {
        paperSize.width = (Number(paper.width.replace('in', '')) * dpiBase) + 'px';
        paperSize.height = (Number(paper.height.replace('in', '')) * dpiBase) + 'px';
      }

      return paperSize;
    }.bind(this), {});

    callback();
  };

  obj.disable = function (callback) {
    var paperSize = this.page.paperSize;

    if (paperSize) {
      paperSize.width = paperSize.height = null;
      paperSize.format = defaultPaperSize.format;
    }

    callback();
  };

  obj.summary = function () {
    return JSON.stringify(obj.introspectedPaper.call(this));
  };

  return {
    install: function (ns) {
      obj.ns = ns;

      ns.Recipe.prototype.features.beforeRender.push(obj);

      return obj;
    }
  };

})();