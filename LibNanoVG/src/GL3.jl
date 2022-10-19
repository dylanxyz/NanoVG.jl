module GL3

using CEnum
using NanoVG_jll

using ..LibNanoVG: _init_glew
using ..LibNanoVG: NVGcontext
using ..LibNanoVG: NVGLUframebuffer

function nvgluCreateFramebuffer(ctx, width, height, imageFlags)
    @ccall libnanovggl3.nvgluCreateFramebuffer(
        ctx::Ptr{NVGcontext},
        width::Cint,
        height::Cint,
        imageFlags::Cint,
    )::Ptr{NVGLUframebuffer}
end

nvgluBindFramebuffer(fbo) = @ccall libnanovggl3.nvgluBindFramebuffer(fbo::Ptr{NVGLUframebuffer})::Cvoid
nvgluDeleteFramebuffer(fbo) = @ccall libnanovggl3.nvgluDeleteFramebuffer(fbo::Ptr{NVGLUframebuffer})::Cvoid

function nvgCreate(flags)
    _init_glew()
    return @ccall libnanovggl3.nvgCreateGL3(flags::Cint)::Ptr{NVGcontext}
end

nvgDelete(ctx) = @ccall libnanovggl3.nvgDeleteGL3(ctx::Ptr{NVGcontext})::Cvoid

export nvgluCreateFramebuffer
export nvgluBindFramebuffer
export nvgluDeleteFramebuffer
export nvgCreate
export nvgDelete

end # module
