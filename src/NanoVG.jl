module NanoVG

using ColorTypes
using LibNanoVG
using ModernGL

using Base: @kwdef

export @layer
export @fill
export @stroke
export @fillstroke

export rgb
export rgba
export hsl
export hsla
export delete

export loadfont
export fallbackfont
export resetfonts
export findfont
export textbounds
export breaklines
export glyphpos
export textmetrics

export LinearGradient
export BoxGradient
export RadialGradient

export transform
export translate
export rotate
export skewx
export skewy
export scale
export transformation

export save
export restore
export resetsyle
export scissor
export clip
export antialias
export strokecolor
export fillcolor
export background
export pattern
export miterlimit
export strokewidth
export linecap
export linejoin
export setalpha
export fontface
export fontsize
export fontblur
export lineheight
export textspacing
export textalign

export beginpath
export fillpath
export strokepath
export fillstroke
export closepath
export winding
export moveto
export lineto
export line
export cubic
export quadratic
export arc
export arcto
export rect
export rrect
export ellipse
export circle
export square
export image
export text
export poly

const Maybe{T} = Union{T, Nothing}
const Pointer{T} = Union{AbstractArray{T}, Ptr{T}}
const ColorLike = Union{Colorant, AbstractString}

var"@vg"(::Any, ::Any) = :( context().handle )

function delete end

include("utils.jl")
include("image.jl")
include("font.jl")
include("gradient.jl")
include("transform.jl")
include("style.jl")
include("drawing.jl")

@enum NvgRenderer begin
    GL2   # OpenGL 2 implementation
    GL3   # OpenGL 3 implementation
    GLES2 # OpenGL ES 2 implementation
    GLES3 # OpenGL ES 3 implementation
end

struct Context
    handle::Ptr{NVGcontext}
    renderer::NvgRenderer
end

const CONTEXT = Ref{Context}()

function context()
    if !isassigned(CONTEXT)
        error("No NanoVG context created. Did you forgot to call NanoVG.create()?")
    end

    return CONTEXT[]
end

@inline function renderer(r::NvgRenderer)
    r == GL2   && return LibNanoVG.GL2
    r == GL3   && return LibNanoVG.GL3
    r == GLES2 && return LibNanoVG.GLES2
    r == GLES3 && return LibNanoVG.GLES3

    return LibNanoVG.GL3
end

renderer() = renderer(context().renderer)

"""
    create(opengl[; antialiasing = false]) -> NvgContext

Creates a new NanoVG context.

The `opengl` determines which `OpenGL` implementation to use:

    NanoVG.GL2   -> Use the OpenGL 2 implementation
    NanoVG.GL3   -> Use the OpenGL 3 implementation
    NanoVG.GLES2 -> Use the OpenGL ES 2 implementation
    NanoVG.GLES3 -> Use the OpenGL ES 3 implementation

The keyword argument `antialiasing` determines if anti-aliasing
should be used when rendering.
"""
function create(opengl::NvgRenderer; antialiasing::Bool=false)
    handle = renderer(opengl).nvgCreate(antialiasing ? NVG_ANTIALIAS : 0)
    CONTEXT[] = Context(handle, opengl)
    return CONTEXT[]
end

"""
    dispose()

Deletes the current NanoVG `context`.
"""
function dispose()
    renderer().nvgDelete(@vg)
end

# --------------------- Frame Handling --------------------- #

"""
    frame(width, height, pixelScale) -> Nothing

Begin drawing a new frame.

Calls to nanovg drawing API should be wrapped in `frame()` and `render()`.

`frame()` defines the size of the window to render to in relation currently
set viewport (i.e. `glViewport` on GL backends). `pixelScale` allows to
control the rendering on Hi-DPI devices.
"""
function frame(width::Real, height::Real, pixelScale::Real)
    nvgBeginFrame(@vg, width, height, pixelScale)
end

"""
    cancel() -> Nothing

Cancels drawing the current frame.
"""
cancel() = nvgCancelFrame(@vg)

"""
    render() -> Nothing

Ends drawing flushing remaining render state.
"""
render() = nvgEndFrame(@vg)

function example(example::String)
    dir = readdir(joinpath(@__DIR__, "..", "examples"); join=true)
    dir = normpath.(dir)
    found = false
    for path in dir
        # ignore other files
        isfile(path) && continue
        # ignore assets folder
        basename(path) == "assets" && continue

        if basename(path) == example
            @info "Running example $example"
            file = joinpath(path, example * ".jl")
            found = true
            run(`julia -q \
                --startup-file=no --project=$(path) \
                -e 'import Pkg; Pkg.instantiate(); include(ARGS[1])' $file`)
            break
        end
    end

    if !found
        examples = dir
        examples = filter(isdir, examples)
        examples = map(basename, examples)
        examples = filter(!=("assets"), examples)
        @error "Example \"$example\" not found. Valid examples are: $(repr(examples))"
    end
end

end # module
