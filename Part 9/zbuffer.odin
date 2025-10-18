package main 

ZBuffer :: [SCREEN_WIDTH * SCREEN_HEIGHT]f32

ClearZBuffer :: proc(zBuffer: ^ZBuffer) {
    for i in 0..<len(zBuffer) {
        zBuffer[i] = 999_999;
    }
}