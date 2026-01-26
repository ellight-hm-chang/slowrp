export PATH := $(GOPATH)/bin:$(PATH)
export GO111MODULE=on
LDFLAGS := -s -w

all: fmt build

build: VORTEX_Access_Server VORTEX_Access

# compile assets into binary file
file:
	rm -rf ./assets/VORTEX_Access_Server/static/*
	rm -rf ./assets/VORTEX_Access/static/*
	cp -rf ./web/VORTEX_Access_Server/dist/* ./assets/VORTEX_Access_Server/static
	cp -rf ./web/VORTEX_Access/dist/* ./assets/VORTEX_Access/static

fmt:
	go fmt ./...

fmt-more:
	gofumpt -l -w .

gci:
	gci write -s standard -s default -s "prefix(github.com/ellight-hm-chang/VORTEX_Access/)" ./

vet:
	go vet ./...

VORTEX_Access_Server:
	env CGO_ENABLED=0 go build -trimpath -ldflags "$(LDFLAGS)" -tags VORTEX_Access_Server -o bin/VORTEX_Access_Server ./cmd/VORTEX_Access_Server

VORTEX_Access:
	env CGO_ENABLED=0 go build -trimpath -ldflags "$(LDFLAGS)" -tags VORTEX_Access -o bin/VORTEX_Access ./cmd/VORTEX_Access

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

e2e-compatibility-last-VORTEX_Access:
	if [ ! -d "./lastversion" ]; then \
		TARGET_DIRNAME=lastversion ./hack/download.sh; \
	fi
	VORTEX_ACCESS_PATH="`pwd`/lastversion/VORTEX_Access" ./hack/run-e2e.sh
	rm -r ./lastversion

e2e-compatibility-last-VORTEX_Access_Server:
	if [ ! -d "./lastversion" ]; then \
		TARGET_DIRNAME=lastversion ./hack/download.sh; \
	fi
	VORTEX_ACCESS_SERVER_PATH="`pwd`/lastversion/VORTEX_Access_Server" ./hack/run-e2e.sh
	rm -r ./lastversion

alltest: vet gotest e2e
	
clean:
	rm -f ./bin/VORTEX_Access
	rm -f ./bin/VORTEX_Access_Server
	rm -rf ./lastversion
