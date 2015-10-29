/* global module, log, require */

module.exports = (function () {

  var spawn = require('child_process').spawn,
      obj = { name: 'retina' },
      defaultValue = false;

  obj.isEnabled = function () {
    return this.recipe.output.format == 'png';
  };

  // Simulate a retina display
  obj.enable = function (callback) {
    var zoomFactor = obj.pixelRatio.call(this),
        viewportSize = obj.adjustedViewportSize.call(this);

    // Update recipe
    this.recipe.viewport = viewportSize;
    this.recipe.zoom = zoomFactor;

    // Update page properties
    this.setPageProperty('viewportSize', function () { return viewportSize; }.bind(this));
    this.setPageProperty('zoomFactor', function () { return zoomFactor; }.bind(this));

    callback();
  };

  obj.disable = function (callback) {
    callback();
  };

  obj.pixelRatio = function () {
    return (obj.isEnabled.call(this)) ? 2 : 1;
  }

  obj.adjustedViewportSize = function () {
    var pixelRatio = obj.pixelRatio.call(this);

    return {
      height: this.recipe.viewport.height * pixelRatio,
      width: this.recipe.viewport.width * pixelRatio
    }
  };

  obj.adjustedZoomFactor = function () {
    return obj.pixelRatio.call(this);
  };

  obj.summary = function () {
    return JSON.stringify({ pixelRatio: obj.pixelRatio.call(this) });
  };

  return {
    install: function (ns) {
      obj.ns = ns;

      ns.Recipe.prototype.features.beforeLoad.push(obj);

      return obj;
    }
  };

})();