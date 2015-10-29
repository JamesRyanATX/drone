/* global module */

module.exports = (function () {

  var formatMap = {
        A3:      { width: '11.7in', height: '16.5in', margin: '0.5in' },
        A4:      { width:  '8.3in', height: '11.7in', margin: '0.5in' },
        A5:      { width:  '5.8in', height:  '8.3in', margin: '0.5in' },
        Letter:  { width:  '8.5in', height: '11.0in', margin: '0.5in' },
        Legal:   { width:  '8.5in', height: '14.0in', margin: '0.5in' },
        Tabloid: { width: '11.0in', height: '17.0in', margin: '0.5in' },
      },
      defaultPaperSize = {
        format: 'Letter',
        margin: '0.5in'
      },
      obj = { name: 'paper_size' };

  obj.introspectedPaper = function () {
    var paper = this.recipe.paper,
        format = paper.format || defaultPaperSize.format;

    return {
      height: paper.height || formatMap[format].height,
      margin: paper.margin || formatMap[format].margin,
      width: paper.width || formatMap[format].width
    };
  };

  obj.isEnabled = function () {
    return this.recipe.output.format == 'pdf';
  };

  obj.enable = function (callback) {
    var paper = obj.introspectedPaper.call(this);

    this.setPageProperty('paperSize', function (paperSize) {
      paperSize.height = paper.height;
      paperSize.margin = paper.margin;
      paperSize.width = paper.width;

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