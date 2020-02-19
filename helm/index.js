const Generator = require('yeoman-generator')

module.exports = class extends Generator {
    constructor(args, opts) {
        super(args, opts)

        this.argument("test-name", { type: String, required: true })
        this.option("target-dir", { type: String, default: process.cwd() })
        this.option("docker-repo", {type: String, default: ""})
    }

    writing() {
        this.log('\n' +
            'ISV CI Helm Test\n' +
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
            dockerRepo: this.options['docker-repo']
        };

        [
            "README.md",
            "needs.json",
            "Makefile",
            "Dockerfile",
            "steps.sh",
            "run.sh"
        ].forEach((filename) => {
            this.fs.copyTpl(
                this.templatePath(filename),
                this.destinationPath(filename),
                context
            )
        })        
         this.fs.copyTpl(
                this.templatePath("_gitignore"),
                this.destinationPath(".gitignore"),
                context
            )
    }

    end() {
        this.log(`\nCreated helm test '${this.testName}' in '${this.testDir}'`)
        this.log(`\nSee '${this.testDir}/README.md' for pre-requisites.`)
        this.log('\nTo run the test:')
        this.log(`  cd '${this.testDir}'`)
        this.log('  make run')
        this.log('')
    }
}