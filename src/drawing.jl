# --------------------- Path handling --------------------- #

doaction(action) = throw(ArgumentError("No action defined for $(repr(action))"))

function doaction(action::Symbol)
    action == :fill       ? fillpath()   :
    action == :stroke     ? strokepath() :
    action == :fillstroke ? fillstroke() :
    action == :strokefill ? fillstroke() :
    action == :path       ? nothing      :
    throw(ArgumentError("""Invalid action: :$action. Valid actions are:
        :path         -> Add the shape to the current path instead of drawing it.
        :fill         -> Draw the shape and fill it.
        :stroke       -> Draw the shape and stroke it.
        :fillstroke   -> Draw the shape, fill and stroke it.
        :strokefill   -> Draw the shape, fill and stroke it.
    """))
end

"""
    beginpath()

Clears the current path and sub-paths.
"""
beginpath() = nvgBeginPath(@vg)

beginpath(action) = action != :path && beginpath()

"""
    strokepath()

Fills the current path with current stroke style.
"""
strokepath() = nvgStroke(@vg)

"""
    fillpath()

Fills the current path with current fill style.
"""
fillpath() = nvgFill(@vg)

"""
    fillstroke()

Fill and stroke the current path.

Calling this function is the same as doing:

    fillpath()
    strokepath()
"""
fillstroke() = (fillpath(); strokepath())

"""
    closepath()

Closes current sub-path with a line segment.
"""
closepath() = nvgClosePath(@vg)

"""
    winding(dir)

Sets the current sub-path winding.

`dir` can be either `:ccw` (counter clock-wise) or `:cw` (clock-wise).
"""
winding(dir::Symbol) = nvgPathWinding(@vg,
    dir == :ccw  ? NVG_CCW  :
    dir == :cw   ? NVG_CW   :
    dir == :hole ? NVG_HOLE :
    error("In winding(), expected :ccw or :cw, got: $dir")
)

"""
    moveto(x, y)
    moveto(point)

Starts new sub-path with specified point as first point.
"""
moveto(x::Real, y::Real) = nvgMoveTo(@vg, x, y)

"""
    lineto(x, y)
    lineto(point)

Adds line segment from the last point in the path to the specified point.
"""
lineto(x::Real, y::Real) = nvgLineTo(@vg, x, y)

# --------------------- Basic Shapes --------------------- #

"""
    line(x1, y1, x2, y2; action=:path)
    line(x1, y1, x2, y2, action)

Draws a line segment between two points.
"""
function line(x1::Real, y1::Real, x2::Real, y2::Real; action=:path)
    beginpath(action)
    moveto(x1, y1)
    lineto(x2, y2)
    doaction(action)
end

function line(x1::Real, y1::Real, x2::Real, y2::Real, action)
    line(x1, y1, x2, y2; action)
end

"""
    cubic(c1x, c1y, c2x, c2y, x, y; action=:path)
    cubic(c1x, c1y, c2x, c2y, x, y, action)
    cubic(ox, oy, c1x, c1y, c2x, c2y, x, y; action=:path)
    cubic(ox, oy, c1x, c1y, c2x, c2y, x, y, action)

Draws a cubic bezier curve with control points `(c1x, c1y)` and `(c2x, c2y)`
to the point `(x, y)`.

The starting point `(ox, oy)` can be omitted, in that case, the last point on
the path will be used instead.
"""
function cubic(c1x::Real,
    c1y::Real,
    c2x::Real,
    c2y::Real,
    x  ::Real,
    y  ::Real;
    action=:path
)
    beginpath(action)
    nvgBezierTo(@vg, c1x, c1y, c2x, c2y, x, y)
    doaction(action)
end

function cubic(c1x::Real,
    c1y::Real,
    c2x::Real,
    c2y::Real,
    x  ::Real,
    y  ::Real,
    action,
)
    cubic(c1x, c1y, c2x, c2y, x, y; action)
end

function cubic(ox::Real,
    oy ::Real,
    c1x::Real,
    c1y::Real,
    c2x::Real,
    c2y::Real,
    x  ::Real,
    y  ::Real;
    action=:path
)
    beginpath(action)
    moveto(ox, oy)
    cubic(c1x, c1y, c2x, c2y, x, y; action)
end

function cubic(ox::Real,
    oy ::Real,
    c1x::Real,
    c1y::Real,
    c2x::Real,
    c2y::Real,
    x  ::Real,
    y  ::Real,
    action
)
    cubic(ox, oy, c1x, c1y, c2x, c2y, x, y; action)
end

"""
    quadratic(cx, cy, x, y; action=:path)
    quadratic(cx, cy, x, y, action)
    quadratic(ox, oy, cx, cy, x, y; action=:path)
    quadratic(ox, oy, cx, cy, x, y, action)

Draws a quadratic bezier curve with control point `(cx, cy)` to the point `(x, y)`.

The starting point `(ox, oy)` can be omitted, in that case, the last
point on the path will be used instead.
"""
function quadratic(cx::Real, cy::Real, x::Real, y::Real; action=:path)
    beginpath(action)
    nvgQuadTo(@vg, cx, cy, x, y)
    doaction(action)
end

function quadratic(cx::Real, cy::Real, x::Real, y::Real, action)
    quadratic(cx, cy, x, y; action)
end

function quadratic(ox::Real, oy::Real, cx::Real, cy::Real, x::Real, y::Real; action=:path)
    beginpath(action)
    moveto(ox, oy)
    quadratic(cx, cy, x, y, action)
end

function quadratic(ox::Real, oy::Real, cx::Real, cy::Real, x::Real, y::Real, action)
    quadratic(ox, oy, cx, cy, x, y; action)
end

"""
    arcto(x1, y1, x2, y2, radius; action=:path)
    arcto(x1, y1, x2, y2, radius, action)

Draws an arc segment between three points.
"""
function arcto(x1::Real, y1::Real, x2::Real, y2::Real, radius::Real; action=:path)
    beginpath(action)
    nvgArcTo(@vg, Cfloat(x1), Cfloat(y1), Cfloat(x2), Cfloat(y2), Cfloat(radius))
    doaction(action)
end

function arcto(x1::Real, y1::Real, x2::Real, y2::Real, radius::Real, action)
    arcto(x1, y1, x2, y2, radius; action)
end

"""
    arc(cx, cy, radius, θ₀, θ₁; action=:path, dir=:ccw)
    arc(cx, cy, radius, θ₀, θ₁, action; dir=:ccw)

Draws a circle shaped arc segment centered at `(cx, cy)` with radius `radius`,
where `θ₀` and `θ₁` are the starting and ending angles, respectively.

`dir` is the direction which the arc is drawn, can be
either `:ccw` (counter clockwise) or `:cw` (clockwise).
"""
function arc(cx::Real, cy::Real, radius::Real, θ₀::Real, θ₁::Real; action=:path, dir=:ccw)
    direction =
        dir == :ccw ? NVG_CCW :
        dir == :cw ? NVG_CW :
        error("In arc(), expected dir to be either :ccw or :cw, got: :$dir")

    beginpath(action)
    nvgArc(@vg, Cfloat(cx), Cfloat(cy), Cfloat(radius), Cfloat(θ₀), Cfloat(θ₁), direction)
    doaction(action)
end

function arc(cx::Real, cy::Real, radius::Real, θ₀::Real, θ₁::Real, action; dir=:ccw)
    arc(cx, cy, radius, θ₀, θ₁; action, dir)
end

"""
    rect(x, y, width, height; action=:path)
    rect(x, y, width, height, action)

Draws a rectangle with top-left corner at `(x, y)`.
"""
function rect(x::Real, y::Real, width::Real, height::Real; action=:path)
    beginpath(action)
    nvgRect(@vg, Cfloat(x), Cfloat(y), Cfloat(width), Cfloat(height))
    doaction(action)
end

function rect(x::Real, y::Real, width::Real, height::Real, action)
    rect(x, y, width, height; action)
end

"""
    rrect(x, y, width, height, radii::NTuple{4}; action=:path)
    rrect(x, y, width, height, radii::NTuple{4}, action)
    rrect(x, y, width, height, radius::Real; action=:path)
    rrect(x, y, width, height, radius::Real, action)

Draws a rounded rectangle with top-left corner at `(x, y)`.

`radius` can be a `tuple` of 4 numbers defining the *radii* for each corner
individually, with the order: `(top-left, top-right, bottom-right, bottom-left)`.

The *radii* can be equal for all corners by passing `radius` as a single number.
"""
function rrect(x::Real, y::Real, width::Real, height::Real, radius::Real; action=:path)
    beginpath(action)
    nvgRoundedRect(@vg, Cfloat(x), Cfloat(y), Cfloat(width), Cfloat(height), Cfloat(radius))
    doaction(action)
end

function rrect(x::Real, y::Real, width::Real, height::Real, radius::Real, action)
    rrect(x, y, width, height, radius::Real; action)
end

function rrect(x::Real, y::Real, width::Real, height::Real, radii::NTuple{4,<:Real}; action=:path)
    beginpath(action)
    nvgRoundedRectVarying(@vg, Cfloat(x), Cfloat(y), Cfloat(width), Cfloat(height), Cfloat.(radii)...)
    doaction(action)
end

function rrect(x::Real, y::Real, width::Real, height::Real, radii::NTuple{4,<:Real}, action)
    rrect(x, y, width, height, radii; action)
end

function box(x::Real, y::Real, width::Real, height::Real; radii=0, action=:path)
    x = x - width / 2
    y = y - height / 2
    if radii == 0
        rect(x, y, width, height; action)
    else
        rrect(x, y, width, height, radii; action)
    end
end

function box(x::Real, y::Real, width::Real, height::Real, action; radii=0)
    box(x, y, width, height; action, radii)
end

"""
    ellipse(cx, cy, rx, ry; action=:path)
    ellipse(cx, cy, rx, ry, action)

Draws a ellipse centered at `(cx, cy)`, with horizontal and vertical
radii `rx` and `ry`, respectively.
"""
function ellipse(cx::Real, cy::Real, rx::Real, ry::Real; action=:path)
    beginpath(action)
    nvgEllipse(@vg, Cfloat(cx), Cfloat(cy), Cfloat(rx), Cfloat(ry))
    doaction(action)
end

function ellipse(cx::Real, cy::Real, rx::Real, ry::Real, action)
    ellipse(cx, cy, rx, ry; action)
end

"""
    circle(cx, cy, radius; action=:path)
    circle(cx, cy, radius, action)

Draws a circle centered at `(x, y)`.
"""
function circle(cx::Real, cy::Real, radius::Real; action=:path)
    beginpath(action)
    nvgCircle(@vg, Cfloat(cx), Cfloat(cy), Cfloat(radius))
    doaction(action)
end

function circle(cx::Real, cy::Real, radius::Real, action)
    circle(cx, cy, radius; action)
end

"""
    square(x, y, size; action=:path)
    square(x, y, size, action)

Draws a square with top-left corner at `(x, y)` and side length `size`.
"""
function square(x::Real, y::Real, size::Real; action=:path)
    rect(x, y, size, size; action)
end

function square(x::Real, y::Real, size::Real, action)
    rect(x, y, size, size; action)
end

"""
    image(image, x, y; alpha=1, angle=0)
    image(image, x, y, width, height; alpha=1, angle=0)

Draws an `image` with top-left corner at `(x, y)`.

`alpha` specifies the transparency of the image.

`angle` specifies the rotation of the image.

If `width` and `height` are omitted, the size of the image is used instead.

Additionally, you can pass a `canvas` directly instead of converting to a [`Image`](@ref).
"""
function image(img::Image, x::Real, y::Real, width::Real, height::Real; angle=0, alpha=1)
    fillcolor(pattern(img, x, y, width, height; alpha, angle))
    rect(x, y, width, height, :fill)
end

function image(img::Image, x::Real, y::Real; kwargs...)
    image(img, x, y, size(img)...; kwargs...)
end

function image(canvas::Canvas, x::Real, y::Real, width::Real, height::Real; kwargs...)
    image(Image(canvas), x, y, width, height; kwargs...)
end

function image(canvas::Canvas, x::Real, y::Real; kwargs...)
    image(Image(canvas), x, y, size(canvas)...; kwargs...)
end

"""
    text(text, x, y)
    text(text, x, y, width)

Draws `text` string at position `(x, y)`.

The optional `width` parameter determines the width of the text box where the text should be drawn.
"""
function text(text::AbstractString, x::Real, y::Real)
    nvgText(@vg, Cfloat(x), Cfloat(y), string(text), C_NULL)
end

function text(text::AbstractString, x::Real, y::Real, width::Real)
    nvgTextBox(@vg, Cfloat(x), Cfloat(y), Cfloat(width), string(text), C_NULL)
end
