/* global module, phantom */

module.exports = (function () {

  var obj = { name: 'paper_footer' },
      template = '<div style="font-family: muli, helvetica, arial, sans-serif">' +
        '<span style="float: right">Page ${pageNum} of ${numPages}</span>' +
        '<strong>${text}</strong>',
      baseStyle = {
        'border-top': '1px solid #ccc',
        'color': '#555',
        'font-family': 'arial',
        'font-size': '10pt',
        'padding-top': '0.5rem'
      };

  obj.isEnabled = function () {
    return this.recipe.output.format == 'pdf' && this.recipe.paper.footer.text;
  };

  obj.enable = function (callback) {
    var footer = this.recipe.paper.footer;

    this.setPageProperty('paperSize', function (paperSize) {
      paperSize.footer = {
        height: '1in',
        contents: phantom.callback(function(pageNum, numPages) {
          return this.inject.tagFactory('div', {
            css: baseStyle,
            style: footer.style,
            html: template
              .replace('${pageNum}', pageNum)
              .replace('${numPages}', numPages)
              .replace('${text}', footer.text)
          });
        }.bind(this))
      };

      return paperSize;
    }.bind(this), {});

    callback();
  };

  obj.disable = function (callback) {
    this.page.paperSize.header = null;
    callback();
  };

  obj.summary = function () {
    return JSON.stringify({
      text: this.recipe.paper.footer.text,
      style: this.recipe.paper.footer.style
    });
  };

  return {
    install: function (ns) {
      obj.ns = ns;

      ns.Recipe.prototype.features.beforeRender.push(obj);

      return obj;
    }
  };

})();