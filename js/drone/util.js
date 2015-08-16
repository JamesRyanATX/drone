/* global module */

module.exports = (function () {

  var obj = {};

  // Logging in a specific format
  obj.log = function (severity, message) {
    console.log('drone.' + severity + ': ' + message);
  };

  // Function#bind polyfill
  obj.applyPolyfills = function () {
    if (typeof Function.prototype.bind == 'undefined') {
      Function.prototype.bind = function (target) {
        var f = this;
        return function () {
          f.apply(target, arguments);
        };
      };
    }
  };

  // Merge two objects together
  obj.merge = function (target, source) {
    Object.keys(source).forEach(function (key) {
      if (typeof target[key] === 'undefined') {
        target[key] = source[key];
      }
    });

    return target;
  };

  // *cough* phantomjs bind *cough*
  obj.applyPolyfills();

  return {
    install: function (ns) {
      obj.ns = ns;

      return obj;
    }
  };

})();