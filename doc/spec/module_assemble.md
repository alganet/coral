module_assemble
===============

```sh file mymodule.sh
mymodule ()
{
	echo 1
}
```


```console test
$ MODULE=mymodule
$ ./lib/dev module_assemble $MODULE $MODULE
$ echo $MODULE
mymodule
$ sh ./mymodule
1
```
