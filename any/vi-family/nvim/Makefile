.PHONY: fmt
fmt:
	stylua --config-path .stylua.toml *.lua -- lua
	stylua --config-path .stylua.toml --glob 'lua/**/*.lua' -- lua

.PHONY: lint
lint:
	luacheck .
