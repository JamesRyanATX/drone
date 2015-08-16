/* global module */

module.exports = (function () {

  var obj = { name: 'paper_orientation' };

  obj.isEnabled = function () {
    return (this.recipe.output.format == 'pdf' && this.recipe.paper.orientation === 'landscape');
  };

  obj.enable = function (callback) {
    this.setPageProperty('paperSize', function (paperSize) {
      paperSize.orientation = this.recipe.paper.orientation;

      return paperSize;
    }.bind(this), {});

    callback();
  };

  obj.disable = function (callback) {
    this.setPageProperty('paperSize', function (paperSize) {
      paperSize.orientation = 'portrait';

      return paperSize;
    }.bind(this), {});

    callback();
  };

  obj.summary = function () {
    return JSON.stringify({ orientation: this.recipe.paper.orientation });
  };

  return {
    install: function (ns) {
      obj.ns = ns;

      ns.Recipe.prototype.features.beforeRender.push(obj);

      return obj;
    }
  };

})();