Package.describe({
  name: 'jss:google-calendar-api',
  version: '0.0.1',
  // Brief, one-line summary of the package.
  summary: '',
  // URL to the Git repository containing the source code for this package.
  git: '',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Npm.depends({
  'google-calendar': '1.3.2'
});

Package.onUse(function(api) {
  api.versionsFrom('1.1.0.2');
  api.addFiles('google-calendar-api.js', 'server');
  api.export('GCalendar', 'server');
});

Package.onTest(function(api) {
  api.use('tinytest');
  api.use('jss:google-calendar-api');
  api.addFiles('google-calendar-api-tests.js');
});
