const {Before, Given, Then, When} = require('cucumber')
const {exec} = require("child_process")
const {expect} = require("chai")
const fs = require("fs").promises
const path = require("path")

Before(async function () {
    this.tmpDir = await fs.mkdtemp(path.join(process.cwd(), "temp", "smoke-test-dir-"), {recursive: true})
})

Given(/^I have generated my test$/, function (done) {
    console.log(`Generating test inside ${this.tmpDir}...`)
    exec(`yo isv-ci:tile-install-uninstall --target-dir ${this.tmpDir} smoke-tile-install-uninstall-test`, (err, stdout, stderr) => {
        if (err != null) {
            console.log(stdout)
            console.error(stderr)
        }
        expect(err).to.be.null
        done()
    })
})

Given(/^an environment is configured$/, function () {
    expect(process.env).to.include.keys([
        "OM_TARGET",
        "OM_USERNAME",
        "OM_PASSWORD",
        "OM_SKIP_SSL_VALIDATION"
    ])
})

const ONE_MINUTE = 60 * 1000
Given(/^I have an app\-only tile$/, {timeout: ONE_MINUTE}, function (done) {
    expect(process.env).to.include.key("PIVNET_TOKEN")
    exec(`marman download-tile --slug z-pe-test-pas-tile --version 0.3.38`, {
        cwd: this.tmpDir
    }, (err, stdout, stderr) => {
        if (err != null) {
            console.log(stdout)
            console.error(stderr)
        }
        expect(err).to.be.null
        done()
    })
})

Given(/^I have a working config file for my app\-only tile$/, async function () {
    this.configFilePath = path.join(this.tmpDir, "config.json")

    let configData = {
        "product-properties": {}
    }

    await fs.writeFile(this.configFilePath, JSON.stringify(configData))
})

const ONE_HOUR = 60 * 60 * 1000
When(/^I run the test$/, {timeout: ONE_HOUR}, function (done) {
    process.env.TILE_PATH = path.join(this.tmpDir, "z-pe-test-pas-tile-0.3.38.pivotal")
    process.env.TILE_CONFIG_PATH = this.configFilePath

    exec(`make run`, {
        cwd: path.join(this.tmpDir, "smoke-tile-install-uninstall-test")
    }, (err, stdout, stderr) => {
        this.testOutput = stdout
        console.log(stdout)
        console.error(stderr)
        expect(err).to.be.null
        done()
    })
})

Then(/^I see that the tile installed and uninstalled$/, function () {
    expect(this.testOutput).to.contain("section-end: 'install tile' result: 0")
    expect(this.testOutput).to.contain("section-end: 'uninstall tile' result: 0")
})
