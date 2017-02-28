[-]:Main ( :MyAppSh and :MyAppRun )

`coral` — a contemporary shell script system
--------------------------------------------

 - *Interoperable* — It builds, runs, tests and documents itself in
   [many platforms](docs/compatibility.md).

 - *Portable* — All libraries you need to get started bundled in a 
   [single portable file](docs/downloads.md).

 - *Modular* — [small independent tools](docs/libraries.md) that link
   together dynamically or statically.

 - *Tidy* — No batshit shell syntax, a sensible 
   [programming style](docs/libraries.md) that allows readable code.

 - *Robust* — documentation, guide, examples and tests everywhere.

You can use it in any terminal or to write equally interoperable, 
portable and modular scripts.
  
---
[-]:MyAppSh:./myapp.sh

```shell
require 'assert'

myapp ()
{
    if assert "Hello World" ends with "rld"
    then
      echo 'epa epa'
      echo 'epa epa'
      echo 'epa epa'
    fi
}
```

[-]:MyAppRun

Use `coral` as the interpreter and automatic dependency manager:

```console
$ coral myapp
epa epa
epa epa
epa epa
```

[-]:MyAppBundle

Bundle everything into a single executable:

```console
$ coral ship myapp.sh > myapp
$ ./myapp
  Hello World!
  4,294,967,296
```

<h1 align=center>🐚</h1>

