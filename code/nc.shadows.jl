using Gradus, Makie, CairoMakie

x = SVector(0.0, 10000.0, π / 2, 0.0)

α1, β1, img1 = rendergeodesics(
    KerrMetric(1.0, 0.0),
    x,
    # max integration time
    20_000.0,
    image_width = 800,
    image_height = 800,
    αlims = (-6, 6),
    βlims = (-6, 6),
)

α2, β2, img2 = rendergeodesics(
    KerrMetric(1.0, 0.998),
    x,
    # max integration time
    20_000.0,
    image_width = 800,
    image_height = 800,
    αlims = (-3, 8),
    βlims = (-6, 6),
    verbose = true,
    ensemble = Gradus.EnsembleEndpointThreads(),
)

begin
    fig = Figure(size = (600, 320), backgroundcolor = RGBAf(0.0,0.0,0.0,0.0))

    ga = fig[1,1] = GridLayout()

    ax1 = Axis(ga[1,1], backgroundcolor = RGBAf(0.0, 0.0, 0.0, 1.0), aspect = DataAspect(), title = "Schwarzschild", ylabel = "β", xlabel = "α")
    ax2 = Axis(ga[1,2], backgroundcolor = RGBAf(0.0, 0.0, 0.0, 1.0), aspect = DataAspect(), title = "Kerr", xlabel = "α")

    hideydecorations!(ax2, grid=false)

    heatmap!(ax1, α1, β1, img1', colormap = :bone)
    heatmap!(ax2, α2, β2, img2', colormap = :bone)
    # heatmap!(ax1, α1, β1, img1', colormap = Reverse(:bone))
    # heatmap!(ax2, α2, β2, img2', colormap = Reverse(:bone))

    hlines!(ax1, [0.0], color = :red, linewidth = 1.0)
    hlines!(ax2, [0.0], color = :red, linewidth = 1.0)
    vlines!(ax1, [0.0], color = :red, linewidth = 1.0)
    vlines!(ax2, [0.0], color = :red, linewidth = 1.0)

    colgap!(ga, 0)

    Makie.save("presentation/figs/shadows.png", fig, px_per_unit = 3)
    fig
end
