# Valimail Collections

## Workstation Setup

### General

_All commands in setup instructions are relative to the root of this repo!_

```bash
brew cask install docker
brew install gimme cloc docker circleci

# Activate the Go version for this project -- do this in ALL TERMINAL WINDOWS
# in which you want to work on this project!
eval "$(gimme 1.11.2)"

# Install tools that are needed for both development and CI:
make prepare_workstation

# Update tools that are needed for both development and CI:
make update_workstation

# Make sure Docker is running, then run the CI process locally:
circleci build

# See what other things you have available:
make

# Note that `dep` is not folded into various make tasks!  It's up to you to use it as appropriate.
```

### Editor

You may find it of value to look for editor-specific plugins to integrate with:

* [gocode](https://github.com/mdempsky/gocode)
* [guru](https://golang.org/x/tools/cmd/guru)
* [goimports](https://golang.org/x/tools/cmd/goimports)
* [godoc](https://golang.org/x/tools/cmd/godoc)

Also, if your editor's build system defaults to running `make`, you'll need to change it to run
`make build`, as `make` with no task just shows the available tasks.

You _should_ set up an appropriate EditorConfig plugin for your editor, as well!


## Workflow

### General

```bash
# Activate the Go version for this project -- do this in ALL TERMINAL WINDOWS
# in which you want to work on this project!
eval "$(gimme 1.11.2)"

# See what targets are available:
make

# Run tests in a one-off manner, with race detection and coverage/profiling:
make test

# Run go test directly:
go test ./...

# Run all sorts of lint checks:
make lint -j 8

# Format / tidy your code:
make fmt

# Continuous testing:
goconvey
```
