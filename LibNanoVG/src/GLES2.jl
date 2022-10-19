module GLES2

using CEnum
using NanoVG_jll

using ..LibNanoVG: _init_glew
using ..LibNanoVG: NVGcontext
using ..LibNanoVG: NVGLUframebuffer

function nvgluCreateFramebuffer(ctx, width, height, imageFlags)
    @ccall libnanovggles2.nvgluCreateFramebuffer(
        ctx::Ptr{NVGcontext},
        width::Cint,
        height::Cint,
        imageFlags::Cint,
    )::Ptr{NVGLUframebuffer}
end

nvgluBindFramebuffer(fbo) = @ccall libnanovggles2.nvgluBindFramebuffer(fbo::Ptr{NVGLUframebuffer})::Cvoid
nvgluDeleteFramebuffer(fbo) = @ccall libnanovggles2.nvgluDeleteFramebuffer(fbo::Ptr{NVGLUframebuffer})::Cvoid

function nvgCreate(flags)
    _init_glew()
    return @ccall libnanovggles2.nvgCreateGLES2(flags::Cint)::Ptr{NVGcontext}
end

nvgDelete(ctx) = @ccall libnanovggles2.nvgDeleteGLES2(ctx::Ptr{NVGcontext})::Cvoid

export nvgluCreateFramebuffer
export nvgluBindFramebuffer
export nvgluDeleteFramebuffer
export nvgCreate
export nvgDelete

end # module
