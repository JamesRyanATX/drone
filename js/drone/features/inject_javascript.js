/* global module */

module.exports = (function () {

  var obj = { name: 'inject_javascript' };

  obj.isEnabled = function () {
    return this.recipe.inject.javascript;
  };

  obj.enable = function (callback) {
    this.inject.javascript(this.recipe.inject.javascript, callback);
  };

  obj.disable = function (callback) {
    callback();
  };

  obj.summary = function () {
    return JSON.stringify({ javascript: this.recipe.inject.javascript });
  };

  return {
    install: function (ns) {
      obj.ns = ns;

      ns.Recipe.prototype.features.beforeRender.push(obj);

      return obj;
    }
  };

})();