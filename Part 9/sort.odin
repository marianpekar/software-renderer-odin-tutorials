package main

Sort :: proc {
    SortPoints,
    SortPointsAndUVs,
}

SortPoints :: proc(p1, p2, p3: ^Vector3) {
    if p1.y > p2.y {
        p1.x, p2.x = p2.x, p1.x
        p1.y, p2.y = p2.y, p1.y
        p1.z, p2.z = p2.z, p1.z
    }
    if p2.y > p3.y {
        p2.x, p3.x = p3.x, p2.x
        p2.y, p3.y = p3.y, p2.y
        p2.z, p3.z = p3.z, p2.z
    }
    if p1.y > p2.y {
        p1.x, p2.x = p2.x, p1.x
        p1.y, p2.y = p2.y, p1.y
        p1.z, p2.z = p2.z, p1.z
    }
}

SortPointsAndUVs :: proc(
    p1, p2, p3: ^Vector3, 
    uv1, uv2, uv3: ^Vector2
) {
    if p1.y > p2.y {
        p1.x, p2.x = p2.x, p1.x
        p1.y, p2.y = p2.y, p1.y
        p1.z, p2.z = p2.z, p1.z
        uv1.x, uv2.x = uv2.x, uv1.x
        uv1.y, uv2.y = uv2.y, uv1.y
    }
    if p2.y > p3.y {
        p2.x, p3.x = p3.x, p2.x
        p2.y, p3.y = p3.y, p2.y
        p2.z, p3.z = p3.z, p2.z
        uv2.x, uv3.x = uv3.x, uv2.x
        uv2.y, uv3.y = uv3.y, uv2.y
    }
    if p1.y > p2.y {
        p1.x, p2.x = p2.x, p1.x
        p1.y, p2.y = p2.y, p1.y
        p1.z, p2.z = p2.z, p1.z
        uv1.x, uv2.x = uv2.x, uv1.x
        uv1.y, uv2.y = uv2.y, uv1.y
    }
}