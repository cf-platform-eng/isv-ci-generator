// +build feature

package features_test

import (
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
	"path"
	"path/filepath"

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

	Describe("generated project", func() {
		Scenario("fails when missing parameters", func() {
			steps.Given("I run generate helm project")
			steps.Then("It creates a helm project successfully")
			steps.Then("I make run in the new project without a helm chart")
			steps.Then("make run fails with unsatisfied needs")
		})

		Scenario("succeeds with valid helm chart", func() {
			steps.Given("I run generate helm project")
			steps.Then("It creates a helm project successfully")
			steps.Then("I make run in the new project with helm chart")
			steps.Then("make run succeeds")
		})
	})

	steps.Define(func(define Definitions) {
		var (
			cmd       *exec.Cmd
			output    string
			exitError error
			destDir   string
		)

		BeforeEach(func() {
			var err error
			destDir, err = ioutil.TempDir("", "helm-project")
			Expect(err).ToNot(HaveOccurred())
		})

		AfterEach(func() {
			if destDir != "" {
				if _, err := os.Stat(destDir); !os.IsNotExist(err) {
					err = os.RemoveAll(destDir)
					Expect(err).ToNot(HaveOccurred())
				}
			}
		})

		define.When(`^I run generate helm project$`, func() {
			cmd = exec.Command("yo", "isv-ci:helm", "my-example-test", fmt.Sprintf("--target-dir=%s", destDir))
			var outputBytes []byte
			outputBytes, exitError = cmd.CombinedOutput()
			output = string(outputBytes)
		})

		define.Then(`^It creates a helm project successfully$`, func() {
			Expect(output).To(ContainSubstring(fmt.Sprintf("Created helm test 'my-example-test' in '%s/my-example-test'", destDir)))
			Expect(output).To(ContainSubstring(fmt.Sprintf("See '%s/my-example-test/README.md' for pre-requisites.", destDir)))
			Expect(output).To(ContainSubstring("To run the test:"))
			Expect(exitError).ToNot(HaveOccurred())
			_, err := os.Stat(path.Join(destDir, "my-example-test"))
			Expect(err).ToNot(HaveOccurred())
		})

		define.Then(`^I make run in the new project without a helm chart$`, func() {
			cmd = exec.Command("make", "run")
			cmd.Dir = path.Join(destDir, "my-example-test")
			os.Unsetenv("HELM_CHART")
			var outputBytes []byte
			outputBytes, exitError = cmd.CombinedOutput()
			output = string(outputBytes)
		})

		define.Then(`^I make run in the new project with helm chart$`, func() {
			cmd = exec.Command("make", "run")
			cmd.Dir = path.Join(destDir, "my-example-test")
			helmChart, err := filepath.Abs("./fixtures/charts/mysql")
			Expect(err).ToNot(HaveOccurred())
			cmd.Env = append(os.Environ(), fmt.Sprintf("HELM_CHART=%s", helmChart))
			var outputBytes []byte
			outputBytes, exitError = cmd.CombinedOutput()
			output = string(outputBytes)
		})

		define.Then(`^make run fails with unsatisfied needs$`, func() {
			Expect(output).To(ContainSubstring("The requirements in needs.json were not completely met"))
			Expect(exitError).To(HaveOccurred())
		})

		define.Then(`^make run succeeds$`, func() {
			Expect(output).To(ContainSubstring("my-example-test succeeded"))
			Expect(exitError).ToNot(HaveOccurred())
		})
	})
})
