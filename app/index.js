const Generator = require('yeoman-generator')

module.exports = class extends Generator {
    constructor(args, opts) {
        super(args, opts)

        this.argument("test-name", {type: String, required: true})
        // todo: test this
        this.option("target-dir", {type: String, default: "."})
    }


    writing() {
        console.log('\n' +
            'ISV CI Test\n' +
            '-----------\n' +
            '\n')

        console.log(this.options)
        const testName = this.options['test-name']
            .replace(/\s+/g, '-')
            .replace(/_+/g, '-')
            .toLowerCase()

        console.log("Test name: " + testName)

        const location = this.options['target-dir'] + ((this.options['target-dir'].substr(-1) === '/') ? '' : '/')
        const testDir = location + testName

        this.destinationRoot(testDir)

        console.log('Generating skeleton in \'' + testDir + '\'')

        let context = {
            testName: testName,
        };

        [
            "README.md"
        ].forEach((filename) => {
            this.fs.copyTpl(
                this.templatePath(filename),
                this.destinationPath(filename),
                context
            )
        })

        // this.fs.copyTpl(
        //     this.templatePath("cmd/appname/main.go"),
        //     this.destinationPath("cmd/" + appName + "/main.go"),
        //     context
        // )

        // console.log(
        //     'When done, try:\n' +
        //     '\n' +
        //     '  cd ' + this.destinationPath() + '\n' +
        //     '  make\n' +
        //     '  ./build/' + appName + '\n' +
        //     '\n'
        // )

    }
}
