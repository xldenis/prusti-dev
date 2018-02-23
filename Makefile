SHELL := /bin/bash
IMAGE_VERSION=2017-12-10
IMAGE_NAME="vakaras/prusti:${IMAGE_VERSION}"
LOG_LEVEL=error
RUN_FILE=tests/typecheck/pass/lint.rs
STDERR_FILE=$(RUN_FILE:.rs=.stderr)
RUN_FILE_FOLDER=$(shell dirname ${RUN_FILE})
STAGE2_COMPILER_PATH=../../rust/build/x86_64-unknown-linux-gnu/stage2
LIB_PATH=${STAGE2_COMPILER_PATH}/lib/:../target/debug/:$$JAVA_HOME/jre/lib/amd64/server/
DRIVER=../target/debug/prusti-driver

run:
	RUST_LOG=debug \
	LD_LIBRARY_PATH=${LIB_PATH} \
	${DRIVER} \
		--sysroot ${STAGE2_COMPILER_PATH}/lib/ \
		-L ../target/debug/ \
		-L ${STAGE2_COMPILER_PATH}/lib/ \
		-L ${STAGE2_COMPILER_PATH}/lib/rustlib/x86_64-unknown-linux-gnu/lib/ \
		--extern prusti_contracts=$(wildcard ../target/debug/deps/libprusti_contracts-*.rlib) \
		-Z mir-emit-validate=1 \
		-Z dump-mir=all \
		-Z dump-mir-graphviz \
		-Z identify-regions \
		-Z verbose \
		-Z borrowck=mir \
		-Z nll \
		-Z nll_dump_cause \
		${RUN_FILE}
	dot -Tps graph.dot -Ograph.ps

generate_ui_stderr:
	-LD_LIBRARY_PATH=${LIB_PATH} \
	${DRIVER} \
		--sysroot ${STAGE2_COMPILER_PATH}/lib/ \
        -L ../target/debug/ \
        -L ${STAGE2_COMPILER_PATH}/lib/ \
        -L ${STAGE2_COMPILER_PATH}/lib/rustlib/x86_64-unknown-linux-gnu/lib/ \
        --extern prusti_contracts=$(wildcard ../target/debug/deps/libprusti_contracts-*.rlib) \
        -Z mir-emit-validate=1 \
		-Z borrowck=mir \
		-Z nll \
		${RUN_FILE} 2> ${STDERR_FILE}
	sed -e "s|${RUN_FILE_FOLDER}|\$$DIR|g" -i ${STDERR_FILE}


build:
	LD_LIBRARY_PATH=${LIB_PATH} \
    cargo +stage2 build

test:
	LD_LIBRARY_PATH=${LIB_PATH} \
    cargo +stage2 test

clean:
	cargo clean
	rm -f lint

doc:
	cargo rustdoc --lib -- \
		-Z unstable-options --document-private-items --enable-commonmark

# cargo install --force clippy
clippy:
	cargo clippy

# cargo install rustfmt-nightly
format_code:
	cargo fmt

build_release:
	cargo +stage2 build --release

build_image:
	sudo docker build -t ${IMAGE_NAME} docker

build_image_as_rust_nightly: build_image
	sudo docker build -t rust-nightly docker
