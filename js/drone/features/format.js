/* global module */

module.exports = (function () {

  var obj = { name: 'format' };

  obj.isEnabled = function () {
    return true;
  };

  obj.enable = function (callback) {
    callback();
  };

  obj.disable = function (callback) {
    callback();
  };

  obj.summary = function () {
    return JSON.stringify({ format: this.recipe.output.format });
  };

  return {
    install: function (ns) {
      obj.ns = ns;

      ns.Recipe.prototype.features.beforeRender.push(obj);

      return obj;
    }
  };

})();