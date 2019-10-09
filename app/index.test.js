const helpers = require('yeoman-test')
const assert = require('yeoman-assert')
const path = require('path')

describe('isv-ci:app (test generator)', () => {

    it('underscores and spaces become dasherized', () => {
        return helpers.run(path.join(__dirname, '../app'))
            .withArguments(['my badly_named test'])
            .then(() => {
                assert.fileContent('README.md', /# my-badly-named-test/)
            })
    })

    it('generates the test', () => {
        return helpers.run(path.join(__dirname, '../app'))
            .withArguments(['my-test'])
            .then(() => {
                // docs
                assert.fileContent('README.md', /# my-test/)

                // needs
                assert.jsonFileContent('needs.json', []);

                // makefile
                assert.fileContent('Makefile', "IMAGE_NAME := \"my-test\"\n");

                // Dockerfile
                assert.file('Dockerfile');

                // runtime
                assert.fileContent('run.sh', "echo \"my-test succeeded\"")
                assert.fileContent('run.bats', "output_equals \"my-test succeeded\"")
                assert.file('steps.sh')
                assert.file('steps.bats')


            })
    })

})