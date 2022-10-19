raw"""
    transform(a, b, c, d, e, f) -> Nothing
    transform(matrix) -> Nothing
    transform(::Nothing) -> Nothing

Premultiplies current coordinate system by specified `3×2` matrix.

The `matrix` is interpreted as follows:

```math
\begin{bmatrix}
   a & d \\
   b & e \\
   c & f
\end{bmatrix}
```
Additionally, you can provide each component of the `matrix` individually.

The current transformation matrix is a affine matrix:

```math
\begin{bmatrix}
   sx & kx & tx \\
   ky & sy & ty \\
    0 &  0 &  1 \\
\end{bmatrix}
```

Where: `sx`, `sy` define scaling, `kx`, `ky` skewing, and `tx`, `ty` translation.

Passing `nothing` as argument resets the current transform to a identity matrix.
"""
transform(a::Real, b::Real, c::Real, d::Real, e::Real, f::Real) = nvgTransform(@vg, a, b, c, d, e, f)
transform(m::AbstractMatrix{<:Real}) = transform(m...)
transform(::Nothing) = nvgResetTransform(@vg)

"""
    translate(x, y) -> Nothing

Translates current coordinate system.
"""
translate(x::Real, y::Real) = nvgTranslate(@vg, Float32(x), Float32(y))

"""
    rotate(angle) -> Nothing

Rotates current coordinate system. Angle is specified in radians.
"""
rotate(angle::Real) = nvgRotate(@vg, Float32(angle))

"""
    skewx(angle) -> Nothing

Skews the current coordinate system along X axis. Angle is specified in radians.
"""
skewx(angle::Real) = nvgSkewX(@vg, Float32(angle))
"""
    skewy(angle) -> Nothing

Skews the current coordinate system along Y axis. Angle is specified in radians.
"""
skewy(angle::Real) = nvgSkewY(@vg, Float32(angle))

"""
    scale(x, [y = x]) -> Nothing

Scales the current coordinate system.
"""
scale(x::Real, y::Real=x) = nvgScale(@vg, Float32(x), Float32(y))

raw"""
    transformation() -> Matrix{Float32}

Returns the current transformation matrix:

```math
\begin{bmatrix}
   a & c & e \\
   b & d & f \\
   0 & 0 & 1
\end{bmatrix}
```
"""
function transformation()
    matrix = Matrix{Float32}(undef, (3, 3))
    nvgCurrentTransform(@vg, matrix)
    return matrix
end
