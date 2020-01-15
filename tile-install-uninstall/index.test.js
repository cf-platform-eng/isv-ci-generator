const helpers = require('yeoman-test')
const assert = require('yeoman-assert')
const path = require('path')

describe('isv-ci:helm (test generator)', () => {

    it('underscores and spaces become dasherized', () => {
        return helpers.run(path.join(__dirname, '.'))
            .withArguments(['my badly_named test'])
            .then(() => {
                assert.fileContent('README.md', /# my-badly-named-test/)
            })
    })

    it('generates the test', () => {
        return helpers.run(path.join(__dirname, '.'))
            .withArguments(['my-test'])
            .then(() => {
                // --- plain files
                assert.file('.gitignore')
                assert.file('Dockerfile')
                assert.file('needs.json')
                assert.file('run.sh')
                assert.file('steps.sh')

                // --- templates
                assert.fileContent('README.md', /# my-test/)

                assert.fileContent('Makefile', "IMAGE_NAME := \"my-test\"\n")
                assert.fileContent('Makefile', "#DOCKER_REPO := \"<specify your docker repo here>\"\n")
                assert.noFileContent('Makefile', /^DOCKER_REPO/m )
            })
    })

    describe('with docker-repo provided', () => {
        it('passes the docker-repo option to the Makefile', function () {
            return helpers.run(path.join(__dirname, '.'))
                .withArguments(['my-test'])
                .withOptions({dockerRepo: 'my-repo'})
                .then(() => {
                    assert.fileContent('Makefile', "DOCKER_REPO := \"my-repo\"\n")
                    assert.noFileContent('Makefile', "#DOCKER_REPO := \"<specify your docker repo here>\"")
                })

        })
    })


})