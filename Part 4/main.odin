package main

import rl "vendor:raylib"

main :: proc() {
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Renderer")

    mesh := MakeCube()

    for !rl.WindowShouldClose() {

        // TODO:

        rl.EndDrawing()
    }

    rl.CloseWindow()
}