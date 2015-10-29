/* global module, log, require */

module.exports = (function () {

  var spawn = require('child_process').spawn,
      obj = { name: 'output_quality' },
      defaultQuality = 50;

  obj.isEnabled = function () {
    return this.recipe.output.format == 'png' && this.recipe.output.quality;
  };

  obj.enable = function (callback) {
    this.recipe.output.quality = obj.quality.call(this);

    callback();
  };

  obj.disable = obj.enable;

  obj.quality = function () {
    return this.recipe.output.quality || defaultQuality;
  };

  obj.summary = function () {
    return JSON.stringify({
      quality: obj.quality.call(this)
    });
  };

  return {
    install: function (ns) {
      obj.ns = ns;

      ns.Recipe.prototype.features.beforeRender.push(obj);

      return obj;
    }
  };

})();