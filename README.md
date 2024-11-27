# ⚠️ Under Development: SmallString

**This repository is a work in progress.** The contents are subject to change, and a more complete README will replace this temporary one in the future.

## About SmallString

`SmallString` is a Rust crate designed with the following features:

- **16-byte structure** for storing UTF-8 strings.
- **16-byte inline buffer** for small strings.
- Utilizes a **heap buffer** for storing UTF-8 strings exceeding 16 bytes.
- Implements **Copy-on-Write (CoW)** for mutability.
- Internally uses **unsafe Rust** to achieve performance and compactness.

This crate implements **Short String Optimization (SSO)**. For comparison with other Rust String crates, refer to:

[Rust String Benchmarks](https://github.com/rosetta-rs/string-rosetta-rs)
