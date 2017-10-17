
### Namespacing

```sh file zoo.sh

zoo () 
{ 
	echo zoo
}
```

```sh file path2/zoo/lion.sh

require 'zoo.sh'

zoo_lion () 
{ 
	zoo
	echo lion
}
```

```sh file path4/zoo/animals.sh

require 'zoo/lion.sh'

zoo_animals () 
{ 
	lion
	monkey
}
```

```console test
$ require_path=path2:path4:. coral zoo/animals
$ require_path=path2:path4:. coral zoo/lion
$ require_path=path2:path4:. coral zoo
zoo
```
