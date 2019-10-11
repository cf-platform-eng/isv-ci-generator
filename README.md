## ISV CI Test Yeoman Generator

This is a [Yeoman Generator](https://yeoman.io/) that generates a scaffold which contains just enough
to get you (our valued partner) started with your own ISV-CI tests.

Currently there is one scaffold, the default, which is a simple 'Hello World'. We plan to add at least two
more:
1. `tile`, which will install and uninstall your tile, just like our [pre-canned version](https://github.com/cf-platform-eng/isv-ci-toolkit/tree/master/tests/install-uninstall-pas-tile)
  that you can expand with your own custom tests.
1. `helm`, which will install and test a helm chart. This is pending the creation of a pre-canned version. 

## Usage

1. Use your web browser to download `isv-ci-generator.tgz` from the latest release at https://github.com/cf-platform-eng/isv-ci-generator/releases

2. Extract the tarball.
    ```bash
    mkdir isv-ci-generator
    cd isv-ci-generator
    tar xzf <path to downloaded isv-ci-generator.tgz>
    ```

3. Install yeoman and link the generator

    ```bash
    npm install -g yo
    npm link
    ```

4. Run the generator

    ```bash
    cd ~
    yo isv-ci <your-test-name>
    ```
    
    Follow the instructions provided by the generator to get started

## Development

1. Link this generator to the Yeoman registry

     run `npm link` in this directory
     
2. use Yeoman to test the generator, eg:
    ```bash
    cd ~/
    yo isv-ci my-sample-test
    ```
 
### Tests

Template test is `app/index.test.js`

Unit tests are included with the template, and can be exercised with `make test` which:
  1. runs the template, building the app in `./temp/example`
  1. runs the `bats` tests inside the example directory.