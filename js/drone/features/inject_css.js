/* global module */

module.exports = (function () {

  var obj = { name: 'inject_css' };
//      testCss = '' +
//        "html { height: auto; }\n" +
//        "body { height: auto; background: red !important; }\n" +
//        "div.workspace { display: block; height: auto; position: static; }\n";


  obj.isEnabled = function () {
    return !!this.recipe.inject.css;
  };

  obj.enable = function (callback) {
    this.inject.css(this.recipe.inject.css, callback);
  };

  obj.disable = function (callback) {
    callback();
  };

  obj.summary = function () {
    return JSON.stringify({ css: this.recipe.inject.css });
  };

  return {
    install: function (ns) {
      obj.ns = ns;

      ns.Recipe.prototype.features.beforeRender.push(obj);

      return obj;
    }
  };

})();