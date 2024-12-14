using Gradus, Makie, CairoMakie

function plot_solutions!(ax, sols)
    for sol in sols.u
        path = Gradus._extract_path(sol, 20048, t_span = 50.0)  
        x = path[1]
        y = path[2]
        
        lines!(ax, x, y)
    end
end

function calculate_geodesics(m)
    # observer position
    x = SVector(0.0, 10000.0, π/2, 0.0)
    # set up impact parameter space
    α = collect(range(-10.0, 10.0, 20))
    β = fill(0, size(α))

    # build initial velocity and position vectors
    vs = map_impact_parameters(m, x, α, β)
    xs = fill(x, size(vs))

    sols = tracegeodesics(m, xs, vs, 20000.0, chart = Gradus.chart_for_metric(m, closest_approach = 1.10))
end

flat = Gradus.SphericalMetric()
schwarzschild = KerrMetric(M=1.0, a=0.0)
kerr = KerrMetric(M=1.0, a=-1.0)

begin
    fig = Figure(size = (800,300), backgroundcolor = RGBAf(0.0, 0.0, 0.0, 0.0))
    dim = 17

    ga = fig[1,1] = GridLayout()

    for (title, i, m) in zip(
        ("Flat", "Schwarzschild", "Kerr"),
        1:3,
        (flat, schwarzschild, kerr)
    )
        ax = Axis(ga[1,i], aspect = DataAspect(), title = title, backgroundcolor = RGBAf(0.0, 0.0, 0.0, 0.0))
        
        sols = calculate_geodesics(m)
        plot_solutions!(ax, sols)

        if i != 1
            hideydecorations!(ax, grid=false)
        end

        Makie.xlims!(ax, -dim,dim)
        Makie.ylims!(ax, -dim,dim)

        if title != "Flat"
            R = Gradus.inner_radius(m)
            ϕ = collect(range(0.0, 2π, 100))
            r = fill(R, size(ϕ))
            x = @. r * cos(ϕ)
            y = @. r * sin(ϕ)
            lines!(ax, x, y, color = :black, linewidth = 3.0)
        end
    end

    colgap!(ga, 0)

    Makie.save("presentation/figs/geodesic-paths.svg", fig)
    fig
end
