// +build feature

package features_test

import (
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"

	. "github.com/bunniesandbeatings/goerkin"
	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
)

var _ = Describe("isv-ci-generator", func() {
	steps := NewSteps()

	Describe("helm test generator", func() {
		Scenario("generates project", func() {
			steps.Given("I run generate helm project")
			steps.Then("It creates a helm project successfully")
		})
	})

	steps.Define(func(define Definitions) {
		var (
			cmd       *exec.Cmd
			output    string
			exitError error
			destDir   string
		)

		AfterEach(func() {
			if destDir != "" {
				if _, err := os.Stat(destDir); !os.IsNotExist(err) {
					err = os.RemoveAll(destDir)
					Expect(err).ToNot(HaveOccurred())
				}
			}
		})

		define.When(`^I run generate helm project$`, func() {
			var err error
			destDir, err = ioutil.TempDir("", "helm-project")
			Expect(err).ToNot(HaveOccurred())
			cmd = exec.Command("yo", "isv-ci:helm", "my-example-test", fmt.Sprintf("--target-dir=%s", destDir))
			var outputBytes []byte
			outputBytes, exitError = cmd.CombinedOutput()
			output = string(outputBytes)
		})

		define.Then(`^It creates a helm project successfully$`, func() {
			Expect(output).To(ContainSubstring("Created helm test 'my-example-test' in"))
			Expect(exitError).ToNot(HaveOccurred())
			_, err := os.Stat(destDir)
			Expect(err).ToNot(HaveOccurred())
		})
	})
})
