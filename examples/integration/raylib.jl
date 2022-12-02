using Raylib
using NanoVG


function draw()
    background(rgb(8))

    elapsed = Raylib.GetTime()
    mx, my = Raylib.GetMousePosition()
    hue = 360 * (cos(π/12 * elapsed) + 1)

    fillcolor(hsl(hue, 0.75, 0.65))
    circle(mx, my, 64.0, :fill)
end

function main()
    Raylib.InitWindow(800, 600, "NanoVG && Raylib")
    # create a NanoVG context
    NanoVG.create(NanoVG.GL3)

    while !Raylib.WindowShouldClose()
        Raylib.BeginDrawing()
        dpi = Raylib.GetWindowScaleDPI()
        width = Raylib.GetScreenWidth()
        height = Raylib.GetScreenHeight()

        # create a new frame
        NanoVG.frame(width, height, dpi.x)
        # drawing functions should be called here
        draw()
        # render the frame
        NanoVG.render()
        Raylib.EndDrawing()
    end

    # Deletes the NanoVG context
    NanoVG.dispose()
    Raylib.CloseWindow()
end

main()
