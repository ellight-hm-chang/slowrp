package VORTEX_Access_Server

import (
	"embed"

	"github.com/ellight-hm-chang/VORTEX_Access/assets"
)

//go:embed static/*
var content embed.FS

func init() {
	assets.Register(content)
}
