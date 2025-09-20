package main

import rl "vendor:raylib"

main :: proc() {
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Renderer")

    mesh := MakeCube()
    camera := MakeCamera({0.0, 0.0, -3.0}, {0.0, 0.0, -1.0})
    light := MakeLight({0.0, 0.0, -3.0}, {0.0, 1.0, 0.0}, 1.0)
    zBuffer := new(ZBuffer)

    translation := Vector3{0.0, 0.0, 0.0}
    rotation := Vector3{0.0, 0.0, 0.0}
    scale: f32 = 1.0

    renderModesCount :: 4
    renderMode: i8 = renderModesCount - 1

    projectionMatrix := MakeProjectionMatrix(FOV, SCREEN_WIDTH, SCREEN_HEIGHT, NEAR_PLANE, FAR_PLANE)

    for !rl.WindowShouldClose() {
        deltaTime := rl.GetFrameTime()
        HandleInputs(&translation, &rotation, &scale, &renderMode, renderModesCount, deltaTime)

        translationMatrix := MakeTranslationMatrix(translation.x, translation.y, translation.z)
        rotationMatrix    := MakeRotationMatrix(rotation.x, rotation.y, rotation.z)
        scaleMatrix       := MakeScaleMatrix(scale, scale, scale)
        modelMatrix       := Mat4Mul(translationMatrix, Mat4Mul(rotationMatrix, scaleMatrix))
        viewMatrix        := MakeViewMatrix(camera.position, camera.target)
        viewMatrix         = Mat4Mul(viewMatrix, modelMatrix)
        
        ApplyTransformations(&mesh.transformedVertices, mesh.vertices, viewMatrix)

        rl.BeginDrawing()

        ClearZBuffer(zBuffer)
        
        switch renderMode {
            case 0: DrawWireframe(mesh.transformedVertices, mesh.triangles, projectionMatrix, rl.GREEN, false)
            case 1: DrawWireframe(mesh.transformedVertices, mesh.triangles, projectionMatrix, rl.GREEN, true)
            case 2: DrawUnlit(mesh.transformedVertices, mesh.triangles, projectionMatrix, rl.WHITE, zBuffer)
            case 3: DrawFlatShaded(mesh.transformedVertices, mesh.triangles, projectionMatrix, light, rl.WHITE, zBuffer)
        }

        rl.EndDrawing()
        
        rl.ClearBackground(rl.BLACK)
    }

    rl.CloseWindow()
}

ApplyTransformations :: proc(transformed: ^[]Vector3, original: []Vector3, mat: Matrix4x4) {
    for i in 0..<len(original) {
        transformed[i] = Mat4MulVec3(mat, original[i])
    }
}