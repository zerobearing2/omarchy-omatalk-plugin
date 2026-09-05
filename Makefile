PLUGIN_DIR ?= $(HOME)/.config/omarchy/plugins/zerobearing.omatalk
REPO := $(CURDIR)
# omatalk tag (vX.Y.Z) or 40-char commit. Empty = latest GitHub release.
REF ?=

.PHONY: test validate dev-reload pin pin-release bump bump-manifest release

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
		--exclude scripts --exclude docs \
		"$(REPO)/" "$(PLUGIN_DIR)/"
	omarchy restart shell
	omarchy plugin enable zerobearing.omatalk >/dev/null 2>&1 || true

# Rewrite Panel.qml's installer pin to omatalk $(REF) (latest release if empty).
# Does not commit. `make pin-release` commits the pin with a plugin version bump.
pin:
	./scripts/pin-installer.sh "$(REF)"

# Pin the Daemon installer, bump the plugin version, one commit. Working tree
# must be clean. Does not push — push, then `make release`.
pin-release:
	@if [ -n "$$(git status --porcelain)" ]; then echo "working tree must be clean" >&2; exit 1; fi
	./scripts/pin-installer.sh "$(REF)"
	@if git diff --quiet -- Panel.qml; then echo "installer pin already current" >&2; exit 1; fi
	$(MAKE) bump-manifest
	$(MAKE) test
	@new=$$(sed -n 's/^  "version": "\(.*\)",$$/\1/p' manifest.json); \
	commit=$$(sed -n 's/^  readonly property string installerUrl: "https:\/\/raw.githubusercontent.com\/zerobearing2\/omatalk\/\([0-9a-f]\{40\}\)\/install.sh"$$/\1/p' Panel.qml); \
	git add Panel.qml manifest.json; \
	git commit -m "Pin omatalk installer $$commit and bump to $$new"; \
	echo "Committed $$new (pin $$commit). Push, then make release."

# Bump manifest.json's version and commit it (not pushed — push yourself
# when ready). `make bump` increments the patch; `make bump VERSION=0.2.0`
# sets that exact version instead. This commit is what `release` (below) and
# the Release workflow read the version from, so bump and push *before*
# releasing, not as part of releasing. For a newer Daemon installer use
# `make pin-release` instead of bump alone.
bump-manifest:
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
	echo "$$current -> $$new"

bump: bump-manifest
	@new=$$(sed -n 's/^  "version": "\(.*\)",$$/\1/p' manifest.json); \
	git add manifest.json; \
	git commit -m "Bump version to $$new"; \
	echo "Bumped to $$new (commit made — push when ready)"

# Trigger the Release workflow (manual-only, see .github/workflows/release.yml).
# It releases whatever version is already committed in manifest.json on the
# remote's default branch, so `make bump` (and push) first.
release:
	gh workflow run release.yml
	@echo "Triggered. Watch with: gh run watch \$$(gh run list --workflow=release.yml -L1 --json databaseId -q '.[0].databaseId')"
