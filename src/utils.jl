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

rgba(r::Real, g::Real, b::Real, a::Real) = nvgRGBA(r, g, b, a)
rgba(s::Real, alpha::Real) = nvgRGBA(s, s, s, alpha)
rgba(s::Real) = nvgRGBA(s, s, s, s)

hsl(hue::Real, s::Real, l::Real) = nvgHSL(hue / 360, s, l)
hsla(hue::Real, s::Real, l::Real, alpha::Real=255) = nvgHSLA(hue / 360, s, l, alpha)

rgba(color::RGBA{Float32}) = color
rgba(color::ColorLike) = parse(RGBA{Float32}, color)

# This is kinda messy, but it is necessary for us to be able to retrieve the
# GL texture id of a NanoVG Image, so we don't have to use other packages to
# load images, we can use the image directly from NanoVG.

struct GLNVGtexture
    id::Cint
    tex::GLuint
    width::Cint
    height::Cint
    type::Cint
    flags::Cint
end

struct GLNVGshader
    prog::GLuint
    frag::GLuint
    vert::GLuint
    loc::NTuple{3, GLint}
end

struct GLNVGblend
    srcRGB::GLenum
    dstRGB::GLenum
    srcAlpha::GLenum
    dstAlpha::GLenum
end

struct GLNVGcall
	type::Cint
	image::Cint
	pathOffset::Cint
	pathCount::Cint
	triangleOffset::Cint
	triangleCount::Cint
	uniformOffset::Cint
	blendFunc::GLNVGblend
end

struct GLNVGpath
	fillOffset::Cint
	fillCount::Cint
	strokeOffset::Cint
	strokeCount::Cint
end

struct GLNVGcontext
	shader::GLNVGshader
	textures::Ptr{GLNVGtexture}
	view::NTuple{2, Cfloat}
	ntextures::Cint
	ctextures::Cint
	textureId::Cint
	vertBuf::GLuint
	vertArr::GLuint
	fragBuf::GLuint
	fragSize::Cint
	flags::Cint
	calls::Ptr{GLNVGcall}
    ccalls::Cint
    ncalls::Cint
	paths::Ptr{GLNVGpath}
    cpaths::Cint
    npaths::Cint
	verts::Ptr{NVGvertex}
    cverts::Cint
    nverts::Cint
	uniforms::Ptr{Cuint}
    cuniforms::Cint
    nuniforms::Cint
	boundTexture::GLuint
	stencilMask::GLuint
	stencilFunc::GLenum
	stencilFuncRef::GLint
	stencilFuncMask::GLuint
	blendFunc::GLNVGblend
    dummyTex::Cint
end

function nvgGetTextureId(nvgctx, img::Cint)
    context::GLNVGcontext = begin
        ctx = nvgInternalParams(nvgctx)
        ptr = unsafe_load(ctx).userPtr
        unsafe_load(Ptr{GLNVGcontext}(ptr))
    end

    for i in 0:context.ntextures - 1
        texture = unsafe_load(context.textures, i + 1)
        if texture.id == img
            return texture.tex
        end
    end

    return Cint(-1)
end
