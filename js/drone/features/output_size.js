/* global module, log, require */

module.exports = (function () {

  var spawn = require('child_process').spawn,
      obj = { name: 'output_size' };

  obj.isEnabled = function () {
    return this.recipe.output.height && this.recipe.output.width;
  };

  obj.enable = function (callback) {
    var command = this.capture.options.convert,
        args = [
          this.filename(),
          '-thumbnail',
            this.recipe.output.width + 'x' + this.recipe.output.height + '^',
          '-gravity',
            'center',
          '-extent',
            this.recipe.output.width + 'x' + this.recipe.output.height,
          this.filename()
        ],
        child = spawn(command, args);

    child.on("exit", function (failure) {
      callback(!failure);
    });
  };

  obj.disable = function (callback) {
    callback();
  };

  obj.summary = function () {
    return JSON.stringify({
      width: this.recipe.output.width,
      height: this.recipe.output.height
    });
  };

  return {
    install: function (ns) {
      obj.ns = ns;

      ns.Recipe.prototype.features.afterRender.push(obj);

      return obj;
    }
  };

})();