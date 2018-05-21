🐚 coral
=======

A modest shell script library that _works everywhere_.

> We are under _prototype_ development. Things are expected to work just
fine though.

`coral` is designed to fill strategic gaps in _Shell Script_ by
providing portable libraries that work across [multiple shells](doc/support.md).

---

### [require.sh](doc/spec/require.md)

A modern module loader with support for circular references and multiple
paths.

All `coral` libraries are exported as reusable modules.

### [spec/doc.sh](doc/spec/spec_doc.md)

A [literate](https://en.wikipedia.org/wiki/Literate_programming) test
runner that runs documents written for humans as automated tests.

It is used to test all `coral` software.

### [module/assemble.sh](doc/spec/module_assemble.md)

A shell script bundler that can create single executables from multiple
shell sources, supports runtime evaluated code and plays along with
`require.sh`.

It is used to build the `coral` releases.

### [lib/dev](doc/spec/lib_dev.md)

Used to bootstrap the modules, build and develop `coral` applications
from scratch.

---

