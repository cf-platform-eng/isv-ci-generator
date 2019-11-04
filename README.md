## ISV CI Test Yeoman Generator

This is a [Yeoman Generator](https://yeoman.io/) that generates a scaffold which contains just enough
to get you (our valued partner) started with your own ISV-CI tests.

Currently there is one scaffold, the default, which is a simple 'Hello World'. We plan to add at least two
more:
1. `tile`, which will install and uninstall your tile, just like our [pre-canned version](https://github.com/cf-platform-eng/isv-ci-toolkit/tree/master/tests/install-uninstall-pas-tile)
  that you can expand with your own custom tests.
1. `helm`, which will install and test a helm chart. This is pending the creation of a pre-canned version. 

## Usage

1. Gather prerequisites
    1. You will need [NPM](https://www.npmjs.com/) installed on your computer

    1. Install [Yeoman](https://yeoman.io/) if you don't have it already
    ```bash
    npm install -g yo
    ```

1. Install the generator.

    1. [Download the latest release of `isv-ci-generator.tgz`](https://github.com/cf-platform-eng/isv-ci-generator/releases)

    1. Extract the tarball to a directory. You should put this somewhere meaningful if you want to keep the generator installed.
    ```bash
    mkdir isv-ci-generator
    cd isv-ci-generator
    tar xzf <path to downloaded isv-ci-generator.tgz>
    ```
   
   1. In the generator directory, link the generator to Yeoman
    ```bash
    npm link
    ```   

4. Run the generator
- To generate a simple hello world test:
    ```bash
    cd <project parent> 
    yo isv-ci <your-test-name> # Test scaffold is generated in <project parent>/<your-test-name> 
    ```
- To generate a [helm chart install/uninstall](./helm/templates/README.md) test:
    ```bash
    cd <project parent> 
    yo isv-ci:helm <your-test-name> # Test scaffold for helm test is generated in <project parent>/<your-test-name> 
    ```    
    Follow the instructions provided by the generator to get started

## Development

1. Link this generator to the Yeoman registry

     run `npm link` in this directory
     
2. use Yeoman to test the generator. To generate a simple hello world test:
    ```bash
    yo isv-ci my-sample-test
    ```
### Tests

Template test is `app/index.test.js`

Unit tests are included with the template, and can be exercised with `make test` which:
  1. runs the template, building the app in `./temp/example`
  2. runs the `bats` tests inside the example directory.