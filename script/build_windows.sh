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
    echo "Building VORTEX_Access_Server for Windows amd64 (with garble)..."
    garble -seed=random build -trimpath -ldflags "${LDFLAGS}" -tags VORTEX_Access_Server -o bin/VORTEX_Access_Server.exe ./cmd/VORTEX_Access_Server
    echo "✓ VORTEX_Access_Server.exe built successfully"

    echo "Building VORTEX_Access for Windows amd64 (with garble)..."
    garble -seed=random build -trimpath -ldflags "${LDFLAGS}" -tags VORTEX_Access -o bin/VORTEX_Access.exe ./cmd/VORTEX_Access
    echo "✓ VORTEX_Access.exe built successfully"
else
    echo "Building VORTEX_Access_Server for Windows amd64..."
    go build -trimpath -ldflags "${LDFLAGS}" -tags VORTEX_Access_Server -o bin/VORTEX_Access_Server.exe ./cmd/VORTEX_Access_Server
    echo "✓ VORTEX_Access_Server.exe built successfully"

    echo "Building VORTEX_Access for Windows amd64..."
    go build -trimpath -ldflags "${LDFLAGS}" -tags VORTEX_Access -o bin/VORTEX_Access.exe ./cmd/VORTEX_Access
    echo "✓ VORTEX_Access.exe built successfully"
fi

echo ""
echo "All builds completed!"
ls -lh bin/*.exe

