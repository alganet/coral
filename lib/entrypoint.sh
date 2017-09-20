#!/usr/bin/env sh

# Run command named by the entrypoint variable or nothing (the : command)
${entrypoint:-:} "${@:-}"
