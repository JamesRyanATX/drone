/* global module, require */

module.exports = (function () {

  return {
    install: function (ns) {
      ns.Util           = require('./drone/util').install(ns);
      ns.Recipe         = require('./drone/recipe').install(ns);
      ns.RecipeSequence = require('./drone/recipe_sequence').install(ns);
      ns.Capture        = require('./drone/capture').install(ns);
      ns.Inject         = require('./drone/inject').install(ns);
      ns.Features       = require('./drone/features').install(ns);

      return ns;
    }
  };

})();
