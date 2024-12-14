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
    plot_solutions!(ax, sols)


    Makie.xlims!(ax, -7, 14.0)
    Makie.ylims!(ax, -6, dim)

    draw_ring!(ax, Gradus.inner_radius(m))
    draw_ring!(ax, 3 * √3, linestyle = :dash, linewidth = 1.0)

    colgap!(ga, 0)

    # Makie.save("presentation/figs/photon-ring-paths.svg", fig)
    fig
end
