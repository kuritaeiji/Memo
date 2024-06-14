FROM golang:1.22.3-bullseye

WORKDIR /go/app

# gopls: 言語サーバー  dlv: デバッガー  goimports: フォーマッター  glangci-lint: リンター  mockery: モック作成
RUN apt update && \
    go install golang.org/x/tools/gopls@latest && \
    go install github.com/go-delve/delve/cmd/dlv@latest && \
    go install golang.org/x/tools/cmd/goimports@latest && \
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.55.2 && \
    go install github.com/vektra/mockery/v2@v2.37.1
