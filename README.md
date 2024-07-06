[#]:# "Copyright (c) Alexandre Gomes Gaigalas <alganet@gmail.com>"
[#]:# "SPDX-License-Identifier: ISC"
🐚 coral
========

a **modular** library to create **portable shell scripts** that run everywhere.

## Introduction

_coral_ is meant to solve the script portability problem the hard way: by writing reusable code and testing it.

There is no compilation or build step. Once you download it, you're good to go.

# Testing

Run all tests locally against the default shell:

```sh
./coral tap
```

Run a single test. For example, the pseudoarray implementation:

```sh
sh coral tap 'test/_idiom/005-Arr.sh'
```

Run all tests inside an ephemeral docker container against all shells:

```sh
make docker-matrix
```
