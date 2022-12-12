
target="x86_64-unknown-linux-gnu"

cargo install cross;
CARGO_INCREMENTAL=0 PKG_CONFIG_ALLOW_CROSS=1 cross build  --release --target=${target}

