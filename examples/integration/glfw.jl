using GLFW
using NanoVG
using ModernGL

elapsed() = @ccall GLFW.libglfw.glfwGetTime()::Cdouble

function draw(window)
    background(rgb(8))

    mx, my = GLFW.GetCursorPos(window)
    hue = 360 * (cos(π/12 * elapsed()) + 1)

    fillcolor(hsl(hue, 0.75, 0.65))
    circle(mx, my, 64.0, :fill)
end

function main()
    GLFW.SetErrorCallback() do error
        @error "[GLFW]" error
    end

    window = GLFW.CreateWindow(800, 600, "NanoVG && GLFW")
    @assert window.handle != C_NULL "Could not create a GLFW window 😥"

    GLFW.MakeContextCurrent(window)
    # Create the NanoVG context with the GL3 implementation
    NanoVG.create(NanoVG.GL3, antialiasing=true)

    while !GLFW.WindowShouldClose(window)
        # get window dimensions
        width, height = GLFW.GetFramebufferSize(window)
        winWidth, winHeight = GLFW.GetWindowSize(window)

        # set the viewport
        glViewport(0, 0, width, height)
        # create a new frame
        NanoVG.frame(winWidth, winHeight, width / winWidth)
        # drawing functions should be called here
        draw(window)
        # render the frame to the screen
        NanoVG.render()

        GLFW.SwapBuffers(window)
        GLFW.PollEvents()
    end

    NanoVG.dispose()
    GLFW.DestroyWindow(window)
end

main()
