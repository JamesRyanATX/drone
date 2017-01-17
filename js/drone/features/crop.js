/* global module */

module.exports = (function () {

  var obj = { name: 'crop' };


  obj.isEnabled = function () {
    return this.recipe.crop.width && this.recipe.crop.height;
  };

  obj.enable = function (callback) {
    var crop = this.recipe.crop;

    this.page.clipRect = {
      top: crop.top || 0,
      left: crop.left || 0,
      width: crop.width,
      height: crop.height
    };

    callback();
  };

  obj.disable = function (callback) {
    this.page.clipRect = null;
    callback();
  };

  obj.summary = function () {
    return JSON.stringify({ crop: this.recipe.crop });
  };

  return {
    install: function (ns) {
      obj.ns = ns;

      ns.Recipe.prototype.features.beforeRender.push(obj);

      return obj;
    }
  };

})();