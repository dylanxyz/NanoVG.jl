using GLFW
using NanoVG
using ModernGL

include("../utils.jl")
include("../demo.jl")

const settings = Demo.settings

GLFW.SetErrorCallback() do error
    @error "[GLFW]" error = error
end

# Use OpenGL 3.2
GLFW.WindowHint(GLFW.CONTEXT_VERSION_MAJOR, 3)
GLFW.WindowHint(GLFW.CONTEXT_VERSION_MINOR, 2)
GLFW.WindowHint(GLFW.OPENGL_FORWARD_COMPAT, true)
GLFW.WindowHint(GLFW.OPENGL_PROFILE, GLFW.OPENGL_CORE_PROFILE)
GLFW.WindowHint(GLFW.SAMPLES, 4)

function main()
    window = GLFW.CreateWindow(settings.width, settings.height, settings.title)
    @assert window != C_NULL "Could not create a GLFW window 😥"

    GLFW.MakeContextCurrent(window)
    GLFW.SwapInterval(settings.vsync)

    # Create the NanoVG context with the GL3 implementation
    NanoVG.create(NanoVG.GL3)
    Demo.setup()

    time = TimeInfo()
    while !GLFW.WindowShouldClose(window)
        update!(time)
        # get window dimensions
        width, height = GLFW.GetFramebufferSize(window)
        winWidth, winHeight = GLFW.GetWindowSize(window)
        # dpr = device pixel ratio
        dpr = width / winWidth
        # get the mouse position
        mouse = GLFW.GetCursorPos(window)
        glViewport(0, 0, width, height)
        # create a new frame
        NanoVG.frame(winWidth, winHeight, dpr)
        # drawing functions should be called here
        Demo.draw(width, height, time.elapsed, mouse)
        # render the frame to the screen
        NanoVG.render()

        GLFW.SwapBuffers(window)
        GLFW.PollEvents()
    end

    Demo.dispose()
    NanoVG.dispose()
    GLFW.DestroyWindow(window)
end

main()
