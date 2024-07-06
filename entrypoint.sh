# Copyright (c) Alexandre Gomes Gaigalas <alganet@gmail.com>
# SPDX-License-Identifier: ISC

__OPT__="${-:-}"
__PAT__="$PATH"
__PWD__="$PWD"
__SLF__="$PWD/$0"
__LIB__="${__SLF__%\/*}"

. "${__LIB__}/idiom/compat.sh"   # Most primitive shims and checks. This must be first.
. "${__LIB__}/idiom/data.sh"     # Pseudo-datastructures.
. "${__LIB__}/idiom/require.sh"  # Module loader.
. "${__LIB__}/idiom/wrapper.sh"  # Actually runs the thing.

