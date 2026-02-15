package main

import rl "vendor:raylib"

ProjectionType :: enum {
    Perspective,
    Orthographic,
}

main :: proc() {
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Renderer")

    mesh := LoadMeshFromObjFile("assets/monkey.obj")
    texture := LoadTextureFromFile("assets/uv_checker.png")
    camera := MakeCamera({0.0, 0.0, -3.0}, {0.0, 0.0, -1.0})

    red_light  := MakeLight({-4.0,  0.0, -3.0}, { 1.0,  1.0, 0.0}, {1.0, 0.0, 0.0, 1.0})
    green_light := MakeLight({ 4.0,  0.0, -3.0}, {-1.0, -1.0, 0.0}, {0.0, 1.0, 0.0, 1.0})
    lights := []Light{red_light, green_light}

    ambient := Vector3{0.2, 0.2, 0.2}
    ambient2 := Vector3{0.1, 0.1, 0.2}

    zBuffer := new(ZBuffer)

    translation := Vector3{0.0, 0.0, 0.0}
    rotation := Vector3{0.0, 0.0, 0.0}
    scale: f32 = 1.0

    renderModesCount :: 8
    renderMode: i8 = renderModesCount - 1

    renderImage := rl.GenImageColor(SCREEN_WIDTH, SCREEN_HEIGHT, rl.LIGHTGRAY)
    renderTexture := rl.LoadTextureFromImage(renderImage)

    projectionMatrix : Matrix4x4
    projectionType : ProjectionType = .Perspective
    perspectiveMatrix := MakePerspectiveMatrix(FOV, SCREEN_WIDTH, SCREEN_HEIGHT, NEAR_PLANE, FAR_PLANE)
    orthographicMatrix := MakeOrthographicMatrix(SCREEN_WIDTH, SCREEN_HEIGHT, NEAR_PLANE, FAR_PLANE)

    for !rl.WindowShouldClose() {
        deltaTime := rl.GetFrameTime()

        HandleInputs(&translation, &rotation, &scale, &renderMode, renderModesCount, &projectionType, deltaTime)

        switch projectionType {
            case .Perspective: projectionMatrix = perspectiveMatrix
            case .Orthographic: projectionMatrix = orthographicMatrix
        }

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
            case 0: DrawWireframe(mesh.transformedVertices, mesh.triangles, projectionMatrix, projectionType, rl.GREEN, false, &renderImage)
            case 1: DrawWireframe(mesh.transformedVertices, mesh.triangles, projectionMatrix, projectionType, rl.GREEN, true, &renderImage)
            case 2: DrawUnlit(mesh.transformedVertices, mesh.triangles, projectionMatrix, projectionType, rl.WHITE, zBuffer, &renderImage)
            case 3: DrawFlatShaded(mesh.transformedVertices, mesh.triangles, projectionMatrix, projectionType, lights, rl.WHITE, zBuffer, &renderImage, ambient)
            case 4: DrawPhongShaded(mesh.transformedVertices, mesh.triangles, mesh.transformedNormals, lights, rl.WHITE, zBuffer, projectionMatrix, projectionType, &renderImage, ambient2)
            case 5: DrawTexturedUnlit(mesh.transformedVertices, mesh.triangles, mesh.uvs, texture, zBuffer, projectionMatrix, projectionType, &renderImage)
            case 6: DrawTexturedFlatShaded(mesh.transformedVertices, mesh.triangles, mesh.uvs, lights, texture, zBuffer, projectionMatrix, projectionType, &renderImage, ambient)
            case 7: DrawTexturedPhongShaded(mesh.transformedVertices, mesh.triangles, mesh.uvs, mesh.transformedNormals, lights, texture, zBuffer, projectionMatrix, projectionType, &renderImage, ambient2)
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