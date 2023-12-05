# xinput-json

Reproduce the result of `xinput list --short` in a json format, suitable for later processing.
This is heavily based on [the example `input.rs`](https://github.com/AltF02/x11-rs/blob/master/x11/examples/input.rs) from [the `x11` crate](https://github.com/AltF02/x11-rs).

Of course, I can write a convoluted `sed` or `awk` script to parse the text output of `xinput`, but I chose not to.
It is much more elegant to write a tiny rust program to do that!

## usage

- A standalone (static) binary is attached to [the latest release](https://github.com/bryango/xinput-json/releases/latest). It should just work.
- The binary is built with a nix flake and is (supposedly) reproducible:
```bash
## The following commands depend on the `nix` package manager
## ... with `experimental-features = nix-command flakes`
## See: https://github.com/DeterminateSystems/nix-installer

## run the binary with nix
nix run github:bryango/xinput-json

## reproduce the build
nix build github:bryango/xinput-json
./result/bin/xinput-json

## install the binary
nix profile install github:bryango/xinput-json

## install the example script
nix profile install github:bryango/xinput-json#wingcool-bind
## ... that binds a touch input to the screen output
```

## development

Use nix to maximize purity, or just use vanilla Cargo:
```bash
cargo build --release
cargo run --release
```
If you are a nix fanatic like me, try the following:
```bash
nix flake clone github:bryango/xinput-json --dest xinput-json
cd xinput-json

## a `.envrc` is provided for easy of use
## if you are using `nix-direnv`, simply do `direnv allow`
## otherwise, try:
nix develop
```
