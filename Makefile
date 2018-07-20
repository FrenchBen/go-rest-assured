GO ?= go
COVERAGEDIR = coverage
ifdef CIRCLE_ARTIFACTS
	COVERAGEDIR=$(CIRCLE_ARTIFACTS)/coverage
endif

LDFLAGS = -ldflags '-X main.gitSHA=$(shell git rev-parse HEAD)'

DOCKER_IMG = go-rest-assured
DOCKER_TAG = latest

all: build test cover
install-deps:
	glide install
build:
	if [ ! -d bin ]; then mkdir bin; fi
	$(GO) build $(LDFLAGS) -v -o bin/go-rest-assured
install:
	if [ ! -d bin ]; then mkdir bin; fi
	$(GO) install $(LDFLAGS)
fmt:
	find . -not -path "./vendor/*" -name '*.go' -type f | sed 's#\(.*\)/.*#\1#' | sort -u | xargs -n1 -I {} bash -c "cd {} && goimports -w *.go && gofmt -w -l -s *.go"
test:
	if [ ! -d $(COVERAGEDIR) ]; then mkdir $(COVERAGEDIR); fi
	$(GO) test -v ./assured -cover -coverprofile=$(COVERAGEDIR)/assured.coverprofile
cover:
	if [ ! -d $(COVERAGEDIR) ]; then mkdir $(COVERAGEDIR); fi
	$(GO) tool cover -html=$(COVERAGEDIR)/assured.coverprofile -o $(COVERAGEDIR)/assured.html
coveralls:
	if [ ! -d $(COVERAGEDIR) ]; then mkdir $(COVERAGEDIR); fi
	gover $(COVERAGEDIR) $(COVERAGEDIR)/coveralls.coverprofile
	goveralls -coverprofile=$(COVERAGEDIR)/coveralls.coverprofile  -service=circle-ci -repotoken=$(COVERALLS_TOKEN)
assert-no-diff:
	test -z "$(shell git status --porcelain)"
img:
	docker image build --tag $(DOCKER_IMG):$(DOCKER_TAG) .
clean:
	$(GO) clean
	rm -f bin/go-rest-assured
	rm -rf coverage/
	rm -rf vendor/
