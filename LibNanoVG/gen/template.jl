module $GL

using CEnum
using NanoVG_jll

using ..LibNanoVG: _init_glew
using ..LibNanoVG: NVGcontext
using ..LibNanoVG: NVGLUframebuffer

function nvgluCreateFramebuffer(ctx, width, height, imageFlags)
    @ccall libnanovg$gl.nvgluCreateFramebuffer(
        ctx::Ptr{NVGcontext},
        width::Cint,
        height::Cint,
        imageFlags::Cint,
    )::Ptr{NVGLUframebuffer}
end

nvgluBindFramebuffer(fbo) = @ccall libnanovg$gl.nvgluBindFramebuffer(fbo::Ptr{NVGLUframebuffer})::Cvoid
nvgluDeleteFramebuffer(fbo) = @ccall libnanovg$gl.nvgluDeleteFramebuffer(fbo::Ptr{NVGLUframebuffer})::Cvoid

function nvgCreate(flags)
    _init_glew()
    return @ccall libnanovg$gl.nvgCreate$GL(flags::Cint)::Ptr{NVGcontext}
end

nvgDelete(ctx) = @ccall libnanovg$gl.nvgDelete$GL(ctx::Ptr{NVGcontext})::Cvoid

export nvgluCreateFramebuffer
export nvgluBindFramebuffer
export nvgluDeleteFramebuffer
export nvgCreate
export nvgDelete

end # module
