PLUGIN_DIR ?= $(HOME)/.config/omarchy/plugins/zerobearing.omatalk
REPO := $(CURDIR)

.PHONY: test validate dev-reload

test:
	./tests/run.sh

validate:
	omarchy plugin validate "$(REPO)"

# Copy this checkout's plugin files over the installed plugin and restart
# the shell. Saving under ~/.config/omarchy/plugins/ often hot-reloads; a
# full shell restart is the reliable way to pick up a whole tree swap.
dev-reload:
	omarchy plugin disable zerobearing.omatalk >/dev/null 2>&1 || true
	mkdir -p "$(PLUGIN_DIR)"
	rsync -a --delete \
		--exclude .git --exclude tests --exclude .github \
		--exclude Makefile --exclude AGENTS.md --exclude CONTEXT.md \
		"$(REPO)/" "$(PLUGIN_DIR)/"
	omarchy restart shell
	omarchy plugin enable zerobearing.omatalk >/dev/null 2>&1 || true
