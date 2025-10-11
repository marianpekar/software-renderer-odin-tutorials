package main

Light :: struct {
    direction: Vector3,
    strength: f32,
}

MakeLight :: proc(direction: Vector3, strength: f32) -> Light {
    return { 
        Vector3Normalize(direction), 
        strength 
    }
}