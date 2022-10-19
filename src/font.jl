struct Font
    id  ::Cint
    name::String
end

"""
Represents the vertical metrics based on the current text style.
"""
struct TextMetrics
    ascender  ::Float32
    descender ::Float32
    lineheight::Float32
end

"""
Represents a text row that is used by [`breaklines`](@ref).

# Fields

+ `text` is the text of the row.
+ `width` is the logical width of the row.
+ `xmin` and `xmax` represents the bounds of the row.

Logical `width` and bounds can differ because of kerning and some parts over extending.
"""
struct TextRow
    text ::String
    width::Float32
    xmin ::Float32
    xmax ::Float32
end

"""
Represents a glyph position used by [`glyphpos`](@ref).

# Fields

+ `char` is the actual glyph character as a string.
+ `x` is the x-coordinate of the logical glyph position.
+ `xmin` and `xmax` are the bounds of the glyph shape.
"""
struct GlyphPosition
    char::String
    x   ::Float32
    xmin::Float32
    xmax::Float32
end

"""
Represents the bounding box of a piece of text.

# Fields

+ `xmin` is the x coordinate of the top-left corner of the bounding box.
+ `ymin` is the y coordinate of the top-left corner of the bounding box.
+ `xmax` is the x coordinate of the bottom-right corner of the bounding box.
+ `ymax` is the y coordinate of the bottom-right corner of the bounding box.
+ `next` is the position where the next character should be drawn.
"""
mutable struct TextBounds
    xmin::Float32
    ymin::Float32
    xmax::Float32
    ymax::Float32
    next::Float32
    TextBounds() = new()
    TextBounds(args...) = new(args...)
end

function Base.unsafe_convert(::Type{Ptr{Float32}}, it::TextBounds)
    return convert(Ptr{Float32}, pointer_from_objref(it))
end

"""
    loadfont(name, filename[, index]) -> Font
    loadfont(name, data[, index]) -> Font

Loads a font from a `.ttf/.ttc` at `filename` or from memory.

`name` is an arbritary name that can be used later to select this font.

`index` can be used to specifie which font face to load.

# Example

First whe load the font:

    loadfont("My Font", "path/to/myfont.ttf")

Then we can select it with:

    fontface("My Font")

See also [`fontface`](@ref) and [`findfont`](@ref).
"""
function loadfont(name::AbstractString, filename::AbstractString)
    id = nvgCreateFont(@vg, name, filename)
    @assert id != -1 "Failed to load font '$name' from $filename"
    return Font(id, name)
end

function loadfont(name::AbstractString, filename::AbstractString, index::Integer)
    id = nvgCreateFontAtIndex(@vg, name, filename, index)
    @assert id != -1 "Failed to load font '$name' from $filename at index $index"
    return Font(id, name)
end

function loadfont(name::AbstractString, data::Pointer{UInt8}; free=false)
    id = nvgCreateFontMem(@vg, name, data, length(data), free)
    @assert id != -1 "Failed to load font $name"
    return Font(id, name)
end

function loadfont(name::AbstractString, data::Pointer{UInt8}, index::Integer; free=false)
    id = nvgCreateFontMemAtIndex(@vg, name, data, length(data), free, index)
    @assert id != -1 "Failed to load font $name at index $index"
    return Font(id, name)
end

"""
    fallbackfont(base::Font, fallback::Font)
    fallbackfont(base::AbstractString, fallback::AbstractString)

Adds a fallback font.
"""
function fallbackfont(base::Font, fallback::Font)
    nvgAddFallbackFontId(@vg, base.id, fallback.id)
end

function fallbackfont(base::AbstractString, fallback::AbstractString)
    nvgAddFallbackFont(@vg, base, fallback)
end

"""
    resetfonts(base::Font)
    resetfonts(base::AbstractString)

Reset fallback fonts.
"""
resetfonts(base::Font) = nvgResetFallbackFontsId(@vg, base.id)
resetfonts(base::AbstractString) = nvgResetFallbackFontsId(@vg, base)

"""
    findfont(name) -> Font

Find a font by `name` and returns it, or throws an error if no font is found.

See also [`loadfont`](@ref).
"""
function findfont(name::AbstractString)
    id = nvgFindFont(@vg, string(name))
    @assert id != -1 "Could not find font $name"
    return Font(id, name)
end

Base.getindex(bounds::TextBounds, i::Integer) = getfield(bounds, i)

"""
    textbounds(text, x, y) -> TextBounds
    textbounds(text, x, y, width) -> TextBounds

Returns the bounding box of `text` at position `(x, y)`.

The return value is a [`TextBounds`](@ref) object.

A optional `width` parameter can be used to constrain the text in a text box.
"""
function textbounds(text::AbstractString, x::Real, y::Real)
    bounds = TextBounds()
    nextpos = nvgTextBounds(@vg, x, y, text, C_NULL, bounds)
    bounds.next = isnothing(nextpos) ? 0 : nextpos
    return bounds
end

function textbounds(text::AbstractString, x::Real, y::Real, width::Real)
    bounds = TextBounds()
    nextpos = nvgTextBoxBounds(@vg, x, y, width, text, C_NULL, bounds)
    bounds.next = isnothing(nextpos) ? 0 : nextpos
    return bounds
end

"""
    breaklines(f, text, width, [maxrows])

Breaks the specified text into lines, then call `f` for each line.

The `f` function accepts 2 arguments: a [`TextRow`](@ref) and the current line position.

White space is stripped at the beginning of the rows, the text is split at word boundaries
or when new-line characters are encountered.

Words longer than the max width are slit at nearest character (i.e. no hyphenation).
"""
function breaklines(f::Function, text::AbstractString, width::Real, maxrows::Integer)
    rows = Vector{NVGtextRow}(undef, maxrows)
    start = text
    line = 1

    while (nrows = nvgTextBreakLines(@vg, start, C_NULL, width, rows, maxrows); nrows != 0)
        for i in 1:nrows
            row = rows[i]
            len = max(pointer(row._end) - pointer(row.start), 0)
            str = unsafe_string(pointer(row.start), len)
            textRow = TextRow(str, row.width, row.minx, row.maxx)
            f(textRow, line)
            line += 1
        end

        start = rows[nrows].next
    end
end

function breaklines(f::Function, text::AbstractString, width::Real)
    breaklines(f, text, width, count(==('\n'), text))
end

"""
    glyphpos(text, x, y) -> Vector{GlyphPosition}

Calculates the glyph `x` positions of the specified `text`.
"""
function glyphpos(text::AbstractString, x::Real, y::Real)
    maxPositions = length(text)
    positions = Vector{NVGglyphPosition}(undef, maxPositions)
    npositions = nvgTextGlyphPositions(@vg, x, y, text, C_NULL, positions, maxPositions)
    result = Vector{GlyphPosition}(undef, npositions)

    for i in 1:npositions
        pos = positions[i]
        len = max(0, pointer(pos.str) - pointer(text)) + 1
        result[i] = GlyphPosition(text[len:len], pos.x, pos.minx, pos.maxx)
    end

    return result
end

"""
    textmetrics() -> TextMetrics

Returns the vertical metrics based on the current text style.

Measured values are returned in local coordinate space.

See also [`TextMetrics`](@ref).
"""
function textmetrics()
    ascender = Ref{Cfloat}()
    descender = Ref{Cfloat}()
    lineheight = Ref{Cfloat}()
    nvgTextMetrics(@vg, ascender, descender, lineheight)
    return TextMetrics(ascender[], descender[], lineheight[])
end
