# xinput-json

Reproduce the result of `xinput list --short` in a json format, suitable for later processing.

Of course, I can write a convoluted `sed` or `awk` script to parse the text output of `xinput`, but I chose not to.
It is much more elegant to write a tiny rust program to do that!

## usage

```bash
cargo build --release
cargo run --release
```
