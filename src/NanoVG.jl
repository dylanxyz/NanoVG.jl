module NanoVG

using ColorTypes
using LibNanoVG

using Base: @kwdef

export @layer
export @fill
export @stroke
export @fillstroke

export rgb
export rgba
export hsl
export hsla

export loadfont
export fallbackfont
export resetfonts
export findfont
export textbounds
export breaklines
export glyphpos
export textmetrics

var"@vg"(::Any, ::Any) = :( context().handle )

include("utils.jl")
include("font.jl")

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

end # module
