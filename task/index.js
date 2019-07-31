const Generator = require('yeoman-generator')

module.exports = class extends Generator {
    constructor(args, opts) {
        super(args, opts)

        this.argument("taskname", {type: String, required: true})
        this.option("taskdir", {type: String, default: "."})
        this.option("repo", {type: String, default: "github.com/cf-platform-eng/<appname>"})
    }


    writing() {
        console.log('\n' +
            'ISV CI Toolkit Task\n' +
            '-------------------\n' +
            '\n')

        const appName = this.options.appname.replace(/\s+/g, '-').toLowerCase()
        const location = this.options.appdir + ((this.options.appdir.substr(-1) === '/') ? '' : '/')
        const appDir = location + appName
        const repoURL = this.options.repo.replace(/<appname>/g, appName)

        this.destinationRoot(appDir)
        console.log('Generating app dir \'' + appDir + '\'')

        let context = {
            appPackage: appName,
            appName: appName,
            repoURL: repoURL,
        };

        [
            ".gitignore",
            "config.go",
            "constants.go",
            "go.mod",
            "Makefile",
            "README.md",
            "version/version.go",
            "version/version_suite_test.go",
            "version/version_test.go",
            "features/features_suite_test.go",
            "features/version_test.go",
            "ci/tasks/build.yml",
            "ci/tasks/test.yml",
        ].forEach((filename) => {
            this.fs.copyTpl(
                this.templatePath(filename),
                this.destinationPath(filename),
                context
            )
        })

        this.fs.copyTpl(
            this.templatePath("cmd/appname/main.go"),
            this.destinationPath("cmd/" + appName + "/main.go"),
            context
        )

        console.log(
            'When done, try:\n' +
            '\n' +
            '  cd ' + this.destinationPath() + '\n' +
            '  make\n' +
            '  ./build/' + appName + '\n' +
            '\n'
        )

    }
}
