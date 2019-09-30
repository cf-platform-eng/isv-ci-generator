## ISV CI Test Yeoman Generator


## Usage


1. Install yeoman, deps and link the generator

    ``` bash
    npm install -g yo
    npm install
    npm link
    ```

1. Run the generator

    ```bash
    yo isv-ci-test <test name>
    ```


## Development

1. Link this generator to the Yeoman registry

     run `npm link` in this directory
     
2. use Yeoman to test the generator, eg:
    ```bash
    cd ~/
    yo isv-ci-test my-sample-test
    ```
 
### Tests
Using Mocha for compatibility with Yeoman