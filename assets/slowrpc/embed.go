package slowrpc

import (
	"embed"

	"github.com/ellight-hm-chang/slowrp/assets"
)

//go:embed static/*
var content embed.FS

func init() {
	assets.Register(content)
}
