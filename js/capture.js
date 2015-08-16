/* global phantom, require */

var Drone = require('./drone').install({}),
    system = require('system'),
    fs = require('fs'),
    scriptArguments = system.args,
    log = window.log = Drone.Util.log;


// Bail if no arguments present or they are not in an expected format
if (typeof scriptArguments === 'undefined' || scriptArguments.length !== 2) {
  log('error', 'Fatal: missing or incorrect arguments detected.  Ruby IO problem, perhaps?');
}

// Decode arguments and run Drone
else {
  new Drone.Capture(JSON.parse(fs.read(scriptArguments[1])), function (result, message) {
    if (result) {
      log('debug', 'all recipes have been prepared!');
    }
    else {
      log('debug', 'one or more captures failed; message="' + message + '"');
    }

    phantom.exit((result) ? 0 : 1);
  });
}
