export PATH := $(GOPATH)/bin:$(PATH)
export GO111MODULE=on
LDFLAGS := -s -w

all: fmt build

build: slowrps slowrpc

# compile assets into binary file
file:
	rm -rf ./assets/slowrps/static/*
	rm -rf ./assets/slowrpc/static/*
	cp -rf ./web/slowrps/dist/* ./assets/slowrps/static
	cp -rf ./web/slowrpc/dist/* ./assets/slowrpc/static

fmt:
	go fmt ./...

fmt-more:
	gofumpt -l -w .

gci:
	gci write -s standard -s default -s "prefix(github.com/ellight-hm-chang/slowrp/)" ./

vet:
	go vet ./...

slowrps:
	env CGO_ENABLED=0 go build -trimpath -ldflags "$(LDFLAGS)" -tags slowrps -o bin/slowrps ./cmd/slowrps

slowrpc:
	env CGO_ENABLED=0 go build -trimpath -ldflags "$(LDFLAGS)" -tags slowrpc -o bin/slowrpc ./cmd/slowrpc

test: gotest

gotest:
	go test -v --cover ./assets/...
	go test -v --cover ./cmd/...
	go test -v --cover ./client/...
	go test -v --cover ./server/...
	go test -v --cover ./pkg/...

e2e:
	./hack/run-e2e.sh

e2e-trace:
	DEBUG=true LOG_LEVEL=trace ./hack/run-e2e.sh

e2e-compatibility-last-slowrpc:
	if [ ! -d "./lastversion" ]; then \
		TARGET_DIRNAME=lastversion ./hack/download.sh; \
	fi
	SLOWRPC_PATH="`pwd`/lastversion/slowrpc" ./hack/run-e2e.sh
	rm -r ./lastversion

e2e-compatibility-last-slowrps:
	if [ ! -d "./lastversion" ]; then \
		TARGET_DIRNAME=lastversion ./hack/download.sh; \
	fi
	SLOWRPS_PATH="`pwd`/lastversion/slowrps" ./hack/run-e2e.sh
	rm -r ./lastversion

alltest: vet gotest e2e
	
clean:
	rm -f ./bin/slowrpc
	rm -f ./bin/slowrps
	rm -rf ./lastversion
