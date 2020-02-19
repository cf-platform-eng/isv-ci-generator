const Generator = require('yeoman-generator')

module.exports = class extends Generator {
    constructor(args, opts) {
        super(args, opts)

        this.argument("test-name", {type: String, required: true})
        this.option("target-dir", {type: String, default: process.cwd()})
        this.option("docker-repo", {type: String, default: ""})
    }

    writing() {
        this.log('\n' +
            'ISV CI Tile install/uninstall test\n' +
            '----------------------------------'
        )

        this.testName = this.options['test-name']
            .replace(/\s+/g, '-')
            .replace(/_+/g, '-')
            .toLowerCase()

        this.log(`Test name: ${this.testName}\n`)

        const location = this.options['target-dir'] + ((this.options['target-dir'].substr(-1) === '/') ? '' : '/')
        this.testDir = location + this.testName

        this.destinationRoot(this.testDir)

        let files = [
            ["_gitignore", ".gitignore"],
            ["Dockerfile", "Dockerfile"],
            ["run.sh", "run.sh"],
            ["steps.sh", "steps.sh"],
            ["needs.json", "needs.json"],
            ["logs/.gitkeep", "logs/.gitkeep"]
        ]

        files.forEach(([src, dst]) => {
            this.fs.copy(
                this.templatePath(src),
                this.destinationPath(dst),
            )
        })

        let context = {
            testName: this.testName,
            dockerRepo: this.options['docker-repo']
        }

        let templateFiles = [
            ["README.md", "README.md"],
            ["Makefile", "Makefile"]
        ]

        templateFiles.forEach(([src, dst]) => {
            this.fs.copyTpl(
                this.templatePath(src),
                this.destinationPath(dst),
                context
            )
        })
    }

    end() {
        this.log(`\nCreated tile-install-uninstall test '${this.testName}' in '${this.testDir}'`)
        this.log(`\nSee '${this.testDir}/README.md' for pre-requisites.`)
        this.log('\nTo run the test:')
        this.log(`  cd '${this.testDir}'`)
        this.log('  make run')
        this.log(`\n'make run' will prompt for required configuration`)
        this.log(`'make run' is logged to '${this.testDir}/logs/'`)
        this.log('')
    }
}