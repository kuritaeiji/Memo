.DEFAULT_GOAL := build

tidy:
	go mod tidy
.PHONY: tidy

fmt: tidy
	goimports -l -w cmd
.PHONY: fmt

lint: fmt
	golangci-lint run ./...
.PHONY: lint

gen: lint
	go generate ./...
.PHONY: gen

run: gen
	go run cmd/main.go
.PHONY: run

build:
	go build -o main cmd/main.go
.PHONY: build

test: gen
	go test -v -cover -coverprofile=cover.out ./...
	go tool cover -html=cover.out -o cover.html
.PHONY: test