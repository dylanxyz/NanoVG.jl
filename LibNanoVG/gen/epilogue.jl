@cenum NVGcreateFlags begin
    NVG_ANTIALIAS        = 1 << 0
    NVG_STENCIL_STROKES  = 1 << 1
    NVG_DEBUG            = 1 << 2
end

struct NVGLUframebuffer
    ctx     :: Ptr{NVGcontext}
    fbo     :: Cuint
    rbo     :: Cuint
    texture :: Cuint
    image   :: Cint
end

function Base.getproperty(self::Ptr{NVGLUframebuffer}, prop::Symbol)
    return getfield(unsafe_load(self), prop)
end

const GLEW_INIT = Ref(false)

function _init_glew()
    if !GLEW_INIT[]
        @assert (@ccall libGLEW.glewInit()::Cint) == 0 "Failed to init GLEW!"
        GLEW_INIT[] = true
    end
end

include("GL2.jl")
include("GL3.jl")
include("GLES2.jl")
include("GLES3.jl")
