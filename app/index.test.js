const helpers = require('yeoman-test')
const assert = require('yeoman-assert');
const generator = require('./index')
const path = require('path');

describe('isv-ci(test)', function () {
    it('generates a project with require.js', function () {
      return helpers.run(path.join(__dirname, '../app'))
      .withArguments(['my-test'])        // Mock the arguments
      // .withPrompts({ coffee: false })   // Mock the prompt answers
      // .withLocalConfig({ lang: 'en' }) // Mock the local config
      .then(function() {
        assert.file('README.md');
      });
    })
})