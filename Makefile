PLUGIN_DIR ?= $(HOME)/.config/omarchy/plugins/zerobearing.omatalk
REPO := $(CURDIR)

.PHONY: test validate dev-reload bump release

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

# Bump manifest.json's version and commit it (not pushed — push yourself
# when ready). `make bump` increments the patch; `make bump VERSION=0.2.0`
# sets that exact version instead. This commit is what `release` (below) and
# the Release workflow read the version from, so bump and push *before*
# releasing, not as part of releasing.
bump:
	@current=$$(sed -n 's/^  "version": "\(.*\)",$$/\1/p' manifest.json); \
	if [ -z "$$current" ]; then echo "could not read version from manifest.json" >&2; exit 1; fi; \
	if [ -n "$(VERSION)" ]; then \
		new="$(VERSION)"; \
	else \
		major=$$(echo "$$current" | cut -d. -f1); \
		minor=$$(echo "$$current" | cut -d. -f2); \
		patch=$$(echo "$$current" | cut -d. -f3); \
		new="$$major.$$minor.$$((patch + 1))"; \
	fi; \
	sed -i "s/^  \"version\": \".*\",$$/  \"version\": \"$$new\",/" manifest.json; \
	git add manifest.json; \
	git commit -m "Bump version to $$new"; \
	echo "Bumped $$current -> $$new (commit made — push when ready)"

# Trigger the Release workflow (manual-only, see .github/workflows/release.yml).
# It releases whatever version is already committed in manifest.json on the
# remote's default branch, so `make bump` (and push) first.
release:
	gh workflow run release.yml
	@echo "Triggered. Watch with: gh run watch \$$(gh run list --workflow=release.yml -L1 --json databaseId -q '.[0].databaseId')"
