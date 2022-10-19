"""
    @layer expression

Wraps `expression` between `save()` and `restore()`.

See also [`save`](@ref) and [`restore`](@ref).
"""
macro layer(block)
    quote
        save()
        $(esc(block))
        restore()
    end
end

"""
    @fill expression

Wraps `expression` between `beginpath()` and `fillpath()`.

See also [`@stroke`](@ref), [`@fillstroke`](@ref) and [`@layer`](@ref).
"""
macro fill(block)
    quote
        beginpath()
        $(esc(block))
        fillpath()
    end
end

"""
    @stroke expression

Wraps `expression` between `beginpath()` and `strokepath()`.

See also [`@fill`](@ref), [`@fillstroke`](@ref) and [`@layer`](@ref).
"""
macro stroke(block)
    quote
        beginpath()
        $(esc(block))
        strokepath()
    end
end

"""
    @fillstroke expression

Wraps `expression` between `beginpath()` and `fillstroke()`.

See also [`@stroke`](@ref), [`@fill`](@ref) and [`@layer`](@ref).
"""
macro fillstroke(block)
    quote
        beginpath()
        $(esc(block))
        fillstroke()
    end
end

rgb(r::Real, g::Real, b::Real) = nvgRGB(r, g, b)
rgb(s::Real) = nvgRGB(s, s, s)

rgba(r::Real, g::Real, b::Real, a::Real=255) = nvgRGBA(r, g, b, a)
rgba(s::Real, a::Real=255) = nvgRGBA(s, s, s, a)

hsl(hue::Real, s::Real, l::Real) = nvgHSL(hue / 360, s, l)
hsla(hue::Real, s::Real, l::Real, alpha::Real=255) = nvgHSLA(hue / 360, s, l, alpha)
