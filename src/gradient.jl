abstract type Gradient end

"""
    LinearGradient(sx, sy, ex, ey, icol, ocol) -> LinearGradient

Creates a linear gradient. Parameters `(sx, sy)-(ex, ey)` specify the
start and end coordinates of the linear gradient, `icol` specifies the
start color and `ocol` the end color.

The gradient is transformed by the current transform when it is passed
to [`setfill`](@ref) or [`setstroke`](@ref).
"""
struct LinearGradient <: Gradient
    paint::NVGpaint
end

"""
    BoxGradient(x, y, w, h, r, f, icol, ocol) -> BoxGradient

Creates a box gradient. Box gradient is a feathered rounded rectangle, it is useful for
rendering drop shadows or highlights for boxes. Parameters `(x, y)` define the top-left
corner of the rectangle, `(w, h)` define the size of the rectangle, `r` defines the
corner radius, and `f` feather. Feather defines how blurry the border of the rectangle is.

Parameter `icol` specifies the inner color and `ocol` the outer color of the gradient.

The gradient is transformed by the current transform when it is passed to
[`setfill`](@ref) or [`setstroke`](@ref).
"""
struct BoxGradient <: Gradient
    paint::NVGpaint
end

"""
    RadialGradient(cx, cy, inr, onr, icol, ocol) -> RadialGradient

Creates a radial gradient. Parameters `(cx, cy)` specify the center,
`inr` and `outr` specify the inner and outer radius of the gradient,
`icol` specifies the start color and `ocol` the end color.

The gradient is transformed by the current transform when it is passed to
[`setfill`](@ref) or [`setstroke`](@ref).
"""
struct RadialGradient <: Gradient
    paint::NVGpaint
end

LinearGradient(sx::Real,
    sy::Real,
    ex::Real,
    ey::Real,
    icol::ColorLike,
    ocol::ColorLike
) = LinearGradient(nvgLinearGradient(@vg, sx, sy, ex, ey, rgba(icol), rgba(ocol)))

BoxGradient(x::Real,
    y::Real,
    w::Real,
    h::Real,
    r::Real,
    f::Real,
    icol::ColorLike,
    ocol::ColorLike
) = BoxGradient(nvgBoxGradient(@vg, x, y, w, h, r, f, rgba(icol), rgba(ocol)))

RadialGradient(cx::Real,
    cy::Real,
    inr::Real,
    onr::Real,
    icol::ColorLike,
    ocol::ColorLike
) = RadialGradient(nvgRadialGradient(@vg, cx, cy, inr, onr, rgba(icol), rgba(ocol)))
