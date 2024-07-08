# coral style guide

These guidelines fully apply to `modules` (reusable code), and apply on a
best-effort basis to `idiom` (compatibility and internals).

### 4-width tab indents

<font color=green>**RIGHT**</font>: Tabs configured to width 4.

<font color=red>**WRONG**</font> Spaces, tabs configured to width different than 4.

_Rationale_: Shell script indented heredocs `<<-` require the use of tabs. Failure to use tabs might yield extra spaces when reading the contents of these structures.

### Space after function name declaration

<font color=green>**RIGHT**</font>: Space between name and `()`
```sh
mymod_myfn () {
    _print hello
}
```

<font color=red>**WRONG**</font>: No space between name and `()`
```sh
mymod_myfn() {
    _print hello
}
```

_Rationale_: In sh, we call functions as `foo arg`, not `foo(arg` so we must declare it with an extra space to leverage tools like grep and IDE search.

### No function keyword

<font color=green>**RIGHT**</font>: Space between name and `()`
```sh
mymod_myfn () {
    _print hello
}
```

<font color=red>**WRONG**</font> No space between name and `()`
```sh
function mymod_myfn {
    _print hello
}
```

_Rationale_: This syntax is not portable.

### Function declaration must be in its own line

<font color=green>**RIGHT**</font>: Function declaration and closing on separated lines
```sh
mymod_myfn () {
    _print hello
}
```

<font color=red>**WRONG**</font>: Inlined function
```sh
mymod_myfn () { _print hello; }
```

<font color=red>**WRONG**</font>: Comment on the declaration line
```sh
mymod_myfn () { # a function!
    _print hello
}
```

_Rationale_: Most shells don't support reflection on the currently defined functions. _coral_ uses a shallow parser to perform such reflection once before runtime (for instance, on unit tests). This parser assumes a strict formatting of the source code.

### Functions live at indentation zero

<font color=green>**RIGHT**</font>: Functions are defined on indentation level zero
```sh
mymod_myfn () {
    _print hello
}
```

<font color=orange>**OK**</font>: Declaration is on its own line and at indentation zero.
```sh
mymod_myfn () {
        _print hello; }
```

<font color=red>**WRONG**</font>: Indented function declaration
```sh
    mymod_myfn () {
        _print hello
    }
```

_Rationale_: Most shells don't support reflection on the currently defined functions. _coral_ uses a shallow parser to perform such reflection once before runtime (for instance, on unit tests). This parser assumes a strict formatting of the source code.

