/* global module, drone, WebPage, log */

module.exports = (function () {

  var obj;


  obj = function (capture, recipe) {
    this.capture = capture;
    this.options = capture.options;
    this.recipe = recipe;

    this.inject = new obj.ns.Inject(this);
  };

  obj.prototype = {
    pollCount: 0,
    timeouts: {},
    features: {
      beforeLoad: [],
      afterRender: [],
      beforeRender: [],
    },

    // Various strategies that determine readiness for capture (chosen via this.options.ready)
    ready: {

      // Rely on window.drone.ready = true
      drone: function () {
        return this.page.evaluate(function () {
          if (typeof drone !== 'undefined' && drone.ready) {

            // Reset for next viewport adjustment
            drone.ready = false;
    
            return true;
          }
          else {
            return false;
          }
        });
      },

      // For faster specs
      mock: function () {
        return true;
      },

      // Rely on factory phantomjs "success" status
      success: function () {
        return this.page.status === 'success';
      }
    },

    execute: function (callback) {
      var startTime = Date.now();

      this.callback = callback;
      this.prepare();

      this.applyFeatures('beforeLoad', function () {
        log('debug', '-> url: ' + this.capture.options.url);

        this.page.open(this.capture.options.url, function (status) {
          if (status !== 'success') {
            log('error', '=> recipe#execute load failed; status=' + status + ' time=' + (Date.now() - startTime) + 'ms');
            this.finish(false);
          }
        }.bind(this));

        this.startTimers();
      }.bind(this));
    },

    startTimers: function () {
      log('debug', '-> ready: ' + this.options.ready);

      this.startPollTimer();
      this.startFailsafeTimer();
    },

    finish: function (result, message) {
      if (result) {
        log('success', '✔ wrote ' + this.filename());
      }
      else {
        log('error', '✘ failed to write ' + this.filename());
      }

      this.clean();
      this.callback(result, message);
    },

    startFailsafeTimer: function () {
      this.timeouts.failsafe = window.setTimeout(this.failsafe.bind(this), this.options.max_capture_time * 1000);
    },

    startPollTimer: function () {
      var ready = this.ready[this.options.ready].call(this);

      this.pollCount++;

      if (ready) {
        log('debug', '.. ready for capture in ' + this.pollCount + ' tries');
        window.setTimeout(this.render.bind(this), 2000);
      }
      else {
        log('debug', '.. ready check #' + this.pollCount);
        this.timeouts.poll = window.setTimeout(this.startPollTimer.bind(this), (this.options.poll_capture_interval * 1000));
      }
    },

    applyFeatures: function (featureType, callback) {
      var features = this.features[featureType].concat(),
          noop = function () { },
          nextFeature;

      log('debug', '-> applying ' + featureType + ' features');

      nextFeature = function () {
        var feature = features.shift(),
            enabled = (feature) ? feature.isEnabled.call(this) : false,
            summary = (feature) ? feature.summary.call(this) : null;

        // No more features; continue onward
        if (!feature) {
          return callback(true);
        }

        log('debug', '.. ' +
          ((enabled) ? '✔' : '✘') + ' ' + feature.name + ': ' + summary);
        
        if (enabled) {
          (feature.enable || noop).call(this, nextFeature);
        }
        else {
          (feature.disable || noop).call(this, nextFeature);          
        }
      }.bind(this);

      nextFeature();
    },

    render: function () {
      this.applyFeatures('beforeRender', function () {
        this.inject.write(function () {
          log('debug', '-> rendering ' + this.recipe.output.format);

          if (this.page.render(this.filename(), {
            format: this.recipe.output.format,
            quality: this.quality()
          })) {
            this.applyFeatures('afterRender', this.finish.bind(this));
          }
          else {
            this.finish(false);
          }

        }.bind(this));
      }.bind(this));
    },

    logSummary: function (title) {
      var message = "PhantomJS page object " + title + ":\n" + JSON.stringify(this.summary(), null, 4);

      message.split("\n").forEach(function (line) {
        log('debug', line);
      });
    },

    setPageProperty: function (property, valueFn, defaultValue) {
      this.page[property] = valueFn(this.page[property] || defaultValue);
    },

    summary: function () {
      return {
        dpi: this.page.settings.dpi,
        paperSize: this.page.paperSize,
        viewportSize: this.page.viewportSize,
        zoomFactor: this.page.zoomFactor
      };
    },

    // Evaluate a function inside the page context.  Arguments can
    // also be passed as long as they are strings or numbers.
    evaluate: function(fn) {
      var args = [].slice.call(arguments, 1),
          fnString = "function() { return (" + fn.toString() + ").apply(this, " + JSON.stringify(args) + ");}";

      return this.page.evaluateJavaScript(fnString);
    },

    // [TODO] move
    quality: function () {
      return '75';
    },

    // Local output path
    filename: function () {
      return this.options.output + '.' + this.recipe.name + '.' + this.recipe.output.format;
    },

    // Remove any polls and timers
    clean: function () {
      window.clearTimeout(this.timeouts.poll);
      window.clearTimeout(this.timeouts.failsafe);
    },

    // Prepare a page object for rendering
    prepare: function () {
      this.page = this.capture.currentPage = (this.capture.currentPage || new WebPage());
      this.page.clearMemoryCache();

      this.page.onError = function (message, trace) {
        log('error', message);

        trace.forEach(function(item) {
          log('error', item.file, ':', item.line);
        });
      };

      this.page.onConsoleMessage = function(message) {
        log('debug', 'console: ' + message);
      }.bind(this);

      this.page.onLoadFinished = function (status) {
        this.page.status = status;
      }.bind(this);
    },

    // Called if timeout exceeded
    failsafe: function () {
      this.finish(false, 'acceptable time window of ' + this.options.max_capture_time + 's exceeded');
    }

  };

  return {
    install: function (ns) {
      obj.ns = ns;

      return obj;
    }
  };

})();