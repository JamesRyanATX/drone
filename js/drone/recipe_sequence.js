/* global module */

module.exports = (function () {

  var obj;

  obj = function (capture) {
    this.capture = capture;
    this.recipes = [];

    capture.options.recipes.forEach(function (recipe) {
      this.recipes.push(new obj.ns.Recipe(capture, recipe));
    }.bind(this));

    this.sort();
  };

  obj.prototype = {

    execute: function (callback) {
      this.callback = callback;
      this.executeNextRecipe();
    },

    finish: function (result, message) {
      this.callback(result, message);
    },

    executeNextRecipe: function () {
      if (this.recipes.length > 0) {
        this.recipes.pop().execute(function (result, message) {
          if (result) {
            this.executeNextRecipe();
          }
          else {
            this.finish(false, message);
          }
        }.bind(this));
      }
      else {
        this.finish(true);
      }
    },

    sort: function () {
      obj.ns.Util.log('debug', 'recipesequence#sort sorting by viewport not supported yet');
    }

  };

  return {
    install: function (ns) {
      obj.ns = ns;

      return obj;
    }
  };

})();