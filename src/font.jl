struct Font
    id  ::Cint
    name::String
end

struct TextMetrics
    ascender  ::Float32
    descender ::Float32
    lineheight::Float32
end

struct TextRow
    text ::String
    width::Float32
    xmin ::Float32
    xmax ::Float32
end

struct GlyphPosition
    char::String
    x   ::Float32
    xmin::Float32
    xmax::Float32
end

mutable struct TextBounds
    xmin::Float32
    ymin::Float32
    xmax::Float32
    ymax::Float32
    next::Float32
    TextBounds() = new()
    TextBounds(args...) = new(args...)
end

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

function fallbackfont(base::Font, fallback::Font)
    nvgAddFallbackFontId(@vg, base.id, fallback.id)
end

function fallbackfont(base::AbstractString, fallback::AbstractString)
    nvgAddFallbackFont(@vg, base, fallback)
end

resetfonts(base::Font) = nvgResetFallbackFontsId(@vg, base.id)
resetfonts(base::AbstractString) = nvgResetFallbackFontsId(@vg, base)

function findfont(name::AbstractString)
    id = nvgFindFont(@vg, string(name))
    @assert id != -1 "Could not find font $name"
    return Font(id, name)
end

Base.getindex(bounds::TextBounds, i::Integer) = getfield(bounds, i)

function textbounds(text::AbstractString, x::Real, y::Real)
    bounds = TextBounds()
    nextpos = nvgTextBounds(@vg, x, y, text, C_NULL, bounds)
    bounds.next = isnothing(nextpos) ? 0 : nextpos
    return bounds
end

function textbounds(text::AbstractString, x::Real, y::Real, rowWidth::Real)
    bounds = TextBounds()
    nextpos = nvgTextBoxBounds(@vg, x, y, rowWidth, text, C_NULL, bounds)
    bounds.next = isnothing(nextpos) ? 0 : nextpos
    return bounds
end

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

function breaklines(callback::Function, text::AbstractString, width::Real)
    breaklines(callback, text, width, count(==('\n'), text))
end

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

function textmetrics()
    ascender = Ref{Cfloat}()
    descender = Ref{Cfloat}()
    lineheight = Ref{Cfloat}()
    nvgTextMetrics(@vg, ascender, descender, lineheight)
    return TextMetrics(ascender[], descender[], lineheight[])
end
