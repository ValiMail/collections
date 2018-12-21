# NOTE: If making very long task names, run `make`, and adjust the `%-20s` in the printf in the
# `help` task as needed!

APP_NAME=collections
VERSION=1.0.0
# REV=$(shell git rev-parse --short HEAD)
# BUILD_DATE=$(shell date -u +%Y-%m-%dT%H:%M:%S%z)
GOOS?=darwin
GOARCH?=amd64
DIST_NAME=${APP_NAME}

.DEFAULT_GOAL := help

.PHONY: help

test: ## Run test suite with race detection and coverage/profiling
	go test -race -coverprofile coverage.txt ./...

compile: ## Compile project for specified GOOS/GOARCH
	GOOS=${GOOS} GOARCH=${GOARCH} go build -o "${DIST_NAME}" .

build: test compile ## Run tests, then compile the project

# Linting tools we might find useful later:
# go get -u github.com/kisielk/errcheck # Would be nice, but very very very noisy, overlaps with gosec.
# go get -u gitlab.com/opennota/check/cmd/aligncheck # Might be handy later, when we need to optimize.

# Dev tools we might find useful later:
# go get -u github.com/jgautheron/goconst/cmd/goconst # This tool seems... very broken.

prepare_ci: ## Install CI-time tools
	go get $$(cat tools.ci)

update_ci: ## Update CI-time tools
	go get -u $$(cat tools.ci)

prepare_workstation: prepare_ci ## Install all (CI-time, and development-time) tools
	go get $$(cat tools.dev)

update_workstation: update_ci ## Update all (CI-time, and development-time) tools
	go get -u $$(cat tools.dev)

fmt: ## Format code
	gofmt -s -l -w $$(find . -name '*.go' -and -not -path './vendor/*')
	goimports -w $$(find . -name '*.go' -and -not -path './vendor/*')

lint_vet:
	go vet -all -shadow ./...

lint_golint:
	golint -set_exit_status $$(go list ./...)

lint_ineffassign:
	ineffassign .

lint_structcheck:
	structcheck -e ./...

lint_varcheck:
	varcheck -e ./...

lint_gocyclo:
	gocyclo -over 10 $$(find . -name '*.go' -and -not -path './vendor/*')

lint_dupl:
	# Complex shenanigans here because I don't know how to set a Make variable _from within a task_,
	# and shell variables don't survive from statement to statement (because sub-processes get their
	# own environment, blah blah).
	# tl;dr: `dupl` doesn't set the exit status when violations are found, so I need to check the
	# output and set it myself,
	export TMPFILE=$(shell mktemp /tmp/collections.dupl.XXXXXXX || exit 1); \
	dupl -t 100 $$(find . -name '*.go' -and -not -path './cmd/*' -and -not -path './vendor/*' -and -not -name '*_test.go') 2>&1 | \
		tee $$TMPFILE && \
	if [ $$(($$(wc -l < $$TMPFILE) + 0)) -gt 2 ]; then exit 1; fi

lint_lll:
	export TMPFILE=$(shell mktemp /tmp/collections.lll.XXXXXXX || exit 1); \
	lll --maxlength=100 --tabwidth=2 --goonly . 2>&1 | \
		tee $$TMPFILE && \
	if [ $$(($$(wc -l < $$TMPFILE) + 0)) -gt 0 ]; then exit 1; fi

lint_unparam:
	export TMPFILE=$(shell mktemp /tmp/collections.unparam.XXXXXXX || exit 1); \
	unparam -algo rta ./... 2>&1 | \
		tee $$TMPFILE && \
	if [ $$(($$(wc -l < $$TMPFILE) + 0)) -gt 0 ]; then exit 1; fi

lint: lint_vet lint_golint lint_ineffassign lint_structcheck lint_varcheck lint_gocyclo lint_dupl lint_lll lint_unparam ## Run linting tools (e.g. go vet and golint) against the project

tag: ## Tag the git repo with the current VERSION, and push tags upstream
	git tag v$(VERSION)
	git push --tags

cloc: ## Measure the volume of code in the project, excluding vendor, and such
	cloc . --exclude-dir=vendor

todo: ## Find all TODO comments in the code.
	find . -name "*.go" -and -not -path './vendor/*' -print0 | xargs -0 grep -n 'TODO'

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "%-20s %s\n", $$1, $$2}'
