using NanoVG
using Tela
using Tela: Vec2f

import Base: in
import Base: eltype
import Base: iterate

struct Rect
    min::Vec2f
    max::Vec2f
end

Rect(x, y, w, h) = Rect(Vec2f(x, y), Vec2f(x + w, y + h))

in((x, y), r::Rect) = r.min.x ≤ x ≤ r.max.x && r.min.y ≤ y ≤ r.max.y

struct Cell{Row, Column}
    w::Float64
    h::Float64
    x::Float64
    y::Float64
end

eltype(::Cell) = Float64
iterate(it::Cell, i = 1) = i ≤ fieldcount(Cell) ? (getfield(it, i), i + 1) : nothing

function configure(::App)
    setting"title"  = "[Example] Shapes"
    setting"width"  = 800
    setting"height" = 600
end

function update(::App)
    background(rgb(8))

    width, height = @width, @height
    rows, cols = 3, 3
    padding = 10

    for i in 1:cols, j in 1:rows
        w = width / cols
        h = height / rows
        x = (i - 1) * w
        y = (j - 1) * h

        @layer let p = padding
            cell = Cell{i, j}(w, h, x, y)
            clip(x + p, y + p, w - 2p, h - 2p)
            translate(x, y)
            @layer draw(cell)

            if @mouse[x, y] in Rect(x, y, w, h)
                fillcolor(rgba(0, 196))
                rect(0, 0, w, h, :fill)

                fontface("sans")
                textalign(:center, :middle)
                fillcolor(rgb(244))
                text(title(cell), w/2, h/2)
            end
        end
    end
end

title(::Cell) = "TODO"

function draw((w, h)::Cell)
    fillcolor(rgb(8))
    strokecolor(rgb(212))
    rect(0, 0, w, h, :fillstroke)
end

title(::Cell{1, 1}) = "line()"

function draw((w, h)::Cell{1, 1})
    linecap(:round)
    translate(w/2, h/2)
    rotate(0.25 * @seconds)
    translate(-w/2, -h/2)

    for n in 0:9
        strokecolor(hsl(196 + 12n, 0.85, 0.65))
        strokewidth(10 - n)
        line(0, h * n/10, w, h * n/10 + 20, :stroke)
    end
end

title(::Cell{2, 1}) = "rect()"

function draw((w, h)::Cell{2, 1})
    N = 8
    for i in 0:N - 1
        hue = 164 - 8i
        fillcolor(hsl(hue, 0.8, 0.4(i/N) + 0.2))

        let x = 0.5i * w/N, y = 0.5i * w/N
            y += 14 * sin(i + π * @seconds)
            rect(x, y, 0.4w, 0.4h, :fill)
        end
    end
end

title(::Cell{3, 1}) = "rrect()"

function draw((w, h)::Cell{3, 1})
    N = 4
    for i in 0:N - 1
        hue = 220 - 8i
        fillcolor(hsl(hue, 0.8, 0.4(i/N) + 0.3))

        let x = 0.5i * w/N, y = 0.5i * w/N
            x += 8 * cos(i * π/3 * @seconds) + 10
            y += 8 * sin(i * π/3 * @seconds) + 10
            rrect(x, y, 0.5w, 0.5h, 4i, :fill)
        end
    end
end

title(::Cell{1, 2}) = "circle()"

function draw((w, h)::Cell{1, 2})
    N = 8
    for i in 0:N - 1
        hue = 181 - 8i
        fillcolor(hsl(hue, 0.8, 0.3(i/N) + 0.3))

        let x = 0.5i * w/N, y = 0.5i * w/N
            x += 12 * cos(i + π * @seconds) + 10
            circle(x, y, 0.1w, :fill)
        end
    end
end

Tela.@run()
