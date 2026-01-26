#!/bin/bash

# Install garble if not exists
# go install mvdan.cc/garble@v0.14.2

set -e

# Clean build cache to avoid version mismatch errors
echo "Cleaning build cache..."
go clean -cache -modcache
rm -rf ~/.cache/garble 2>/dev/null || true
rm -rf ~/.cache/go-build 2>/dev/null || true
echo "✓ Cache cleaned"
echo ""

LDFLAGS="-s -w"
export CGO_ENABLED=0
export GOARCH=amd64
export GOOS=windows
export GOCACHE=$(mktemp -d)  # Use fresh temporary cache

# Try with standard go build first (more reliable for cross-compilation)
USE_GARBLE=${USE_GARBLE:-false}

if [ "$USE_GARBLE" = "true" ]; then
    echo "Building slowrps for Windows amd64 (with garble)..."
    garble -seed=random build -trimpath -ldflags "${LDFLAGS}" -tags slowrps -o bin/slowrps.exe ./cmd/slowrps
    echo "✓ slowrps.exe built successfully"

    echo "Building slowrpc for Windows amd64 (with garble)..."
    garble -seed=random build -trimpath -ldflags "${LDFLAGS}" -tags slowrpc -o bin/slowrpc.exe ./cmd/slowrpc
    echo "✓ slowrpc.exe built successfully"
else
    echo "Building slowrps for Windows amd64..."
    go build -trimpath -ldflags "${LDFLAGS}" -tags slowrps -o bin/slowrps.exe ./cmd/slowrps
    echo "✓ slowrps.exe built successfully"

    echo "Building slowrpc for Windows amd64..."
    go build -trimpath -ldflags "${LDFLAGS}" -tags slowrpc -o bin/slowrpc.exe ./cmd/slowrpc
    echo "✓ slowrpc.exe built successfully"
fi

echo ""
echo "All builds completed!"
ls -lh bin/*.exe

