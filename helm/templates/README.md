# <%= testName %>

**Describe your test Here**

Currently this test accepts a kubeconfig file `KUBECONFIG` and a helm chart `HELM_CHART`, and runs helm install and helm uninstall against the cluster referenced in the kubeconfig file.

For more information see the [ISV-CI Test Toolkit]()

# Running for the first time

## Targeting a cluster

A kubernetes cluster is required to run the test. Credentials to connect to the cluster are contained in a kubeconfig file (usually at `~/.kube/config`.) The cluster referenced by the current context will be used to run the test. The command `kubectl config current-context` will show the cluster currently targeted. 

If you have an alternate kubeconfig file, use the environment variable `KUBECONFIG` to specify it. If it is not specified, the default `~/.kube/config` will be used.

### Cluster requirements

The targeted cluster should be clean. This test will install helm, install your chart, delete your chart and then delete helm. 

## The Helm chart to test

A helm chart directory should exist for the helm chart you wish to test. Specify it in the environment variable `HELM_CHART`

If your helm chart directory is `/my/helm/chart`
```bash
$ export HELM_CHART=/my/helm/chart
```

## Run the test

This readme is in the generated project. Once you `cd` into this directory

```bash
$ make run
```

Your helm chart should get installed and then uninstalled on the targeted cluster.

## Modifying the test

Now that you've run the test once, you probably want to modify it to do something beyond just installing your chart. 

The file `run.sh` is the test script. It looks like this:

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

echo "<%= testName %> succeeded"
```

You can modify this test script and then ru-run `make run` to exercise the new test. An example test is documented [here](../../docs/customize-test.md).