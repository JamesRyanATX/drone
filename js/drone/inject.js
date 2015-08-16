/* global module, log */

module.exports = (function () {

  var obj;

  obj = function (recipe) {
    this.recipe = recipe;
    this.queue = {
      css: [],
      html: [],
      javascript: [],
      tags: []
    };
  };

  obj.prototype = {
    jqueryUrl: 'https://ajax.googleapis.com/ajax/libs/jquery/2.1.4/jquery.min.js',

    css: function (content, callback) {
      this.enqueue('css', content, callback);
    },

    html: function (content, callback) {
      this.enqueue('html', content, callback);
    },

    javascript: function (content, callback) {
      this.enqueue('javascript', content, callback);
    },

    tag: function (properties, callback) {
      this.enqueue('tags', properties, callback);
    },


    /* internals */

    enqueue: function (type, content, callback) {
      this.queue[type].push(content);
      callback();
    },

    write: function (callback) {
      this.writeCSS(function () {
        this.writeHTML(function () {
          this.writeTags(function () {
            this.writeJavaScript(callback);
          }.bind(this));
        }.bind(this));
      }.bind(this));
    },

    writeCSS: function (callback) {
      var content;

      if (this.queue.css.length === 0) {
        return callback();
      }
      else {
        content = this.queue.css.pop();

        this.appendElement({
          tag: 'style',
          attributes: { type: 'text/css' },
          text: content
        }, function () {
          this.writeCSS(callback);
        }.bind(this));
      }
    },

    writeTags: function (callback) {
      var content;

      if (this.queue.tags.length === 0) {
        return callback();
      }
      else {
        content = this.queue.tags.pop();

        this.appendElement(content, function () {
          this.writeTags(callback);
        }.bind(this));
      }
    },

    writeHTML: function (callback) {
      var content;

      if (this.queue.html.length === 0) {
        return callback();
      }
      else {
        content = this.queue.html.pop();

        this.appendHTML(content, function () {
          this.writeHTML(callback);
        }.bind(this));
      }
    },

    writeJavaScript: function (callback) {
      var content;

      if (this.queue.javascript.length === 0) {
        return callback();
      }
      else {
        content = this.queue.javascript.pop();

        this.appendElement({
          tag: 'script',
          attributes: { type: 'text/javascript' },
          text: content
        }, function () {
          this.writeJavaScript(callback);
        }.bind(this));
      }
    },

    evaluate: function (fn, callback) {
      return this.recipe.evaluate(fn, callback);
    },

    page: function () {
      return this.recipe.page;
    },

    appendHTML: function (html, callback) {
      this.withJquery(function () {
        this.evaluate(function (html) {
          console.log('injecting content: ' + html);
          window.$(document.body).append(html);
        }, html);

        callback();
      }.bind(this));
    },

    appendElement: function (options, callback) {
      this.withJquery(function () {
        this.evaluate(function (options) {
          var $elm = window.$('<' + options.tag + '></' + options.tag + '>', options.attributes),
              style = [];

          // Object styles
          if (options.style) {
            $elm.css(options.style);
          }

          if ($elm.attr('style')) {
            style.push($elm.attr('style'));
          }

          // String styles
          if (options.styleOverride) {
            style.push(options.styleOverride);
          }

          $elm
            .attr('style', style.join('; '))
            .html(options.text)
            .appendTo(window.$(document.body));
        }, options);

        callback();
      }.bind(this));
    },

    withJquery: function (callback) {
      if (this.jquery) {
        callback();
      }
      else {
        this.page().includeJs(this.jqueryUrl, callback);
      }

      this.jquery = true;
    },

    cssObjectToString: function (obj, toAppend) {
      return Object.keys(obj)
        .map(function (k) { return k + ': ' + obj[k]; }).join('; ') +
        ((toAppend) ? '; ' + toAppend : '');
    },

    tagFactory: function (tag, properties) {
      var style = this.cssObjectToString(properties.css, properties.style),
          openHTML = '<' + tag + ' style="' + style + '">',
          contentHTML = properties.html,
          closeHTML = '</' + tag + '>';

      return openHTML + contentHTML + closeHTML;
    },

  };

  return {
    install: function (ns) {
      obj.ns = ns;

      return obj;
    }
  };

})();