const Generator = require('yeoman-generator')

module.exports = class extends Generator {
    constructor(args, opts) {
        super(args, opts)

        this.argument("test-name", {type: String, required: true})
        this.option("target-dir", {type: String, default: "."})
    }

    writing() {
        this.log('\n' +
            'ISV CI Test\n' +
            '-----------'
            )

        this.testName = this.options['test-name']
            .replace(/\s+/g, '-')
            .replace(/_+/g, '-')
            .toLowerCase()

        this.log(`Test name: ${this.testName}\n`)

        const location = this.options['target-dir'] + ((this.options['target-dir'].substr(-1) === '/') ? '' : '/')
        this.testDir = location + this.testName

        this.destinationRoot(this.testDir)

        let context = {
            testName: this.testName,
        };

        [
            "README.md",
            "needs.json",
            "Makefile",
            "Dockerfile",
            "steps.sh",
            "steps.bats",
            "run.sh",
            "run.bats"
        ].forEach((filename) => {
            this.fs.copyTpl(
                this.templatePath(filename),
                this.destinationPath(filename),
                context
            )
        })
    }

    end() {
        this.log(`\nCreated test '${this.testName}' in '${this.testDir}'`)
        this.log('\nTo run the skeleton:')
        this.log(`  cd '${this.testDir}'`)
        this.log('  GREETING_NAME="my friend" make run')
        this.log('')
        this.log('You should see output that contains:')
        this.log('  section-start \'greet\' MRL:{...}')
        this.log('  hello my friend')
        this.log('  section-end \'greet\' MRL:{...}')
    }
}
