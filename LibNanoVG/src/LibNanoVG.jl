module LibNanoVG

using ColorTypes

using NanoVG_jll
export NanoVG_jll

using GLEW_jll
export GLEW_jll

using CEnum

mutable struct NVGcontext end

struct NVGpaint
    xform::NTuple{6, Cfloat}
    extent::NTuple{2, Cfloat}
    radius::Cfloat
    feather::Cfloat
    innerColor::RGBA{Float32}
    outerColor::RGBA{Float32}
    image::Cint
end

@cenum NVGwinding::UInt32 begin
    NVG_CCW = 1
    NVG_CW = 2
end

@cenum NVGsolidity::UInt32 begin
    NVG_SOLID = 1
    NVG_HOLE = 2
end

@cenum NVGlineCap::UInt32 begin
    NVG_BUTT = 0
    NVG_ROUND = 1
    NVG_SQUARE = 2
    NVG_BEVEL = 3
    NVG_MITER = 4
end

@cenum NVGalign::UInt32 begin
    NVG_ALIGN_LEFT = 1
    NVG_ALIGN_CENTER = 2
    NVG_ALIGN_RIGHT = 4
    NVG_ALIGN_TOP = 8
    NVG_ALIGN_MIDDLE = 16
    NVG_ALIGN_BOTTOM = 32
    NVG_ALIGN_BASELINE = 64
end

@cenum NVGblendFactor::UInt32 begin
    NVG_ZERO = 1
    NVG_ONE = 2
    NVG_SRC_COLOR = 4
    NVG_ONE_MINUS_SRC_COLOR = 8
    NVG_DST_COLOR = 16
    NVG_ONE_MINUS_DST_COLOR = 32
    NVG_SRC_ALPHA = 64
    NVG_ONE_MINUS_SRC_ALPHA = 128
    NVG_DST_ALPHA = 256
    NVG_ONE_MINUS_DST_ALPHA = 512
    NVG_SRC_ALPHA_SATURATE = 1024
end

@cenum NVGcompositeOperation::UInt32 begin
    NVG_SOURCE_OVER = 0
    NVG_SOURCE_IN = 1
    NVG_SOURCE_OUT = 2
    NVG_ATOP = 3
    NVG_DESTINATION_OVER = 4
    NVG_DESTINATION_IN = 5
    NVG_DESTINATION_OUT = 6
    NVG_DESTINATION_ATOP = 7
    NVG_LIGHTER = 8
    NVG_COPY = 9
    NVG_XOR = 10
end

struct NVGcompositeOperationState
    srcRGB::Cint
    dstRGB::Cint
    srcAlpha::Cint
    dstAlpha::Cint
end

struct NVGglyphPosition
    str::Cstring
    x::Cfloat
    minx::Cfloat
    maxx::Cfloat
end

struct NVGtextRow
    start::Cstring
    _end::Cstring
    next::Cstring
    width::Cfloat
    minx::Cfloat
    maxx::Cfloat
end

@cenum NVGimageFlags::UInt32 begin
    NVG_IMAGE_GENERATE_MIPMAPS = 1
    NVG_IMAGE_REPEATX = 2
    NVG_IMAGE_REPEATY = 4
    NVG_IMAGE_FLIPY = 8
    NVG_IMAGE_PREMULTIPLIED = 16
    NVG_IMAGE_NEAREST = 32
end

function nvgBeginFrame(ctx, windowWidth, windowHeight, devicePixelRatio)
    @ccall libnanovg.nvgBeginFrame(ctx::Ptr{NVGcontext}, windowWidth::Cfloat, windowHeight::Cfloat, devicePixelRatio::Cfloat)::Cvoid
end

function nvgCancelFrame(ctx)
    @ccall libnanovg.nvgCancelFrame(ctx::Ptr{NVGcontext})::Cvoid
end

function nvgEndFrame(ctx)
    @ccall libnanovg.nvgEndFrame(ctx::Ptr{NVGcontext})::Cvoid
end

function nvgGlobalCompositeOperation(ctx, op)
    @ccall libnanovg.nvgGlobalCompositeOperation(ctx::Ptr{NVGcontext}, op::Cint)::Cvoid
end

function nvgGlobalCompositeBlendFunc(ctx, sfactor, dfactor)
    @ccall libnanovg.nvgGlobalCompositeBlendFunc(ctx::Ptr{NVGcontext}, sfactor::Cint, dfactor::Cint)::Cvoid
end

function nvgGlobalCompositeBlendFuncSeparate(ctx, srcRGB, dstRGB, srcAlpha, dstAlpha)
    @ccall libnanovg.nvgGlobalCompositeBlendFuncSeparate(ctx::Ptr{NVGcontext}, srcRGB::Cint, dstRGB::Cint, srcAlpha::Cint, dstAlpha::Cint)::Cvoid
end

function nvgRGB(r, g, b)
    @ccall libnanovg.nvgRGB(r::Cuchar, g::Cuchar, b::Cuchar)::RGBA{Float32}
end

function nvgRGBf(r, g, b)
    @ccall libnanovg.nvgRGBf(r::Cfloat, g::Cfloat, b::Cfloat)::RGBA{Float32}
end

function nvgRGBA(r, g, b, a)
    @ccall libnanovg.nvgRGBA(r::Cuchar, g::Cuchar, b::Cuchar, a::Cuchar)::RGBA{Float32}
end

function nvgRGBAf(r, g, b, a)
    @ccall libnanovg.nvgRGBAf(r::Cfloat, g::Cfloat, b::Cfloat, a::Cfloat)::RGBA{Float32}
end

function nvgLerpRGBA(c0, c1, u)
    @ccall libnanovg.nvgLerpRGBA(c0::RGBA{Float32}, c1::RGBA{Float32}, u::Cfloat)::RGBA{Float32}
end

function nvgTransRGBA(c0, a)
    @ccall libnanovg.nvgTransRGBA(c0::RGBA{Float32}, a::Cuchar)::RGBA{Float32}
end

function nvgTransRGBAf(c0, a)
    @ccall libnanovg.nvgTransRGBAf(c0::RGBA{Float32}, a::Cfloat)::RGBA{Float32}
end

function nvgHSL(h, s, l)
    @ccall libnanovg.nvgHSL(h::Cfloat, s::Cfloat, l::Cfloat)::RGBA{Float32}
end

function nvgHSLA(h, s, l, a)
    @ccall libnanovg.nvgHSLA(h::Cfloat, s::Cfloat, l::Cfloat, a::Cuchar)::RGBA{Float32}
end

function nvgSave(ctx)
    @ccall libnanovg.nvgSave(ctx::Ptr{NVGcontext})::Cvoid
end

function nvgRestore(ctx)
    @ccall libnanovg.nvgRestore(ctx::Ptr{NVGcontext})::Cvoid
end

function nvgReset(ctx)
    @ccall libnanovg.nvgReset(ctx::Ptr{NVGcontext})::Cvoid
end

function nvgShapeAntiAlias(ctx, enabled)
    @ccall libnanovg.nvgShapeAntiAlias(ctx::Ptr{NVGcontext}, enabled::Cint)::Cvoid
end

function nvgStrokeColor(ctx, color)
    @ccall libnanovg.nvgStrokeColor(ctx::Ptr{NVGcontext}, color::RGBA{Float32})::Cvoid
end

function nvgStrokePaint(ctx, paint)
    @ccall libnanovg.nvgStrokePaint(ctx::Ptr{NVGcontext}, paint::NVGpaint)::Cvoid
end

function nvgFillColor(ctx, color)
    @ccall libnanovg.nvgFillColor(ctx::Ptr{NVGcontext}, color::RGBA{Float32})::Cvoid
end

function nvgFillPaint(ctx, paint)
    @ccall libnanovg.nvgFillPaint(ctx::Ptr{NVGcontext}, paint::NVGpaint)::Cvoid
end

function nvgMiterLimit(ctx, limit)
    @ccall libnanovg.nvgMiterLimit(ctx::Ptr{NVGcontext}, limit::Cfloat)::Cvoid
end

function nvgStrokeWidth(ctx, size)
    @ccall libnanovg.nvgStrokeWidth(ctx::Ptr{NVGcontext}, size::Cfloat)::Cvoid
end

function nvgLineCap(ctx, cap)
    @ccall libnanovg.nvgLineCap(ctx::Ptr{NVGcontext}, cap::Cint)::Cvoid
end

function nvgLineJoin(ctx, join)
    @ccall libnanovg.nvgLineJoin(ctx::Ptr{NVGcontext}, join::Cint)::Cvoid
end

function nvgGlobalAlpha(ctx, alpha)
    @ccall libnanovg.nvgGlobalAlpha(ctx::Ptr{NVGcontext}, alpha::Cfloat)::Cvoid
end

function nvgResetTransform(ctx)
    @ccall libnanovg.nvgResetTransform(ctx::Ptr{NVGcontext})::Cvoid
end

function nvgTransform(ctx, a, b, c, d, e, f)
    @ccall libnanovg.nvgTransform(ctx::Ptr{NVGcontext}, a::Cfloat, b::Cfloat, c::Cfloat, d::Cfloat, e::Cfloat, f::Cfloat)::Cvoid
end

function nvgTranslate(ctx, x, y)
    @ccall libnanovg.nvgTranslate(ctx::Ptr{NVGcontext}, x::Cfloat, y::Cfloat)::Cvoid
end

function nvgRotate(ctx, angle)
    @ccall libnanovg.nvgRotate(ctx::Ptr{NVGcontext}, angle::Cfloat)::Cvoid
end

function nvgSkewX(ctx, angle)
    @ccall libnanovg.nvgSkewX(ctx::Ptr{NVGcontext}, angle::Cfloat)::Cvoid
end

function nvgSkewY(ctx, angle)
    @ccall libnanovg.nvgSkewY(ctx::Ptr{NVGcontext}, angle::Cfloat)::Cvoid
end

function nvgScale(ctx, x, y)
    @ccall libnanovg.nvgScale(ctx::Ptr{NVGcontext}, x::Cfloat, y::Cfloat)::Cvoid
end

function nvgCurrentTransform(ctx, xform)
    @ccall libnanovg.nvgCurrentTransform(ctx::Ptr{NVGcontext}, xform::Ptr{Cfloat})::Cvoid
end

function nvgTransformIdentity(dst)
    @ccall libnanovg.nvgTransformIdentity(dst::Ptr{Cfloat})::Cvoid
end

function nvgTransformTranslate(dst, tx, ty)
    @ccall libnanovg.nvgTransformTranslate(dst::Ptr{Cfloat}, tx::Cfloat, ty::Cfloat)::Cvoid
end

function nvgTransformScale(dst, sx, sy)
    @ccall libnanovg.nvgTransformScale(dst::Ptr{Cfloat}, sx::Cfloat, sy::Cfloat)::Cvoid
end

function nvgTransformRotate(dst, a)
    @ccall libnanovg.nvgTransformRotate(dst::Ptr{Cfloat}, a::Cfloat)::Cvoid
end

function nvgTransformSkewX(dst, a)
    @ccall libnanovg.nvgTransformSkewX(dst::Ptr{Cfloat}, a::Cfloat)::Cvoid
end

function nvgTransformSkewY(dst, a)
    @ccall libnanovg.nvgTransformSkewY(dst::Ptr{Cfloat}, a::Cfloat)::Cvoid
end

function nvgTransformMultiply(dst, src)
    @ccall libnanovg.nvgTransformMultiply(dst::Ptr{Cfloat}, src::Ptr{Cfloat})::Cvoid
end

function nvgTransformPremultiply(dst, src)
    @ccall libnanovg.nvgTransformPremultiply(dst::Ptr{Cfloat}, src::Ptr{Cfloat})::Cvoid
end

function nvgTransformInverse(dst, src)
    @ccall libnanovg.nvgTransformInverse(dst::Ptr{Cfloat}, src::Ptr{Cfloat})::Cint
end

function nvgTransformPoint(dstx, dsty, xform, srcx, srcy)
    @ccall libnanovg.nvgTransformPoint(dstx::Ptr{Cfloat}, dsty::Ptr{Cfloat}, xform::Ptr{Cfloat}, srcx::Cfloat, srcy::Cfloat)::Cvoid
end

function nvgDegToRad(deg)
    @ccall libnanovg.nvgDegToRad(deg::Cfloat)::Cfloat
end

function nvgRadToDeg(rad)
    @ccall libnanovg.nvgRadToDeg(rad::Cfloat)::Cfloat
end

function nvgCreateImage(ctx, filename, imageFlags)
    @ccall libnanovg.nvgCreateImage(ctx::Ptr{NVGcontext}, filename::Cstring, imageFlags::Cint)::Cint
end

function nvgCreateImageMem(ctx, imageFlags, data, ndata)
    @ccall libnanovg.nvgCreateImageMem(ctx::Ptr{NVGcontext}, imageFlags::Cint, data::Ptr{Cuchar}, ndata::Cint)::Cint
end

function nvgCreateImageRGBA(ctx, w, h, imageFlags, data)
    @ccall libnanovg.nvgCreateImageRGBA(ctx::Ptr{NVGcontext}, w::Cint, h::Cint, imageFlags::Cint, data::Ptr{Cuchar})::Cint
end

function nvgUpdateImage(ctx, image, data)
    @ccall libnanovg.nvgUpdateImage(ctx::Ptr{NVGcontext}, image::Cint, data::Ptr{Cuchar})::Cvoid
end

function nvgImageSize(ctx, image, w, h)
    @ccall libnanovg.nvgImageSize(ctx::Ptr{NVGcontext}, image::Cint, w::Ptr{Cint}, h::Ptr{Cint})::Cvoid
end

function nvgDeleteImage(ctx, image)
    @ccall libnanovg.nvgDeleteImage(ctx::Ptr{NVGcontext}, image::Cint)::Cvoid
end

function nvgLinearGradient(ctx, sx, sy, ex, ey, icol, ocol)
    @ccall libnanovg.nvgLinearGradient(ctx::Ptr{NVGcontext}, sx::Cfloat, sy::Cfloat, ex::Cfloat, ey::Cfloat, icol::RGBA{Float32}, ocol::RGBA{Float32})::NVGpaint
end

function nvgBoxGradient(ctx, x, y, w, h, r, f, icol, ocol)
    @ccall libnanovg.nvgBoxGradient(ctx::Ptr{NVGcontext}, x::Cfloat, y::Cfloat, w::Cfloat, h::Cfloat, r::Cfloat, f::Cfloat, icol::RGBA{Float32}, ocol::RGBA{Float32})::NVGpaint
end

function nvgRadialGradient(ctx, cx, cy, inr, outr, icol, ocol)
    @ccall libnanovg.nvgRadialGradient(ctx::Ptr{NVGcontext}, cx::Cfloat, cy::Cfloat, inr::Cfloat, outr::Cfloat, icol::RGBA{Float32}, ocol::RGBA{Float32})::NVGpaint
end

function nvgImagePattern(ctx, ox, oy, ex, ey, angle, image, alpha)
    @ccall libnanovg.nvgImagePattern(ctx::Ptr{NVGcontext}, ox::Cfloat, oy::Cfloat, ex::Cfloat, ey::Cfloat, angle::Cfloat, image::Cint, alpha::Cfloat)::NVGpaint
end

function nvgScissor(ctx, x, y, w, h)
    @ccall libnanovg.nvgScissor(ctx::Ptr{NVGcontext}, x::Cfloat, y::Cfloat, w::Cfloat, h::Cfloat)::Cvoid
end

function nvgIntersectScissor(ctx, x, y, w, h)
    @ccall libnanovg.nvgIntersectScissor(ctx::Ptr{NVGcontext}, x::Cfloat, y::Cfloat, w::Cfloat, h::Cfloat)::Cvoid
end

function nvgResetScissor(ctx)
    @ccall libnanovg.nvgResetScissor(ctx::Ptr{NVGcontext})::Cvoid
end

function nvgBeginPath(ctx)
    @ccall libnanovg.nvgBeginPath(ctx::Ptr{NVGcontext})::Cvoid
end

function nvgMoveTo(ctx, x, y)
    @ccall libnanovg.nvgMoveTo(ctx::Ptr{NVGcontext}, x::Cfloat, y::Cfloat)::Cvoid
end

function nvgLineTo(ctx, x, y)
    @ccall libnanovg.nvgLineTo(ctx::Ptr{NVGcontext}, x::Cfloat, y::Cfloat)::Cvoid
end

function nvgBezierTo(ctx, c1x, c1y, c2x, c2y, x, y)
    @ccall libnanovg.nvgBezierTo(ctx::Ptr{NVGcontext}, c1x::Cfloat, c1y::Cfloat, c2x::Cfloat, c2y::Cfloat, x::Cfloat, y::Cfloat)::Cvoid
end

function nvgQuadTo(ctx, cx, cy, x, y)
    @ccall libnanovg.nvgQuadTo(ctx::Ptr{NVGcontext}, cx::Cfloat, cy::Cfloat, x::Cfloat, y::Cfloat)::Cvoid
end

function nvgArcTo(ctx, x1, y1, x2, y2, radius)
    @ccall libnanovg.nvgArcTo(ctx::Ptr{NVGcontext}, x1::Cfloat, y1::Cfloat, x2::Cfloat, y2::Cfloat, radius::Cfloat)::Cvoid
end

function nvgClosePath(ctx)
    @ccall libnanovg.nvgClosePath(ctx::Ptr{NVGcontext})::Cvoid
end

function nvgPathWinding(ctx, dir)
    @ccall libnanovg.nvgPathWinding(ctx::Ptr{NVGcontext}, dir::Cint)::Cvoid
end

function nvgArc(ctx, cx, cy, r, a0, a1, dir)
    @ccall libnanovg.nvgArc(ctx::Ptr{NVGcontext}, cx::Cfloat, cy::Cfloat, r::Cfloat, a0::Cfloat, a1::Cfloat, dir::Cint)::Cvoid
end

function nvgRect(ctx, x, y, w, h)
    @ccall libnanovg.nvgRect(ctx::Ptr{NVGcontext}, x::Cfloat, y::Cfloat, w::Cfloat, h::Cfloat)::Cvoid
end

function nvgRoundedRect(ctx, x, y, w, h, r)
    @ccall libnanovg.nvgRoundedRect(ctx::Ptr{NVGcontext}, x::Cfloat, y::Cfloat, w::Cfloat, h::Cfloat, r::Cfloat)::Cvoid
end

function nvgRoundedRectVarying(ctx, x, y, w, h, radTopLeft, radTopRight, radBottomRight, radBottomLeft)
    @ccall libnanovg.nvgRoundedRectVarying(ctx::Ptr{NVGcontext}, x::Cfloat, y::Cfloat, w::Cfloat, h::Cfloat, radTopLeft::Cfloat, radTopRight::Cfloat, radBottomRight::Cfloat, radBottomLeft::Cfloat)::Cvoid
end

function nvgEllipse(ctx, cx, cy, rx, ry)
    @ccall libnanovg.nvgEllipse(ctx::Ptr{NVGcontext}, cx::Cfloat, cy::Cfloat, rx::Cfloat, ry::Cfloat)::Cvoid
end

function nvgCircle(ctx, cx, cy, r)
    @ccall libnanovg.nvgCircle(ctx::Ptr{NVGcontext}, cx::Cfloat, cy::Cfloat, r::Cfloat)::Cvoid
end

function nvgFill(ctx)
    @ccall libnanovg.nvgFill(ctx::Ptr{NVGcontext})::Cvoid
end

function nvgStroke(ctx)
    @ccall libnanovg.nvgStroke(ctx::Ptr{NVGcontext})::Cvoid
end

function nvgCreateFont(ctx, name, filename)
    @ccall libnanovg.nvgCreateFont(ctx::Ptr{NVGcontext}, name::Cstring, filename::Cstring)::Cint
end

function nvgCreateFontAtIndex(ctx, name, filename, fontIndex)
    @ccall libnanovg.nvgCreateFontAtIndex(ctx::Ptr{NVGcontext}, name::Cstring, filename::Cstring, fontIndex::Cint)::Cint
end

function nvgCreateFontMem(ctx, name, data, ndata, freeData)
    @ccall libnanovg.nvgCreateFontMem(ctx::Ptr{NVGcontext}, name::Cstring, data::Ptr{Cuchar}, ndata::Cint, freeData::Cint)::Cint
end

function nvgCreateFontMemAtIndex(ctx, name, data, ndata, freeData, fontIndex)
    @ccall libnanovg.nvgCreateFontMemAtIndex(ctx::Ptr{NVGcontext}, name::Cstring, data::Ptr{Cuchar}, ndata::Cint, freeData::Cint, fontIndex::Cint)::Cint
end

function nvgFindFont(ctx, name)
    @ccall libnanovg.nvgFindFont(ctx::Ptr{NVGcontext}, name::Cstring)::Cint
end

function nvgAddFallbackFontId(ctx, baseFont, fallbackFont)
    @ccall libnanovg.nvgAddFallbackFontId(ctx::Ptr{NVGcontext}, baseFont::Cint, fallbackFont::Cint)::Cint
end

function nvgAddFallbackFont(ctx, baseFont, fallbackFont)
    @ccall libnanovg.nvgAddFallbackFont(ctx::Ptr{NVGcontext}, baseFont::Cstring, fallbackFont::Cstring)::Cint
end

function nvgResetFallbackFontsId(ctx, baseFont)
    @ccall libnanovg.nvgResetFallbackFontsId(ctx::Ptr{NVGcontext}, baseFont::Cint)::Cvoid
end

function nvgResetFallbackFonts(ctx, baseFont)
    @ccall libnanovg.nvgResetFallbackFonts(ctx::Ptr{NVGcontext}, baseFont::Cstring)::Cvoid
end

function nvgFontSize(ctx, size)
    @ccall libnanovg.nvgFontSize(ctx::Ptr{NVGcontext}, size::Cfloat)::Cvoid
end

function nvgFontBlur(ctx, blur)
    @ccall libnanovg.nvgFontBlur(ctx::Ptr{NVGcontext}, blur::Cfloat)::Cvoid
end

function nvgTextLetterSpacing(ctx, spacing)
    @ccall libnanovg.nvgTextLetterSpacing(ctx::Ptr{NVGcontext}, spacing::Cfloat)::Cvoid
end

function nvgTextLineHeight(ctx, lineHeight)
    @ccall libnanovg.nvgTextLineHeight(ctx::Ptr{NVGcontext}, lineHeight::Cfloat)::Cvoid
end

function nvgTextAlign(ctx, align)
    @ccall libnanovg.nvgTextAlign(ctx::Ptr{NVGcontext}, align::Cint)::Cvoid
end

function nvgFontFaceId(ctx, font)
    @ccall libnanovg.nvgFontFaceId(ctx::Ptr{NVGcontext}, font::Cint)::Cvoid
end

function nvgFontFace(ctx, font)
    @ccall libnanovg.nvgFontFace(ctx::Ptr{NVGcontext}, font::Cstring)::Cvoid
end

function nvgText(ctx, x, y, string, _end)
    @ccall libnanovg.nvgText(ctx::Ptr{NVGcontext}, x::Cfloat, y::Cfloat, string::Cstring, _end::Cstring)::Cfloat
end

function nvgTextBox(ctx, x, y, breakRowWidth, string, _end)
    @ccall libnanovg.nvgTextBox(ctx::Ptr{NVGcontext}, x::Cfloat, y::Cfloat, breakRowWidth::Cfloat, string::Cstring, _end::Cstring)::Cvoid
end

function nvgTextBounds(ctx, x, y, string, _end, bounds)
    @ccall libnanovg.nvgTextBounds(ctx::Ptr{NVGcontext}, x::Cfloat, y::Cfloat, string::Cstring, _end::Cstring, bounds::Ptr{Cfloat})::Cfloat
end

function nvgTextBoxBounds(ctx, x, y, breakRowWidth, string, _end, bounds)
    @ccall libnanovg.nvgTextBoxBounds(ctx::Ptr{NVGcontext}, x::Cfloat, y::Cfloat, breakRowWidth::Cfloat, string::Cstring, _end::Cstring, bounds::Ptr{Cfloat})::Cvoid
end

function nvgTextGlyphPositions(ctx, x, y, string, _end, positions, maxPositions)
    @ccall libnanovg.nvgTextGlyphPositions(ctx::Ptr{NVGcontext}, x::Cfloat, y::Cfloat, string::Cstring, _end::Cstring, positions::Ptr{NVGglyphPosition}, maxPositions::Cint)::Cint
end

function nvgTextMetrics(ctx, ascender, descender, lineh)
    @ccall libnanovg.nvgTextMetrics(ctx::Ptr{NVGcontext}, ascender::Ptr{Cfloat}, descender::Ptr{Cfloat}, lineh::Ptr{Cfloat})::Cvoid
end

function nvgTextBreakLines(ctx, string, _end, breakRowWidth, rows, maxRows)
    @ccall libnanovg.nvgTextBreakLines(ctx::Ptr{NVGcontext}, string::Cstring, _end::Cstring, breakRowWidth::Cfloat, rows::Ptr{NVGtextRow}, maxRows::Cint)::Cint
end

@cenum NVGtexture::UInt32 begin
    NVG_TEXTURE_ALPHA = 1
    NVG_TEXTURE_RGBA = 2
end

struct NVGscissor
    xform::NTuple{6, Cfloat}
    extent::NTuple{2, Cfloat}
end

struct NVGvertex
    x::Cfloat
    y::Cfloat
    u::Cfloat
    v::Cfloat
end

struct NVGpath
    first::Cint
    count::Cint
    closed::Cuchar
    nbevel::Cint
    fill::Ptr{NVGvertex}
    nfill::Cint
    stroke::Ptr{NVGvertex}
    nstroke::Cint
    winding::Cint
    convex::Cint
end

struct NVGparams
    userPtr::Ptr{Cvoid}
    edgeAntiAlias::Cint
    renderCreate::Ptr{Cvoid}
    renderCreateTexture::Ptr{Cvoid}
    renderDeleteTexture::Ptr{Cvoid}
    renderUpdateTexture::Ptr{Cvoid}
    renderGetTextureSize::Ptr{Cvoid}
    renderViewport::Ptr{Cvoid}
    renderCancel::Ptr{Cvoid}
    renderFlush::Ptr{Cvoid}
    renderFill::Ptr{Cvoid}
    renderStroke::Ptr{Cvoid}
    renderTriangles::Ptr{Cvoid}
    renderDelete::Ptr{Cvoid}
end

function nvgCreateInternal(params)
    @ccall libnanovg.nvgCreateInternal(params::Ptr{NVGparams})::Ptr{NVGcontext}
end

function nvgDeleteInternal(ctx)
    @ccall libnanovg.nvgDeleteInternal(ctx::Ptr{NVGcontext})::Cvoid
end

function nvgInternalParams(ctx)
    @ccall libnanovg.nvgInternalParams(ctx::Ptr{NVGcontext})::Ptr{NVGparams}
end

function nvgDebugDumpPathCache(ctx)
    @ccall libnanovg.nvgDebugDumpPathCache(ctx::Ptr{NVGcontext})::Cvoid
end

const NVG_PI = Float32(3.141592653589793)

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


# exports
const PREFIXES = ["NVG", "nvg"]
for name in names(@__MODULE__; all=true), prefix in PREFIXES
    if startswith(string(name), prefix)
        @eval export $name
    end
end

end # module
