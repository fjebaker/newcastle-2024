using Gradus

# metric and metric parameters
m = KerrMetric(M=1.0, a=0.5)
# observer position
x = SVector(0.0, 1000.0, deg2rad(78), 0.0)

d = ThinDisc(Gradus.isco(m), 20.0)
pf = PointFunction((m, p, t) -> p.x[1]) ∘ ConstPointFunctions.filter_intersected()

α, β, img = @time rendergeodesics(
    m,
    x,
    d,
    # maximum integration time
    2000.0,
    βlims = (-13, 14), 
    αlims = (-23, 23),
    image_width = 1080,
    image_height = 720,
    verbose = true,
    pf = pf,
)

pf2 = PointFunction((m, p, t) -> p.x[1]) ∘ FilterPointFunction((m, p, t) -> p.status == Gradus.StatusCodes.WithinInnerBoundary, NaN)

α2, β2, img2 = @time rendergeodesics(
    m,
    x,
    d,
    # maximum integration time
    2000.0,
    βlims = (-13, 14), 
    αlims = (-23, 23),
    image_width = 1080,
    image_height = 720,
    verbose = true,
    pf = pf2,
)


begin
    fig = Figure(size = (600, 420), backgroundcolor = RGBAf(0.0,0.0,0.0,0.0))

    ga = fig[1,1] = GridLayout()

    ax1 = Axis(ga[1,1], aspect = DataAspect(), title = "Moderately spinning (a=0.5)", ylabel = "β", xlabel = "α", backgroundcolor = RGBAf(0.0,0.0,0.0,0.0))
    heatmap!(α2, β2, img2', colormap = :bone)
    heatmap!(α, β, img', colormap = Reverse(:batlow))

    Makie.save("presentation/figs/thin-disc-projection.png", fig, px_per_unit = 3)
    fig
end