/* global module, phantom */

module.exports = (function () {

  var obj = { name: 'paper_header' },
      template = '<span style="float: right; font-size: 10pt">Page ${pageNum} of ${numPages}</span>' +
        '<div style="font-size: 18pt; font-weight: bold; padding-bottom: 7px">${title}</div>' +
        '<div style="padding-bottom: 10px">${subtitle}</div>',
      baseStyle = {
        'border-bottom': '1px solid #555',
        'color': '#555',
        'font-family': 'arial',
        'font-size': '12pt',
        'padding-bottom': '0.5rem'
      };

  obj.isEnabled = function () {
    return this.recipe.output.format == 'pdf' && this.recipe.paper.header.title && this.recipe.paper.header.subtitle;
  };

  obj.enable = function (callback) {
    var header = this.recipe.paper.header;

    this.setPageProperty('paperSize', function (paperSize) {
      paperSize.header = {
        height: '3cm',
        contents: phantom.callback(function(pageNum, numPages) {
          return this.inject.tagFactory('div', {
            css: baseStyle,
            style: header.style,
            html: template
              .replace('${pageNum}', pageNum)
              .replace('${numPages}', numPages)
              .replace('${title}', header.title)
              .replace('${subtitle}', header.subtitle)
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
    var header = this.recipe.paper.header;

    return JSON.stringify({
      title: header.title,
      subtitle: header.subtitle,
      style: header.style
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