.PHONY: build depend install test lint clean vet

PROG:=autoscale
BUILD_DIR:=.build
DIST_DIR:=.dist
TARGET:=$(BUILD_DIR)/$(PROG)

VERSION:=0.1
BUILD:=$(shell git rev-parse HEAD)
GIT_TAG:=$(shell git describe --exact-match HEAD 2>/dev/null)
UNCOMMITED_CHANGES:=$(shell git diff-index --shortstat HEAD 2>/dev/null)

ifeq (v$(VERSION), $(GIT_TAG))
BUILD_TYPE:=RELEASE
else
BUILD_TYPE:=SNAPSHOT
endif

ifneq ($(strip $(UNCOMMITED_CHANGES)),)
BUILD_TYPE:=DEV
BUILD_DATE:=$(shell date +%FT%T%z)
endif

default: build

build: vet
	go build -v -ldflags "-X main.Version=$(VERSION) -X main.BuildType=$(BUILD_TYPE) -X main.Build=$(BUILD) -X main.BuildDate=$(BUILD_DATE)" -o $(TARGET)

clean:
	go clean -i ./... && \
if [ -d $(BUILD_DIR) ] ; then rm -rf $(BUILD_DIR) ; fi && \
if [ -d $(DIST_DIR) ] ; then rm -rf $(DIST_DIR) ; fi

depend:
	go get -t -u github.com/streadway/amqp
	go get -t -u github.com/mattn/go-sqlite3
	if [ ! -d $(GOPATH)/src/k8s.io/kubernetes ] ; then git clone https://github.com/kubernetes/kubernetes.git $(GOPATH)/src/k8s.io/kubernetes ; fi

install:
	go install $(TARGET)

lint:
	golint ./...

test:
	go test -v ./...

vet:
	go tool vet -all -shadow *.go
