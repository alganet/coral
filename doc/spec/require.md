require
=======

### Simple Module Requiring

```sh file require_test
#!/bin/sh

entrypoint='require_test'
require_path="${require_path:-.}"

require ()
{
	require "${@:-}"
}

require_test ()
{
	local name="${1}"
	shift

	require "${name}"
	"${name%*.sh}" "${@:-}"
}

# Require modules from the source folder
. 'lib/script/support'
. 'lib/require.sh'
. 'lib/script/entrypoint'

```

```sh file hello.sh

hello ()
{
	echo hello
}
```

```sh file world.sh

require 'hello.sh'

world ()
{
	hello
	echo world
}

```

```console test
$ sh ./require_test world.sh
hello
world
```

### Self-references

```sh file loop.sh

require 'loop.sh'

loop ()
{
	echo loop
}
```

```console test
$ sh ./require_test loop.sh
loop
```

### Circular references

```sh file lorem.sh

require 'ipsum.sh'

lorem ()
{
	echo lorem
}
```

```sh file ipsum.sh

require 'lorem.sh'

ipsum ()
{
	lorem
	echo ipsum
}

```


```console test
$ sh ./require_test ipsum.sh
lorem
ipsum
```

### Hooks

```sh file hooks.sh

hook_on_request ()
{
	echo 'Request:' "${1:-}" 1>&2
	require_on_request "${1:-}"
}
hook_on_search ()
{
	echo 'Search:' "${1:-}" 1>&2
	require_on_search "${1:-}"
}
hook_on_include ()
{
	echo 'Include:' "${1:-}" 1>&2
	require_on_include "${1:-}"
}

hooks ()
{
	export require_on_request='hook_on_request'
	export require_on_search='hook_on_search'
	export require_on_include='hook_on_include'
	export require_loaded=''

	require 'world.sh'
}

```

```console test
$ sh ./require_test hooks.sh
Request: world.sh
Search: world.sh
Include: ./world.sh
Request: hello.sh
Search: hello.sh
Include: ./hello.sh
```

### Advanced Hooks

```sh file hooks.sh

hook_on_request ()
{
	echo 'Request:' "${1:-}" 1>&2
	test "${1:-}" = "never_finds.sh" && return 0
	test "${1:-}" = "always_requests.sh" && return 1
	require_on_request "${1:-}"
}
hook_on_search ()
{
	echo 'Search:' "${1:-}" 1>&2
	test "${1:-}" = "always_errors.sh" && return 0
	require_on_search "${1:-}"
}
hook_on_include ()
{
	test "${1:-}" = "never_includes.sh" && return 0
	echo 'Include:' "${1:-}" 1>&2
	require_on_include "${1:-}"
}

hooks ()
{
	local require_on_request='hook_on_request'
	local require_on_search='hook_on_search'
	local require_on_include='hook_on_include'
	local require_loaded=''

	require 'always_requests.sh'
	require 'always_requests.sh'
	require 'never_finds.sh'
	require 'never_includes.sh'
	require 'always_errors.sh'
	require 'world.sh'
}

```

```console test
$ printf '' > always_requests.sh
$ printf '' > never_finds.sh
$ printf '' > always_errors.sh
$ printf '' > never_includes.sh
$ sh ./require_test hooks.sh
Request: always_requests.sh
Search: always_requests.sh
Include: ./always_requests.sh
Request: always_requests.sh
Search: always_requests.sh
Include: ./always_requests.sh
Request: never_finds.sh
Request: never_includes.sh
Search: never_includes.sh
Include: ./never_includes.sh
Request: always_errors.sh
Search: always_errors.sh
Could not find dependency 'always_errors.sh'
```

### Paths

```sh file path1/hey.sh

hey ()
{
	echo hey
}
```

```sh file path2/friend.sh

require 'hey.sh'

friend ()
{
	hey
	echo friend
}
```

```console test
$ require_path=path1:path2:lib sh ./require_test friend.sh
hey
friend
```
