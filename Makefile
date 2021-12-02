# NOTE: If making very long task names, run `make`, and adjust the `%-20s` in the printf in the
# `help` task as needed!

APP_NAME=collections
VERSION=1.0.1
# REV=$(shell git rev-parse --short HEAD)
# BUILD_DATE=$(shell date -u +%Y-%m-%dT%H:%M:%S%z)
GOOS?=darwin
GOARCH?=amd64
DIST_NAME=${APP_NAME}

.DEFAULT_GOAL := help

.PHONY: help

test: ## Run test suite with race detection and coverage/profiling
	go test -race -coverprofile coverage.txt ./...

report_coverage: test ## Report coverage
	go install github.com/mattn/goveralls@latest
	${GOENV} goveralls -coverprofile=coverage.txt -service=circle-ci

compile: ## Compile project for specified GOOS/GOARCH
	GOOS=${GOOS} GOARCH=${GOARCH} go build -o "${DIST_NAME}" .

build: test compile ## Run tests, then compile the project

prepare_ci: ## Install CI-time tools
	go install $$(cat tools.ci)

update_ci: ## Update CI-time tools
	go install -u $$(cat tools.ci)

prepare_workstation: prepare_ci ## Install all (CI-time, and development-time) tools
	go install $$(cat tools.dev)

update_workstation: update_ci ## Update all (CI-time, and development-time) tools
	go install -u $$(cat tools.dev)

fmt: ## Format code
	gofmt -s -l -w $$(find . -name '*.go' -and -not -path './vendor/*')
	goimports -w $$(find . -name '*.go' -and -not -path './vendor/*')

lint: clean ## Run all linters
	$("GOENV: [${GOENV}]")
	${GOENV} go vet -stdmethods ./...
	${GOENV} go vet -vettool=$$(which nilness) ./...
	${GOENV} golangci-lint run

clean: ## Clean up
	${GOENV} go clean -cache -testcache ./...
	rm -Rf bin

tag: ## Tag the git repo with the current VERSION, and push tags upstream
	git tag v$(VERSION)
	git push --tags

cloc: ## Measure the volume of code in the project, excluding vendor, and such
	cloc . --exclude-dir=vendor

todo: ## Find all TODO comments in the code.
	find . -name "*.go" -and -not -path './vendor/*' -print0 | xargs -0 grep -n 'TODO'

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "%-20s %s\n", $$1, $$2}'
