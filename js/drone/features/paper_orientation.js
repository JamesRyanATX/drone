/* global module */

module.exports = (function () {

  var obj = { name: 'paper_orientation' },
      dpiByOrientation = {
        landscape: 107,
        portrait: 142
      };

  obj.isEnabled = function () {
    return (this.recipe.output.format == 'pdf' && this.recipe.paper.orientation === 'landscape');
  };

  obj.enable = function (callback) {
    var adjustedPageSize = obj.adjustedPaperSize.call(this);

    this.setPageProperty('paperSize', function (paperSize) {
      paperSize.orientation = adjustedPageSize.orientation;
      paperSize.height = adjustedPageSize.height;
      paperSize.width = adjustedPageSize.width;

      return paperSize;
    }.bind(this), {});

    callback();
  };

  obj.disable = obj.enable;

  obj.orientation = function () {
    return (obj.isEnabled.call(this)) ? this.recipe.paper.orientation : 'portrait';
  };

  obj.adjustedPaperSize = function () {
    var paperSize = this.page.paperSize,
        orientation = obj.orientation.call(this),
        reverse = (orientation === 'landscape'),
        height = (reverse) ? paperSize.width : paperSize.height,
        width = (reverse) ? paperSize.height : paperSize.width,
        dpi = dpiByOrientation[orientation];

    return {
      orientation: orientation,
      width: obj.inchesToPixels.call(this, width, dpi),
      height: obj.inchesToPixels.call(this, height, dpi),
      margin: obj.inchesToPixels.call(this, paperSize.margin, dpi),
      dpi: dpi
    };
  };

  obj.inchesToPixels = function (value, dpi) {
    return (Number((value || '').replace('in', '')) * dpi) + 'px';
  };

  obj.summary = function () {
    return JSON.stringify(obj.adjustedPaperSize.call(this));
  };

  return {
    install: function (ns) {
      obj.ns = ns;

      ns.Recipe.prototype.features.beforeRender.push(obj);

      return obj;
    }
  };

})();