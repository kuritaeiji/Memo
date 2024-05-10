FROM golang:1.22.3-bullseye as builder

WORKDIR /go/app

COPY . .

RUN go mod tidy && go build -o main main.go

FROM ubuntu:22.04 as production

USER 1000

WORKDIR /go/app

COPY --from=builder /go/app/main ./main

ENTRYPOINT [ "./main" ]