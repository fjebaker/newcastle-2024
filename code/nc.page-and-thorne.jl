using Gradus, Makie, CairoMakie

function page_thorne_flux(r, M, a)
    r_isco = Gradus.isco(KerrMetric(M, a))
    if r < r_isco
        return 0.0
    end
    x = √(r / M)
    x0 = √(r_isco / M)

    x1 = 2 * cos((1 / 3) * (acos(a)) - (π / 3))
    x2 = 2 * cos((1 / 3) * (acos(a)) + (π / 3))
    x3 = -2 * cos((1 / 3) * (acos(a)))

    flux =
        (3 / (2 * M)) *
        (1 / (x^2 * (x^3 - (3 * x) + (2 * a)))) *
        (
            x - x0 - ((3 / 2) * a * log(x / x0)) -
            (3 * (x1 - a)^2) / (x1 * (x1 - x2) * (x1 - x3)) *
            log((x - x1) / (x0 - x1)) -
            (3 * (x2 - a)^2) / (x2 * (x2 - x1) * (x2 - x3)) *
            log((x - x2) / (x0 - x2)) -
            (3 * (x3 - a)^2) / (x3 * (x3 - x1) * (x3 - x2)) *
            log((x - x3) / (x0 - x3))
        )

    flux
end

m = KerrMetric(1.0, 0.998)
radii = collect(Gradus.Grids._geometric_grid(Gradus.inner_radius(m), 1000.0, 200))
f = page_thorne_flux.(radii, m.M, m.a)

begin
    fig = Figure()
    ax = Axis(fig[1,1], xscale = log10)
    lines!(ax, radii, f)
    fig
end


x = SVector(0.0, 1000.0, deg2rad(78), 0.0)
d = ThinDisc(Gradus.isco(m), Inf)
redshift_pf = ConstPointFunctions.redshift(m, x)
pf = PointFunction((m, p, t) -> begin
    f = page_thorne_flux(p.x[2], m.M, m.a)
    g = redshift_pf(m, p, t)
    g^3 * f
end
) ∘ ConstPointFunctions.filter_intersected()

α, β, img = @time rendergeodesics(
    m,
    x,
    d,
    # maximum integration time
    2000.0,
    βlims = (-20, 20), 
    αlims = (-40, 40),
    image_width = 1080,
    image_height = 720,
    verbose = true,
    pf = pf,
)

begin
    fig = Figure(size = (600, 320), backgroundcolor = RGBAf(0.0,0.0,0.0,0.0))

    ga = fig[1,1] = GridLayout()

    ax1 = Axis(ga[1,1], aspect = DataAspect(), backgroundcolor = RGBAf(0.0,0.0,0.0,1.0))
    heatmap!(α, β, img', colormap = Reverse(:binary))

    hidedecorations!(ax1)

    Makie.save("presentation/figs/raw/our-version-of-luminet.png", fig, px_per_unit = 3)
    fig
end