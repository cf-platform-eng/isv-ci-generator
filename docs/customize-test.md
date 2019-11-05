# Customizing The Default Helm Test

The [helm yeoman generator](../README.md) generates a test script that installs the chart and then uninstalls the resulting instance. This document will guide you through expanding a test to better validate the system installed by the helm chart.

## Assumptions

- You have [Docker](https://docs.docker.com/v17.09/engine/installation/) installed.

- Your working directory is `~/example`
    ```bash
    $ mkdir ~/example
    $ cd ~/example
    ```
- You have [NPM](https://www.npmjs.com/) installed.

- You have [Yeoman](https://yeoman.io/) installed.
    ```bash
    $ npm install -g yo
    ```
- You've installed the generator.

  - [Download the latest release of `isv-ci-generator.tgz`](https://github.com/cf-platform-eng/isv-ci-generator/releases) to `~/example`

  - Extract the tarball
    ```bash
    $ mkdir isv-ci-generator
    $ cd isv-ci-generator
    $ tar xzf isv-ci-generator.tgz
    ```
  - npm link the generator to Yeoman
    ```bash
    $ npm link
    ```   
- You have the example helm charts
  ```bash
  $ cd ~/example
  $ git clone https://github.com/helm/charts.git
    ```
- You have a Kubernetes cluster you can test against. This is left as a exercise for the reader. This example has been tested against PKS and GKE. The test installs the chart on the cluster reported by:
  ```bash
  $ kubectl config current-context
  ```

## Testing The Mysql Chart
Now you should be ready to generate a test scaffold and modify the test. The mysql chart (`~/example/charts/stable/mysql`) will be used for this exercise.

- Generate the test scaffold
  ```bash
  $ cd ~/example
  $ yo isv-ci:helm mysql-test
  ```
- Set the target chart to install
  ```bash
  $ export HELM_CHART=~/example/charts/stable/mysql
  ```
### Run The Default Test
```bash
$ cd ~/example/mysql-test 
$ make run
```

You should see output that contains this:
```bash
NOTES:
MySQL can be accessed via port 3306 on the following DNS name from within your cluster:
test-instance-mysql.default.svc.cluster.local

To get your root password run:

    MYSQL_ROOT_PASSWORD=$(kubectl get secret --namespace default test-instance-mysql -o jsonpath="{.data.mysql-root-password}" | base64 --decode; echo)

To connect to your database:

1. Run an Ubuntu pod that you can use as a client:

    kubectl run -i --tty ubuntu --image=ubuntu:16.04 --restart=Never -- bash -il

2. Install the mysql client:

    $ apt-get update && apt-get install mysql-client -y

3. Connect using the mysql cli, then provide your password:
    $ mysql -h test-instance-mysql -p
```
In the following steps, those instructions will be used to enhance the test.

### The Default Test Script

The default test script is `run.sh` and looks like this:
```bash
#!/usr/bin/env bash

source ./steps.sh

if ! requirements_check; then exit 1; fi
if ! log_existing_dependencies; then exit 1; fi
if ! init_helm; then exit; fi
if ! install_helm_chart /input/helm-chart test-instance; then exit; fi

# The helm chart is now installed with the instance named 'test-instance'
# Add your test steps here.

if ! delete_helm_chart test-instance; then exit; fi
if ! remove_helm; then exit; fi

echo "mysql-test succeeded"
```
### Add The Test Steps

Add these three lines to `run.sh` after the `# Add your test steps here` :
```bash
while [[ $(kubectl get pods -l app=test-instance-mysql -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for mysql pod" && sleep 15; done

MYSQL_ROOT_PASSWORD=$(kubectl get secret --namespace default test-instance-mysql -o jsonpath="{.data.mysql-root-password}" | base64 --decode; echo)

if ! kubectl run --attach --rm ubuntu --image=ubuntu:16.04 --restart=Never -- bash -c "apt-get update && apt-get install mysql-client -y && mysql -h test-instance-mysql -p${MYSQL_ROOT_PASSWORD}"; then exit; fi 

```

`run.sh` should now look like this :
```bash
#!/usr/bin/env bash

source ./steps.sh

if ! requirements_check; then exit 1; fi
if ! log_existing_dependencies; then exit 1; fi
if ! init_helm; then exit; fi
if ! install_helm_chart /input/helm-chart test-instance; then exit; fi

# The helm chart is now installed with the instance named 'test-instance'
# Add your test steps here.

while [[ $(kubectl get pods -l app=test-instance-mysql -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for mysql pod" && sleep 15; done

MYSQL_ROOT_PASSWORD=$(kubectl get secret --namespace default test-instance-mysql -o jsonpath="{.data.mysql-root-password}" | base64 --decode; echo)

if ! kubectl run --attach --rm ubuntu --image=ubuntu:16.04 --restart=Never -- bash -c "apt-get update && apt-get install mysql-client -y && mysql -h test-instance-mysql -p${MYSQL_ROOT_PASSWORD}"; then exit; fi 

if ! delete_helm_chart test-instance; then exit; fi
if ! remove_helm; then exit; fi

echo "mysql-test succeeded"
```

#### What Has Been Added
Here is a line by line description of what has been added.

1. Wait for the mysql pod to become ready:
    ```bash
    while [[ $(kubectl get pods -l app=test-instance-mysql -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for mysql pod" && sleep 15; done
    ```
2. Get the root password for the mysql instance:
   ```bash
   MYSQL_ROOT_PASSWORD=$(kubectl get secret --namespace default test-instance-mysql -o jsonpath="{.data.mysql-root-password}" | base64 --decode; echo)
   ```
3. Make sure the mysql client can connect to the mysql instance. This is run in a separate pod in the cluster:
   ```bash
   if ! kubectl run --attach --rm ubuntu --image=ubuntu:16.04 --restart=Never -- bash -c "apt-get update && apt-get install mysql-client -y && mysql -h test-instance-mysql -p${MYSQL_ROOT_PASSWORD}"; then exit; fi 
   ```
### Modify The Test Scripts
All of the tools in the test have [BATS](https://github.com/bats-core/bats-core) tests scripts to validate functionality. It is necessary to add some
mocks to the tests so they don't hang trying to connect to actual Kubernetes resources.

Edit `run.bats` and make the following modifications.

#### Add kubectl mock
Add the line

```bash
export mock_kubectl="$(mock_bin kubectl)"
```

into function `setup()` so it looks like this:

```bash
setup() {
    export requirements_check="$(mock_bin requirements_check)"
    export log_existing_dependencies="$(mock_bin log_existing_dependencies)"
    export init_helm="$(mock_bin init_helm)"
    export remove_helm="$(mock_bin remove_helm)"
    export install_helm_chart="$(mock_bin install_helm_chart)"
    export delete_helm_chart="$(mock_bin delete_helm_chart)"
    export mock_kubectl="$(mock_bin kubectl)"
    export PATH="${BIN_MOCKS}:${PATH}"
}
```

#### Set kubectl side effect so wait for mysql pod works
Add the line

```bash
mock_set_side_effect "${mock_kubectl}" "echo True" 1
```

to the top of the `@test "runs all the steps"` function so it begins like this:

```bash
@test "runs all the steps" {
    mock_set_side_effect "${mock_kubectl}" "echo True" 1
    
    create_empty_file steps.sh

    run_isolated_subject "${BATS_TEST_DIRNAME}/run.sh"
```

### Run The New Test
Try to run the new test:
```bash
$ make run
```
You should see the following at the end of the output
```bash
mysql: [Warning] Using a password on the command line interface can be insecure.
pod "ubuntu" deleted
section-start: 'Delete helm chart' MRL:{"type":"section-start","name":"Delete helm chart","time":"2019-11-05T00:24:42.4781901Z"}
release "test-instance" deleted
Helm chart instance 'test-instance' deleted!
section-end: 'Delete helm chart' result: 0 MRL:{"type":"section-end","name":"Delete helm chart","time":"2019-11-05T00:24:43.5924182Z"}
section-start: 'remove helm' MRL:{"type":"section-start","name":"remove helm","time":"2019-11-05T00:24:43.5958465Z"}
deployment.extensions "tiller-deploy" deleted
clusterrolebinding.rbac.authorization.k8s.io "tiller" deleted
serviceaccount "tiller" deleted
Helm removed!
section-end: 'remove helm' result: 0 MRL:{"type":"section-end","name":"remove helm","time":"2019-11-05T00:24:44.8903341Z"}
mysql-test succeeded
```
This shows that mysql was able to connect to the database (even though it complained about the password on the command line.)

## Summary
Now you should have some idea of how the install/uninstall helm test generator works and how you can modify `run.sh` to modify the test execution.

Once you have a test that you're happy with, you can use `make build` and `make publish` to build and publish a docker image that encapsulates your
test and can be leveraged in a build pipeline or by other developers.

## Some Helpful Hints

### If The Test Fails And Leaves The Chart and/or Helm Installed
If the tests fail along the way, the chart and helm will still be installed in the cluster, and re-running the test will result in failures. To cleanup:
```bash
$ source ./steps.sh
$ delete_helm_chart test-instance
$ remove_helm
```
Then you should be able to run the tests again.

### If You Want To Disable The BATS Unit Tests
Find the make target `temp/make-tags/build` in `Makefile`, it should look look like this:
```bash
temp/make-tags/build: temp/make-tags/lint temp/make-tags/test $(SRC)
```

Remove `temp/make-tags/lint temp/make-tags/test` from the line so it looks like this:
```bash
temp/make-tags/build: $(SRC)
```

Now the tests won't run every time the image is built. You may still run the tests with `make test`
