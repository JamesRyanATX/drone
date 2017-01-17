/* global module */

module.exports = (function () {

  var obj;

  obj = function (options, callback) {
    this.callback = callback;
    this.options = obj.ns.Util.merge({
      height: 768,
      width: 1150
    }, options);

    this.execute();
  };

  obj.prototype = {
    timeouts: {},
    currentPage: null,

    execute: function () {
      new obj.ns.RecipeSequence(this).execute(this.finish.bind(this));
    },

    finish: function (result, message) {
      this.callback(result, message);
    }

  };

  return {
    install: function (ns) {
      obj.ns = ns;

      return obj;
    }
  };

})();