package main

import rl "vendor:raylib"

ProjectionType :: enum {
    Perspective,
    Orthographic,
}

main :: proc() {
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Renderer")

    cube := LoadModel("assets/cube.obj", "assets/box.png")
    monkey := LoadModel("assets/monkey.obj", "assets/uv_checker.png")

    cube.translation = {-1.25, 0.0, 0.5}
    monkey.translation = {1.5, 0.0, 0.5}
    monkey.rotation = {180, 0.0, 0.0}
    monkey.wireColor = rl.RED

    models := []Model{cube, monkey}

    camera := MakeCamera({0.0, 0.0, -3.0}, {0.0, 0.0, -1.0})

    red_light  := MakeLight({-4.0,  0.0, -3.0}, { 1.0,  1.0, 0.0}, {1.0, 0.0, 0.0, 1.0})
    green_light := MakeLight({ 4.0,  0.0, -3.0}, {-1.0, -1.0, 0.0}, {0.0, 1.0, 0.0, 1.0})
    lights := []Light{red_light, green_light}

    ambient := Vector3{0.2, 0.2, 0.2}
    ambient2 := Vector3{0.1, 0.1, 0.2}

    zBuffer := new(ZBuffer)

    renderModesCount :: 8
    renderMode: i8 = renderModesCount - 1

    renderImage := rl.GenImageColor(SCREEN_WIDTH, SCREEN_HEIGHT, rl.LIGHTGRAY)
    renderTexture := rl.LoadTextureFromImage(renderImage)

    projectionMatrix : Matrix4x4
    projectionType : ProjectionType = .Perspective
    perspectiveMatrix := MakePerspectiveMatrix(FOV, SCREEN_WIDTH, SCREEN_HEIGHT, NEAR_PLANE, FAR_PLANE)
    orthographicMatrix := MakeOrthographicMatrix(SCREEN_WIDTH, SCREEN_HEIGHT, NEAR_PLANE, FAR_PLANE)

    selectedModelIdx := 0
    modelCount := len(models)
    selectedModel := &models[selectedModelIdx]

    for &model in models {
        ApplyTransformations(&model, camera)
    }

    for !rl.WindowShouldClose() {
        deltaTime := rl.GetFrameTime()

        selectedModel := &models[selectedModelIdx]

        HandleInputs(selectedModel, &selectedModelIdx, modelCount, &renderMode, renderModesCount, &projectionType, deltaTime)

        ApplyTransformations(selectedModel, camera)

        switch projectionType {
            case .Perspective: projectionMatrix = perspectiveMatrix
            case .Orthographic: projectionMatrix = orthographicMatrix
        }

        rl.BeginDrawing()

        ClearZBuffer(zBuffer)
        
        for &model in models {
            switch renderMode {
                case 0: DrawWireframe(model.mesh.transformedVertices, model.mesh.triangles, projectionMatrix, projectionType, model.wireColor, false, &renderImage)
                case 1: DrawWireframe(model.mesh.transformedVertices, model.mesh.triangles, projectionMatrix, projectionType, model.wireColor, true, &renderImage)
                case 2: DrawUnlit(model.mesh.transformedVertices, model.mesh.triangles, projectionMatrix, projectionType, rl.WHITE, zBuffer, &renderImage)
                case 3: DrawFlatShaded(model.mesh.transformedVertices, model.mesh.triangles, projectionMatrix, projectionType, lights, rl.WHITE, zBuffer, &renderImage, ambient)
                case 4: DrawPhongShaded(model.mesh.transformedVertices, model.mesh.triangles, model.mesh.transformedNormals, lights, rl.WHITE, zBuffer, projectionMatrix, projectionType, &renderImage, ambient2)
                case 5: DrawTexturedUnlit(model.mesh.transformedVertices, model.mesh.triangles, model.mesh.uvs, model.texture, zBuffer, projectionMatrix, projectionType, &renderImage)
                case 6: DrawTexturedFlatShaded(model.mesh.transformedVertices, model.mesh.triangles, model.mesh.uvs, lights, model.texture, zBuffer, projectionMatrix, projectionType, &renderImage, ambient)
                case 7: DrawTexturedPhongShaded(model.mesh.transformedVertices, model.mesh.triangles, model.mesh.uvs, model.mesh.transformedNormals, lights, model.texture, zBuffer, projectionMatrix, projectionType, &renderImage, ambient2)
            }
        }

        rl.UpdateTexture(renderTexture, renderImage.data)
        rl.DrawTexture(renderTexture, 0, 0, rl.WHITE)
        rl.DrawFPS(10, 10)
        rl.ImageClearBackground(&renderImage, rl.BLACK)

        rl.EndDrawing()
    }

    rl.CloseWindow()
}