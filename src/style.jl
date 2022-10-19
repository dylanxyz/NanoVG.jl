# --------------------- State --------------------- #

"""
    save() -> Nothing

NanoVG contains state which represents how paths will be rendered.
The state contains transform, fill and stroke styles, text and font styles,
and scissor clipping.

`save()` pushes and saves the current render state into a state stack.

A matching [`restore`](@ref) must be used to restore the state.
"""
save() = nvgSave(@vg)

"""
    restore() -> Nothing

Pops and restores current render state.

See also [`save`](@ref).
"""
restore() = nvgRestore(@vg)

"""
    reset() -> Nothing

Resets current render state to default values. Does not affect the render state stack.
"""
resetsyle() = nvgReset(@vg)

# --------------------- Scissoring --------------------- #

"""
    scissor(x, y, w, h) -> Nothing
    scissor(::Nothing)  -> Nothing

Sets the current scissor rectangle.
The scissor rectangle is transformed by the current transform.

Passing `nothing` as argument resets and disables scissoring.
"""
scissor(x::Real, y::Real, w::Real, h::Real) = nvgScissor(@vg, x, y, w, h)

scissor(::Nothing) = nvgResetScissor(@vg)

"""
    clip(x, y, w, h) -> Nothing

Intersects current scissor rectangle with the specified rectangle. The scissor rectangle is
transformed by the current transform.

Note: in case the rotation of previous scissor rect differs from the current one, the
intersection will be done between the specified rectangle and the previous scissor rectangle
transformed in the current transform space. The resulting shape is always rectangle.
"""
clip(x::Real, y::Real, w::Real, h::Real) = nvgIntersectScissor(@vg, x, y, w, h)

# --------------------- Styles --------------------- #

"""
    antialias(enabled)

Sets whether to draw antialias for `strokepath()` and `fillpath()`. It's enabled by default.
"""
antialias(enabled::Bool) = nvgShapeAntiAlias(@vg, enabled)

"""
    strokecolor(color)
    strokecolor(pattern)
    strokecolor(gradient)

Sets current stroke style to a solid `color`, a `pattern` or a `gradient`.

See also [`fillcolor`](@ref).
"""
strokecolor(color::ColorLike) = nvgStrokeColor(@vg, rgba(color))
strokecolor(pattern::NVGpaint) = nvgStrokePaint(@vg, pattern)
strokecolor(gradient::Gradient) = nvgStrokePaint(@vg, getfield(gradient, 1))

"""
    fillcolor(color)
    fillcolor(pattern)
    fillcolor(gradient)

Sets current fill style to a solid `color`, a `pattern` or a `gradient`.

See also [`strokecolor`](@ref).
"""
fillcolor(color::ColorLike) = nvgFillColor(@vg, rgba(color))
fillcolor(pattern::NVGpaint) = nvgFillPaint(@vg, pattern)
fillcolor(gradient::Gradient) = nvgFillPaint(@vg, getfield(gradient, 1))

"""
    background(color)

Clears the current framebuffer with the specified `color`.
"""
function background(color::Colorant)
    glClearColor(red(color), green(color), blue(color), alpha(color))
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT)
end

background(color::AbstractString) = background(rgba(color))

"""
    pattern(image, x, y, [width, height]; angle=0, alpha=1) -> NVGpaint
    pattern(canvas, x, y, [width, height]; angle=0, alpha=1) -> NVGpaint

Returns a paint pattern that can be used to fill or stroke shapes.

See also: [`fillcolor`](@ref) and [`strokecolor`](@ref).
"""
function pattern(image::Image, x::Real, y::Real, width::Real, height::Real; angle=0, alpha=1)
    nvgImagePattern(@vg, x, y, width, height, angle, image.id, alpha)
end

function pattern(image::Image, x::Real, y::Real; kwargs...)
    pattern(image, x, y, size(image)...; kwargs...)
end

function pattern(canvas::Canvas, x::Real, y::Real, width::Real, height::Real; kwargs...)
    pattern(Image(canvas), x, y, width, height; kwargs...)
end

function pattern(canvas::Canvas, x::Real, y::Real; kwargs...)
    pattern(Image(canvas), x, y; kwargs...)
end

"""
    miterlimit(limit)

Sets the miter limit of the stroke style.

Miter limit controls when a sharp corner is beveled.
"""
miterlimit(limit::Real) = nvgMiterLimit(@vg, limit)

"""
    strokewidth()

Sets the stroke width of the stroke style.
"""
strokewidth(width::Real) = nvgStrokeWidth(@vg, width)

"""
    linecap(cap)

Sets how the end of the line (cap) is drawn.

Can be one of: `:butt` (default), `:round` or `:square`.
"""
linecap(cap::Symbol) = nvgLineCap(@vg,
    cap == :butt ? NVG_BUTT :
    cap == :round ? NVG_ROUND :
    cap == :square ? NVG_SQUARE :
    error("In linecap(), expected :butt, :round or :square, got: :$cap")
)

"""
    linejoin(join)

Sets how sharp path corners are drawn.

Can be one of :miter (default), :round or :bevel.
"""
linejoin(join::Symbol) = nvgLineJoin(@vg,
    join == :miter ? NVG_MITER :
    join == :round ? NVG_ROUND :
    join == :bevel ? NVG_BEVEL :
    error("In linejoin(), expected :miter, :round or :bevel, got: :$join")
)

"""
    setalpha(alpha)

Sets the transparency applied to all rendered shapes.

Already transparent paths will get proportionally more transparent as well.
"""
setalpha(alpha::Real) = nvgGlobalAlpha(@vg, alpha)

"""
    fontface(font)
    fontface(name)

Select which font face to use either by a `font` object or by the font's `name`.

See also [`loadfont`](@ref) and [`findfont`](@ref).
"""
fontface(font::Font) = nvgFontFaceId(@vg, font.id)
fontface(name::AbstractString) = nvgFontFace(@vg, name)

"""
    fontsize(size)

Set the current font `size`.
"""
fontsize(size::Real) = nvgFontSize(@vg, size)

"""
    fontblur(blur)

Set the current font `blur`.
"""
fontblur(blur::Real) = nvgFontBlur(@vg, blur)

"""
    textspacing(spacing)

Set the current letter `spacing`.
"""
textspacing(spacing::Real) = nvgTextLetterSpacing(@vg, spacing)

"""
    lineheight(height)

Set the current line `height`.
"""
lineheight(height::Real) = nvgTextLineHeight(@vg, height)

const ALIGNMENT = Dict{Symbol,Int}(
    :left     => NVG_ALIGN_LEFT,
    :center   => NVG_ALIGN_CENTER,
    :right    => NVG_ALIGN_RIGHT,
    :top      => NVG_ALIGN_TOP,
    :middle   => NVG_ALIGN_MIDDLE,
    :bottom   => NVG_ALIGN_BOTTOM,
    :baseline => NVG_ALIGN_BASELINE,
)

"""
    textalign(alignment...)

Set the current text `alignment`. Multiple alignments may be used together.

Valid options are:

    :left     -> Default, align text horizontally to left.
    :center   -> Align text horizontally to center.
    :right    -> Align text horizontally to right.
    :top      -> Align text vertically to top.
    :middle   -> Align text vertically to middle.
    :bottom   -> Align text vertically to bottom.
    :baseline -> Default, align text vertically to baseline.
"""
function textalign(alignment::Symbol...)
    if !isempty(alignment)
        flags = 0
        for align in alignment
            @assert haskey(ALIGNMENT, align) "Invalid text alignment" align = align
            flags |= ALIGNMENT[align]
        end
        nvgTextAlign(@vg, flags)
    end
end
