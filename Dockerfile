# step 1 - build image
FROM golang:1.15.1-alpine AS builder

WORKDIR /go/src

COPY . .

RUN go build -mod vendor -o podlist ./podlist.go

# step 2 - run image
FROM alpine:3.12.0 AS runner

COPY --from=builder /go/src/podlist /usr/bin/podlist

CMD ["/usr/bin/podlist"]