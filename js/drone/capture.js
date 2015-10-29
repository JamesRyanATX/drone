/* global module */

module.exports = (function () {

  var obj;

  obj = function (options, callback) {
    this.callback = callback;
    this.options = obj.ns.Util.merge({
      failsafeTimeout: 45000,
      height: 768,
      pollInterval: 1000,
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