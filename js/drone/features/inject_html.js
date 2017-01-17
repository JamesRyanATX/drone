/* global module */

module.exports = (function () {

  var obj = { name: 'inject_html' };

  obj.isEnabled = function () {
    return this.recipe.inject.html;
  };

  obj.enable = function (callback) {
    this.inject.html(this.recipe.inject.html, callback);
//    this.appendElement({
//      tag: 'div',
//      text: this.recipe.inject.html
//    }, callback);
  };

  obj.disable = function (callback) {
    callback();
  };

  obj.summary = function () {
    return JSON.stringify({ html: this.recipe.inject.html });
  };

  return {
    install: function (ns) {
      obj.ns = ns;

      ns.Recipe.prototype.features.beforeRender.push(obj);

      return obj;
    }
  };

})();