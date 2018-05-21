module_assemble
===============

Assembles modules and their dependencies into standalone files.

---

Let's start first with a simple module:

```sh file mymodule.sh
mymodule ()
{
	echo 1
}
```

The `module_assemble` function takes two arguments: an input module
name and an option output module name.


```console test
$ MODULE=mymodule
$ ./lib/dev module_assemble $MODULE $MODULE
$ echo $MODULE
mymodule
$ sh ./mymodule
1
```

If no output is provided, the assembled module will be printed out.

```console task
$ MODULE=mymodule
$ assemble_path=: ./lib/dev module_assemble $MODULE | sh
1
```
