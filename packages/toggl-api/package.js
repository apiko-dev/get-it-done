Package.describe({
  name: 'jss:toggl-api',
  version: '0.0.1',
  // Brief, one-line summary of the package.
  summary: '',
  // URL to the Git repository containing the source code for this package.
  git: '',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Package.onUse(function(api) {
  api.versionsFrom('1.1.0.2');
  api.use(['coffeescript']);
  api.addFiles(['server/toggl-api.coffee'], 'server');
  api.export('TogglClient', 'server');
  api.export('TogglClientSide', 'client');
});


Npm.depends({
  'toggl-api': '0.0.3'
});


Package.onTest(function(api) {
  api.use('tinytest');
  api.use('jss:toggl-api');
  api.addFiles('toggl-api-tests.js');
});