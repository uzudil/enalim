package main

import (
	"flag"
	"log"
	"runtime"

	"github.com/go-gl/glfw/v3.3/glfw"
	"github.com/uzudil/isongn/gfx"
	"github.com/uzudil/isongn/runner"
	"github.com/uzudil/isongn/script"
)

func init() {
	// GLFW event handling must run on the main OS thread
	runtime.LockOSThread()
}

func main() {
	winWidth := flag.Int("width", 800, "Window width (default: 800)")
	winHeight := flag.Int("height", 600, "Window height (default: 600)")
	fps := flag.Float64("fps", 60, "Frames per second")
	flag.Parse()

	if err := glfw.Init(); err != nil {
		log.Fatalln("failed to initialize glfw:", err)
	}
	defer glfw.Terminate()

	var game gfx.Game = runner.NewRunner()
	script.InitScript()
	app := gfx.NewApp(game, ".", *winWidth, *winHeight, *fps)
	app.Run()
}
