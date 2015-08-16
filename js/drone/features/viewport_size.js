/* global module */

module.exports = (function () {

  var obj = { name: 'viewport_size' };

  obj.isEnabled = function () {
    return this.recipe.viewport.width && this.recipe.viewport.height;
  };

  obj.enable = function (callback) {
    var viewport = this.recipe.viewport;

    this.setPageProperty('viewportSize', function (viewportSize) {
      viewportSize.width = viewport.width;
      viewportSize.height = viewport.height;

      return viewportSize;
    }.bind(this), { width: null, height: null });

    callback();
  };

  obj.disable = function (callback) {
    this.page.viewportSize = null;
    callback();
  };

  obj.summary = function () {
    return JSON.stringify({ viewport: this.recipe.viewport });
  };

  return {
    install: function (ns) {
      obj.ns = ns;

      ns.Recipe.prototype.features.beforeLoad.push(obj);

      return obj;
    }
  };

})();