/* global module, phantom */

module.exports = (function () {
  var obj = { name: 'paper_header' },
      template = '<div class="header" style="font-family: muli, helvetica, arial, sans-serif">' +
        '<img class="logo" style="float: right; height: 50px" src="${logo}"></img>' +
        '<div style="font-size: 18pt; font-weight: bold; padding-bottom: 7px">${title}</div>' +
        '<div style="padding-bottom: 10px">${subtitle}</div>' +
        '</div>',
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
    var img = new Image();

    this.setPageProperty('paperSize', function (paperSize) {
      paperSize.header = {
        height: '1.5in',
        contents: phantom.callback(function(pageNum, numPages) {
          return this.inject.tagFactory('div', {
            css: baseStyle,
            style: header.style,
            html: template
              .replace('${pageNum}', pageNum)
              .replace('${numPages}', numPages)
              .replace('${title}', header.title)
              .replace('${subtitle}', header.subtitle)
              .replace('${logo}', header.logo)
          });
        }.bind(this))
      };

      return paperSize;
    }.bind(this), {});

    img.src = header.logo;
    img.onload = function() { callback(); };
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
      logo: header.logo,
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