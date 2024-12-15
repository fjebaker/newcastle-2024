using Gradus, Makie, CairoMakie

function plot_solutions!(ax, sols; kwargs...)
    for sol in sols.u
        path = Gradus._extract_path(sol, 20048, t_span = 50.0)  
        x = path[1]
        y = path[2]
        
        lines!(ax, x, y; kwargs...)
    end
end

function calculate_geodesics(m; α = collect(range(-10, 10, 20)))
    # observer position
    x = SVector(0.0, 470_000.0, π/2, 0.0)
    # set up impact parameter space
    β = fill(0, size(α))

    # build initial velocity and position vectors
    vs = map_impact_parameters(m, x, α, β)
    xs = fill(x, size(vs))

    sols = tracegeodesics(m, xs, vs, 2x[2], abstol = 1e-11, reltol = 1e-11, chart = Gradus.chart_for_metric(m, 2x[2]))
end

function draw_ring!(ax, R; kwargs...)
    ϕ = collect(range(0.0, 2π, 100))
    r = fill(R, size(ϕ))
    x = @. r * cos(ϕ)
    y = @. r * sin(ϕ)
    lines!(ax, x, y; color = :black, linewidth = 3.0, kwargs...)
end

m = KerrMetric(M=1.0, a=0.0)

begin
    fig = Figure(size = (400,300), backgroundcolor = RGBAf(0.0, 0.0, 0.0, 0.0))
    dim = 9.3

    ga = fig[1,1] = GridLayout()
    ax = Axis(ga[1,1], aspect = DataAspect(), backgroundcolor = RGBAf(0.0, 0.0, 0.0, 0.0), ylabel = "y or α", xlabel = "x")

    sols = calculate_geodesics(m, α = [-3 * √3])
    plot_solutions!(ax, sols, linewidth = 3.0)

    sols = calculate_geodesics(m, α = -collect(2:2:8))
    plot_solutions!(ax, sols, color = :black)


    Makie.xlims!(ax, -7, 14.0)
    Makie.ylims!(ax, -6, dim)

    draw_ring!(ax, Gradus.inner_radius(m))
    draw_ring!(ax, 3 * √3, linestyle = :dash, linewidth = 1.0)

    colgap!(ga, 0)

    Makie.save("presentation/figs/photon-ring-paths.svg", fig)
    fig
end


function ringfo(m;
    αlims = (-8, 8),
    βlims = (-8, 8),
    )
    x = SVector(0.0, 1_000_000.0, deg2rad(10), 0.0)
    pf = PointFunction( (m, gp, t) -> gp.aux.winding) ∘ 
        FilterPointFunction((m, gp, t) -> gp.aux.winding > 1, NaN)
    a,b,img = @time rendergeodesics(
        m,
        x,
        2x[2],
        αlims = αlims,
        βlims = βlims,
        trace = TraceWindings(),
        chart = Gradus.chart_for_metric(m, 2x[2]),
        image_width = 800,
        image_height = 800,
        verbose = true,
        pf = pf
    )
end

d1 = ringfo(m)
d2 = ringfo(m, αlims = (1.96, 2.04), βlims = (-4.85, -4.75))

extrema(filter(!isnan, d1[3]))

begin
    fig = Figure(size = (400, 400))
    ax1 = Axis(fig[1,1], aspect = DataAspect(), xlabel = "α", ylabel = "β", title = "Schwarzschild")
    ax2 = Axis(fig[1,1], aspect = DataAspect(), width = Relative(0.3), height = Relative(0.4), halign = 0.6, valign = 0.6)
    # hidedecorations!(ax2)

    # hideydecorations!(ax2, grid=false)
    contourf!(ax1, d1[1], d1[2], d1[3]', colormap = :batlow)
    contourf!(ax2, d2[1], d2[2], d2[3]', colormap = :batlow)

    poly!(ax1, [(1.96, -4.85), (1.96, -4.75), (2.04, -4.75), (2.04, -4.85)], color = :red)

    xlims!(ax1, -6.4, 6.4)
    ylims!(ax1, -6.8, 6.3)

    Makie.save("presentation/figs/raw/photon-ring-schwarzschild.svg", fig)
    fig
end