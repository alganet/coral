
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
	echo animals
	zoo_lion
}
```

```console test
$ require_path=path2:path4:. coral zoo_animals
animals
zoo
lion
$ require_path=path2:path4:. coral zoo_lion
zoo
lion
$ require_path=path2:path4:. coral zoo
zoo
```
