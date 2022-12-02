using Tela
using Colors
using NanoVG

import NanoVG: Image

include("perf.jl")

setting"title"  = "NanoVG Demo"
setting"width"  = 1000
setting"height" = 600
setting"vsync"  = false

const images = Vector{Image}(undef, 12)

const icons = (
    search       = string(Char(0x1F50D)),
    check        = "\u2713",
    login        = "\uE740",
    trash        = "\uE729",
    chevronRight = "\uE75E",
    circledCross = "\u2716",
)

isblack(col::Colorant) = red(col) == green(col) == blue(col) == 0
iswhite(col::Colorant) = red(col) == green(col) == blue(col) == 1

function draw_window(title, x, y, w, h)
    cornerRadius = 3.0

    @layer begin
        # Window
        fillcolor(rgba(28, 30, 34, 192))
        rrect(x, y, w, h, cornerRadius, :fill)

        # drop shadow
        shadowPaint = BoxGradient(x, y + 2, w, h, cornerRadius * 2, 10, rgba(0, 128), rgba(0))
        beginpath()
        rect(x - 10, y - 10, w + 20, h + 30)
        rrect(x, y, w, h, cornerRadius)
        winding(:hole)
        fillcolor(shadowPaint)
        fillpath()

        # header
        headerPaint = LinearGradient(x, y, x, y + 15, rgba(255, 8), rgba(0, 16))
        fillcolor(headerPaint)
        rrect(x + 1, y + 1, w - 2, 30, cornerRadius - 1, :fill)
        strokecolor(rgba(0, 32))
        line(x + 0.5, y + 0.5 + 30, x + 0.5 + w - 1, y + 0.5 + 30, :stroke)

        fontsize(15)
        fontface("sans-bold")
        textalign(:center, :middle)

        fontblur(2)
        fillcolor(rgba(0, 128))
        text(title, x + w / 2, y + 16 + 1)

        fontblur(0)
        fillcolor(rgba(220, 160))
        text(title, x + w / 2, y + 16)
    end
end

function draw_search_box(txt, x, y, w, h)
    cornerRadius = h / 2 - 1
    bg = BoxGradient(x, y + 1.5, w, h, h / 2, 5, rgba(0, 16), rgba(0, 92))

    fillcolor(bg)
    rrect(x, y, w, h, cornerRadius, :fill)

    fontsize(1.3h)
    fontface("icons")
    fillcolor(rgba(255, 64))
    textalign(:center, :middle)
    text(icons.search, x + 0.55h, y + 0.55h)

    fontsize(17)
    fontface("sans")
    fillcolor(rgba(255, 32))

    textalign(:left, :middle)
    text(txt, x + 1.05h, y + 0.5h)

    fontsize(1.3h)
    fontface("icons")
    fillcolor(rgba(255, 32))
    textalign(:center, :middle)
    text(icons.circledCross, x + w - 0.55h, y + 0.55h)
end

function draw_dropdown(txt, x, y, w, h)
    cornerRadius = 4
    bg = LinearGradient(x, y, x, y + h, rgba(255, 16), rgba(0, 16))
    fillcolor(bg)
    rrect(x + 1, y + 1, w - 2, h - 2, cornerRadius - 1, :fill)

    strokecolor(rgba(0, 48))
    rrect(x + 0.5, y + 0.5, w - 1, h - 1, cornerRadius - 0.5, :stroke)

    fontsize(17)
    fontface("sans")
    fillcolor(rgba(255, 160))
    textalign(:left, :middle)
    text(txt, x + 0.3h, y + 0.5h)

    fontsize(1.3h)
    fontface("icons")
    fillcolor(rgba(255, 64))
    textalign(:center, :middle)
    text(icons.chevronRight, x + w - 0.5h, y + 0.5h)
end

function draw_label(label, x, y, w, h)
    fontsize(15)
    fontface("sans")
    fillcolor(rgba(255, 128))

    textalign(:left, :middle)
    text(label, x, y + 0.5h)
end

function draw_edit_boxbase(x, y, w, h)
    bg = BoxGradient(x + 1, y + 1 + 1.5, w - 2, h - 2, 3, 4, rgba(255, 32), rgba(32))
    fillcolor(bg)
    rrect(x + 1, y + 1, w - 2, h - 2, 4 - 1, :fill)

    strokecolor(rgba(0, 48))
    rrect(x + 0.5, y + 0.5, w - 1, h - 1, 4 - 0.5, :stroke)
end

function draw_edit_box(txt, x, y, w, h)
    draw_edit_boxbase(x, y, w, h)

    fontsize(17)
    fontface("sans")
    fillcolor(rgba(255, 64))
    textalign(:left, :middle)
    text(txt, x + 0.3h, y + 0.5h)
end

function draw_edit_box_num(txt, units, x, y, w, h)
    draw_edit_boxbase(x, y, w, h)

    uw = textbounds(units, 0, 0).next

    fontsize(15)
    fontface("sans")
    fillcolor(rgba(255, 64))
    textalign(:right, :middle)
    text(units, x + w - 0.3h, y + 0.5h)

    fontsize(17)
    fontface("sans")
    fillcolor(rgba(255, 128))
    textalign(:right, :middle)
    text(txt, x + w - uw - 0.5h, y + 0.5h)
end

function draw_checkbox(txt, x, y, w, h)
    fontsize(15)
    fontface("sans")
    fillcolor(rgba(255, 160))
    text(txt, x + 28, y + 0.5h)

    bg = BoxGradient(x + 1, y + floor(0.5h) - 9 + 1, 18, 18, 3, 3, rgba(0, 32), rgba(0, 92))
    fillcolor(bg)
    rrect(x + 1, y + floor(0.5h) - 9, 18, 18, 3, :fill)

    fontsize(33)
    fontface("icons")
    fillcolor(rgba(255, 128))
    textalign(:center, :middle)
    text(icons.check, x + 9 + 2, y + 0.5h)
end

function draw_button(preicon, txt, x, y, w, h, col)
    a = isblack(col) ? 16 : 32
    cornerRadius = 4
    bg = LinearGradient(x, y, x, y + h, rgba(255, a), rgba(0, a))
    beginpath()
    rrect(x + 1, y + 1, w - 2, h - 2, cornerRadius - 1)
    if !isblack(col)
        fillcolor(col)
        fillpath()
    end
    fillcolor(bg)
    fillpath()

    strokecolor(rgba(0, 48))
    rrect(x + 0.5, y + 0.5, w - 1, h - 1, cornerRadius - 0.5, :stroke)

    fontsize(17)
    fontface("sans-bold")
    iw = 0
    tw = textbounds(txt, 0, 0).next

    if preicon != ""
        fontsize(1.3h)
        fontface("icons")
        iw = textbounds(preicon, 0, 0).next
        iw += 0.15h

        textalign(:left, :middle)
        fillcolor(rgba(255, 96))
        text(preicon, x + 0.5w - 0.5tw - 0.75iw, y + 0.5h)
    end

    fontsize(17)
    fontface("sans-bold")
    textalign(:left, :middle)
    fillcolor(rgba(0, 160))
    text(txt, x + 0.5w - 0.5tw + 0.25iw, y + 0.5h - 1)
    fillcolor(rgba(255, 160))
    text(txt, x + 0.5w - 0.5tw + 0.25iw, y + 0.5h - 1)
end

function draw_slider(pos, x, y, w, h)
    cy = y + floor(0.5h)
    kr = floor(0.25h)

    @layer begin
        # Slot
        bg = BoxGradient(x, cy - 2 + 1, w, 4, 2, 2, rgba(0, 32), rgba(0, 128))
        fillcolor(bg)
        rrect(x, cy - 2, w, 4, 2, :fill)

        # Knob shadow
        bg = RadialGradient(x + floor(pos * w), cy + 1, kr - 3, kr + 3, rgba(0, 64), rgba(0))
        fillcolor(bg)
        beginpath()
        rect(x + floor(pos * w) - kr - 5, cy - kr - 5, 2kr + 5 + 5, 2kr + 5 + 5 + 3)
        circle(x + floor(pos * w), cy, kr)
        fillpath()

        # Knob
        knob = LinearGradient(x, cy - kr, x, cy + kr, rgba(255, 16), rgba(0, 16))
        beginpath()
        circle(x + floor(pos * w), cy, kr - 1)
        fillcolor(rgba(40, 43, 48, 255))
        fillpath()
        fillcolor(knob)
        fillpath()

        circle(x + floor(pos * w), cy, kr - 0.5, :stroke)
    end # @layer
end

function draw_eyes(x, y, w, h, mx, my, t)
    ex = w * 0.23
    ey = h * 0.5
    lx = x + ex
    ly = y + ey
    rx = x + w - ex
    ry = y + ey
    br = (ex < ey ? ex : ey) * 0.5
    blink = 1 - sin(0.5t)^200 * 0.8

    beginpath()
    bg = LinearGradient(x, y + 0.5h, x + 0.1w, y + h, rgba(0, 32), rgba(0, 16))
    fillcolor(bg)
    ellipse(lx + 3, ly + 16, ex, ey)
    ellipse(rx + 3, ry + 16, ex, ey)
    fillpath()

    beginpath()
    bg = LinearGradient(x, y + 0.25h, x + 0.1w, y + h, rgba(220, 255), rgba(128, 255))
    fillcolor(bg)
    ellipse(lx, ly, ex, ey)
    ellipse(rx, ry, ex, ey)
    fillpath()

    dx = (mx - rx) / (ex * 10)
    dy = (my - ry) / (ey * 10)
    d = sqrt(dx^2 + dy^2)

    if d > 1
        dx /= d
        dy /= d
    end

    dx *= 0.4ex
    dy *= 0.5ey

    fillcolor(rgba(32, 255))
    ellipse(lx + dx, ly + dy + 0.25ey * (1 - blink), br, br * blink, :fill)
    ellipse(rx + dx, ry + dy + 0.25ey * (1 - blink), br, br * blink, :fill)

    gloss = RadialGradient(lx - 0.25ex, ly - 0.5ey, 0.1ex, 0.75ex, rgba(255, 128), rgba(255, 0))
    fillcolor(gloss)
    ellipse(lx, ly, ex, ey, :fill)

    gloss = RadialGradient(rx - 0.25ex, ry - 0.5ey, 0.1ex, 0.75ex, rgba(255, 128), rgba(255, 0))
    fillcolor(gloss)
    ellipse(rx, ry, ex, ey, :fill)
end

function draw_graph(x, y, w, h, t)
    dx = w / 5.0

    samples = [
        (1 + sin(1.2345t + cos(0.33457t) * 0.44)) * 0.5,
        (1 + sin(0.68363t + cos(1.3t) * 1.55)) * 0.5,
        (1 + sin(1.1642t + cos(0.33457t) * 1.24)) * 0.5,
        (1 + sin(0.56345t + cos(1.63t) * 0.14)) * 0.5,
        (1 + sin(1.6245t + cos(0.254t) * 0.30)) * 0.5,
        (1 + sin(0.345t + cos(0.03t) * 0.60)) * 0.5,
    ]

    sx = map(i -> x + i * dx, 0:5)
    sy = map(s -> y + h * 0.8s, samples)

    bg = LinearGradient(x, y, x, y + h, rgba(0, 160, 192, 0), rgba(0, 160, 192, 64))
    fillcolor(bg)
    beginpath()
    moveto(sx[1], sy[1])
    for i in 2:6
        cubic(sx[i-1] + 0.5dx, sy[i-1], sx[i] - 0.5dx, sy[i], sx[i], sy[i])
    end

    lineto(x + w, y + h)
    lineto(x, y + h)
    fillpath()

    beginpath()
    strokecolor(rgba(0, 32))
    strokewidth(3)
    moveto(sx[1], sy[1] + 2)
    for i in 2:6
        cubic(sx[i-1] + 0.5dx, sy[i-1] + 2, sx[i] - 0.5dx, sy[i] + 2, sx[i], sy[i] + 2)
    end
    strokepath()

    beginpath()
    strokecolor(rgba(0, 160, 192, 255))
    strokewidth(3)
    moveto(sx[1], sy[1])
    for i in 2:6
        cubic(sx[i-1] + 0.5dx, sy[i-1], sx[i] - 0.5dx, sy[i], sx[i], sy[i])
    end
    strokepath()

    for i in 1:6
        bg = RadialGradient(sx[i], sy[i] + 2, 3, 8, rgba(0, 32), rgba(0))
        fillcolor(bg)
        rect(sx[i] - 10, sy[i] - 10 + 2, 20, 20, :fill)
    end

    fillcolor(rgba(0, 160, 192, 255))
    for i in 1:6
        circle(sx[i], sy[i], 2, :fill)
    end

    fillcolor(rgba(220, 255))
    for i in 1:6
        circle(sx[i], sy[i], 2, :fill)
    end

    strokewidth(1)
end

function draw_spinner(cx, cy, r, t)
    a0 = 6t
    a1 = π + 6t
    r0 = r
    r1 = 0.75r

    @layer begin
        beginpath()
        arc(cx, cy, r0, a0, a1, dir=:cw)
        arc(cx, cy, r1, a1, a0, dir=:ccw)
        closepath()

        ax = cx + cos(a0) * 0.5 * (r0 + r1)
        ay = cy + cos(a0) * 0.5 * (r0 + r1)
        bx = cx + cos(a1) * 0.5 * (r0 + r1)
        by = cy + cos(a1) * 0.5 * (r0 + r1)
        paint = LinearGradient(ax, ay, bx, by, rgba(0), rgba(0, 128))
        fillcolor(paint)
        strokepath()
    end
end

function draw_thumbnails(x, y, w, h, images, t)
    cornerRadius = 3
    thumb = 60
    arry = 30
    stackh = (length(images) / 2) * (thumb + 10) + 10
    u = (1 + cos(0.5t)) * 0.5
    u2 = (1 - cos(0.2t)) * 0.5

    ih = 0.0
    iw = 0.0
    ix = 0.0
    iy = 0.0

    @layer begin
        shadowPaint = BoxGradient(x, y + 4, w, h, 2cornerRadius, 20, rgba(0, 128), rgba(0))
        rect(x - 10, y - 10, w + 20, h + 30)
        winding(:hole)
        fillcolor(shadowPaint)
        rrect(x, y, w, h, cornerRadius, :fill)

        beginpath()
        fillcolor(rgba(200, 255))
        rrect(x, y, w, h, cornerRadius)
        moveto(x - 10, y + arry)
        lineto(x + 1, y + arry - 11)
        lineto(x + 1, y + arry + 11)
        fillpath()

        @layer begin
            scissor(x, y, w, h)
            translate(0, -(stackh - h) * u)

            dv = 1 / (length(images) - 1)
            for (i, img) in enumerate(images)
                tx = x + 10
                ty = y + 10
                tx += ((i - 1) % 2) * (thumb + 10)
                ty += floor((i - 1) / 2) * (thumb + 10)
                imgw, imgh = size(img)
                if imgw < imgh
                    iw = thumb
                    ih = iw * imgh / imgw
                    ix = 0
                    iy = -0.5 * (ih - thumb)
                else
                    ih = thumb
                    iw = ih * imgw / imgh
                    ix = -0.5 * (iw - thumb)
                    iy = 0
                end

                v = i * dv
                a = clamp((u2 - v) / dv, 0, 1)
                if a < 1
                    draw_spinner(tx + thumb / 2, ty + thumb / 2, 0.25thumb, t)
                end

                imgPaint = pattern(img, tx + ix, ty + iy, iw, ih, alpha=a)
                fillcolor(imgPaint)
                rrect(tx, ty, thumb, thumb, 5, :fill)

                beginpath()
                shadowPaint = BoxGradient(tx - 1, ty, thumb + 2, thumb + 2, 5, 3, rgba(0, 128), rgba(0))
                winding(:hole)
                fillcolor(shadowPaint)
                rect(tx - 5, ty - 5, thumb + 10, thumb + 10)
                rrect(tx, ty, thumb, thumb, 6)
                fillpath()

                strokewidth(1)
                strokecolor(rgba(255, 192))
                rrect(tx + 0.5, ty + 0.5, thumb - 1, thumb - 1, 4 - 0.5, :stroke)
            end
        end

        fadePaint = LinearGradient(x, y, x, y + 6, rgba(200, 255), rgba(200, 0))
        fillcolor(fadePaint)
        rect(x + 4, y + h - 6, w - 8, 6, :fill)

        shadowPaint = BoxGradient(x + w - 12 + 1, y + 4 + 1, 8, h - 8, 3, 4, rgba(0, 32), rgba(0, 92))
        fillcolor(shadowPaint)
        rrect(x + w - 12, y + 4, 8, h - 8, 3, :fill)

        scrollh = (h / stackh) * (h - 8)
        shadowPaint = BoxGradient(x + w - 12 - 1, y + 4 + (h - 8 - scrollh) * u - 1, 8, scrollh, 3, 4, rgba(220, 255), rgba(128, 255))
        fillcolor(shadowPaint)
        rrect(x + w - 12 + 1, y + 4 + 1 + (h - 8 - scrollh) * u, 8 - 2, scrollh - 2, 2, :fill)
    end
end

function draw_color_wheel(x, y, w, h, t)
    hue = sin(0.12t)
    ax, ay = 0.0, 0.0
    bx, by = 0.0, 0.0
    cx = x + 0.5w
    cy = y + 0.5h
    r1 = (w < h ? w : h) * 0.5 - 0.5
    r0 = r1 - 20
    aeps = 0.5 / r1

    @layer begin
        for i in 0:5
            a0 = i / 6 * π * 2 - aeps
            a1 = (i + 1) / 6 * π * 2 + aeps
            beginpath()
            arc(cx, cy, r0, a0, a1, dir=:cw)
            arc(cx, cy, r1, a1, a0, dir=:ccw)
            closepath()
            ax = cx + cos(a0) * (r0 + r1) * 0.5
            ay = cy + sin(a0) * (r0 + r1) * 0.5
            bx = cx + cos(a1) * (r0 + r1) * 0.5
            by = cy + sin(a1) * (r0 + r1) * 0.5
            paint = LinearGradient(ax, ay, bx, by, hsl(rad2deg(a0), 1.0, 0.5), hsl(rad2deg(a1), 1.0, 0.5))
            fillcolor(paint)
            fillpath()
        end

        beginpath()
        strokewidth(1)
        strokecolor(rgba(0, 64))
        circle(cx, cy, r0 - 0.5)
        circle(cx, cy, r1 + 0.5)
        strokepath()

        @layer begin
            translate(cx, cy)
            rotate(hue * 2π)

            strokewidth(2)
            strokecolor(rgba(255, 192))
            rect(r0 - 1, -3, r1 - r0 + 2, 6, :stroke)

            paint = BoxGradient(r0 - 3, -5, r1 - r0 + 6, 10, 2, 4, rgba(0, 128), rgba(0))
            beginpath()
            rect(r0 - 2 - 10, -4 - 10, r1 - r0 + 4 + 20, 8 + 20)
            rect(r0 - 2, -4, r1 - r0 + 4, 8)
            winding(:hole)
            fillcolor(paint)
            fillpath()

            r = r0 - 6
            ax = cos(120 / 180 * π) * r
            ay = sin(120 / 180 * π) * r
            bx = cos(-120 / 180 * π) * r
            by = sin(-120 / 180 * π) * r
            beginpath()
            moveto(r, 0)
            lineto(ax, ay)
            lineto(bx, by)
            closepath()
            paint = LinearGradient(r, 0, ax, ay, hsl(360 + 360hue, 1.0, 0.5), rgba(255))
            fillcolor(paint)
            fillpath()
            paint = LinearGradient((r + ax) * 0.5, (0 + ay) * 0.5, bx, by, rgba(0), rgba(0, 255))
            fillcolor(paint)
            fillpath()
            strokecolor(rgba(0, 64))
            strokepath()

            ax = cos(120 / 180 * π) * 0.3r
            ay = sin(120 / 180 * π) * 0.4r
            strokewidth(2)
            strokecolor(rgba(255, 192))
            circle(ax, ay, 5, :stroke)

            paint = RadialGradient(ax, ay, 7, 9, rgba(0, 64), rgba(0))
            fillcolor(paint)
            beginpath()
            rect(ax - 20, ay - 20, 40, 40)
            circle(ax, ay, 7)
            winding(:hole)
            fillpath()
        end
    end
end

function draw_lines(x, y, w, h, t)
    pad = 5
    s = w / 9 - 2pad
    joins = (:miter, :round, :bevel)
    caps = (:butt, :round, :square)
    pts = [
        -0.25s + cos(0.3t) * 0.5s,
        sin(0.3t) * 0.5s,
        -0.25s,
        0,
        0.25s,
        0,
        0.25s + cos(-0.3t) * 0.5s,
        sin(-0.3t) * 0.5s,
    ]

    @layer begin
        for i in 0:2
            for j in 0:2
                fx = x + 0.5s + (3i + j) / 9 * w + pad
                fy = y - 0.5s + pad

                linecap(caps[i+1])
                linejoin(joins[j+1])
                strokewidth(0.3s)
                strokecolor(rgba(0, 160))
                beginpath()
                moveto(fx + pts[1], fy + pts[2])
                lineto(fx + pts[3], fy + pts[4])
                lineto(fx + pts[5], fy + pts[6])
                lineto(fx + pts[7], fy + pts[8])
                strokepath()

                linecap(:butt)
                linejoin(:bevel)

                strokewidth(1)
                strokecolor(rgba(0, 192, 255, 255))
                beginpath()
                moveto(fx + pts[1], fy + pts[2])
                lineto(fx + pts[3], fy + pts[4])
                lineto(fx + pts[5], fy + pts[6])
                lineto(fx + pts[7], fy + pts[8])
                strokepath()
            end
        end
    end
end

function draw_paragraph(x, y, width, height, mx, my)
    txt = "This is longer chunk of text.\n  \n  Would have used lorem ipsum but she    was busy jumping over the lazy dog with the fox and all the men who came to the aid of the party.🎉"
    hoverText = "Hover your mouse over the text to see calculated caret position."
    boxText = "Testing\nsome multiline\ntext."

    lnum = 0
    gutter = 0
    gx = 0
    gy = 0

    @layer begin
        fontsize(15)
        fontface("sans")
        textalign(:left, :top)
        lineh = textmetrics().lineheight

        for row in breaklines(txt, width)
            hit = mx > x && mx < (x + width) && my >= y && my < (y + lineh)

            fillcolor(rgba(255, hit ? 64 : 16))
            rect(x + row.xmin, y, row.xmax - row.xmin, lineh, :fill)

            fillcolor(rgba(255))
            text(row.text, x, y)

            if hit
                caretx = (mx < x + row.width / 2) ? x : x + row.width
                px = x
                glyphs = glyphpos(row.text, x, y)
                for (j, glyph) in enumerate(glyphs)
                    x0 = glyph.x
                    x1 = j < length(glyphs) ? glyphs[j+1].x : x + row.width
                    gx = 0.3x0 + 0.7x1
                    if px <= mx < gx
                        caretx = glyphs[j].x
                    end
                    px = gx
                end

                fillcolor(rgba(255, 192, 0, 255))
                rect(caretx, y, 1, lineh, :fill)

                gutter = lnum + 1
                gx = x - 10
                gy = y + lineh / 2
            end
            lnum += 1
            y += lineh
        end

        if gutter != 0
            fontsize(12)
            textalign(:right, :middle)
            bounds = textbounds(string(gutter), gx, gy)

            fillcolor(rgba(255, 192, 0, 255))
            rrect(
                floor(bounds[1]) - 4,
                floor(bounds[2]) - 2,
                floor(bounds[3] - bounds[1]) + 8,
                floor(bounds[4] - bounds[2]) + 4,
                (floor(bounds[4] - bounds[2]) + 4) / 2 - 1,
                :fill
            )

            fillcolor(rgba(32, 255))
            text(string(gutter), gx, gy)
        end

        y += 20

        fontsize(11)
        textalign(:left, :top)
        lineheight(1.2)

        bounds = textbounds(hoverText, x, y, 150)

        gx = clamp(mx, bounds[1], bounds[3]) - mx
        gy = clamp(my, bounds[2], bounds[4]) - my
        a = sqrt(gx^2 + gy^2) / 30
        a = clamp(a, 0, 1)
        setalpha(a)

        beginpath()
        fillcolor(rgba(220, 255))
        rrect(
            bounds[1] - 2,
            bounds[2] - 2,
            floor(bounds[3] - bounds[1]) + 4,
            floor(bounds[4] - bounds[2]) + 4,
            3,
        )
        px = floor((bounds[3] + bounds[1]) / 2)
        moveto(px, bounds[2] - 10)
        lineto(px + 7, bounds[2] + 1)
        lineto(px - 7, bounds[2] + 1)
        fillpath()

        fillcolor(rgba(0, 220))
        text(hoverText, x, y, 150)
    end
end

function draw_widths(x, y, width)
    @layer begin
        strokecolor(rgba(0, 255))
        for i in 0:19
            w = (i + 0.5) * 0.1
            strokewidth(w)
            line(x, y, x + width, y + 0.3width, :stroke)
            y += 10
        end
    end
end

function draw_caps(x, y, width)
    caps = (:butt, :round, :square)
    lineWidth = 8

    @layer begin
        fillcolor(rgba(255, 32))
        rect(x - lineWidth / 2, y, width + lineWidth, 40, :fill)

        fillcolor(rgba(255, 32))
        rect(x, y, width, 40, :fill)

        strokewidth(lineWidth)
        for i in 0:2
            linecap(caps[i+1])
            strokecolor(rgba(0, 255))
            line(x, y + 10i + 5, x + width, y + 10i + 5, :stroke)
        end
    end
end

function draw_scissor(x, y, t)
    @layer begin
        translate(x, y)
        rotate(deg2rad(5))
        fillcolor(rgba(255, 0, 0, 255))
        rect(-20, -20, 60, 40, :fill)
        scissor(-20, -20, 60, 40)

        translate(40, 0)
        rotate(t)

        @layer begin
            scissor(nothing)
            fillcolor(rgba(255, 128, 0, 64))
            rect(-20, -10, 60, 30, :fill)
        end

        clip(-20, -10, 60, 30)
        fillcolor(rgba(255, 128, 0, 255))
        rect(-20, -10, 60, 30, :fill)
    end
end

function setup(::App)
    assets"images" = [joinpath(dirname(@__DIR__), "..", "assets", "images")]
    assets"fonts"  = [joinpath(dirname(@__DIR__), "..", "assets", "fonts")]

    for i in 1:12
        path = asset("images", "image$i.jpg")
        images[i] = Image(path)
    end

    loadfont("icons", asset"fonts:entypo.ttf")
end

function update(::App)
    t = @seconds
    mx, my = @mouse[x, y]
    width, height = @width, @height

    background(RGB(0.3, 0.3, 0.32))

    draw_eyes(width - 250, 50, 150, 100, mx, my, t)
    draw_paragraph(width - 450, 50, 150, 100, mx, my)
    draw_graph(0, height / 2, width, height / 2, t)
    draw_color_wheel(width - 300, height - 300, 250, 250, t)

    # Line joints
    draw_lines(120, height - 50, 600, 50, t)
    # Line caps
    draw_widths(10, 50, 30)
    # Line caps
    draw_caps(10, 300, 30)

    draw_scissor(50, height - 80, t)

    @layer begin
        # Widgets
        draw_window("Widgets `n Stuff", 50, 50, 300, 400)
        x, y = 60, 95
        draw_search_box("Search", x, y, 280, 25)
        y += 40
        draw_dropdown("Effects", x, y, 280, 28)
        popy = y + 14
        y += 45

        # Form
        draw_label("Login", x, y, 280, 20)
        y += 25
        draw_edit_box("Email", x, y, 280, 28)
        y += 35
        draw_edit_box("Password", x, y, 280, 28)
        y += 38
        draw_checkbox("Remember me", x, y, 140, 28)
        draw_button(icons.login, "Sign in", x + 138, y, 140, 28, rgba(0, 96, 128, 255))
        y += 45

        # Slider
        draw_label("Diameter", x, y, 280, 20)
        y += 25
        draw_edit_box_num("123.00", "px", x + 180, y, 100, 28)
        draw_slider(0.4, x, y, 170, 28)
        y += 55

        draw_button(icons.trash, "Delete", x, y, 160, 28, rgba(128, 16, 8, 255))
        draw_button("", "Cancel", x + 170, y, 110, 28, rgba(0))

        # Thumbnails boxText
        draw_thumbnails(365, popy - 30, 160, 300, images, t)
    end
end

function dispose(::App)
    foreach(delete, images)
end

const Graphs = (;
    fps = PerfGraph(GRAPH_RENDER_FPS, "Frame Time"),
    cpu = PerfGraph(GRAPH_RENDER_MS, "CPU Time")
)

const now = Ref(time_ns())

function before_update(::App)
    now[] = time_ns()
end

function after_update(::App)
    NanoVG.frame(Tela.wsize(@window)..., @window[scale])

    render(Graphs.fps, 5, 5)
    render(Graphs.cpu, 200 + 5, 5)

    cpu_time = 1e-9 * (time_ns() - now[])

    update!(Graphs.fps, @frametime)
    update!(Graphs.cpu, cpu_time)

    NanoVG.render()
end

Tela.@run()
