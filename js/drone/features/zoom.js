/* global module */

module.exports = (function () {

  var obj = { name: 'zoom' };

  obj.isEnabled = function () {
    return this.recipe.zoom != 1;
  };

  obj.enable = function (callback) {
    this.setPageProperty('zoomFactor', function () {
      return this.recipe.zoom || 1;
    }.bind(this), 1);

    callback();
  };

  obj.disable = function (callback) {
    this.setPageProperty('zoomFactor', function () {
      return 1;
    }.bind(this));

    callback();
  };

  obj.summary = function () {
    return JSON.stringify({ zoom: this.recipe.zoom });
  };

  return {
    install: function (ns) {
      obj.ns = ns;

      ns.Recipe.prototype.features.beforeLoad.push(obj);

      return obj;
    }
  };

})();