Prusti-dev
==========

[Prusti](http://www.pm.inf.ethz.ch/research/prusti.html) is a prototype verifier for Rust,
built upon the the [Viper verification infrastructure](http://www.pm.inf.ethz.ch/research/viper.html).

By default Prusti verifies absence of panics by proving that statements such as `unreachable!()` and `panic!()` are unreachable.
Overflow checking can be enabled with a configuration flag, otherwise all integers are treated as unbounded.
In Prusti, the functional behaviour of a function can be specified by using preconditions, postconditions, and loop invariants.

To see examples of programs annotated with specifications and verified, look into the [`prusti/tests/verify/pass/rosetta`](prusti/tests/verify/pass/rosetta) and [`prusti/tests/verify/pass-overflow/rosetta`](prusti/tests/verify/pass-overflow/rosetta) folders.


Build for local development
---------------------------

The following instructions has been tested on Ubuntu 16.04:

- Install the `viper` package.

    ```bash
    wget -q -O - https://pmserver.inf.ethz.ch/viper/debs/xenial/key.asc | sudo apt-key add -
    echo 'deb http://pmserver.inf.ethz.ch/viper/debs/xenial /' | sudo tee /etc/apt/sources.list.d/viper.list
    sudo apt-get update  
    sudo apt-get install viper
    ```

- Install Java 8 or a later version.

    ```bash
    sudo apt-get install default-jdk
    ```

- Install Rustup

	```bash
	curl https://sh.rustup.rs -sSf | sh
	```

- Install the Rust compiler (the exact compiler version is stored in the rust-toolchain file)

    ```bash
    rustup toolchain install $(cat rust-toolchain)
    ```

- Install the dependencies required by some Rust libraries

	```bash
	sudo apt-get install build-essential pkg-config gcc libssl-dev
	```

- Download this Prusti repository and move to the `prusti-dev` folder

	```bash
	git clone "<url-of-prusti-repository>"
	cd prusti-dev
	```

- You can now compile Prusti

    ```bash
    make build
    ```

- Make sure that the tests are passing

    ```bash
    make test
    ```

- To run Prusti and verify a program (without overflow checks) there are two options:

    ```bash
    ./bin/prusti path/to/the/program_to_be_verified.rs
    ```

    or

    ```bash
    make run RUN_FILE=path/to/the/program_to_be_verified.rs
    ```

- Similarly, to run Prusti and verify a program including overflow checks:

    ```bash
    PRUSTI_CHECK_BINARY_OPERATIONS=true ./bin/prusti path/to/the/program_to_be_verified.rs
    ```

    or

    ```bash
    PRUSTI_CHECK_BINARY_OPERATIONS=true make run RUN_FILE=path/to/the/program_to_be_verified.rs
    ```

- (Optional) To install additional tools required by some scripts in the evaluation folder:

	```bash
	sudo apt-get install jq
	```


Demo with `rust-playground`
---------------------------

If you have [Vagrant](https://www.vagrantup.com/) installed, just run
``make demo`` and open
<http://localhost:23438/?version=nightly&mode=debug&edition=2018>.
Otherwise, you can follow the following instructions.

1. Choose a folder in which to run the demo
    ```bash
    export PRUSTI_DEMO_DIR="/tmp/prusti-demo"
    mkdir -p "$PRUSTI_DEMO_DIR"
    ```

2. Build Prusti
    ```bash
    cd "$PRUSTI_DEMO_DIR"
    git clone "<url-of-prusti-repository>"
    make build-docker-images
    ```

3. Build `rust-playground`
    ```bash
    cd "$PRUSTI_DEMO_DIR"
    git clone git@github.com:integer32llc/rust-playground.git
    cd rust-playground
    git checkout f103d06cfb4c96ca6055ae9f4b16ca5cca03c852
    cd ui
    cargo build --release
    cd frontend
    yarn
    yarn run build:production
    ```

4. Start the demo
    ```bash
    cd "$PRUSTI_DEMO_DIR/rust-playground/ui"
    TMPDIR=/tmp \
    RUST_LOG=debug \
    PLAYGROUND_UI_ADDRESS=0.0.0.0 \
    PLAYGROUND_UI_PORT=8080 \
    PLAYGROUND_UI_ROOT=$PWD/frontend/build \
    PLAYGROUND_GITHUB_TOKEN="" \
    ./target/release/ui
    ```

5. Use the demo:
    - Visit <http://localhost:8080/>
    - Select "Nightly channel".
    - Write with the following program:
        ```rust
        extern crate prusti_contracts;

        fn main() {
            unreachable!();
        }
        ```
    - Click on "Build" and watch at the compiler and verifier messages.
