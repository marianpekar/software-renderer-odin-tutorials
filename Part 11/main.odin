package main

import rl "vendor:raylib"

main :: proc() {
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Renderer")

    mesh := LoadMeshFromObjFile("assets/monkey.obj")
    texture := LoadTextureFromFile("assets/uv_checker.png")
    camera := MakeCamera({0.0, 0.0, -3.0}, {0.0, 0.0, -1.0})
    light := MakeLight({0.0, 0.0, -3.0}, {0.0, 1.0, 0.0}, 1.0)
    zBuffer := new(ZBuffer)

    translation := Vector3{0.0, 0.0, 0.0}
    rotation := Vector3{0.0, 0.0, 0.0}
    scale: f32 = 1.0

    renderModesCount :: 8
    renderMode: i8 = renderModesCount - 1

    renderImage := rl.GenImageColor(SCREEN_WIDTH, SCREEN_HEIGHT, rl.LIGHTGRAY)
    renderTexture := rl.LoadTextureFromImage(renderImage)

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
        ApplyTransformations(&mesh.transformedNormals, mesh.normals, viewMatrix)

        rl.BeginDrawing()

        ClearZBuffer(zBuffer)
        
        switch renderMode {
            case 0: DrawWireframe(mesh.transformedVertices, mesh.triangles, projectionMatrix, rl.GREEN, false, &renderImage)
            case 1: DrawWireframe(mesh.transformedVertices, mesh.triangles, projectionMatrix, rl.GREEN, true, &renderImage)
            case 2: DrawUnlit(mesh.transformedVertices, mesh.triangles, projectionMatrix, rl.WHITE, zBuffer, &renderImage)
            case 3: DrawFlatShaded(mesh.transformedVertices, mesh.triangles, projectionMatrix, light, rl.WHITE, zBuffer, &renderImage)
            case 4: DrawPhongShaded(mesh.transformedVertices, mesh.triangles, mesh.transformedNormals, light, rl.WHITE, zBuffer, projectionMatrix, &renderImage)
            case 5: DrawTexturedUnlit(mesh.transformedVertices, mesh.triangles, mesh.uvs, texture, zBuffer, projectionMatrix, &renderImage)
            case 6: DrawTexturedFlatShaded(mesh.transformedVertices, mesh.triangles, mesh.uvs, light, texture, zBuffer, projectionMatrix, &renderImage)
            case 7: DrawTexturedPhongShaded(mesh.transformedVertices, mesh.triangles, mesh.uvs, mesh.transformedNormals, light, texture, zBuffer, projectionMatrix, &renderImage)
        }

        rl.UpdateTexture(renderTexture, renderImage.data)
        rl.DrawTexture(renderTexture, 0, 0, rl.WHITE)
        rl.DrawFPS(10, 10)
        rl.ImageClearBackground(&renderImage, rl.BLACK)

        rl.EndDrawing()
    }

    rl.CloseWindow()
}

ApplyTransformations :: proc(transformed: ^[]Vector3, original: []Vector3, mat: Matrix4x4) {
    for i in 0..<len(original) {
        transformed[i] = Mat4MulVec3(mat, original[i])
    }
}