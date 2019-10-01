const helpers = require('yeoman-test')
const assert = require('yeoman-assert')
const path = require('path')

describe('isv-ci(test)', () => {

    it('underscores and spaces become dasherized', () => {
        helpers.run(path.join(__dirname, '../app'))
            .withArguments(['my test_badly named'])
            .then(() => {
                assert.fileContent('README.md', /# my-test-badly-named/)
            })
    })

    it('generates the readme', () => {
        helpers.run(path.join(__dirname, '../app'))
            .withArguments(['my-test'])
            .then(() => {
                assert.fileContent('README.md', /# my-test/)
            })
    })

})