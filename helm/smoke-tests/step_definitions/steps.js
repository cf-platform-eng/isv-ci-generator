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
    exec(`yo isv-ci:helm helm-project --target-dir ${this.tmpDir} `, (err, stdout, stderr) => {
        if (err != null) {
            console.log(stdout)
            console.error(stderr)
        }
        expect(err).to.be.null
        done()
    })
})

Given(/^an environment is configured$/, function () {
    expect(process.env).to.include.keys(["KUBECONFIG"])
})

Given(/^no helm chart is given$/, function () {
    delete process.env["HELM_CHART"]
})

Given(/^a helm chart is given$/, function () {
    process.env["HELM_CHART"] = path.join(process.cwd(), "features", "fixtures", "charts", "mysql")
})

const ONE_HOUR = 60 * 60 * 1000
When(/^I run the test$/, {timeout: ONE_HOUR}, function (done) {
    exec(`make run`, {
        cwd: path.join(this.tmpDir, "helm-project")
    }, (err, stdout, stderr) => {
        console.log(stdout)
        console.error(stderr)
        this.stdout = stdout
        this.stderr = stderr
        this.err = err
        done()
    })
})

Then(/^the test passes$/, function () {
    expect(this.err).to.be.null
})

Then(/^the test fails$/, function () {
    expect(this.err).to.not.be.null
})

Then(/^I see that the helm chart is missing$/, function () {
    expect(this.stderr).to.contain("*** HELM_CHART not defined. Set this with the full path to your 'helm install'able chart.  Stop.")
})

Then(/^I see that the helm chart is installed and uninstalled$/, function () {
    expect(this.stdout).to.contain("section-end: 'Install helm chart' result: 0")
    expect(this.stdout).to.contain("section-end: 'Delete helm chart' result: 0")
})
