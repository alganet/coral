assemble.sh Module
==================

```sh file mymodule.sh
mymodule ()
{
	echo 1
}
```


```console test
$ MODULE=mymodule
$ ./coral assemble $MODULE $MODULE
$ echo $MODULE
mymodule
$ ./mymodule
1
```
