/* global module */

module.exports = (function () {

  var obj = { name: 'watermark' },
      baseStyle = {
        'position': 'fixed',
        'top': '40%',
        'font-family': 'arial',
        'color': 'rgba(0, 0, 0, 0.1)',
        'font-size': '128px',
        'text-align': 'center',
        'transform': 'rotate(-45deg)',
        'transform-origin': '50% 50%',
        'width': '100%'
      };


  obj.isEnabled = function () {
    return !!this.recipe.watermark.text;
  };

  obj.enable = function (callback) {
    this.inject.tag({
      tag: 'div',
      style: baseStyle,
      text: this.recipe.watermark.text,
      styleOverride: this.recipe.watermark.style
    }, callback);
  };

  obj.disable = function (callback) {
    callback();
  };

  obj.summary = function () {
    return JSON.stringify({ watermark: this.recipe.watermark });
  };

  return {
    install: function (ns) {
      obj.ns = ns;

      ns.Recipe.prototype.features.beforeRender.push(obj);

      return obj;
    }
  };

})();