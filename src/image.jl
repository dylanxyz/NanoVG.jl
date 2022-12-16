import Base: size
import Base: read

"""
    Image(filename, attributes...) -> Image
    Image(data, attributes...) -> Image
    Image(width, height, data, attrs...) -> Image

Creates `image` by loading it from the disk from specified file name or from memory.

You can pass additional `attributes`:

    :flipy         -> Flips (inverses) image in Y direction when rendered.
    :nearest       -> Image interpolation is Nearest instead Linear
    :repeatx       -> Repeat image in X direction.
    :repeaty       -> Repeat image in Y direction
    :mipmaps       -> Generate mipmaps during creation of the image.
    :premultiplied -> Image data has premultiplied alpha
"""
struct Image
    id::Cint
    tex::GLuint
    width::Int
    height::Int
end

function Image(id::Cint, width::Integer, height::Integer)
    tex = nvgGetTextureId(@vg, id)
    return Image(id, tex, width, height)
end

function Image(filename::AbstractString, attrs::Symbol...)
    id = nvgCreateImage(@vg, filename, imgflags(attrs))
    @assert id != 0 "Failed to load image from file $filename"

    return Image(id, imgsize(id)...)
end

function Image(data::Pointer{UInt8}, attrs::Symbol...)
    id = nvgCreateImageMem(@vg, flags(attrs), data, length(data))
    @assert id != 0 "Failed to load image from memory"
    Image(id, imgsize(id)...)
end

function Image(width::Int, height::Int, data::Pointer{UInt8}, attrs::Symbol...)
    id = nvgCreateImageRGBA(@vg, width, height, flags(attrs), data)
    @assert id != 0 "Failed to load image from memory"
    Image(id, imgsize(id)...)
end

function imgflags(attrs::Tuple)
    flags = Cint(0)
    for attr in attrs
        flags |=
            attr == :flipy ? NVG_IMAGE_FLIPY :
            attr == :nearest ? NVG_IMAGE_NEAREST :
            attr == :repeatx ? NVG_IMAGE_REPEATX :
            attr == :repeaty ? NVG_IMAGE_REPEATY :
            attr == :premultiplied ? NVG_IMAGE_PREMULTIPLIED :
            attr == :mipmaps ? NVG_IMAGE_GENERATE_MIPMAPS :
            error("Invalid image attribute: $attr")
    end
    return flags
end

function imgsize(image::Cint)
    w = Ref(Cint(0))
    h = Ref(Cint(0))
    nvgImageSize(@vg, image, w, h)
    return w[], h[]
end

"""
    aspect(image) -> Rational

Returns the `image`'s aspect ratio: `width/height`.
"""
aspect(image::Image) = image.width // image.height

size(image::Image) = (image.width, image.height)
read(filename::AbstractString, ::Type{Image}) = Image(filename)

delete(image::Image) = nvgDeleteImage(@vg, image.id)

# --------------------- Canvas --------------------- #

mutable struct Canvas
    fbo::Ptr{NVGLUframebuffer}
    width::Int
    height::Int
    flags::Cint
end

function Canvas(width::Real, height::Real, flags::Symbol...)
    fbFlags = imgflags(flags)
    ptr = renderer().nvgluCreateFramebuffer(@vg, width, height, fbFlags)
    return Canvas(ptr, width, height, fbFlags)
end

Base.size(canvas::Canvas) = (canvas.width, canvas.height)

function Base.resize!(canvas::Canvas, (width, height)::NTuple{2,<:Real})
    canvas.width = width
    canvas.height = height
    canvas.fbo = renderer().nvgluCreateFramebuffer(@vg, width, height, canvas.flags)
    return canvas
end

function Image(canvas::Canvas)
    img = canvas.fbo.image
    w, h = imgsize(img)
    return Image(img, w, h)
end

aspect(canvas::Canvas) = aspect(Image(canvas))

delete(canvas::Canvas) = renderer().nvgluDeleteFramebuffer(canvas.fbo)

function Base.bind(canvas::Canvas)
    renderer().nvgluBindFramebuffer(canvas.fbo)
end

function frame(canvas::Canvas, pixelScale::Real)
    bind(canvas)
    glViewport(0, 0, canvas.width, canvas.height)
    frame(canvas.width, canvas.height, pixelScale)
end

function render(::Canvas)
    render()
    renderer().nvgluBindFramebuffer(C_NULL)
end
