FROM golang:1.10-alpine AS build-go
RUN apk add --update --no-cache make git
RUN go get github.com/Masterminds/glide
COPY . /go/src/github.com/Jesse0Michael/go-rest-assured
WORKDIR /go/src/github.com/Jesse0Michael/go-rest-assured
RUN make install-deps
RUN make install


# 3) BUILD FINAL IMAGE
FROM alpine
RUN apk --no-cache add ca-certificates
WORKDIR /app/
COPY --from=build-go /go/bin/go-rest-assured /app/go-rest-assured

EXPOSE 8080
CMD ["/app/go-rest-assured","-port","8080"]

