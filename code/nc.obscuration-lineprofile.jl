using CairoMakie, Makie, LaTeXStrings, Printf
using Gradus

gs = collect(range(0.05, 1.4, 300))

function _default_palette()
    Iterators.Stateful(Iterators.Cycle(Makie.wong_colors()))
end

function calc_lineprofiles(m, x, d, corona; offset = 2.0)
    prof = @time emissivity_profile(m, d, corona, n_samples = 20_000)
    gs = collect(range(0.05, 1.4, 300))
    _, y2 = @time lineprofile(
        m,
        x,
        d,
        prof,
        method = TransferFunctionMethod(),
        β₀ = offset,
        maxrₑ = 100.0,
        numrₑ = 130,
        bins = gs,
        verbose = true,
    )
    y2
end

function calc_thick_disc(theta, height; thickness = 0.3)
    m = KerrMetric(1.0, 0.998)
    x = SVector(0.0, 1e5, deg2rad(theta), 0.0)
    d = ShakuraSunyaev(m; eddington_ratio = thickness)
    corona = LampPostModel(h = height, θ = 1e-3)
    gs, fs = calc_lineprofiles(m, x, d, corona)
end

function calc_thin_disc(theta, height)
    m = KerrMetric(1.0, 0.998)
    x = SVector(0.0, 1e5, deg2rad(theta), 0.0)
    d = ThinDisc(0.0, Inf)
    corona = LampPostModel(h = height, θ = 1e-3)
    gs, fs = calc_lineprofiles(m, x, d, corona; offset = 0.0)
end

heights = [2.0, 3.0, 5.0, 10.0]
incls = [10.0, 30.0, 60.0, 80.0]

all_data = map(heights) do h
    map(incls) do inc
        @info h, inc
        d1 = calc_thick_disc(inc, h)
        d2 = calc_thin_disc(inc, h)
        (d1, d2)
    end
end

begin
    fig = Figure(size=(820, 450), backgroundcolor = RGBAf(0.0,0.0,0.0,0.0,))
    ga = fig[1,1] = GridLayout()

    for (i, row) in enumerate(all_data)
        for (j, d) in enumerate(row)
            ax = Axis(ga[i,j], xlabel = "E/E₀", ylabel = "f", backgroundcolor = RGBAf(0.0,0.0,0.0,0.0,))

            if (i < 4)
                hidexdecorations!(ax, grid = false)
            end
            if (j > 1)
                hideydecorations!(ax, grid = false)
            end

            ylims!(ax, 0, nothing)

            thick, thin = d

            lines!(ax, gs, thin ./ maximum(thin), linewidth=2.0)
            lines!(ax, gs, thick ./ maximum(thick), linewidth=2.0)
        end
    end

    colgap!(ga, 10)
    rowgap!(ga, 10)

    for (i, a) in enumerate(incls)
        Label(
            ga[1, i, Top()],
            text = "θ = $(a)°",
            padding = (0, 0, 10, 0),
            fontsize = 13,
            font = :bold,
        )
    end
    for (i, h) in enumerate(heights)
        Label(
            ga[i, 4, Right()],
            text = "h = $h",
            padding = (10, 0, 00, 0),
            fontsize = 13,
            font = :bold,
        )
    end

    Makie.save("presentation/figs/thick-lineprofiles-grid.svg", fig)
    fig
end









function calculate_lineprofile(m, x, d; β₀ = 2.0, with_bins = true)
    gs = collect(range(0.05, 1.4, 300))
    plane = PolarPlane(GeometricGrid(); Nr = 1000, Nθ = 1000, r_max = 2 * 50.0)
    _, y1 = if with_bins
        @time lineprofile(
            m,
            x,
            d,
            method = BinningMethod(),
            maxrₑ = 50.0,
            plane = plane,
            bins = gs,
            verbose = true,
        )
    else
        nothing, nothing
    end
    _, y2 = @time lineprofile(
        m,
        x,
        d,
        method = TransferFunctionMethod(),
        β₀ = β₀,
        maxrₑ = 50.0,
        numrₑ = 120,
        bins = gs,
        verbose = true,
    )
    (gs, y1), (gs, y2)
end

function plot_data!(ax, color, color2, bins, xfm, thin; norm = 1)
    lines!(ax, thin[1], thin[2] ./ norm, color = :lightgrey)
    # uncomment to include the binned transfer functions
    # lines!(ax, bins[1], bins[2] ./ norm, color = color2)
    lines!(ax, xfm[1], xfm[2] ./ norm, color = color)
end

m = KerrMetric(1.0, 0.998)
s = KerrMetric(1.0, 0.0)

@info "1"
x1 = SVector(0.0, 1000.0, deg2rad(70), 0.0)
thick_bin_1, thick_xfm_1 = calculate_lineprofile(
    m,
    x1,
    ShakuraSunyaev(m; eddington_ratio = 0.3),
    with_bins = false,
)
_, thin_xfm_1 = calculate_lineprofile(m, x1, ThinDisc(0.0, 100000.0), with_bins = false)

s_thick_bin_1, s_thick_xfm_1 = calculate_lineprofile(
    s,
    x1,
    ShakuraSunyaev(m; eddington_ratio = 0.3),
    with_bins = false,
)
_, s_thin_xfm_1 = calculate_lineprofile(s, x1, ThinDisc(0.0, 100000.0), with_bins = false)

@info "2"
x2 = SVector(0.0, 1000.0, deg2rad(45), 0.0)
thick_bin_2, thick_xfm_2 = calculate_lineprofile(
    m,
    x2,
    ShakuraSunyaev(m; eddington_ratio = 0.3),
    with_bins = false,
)
_, thin_xfm_2 = calculate_lineprofile(m, x2, ThinDisc(0.0, 100000.0), with_bins = false)

s_thick_bin_2, s_thick_xfm_2 = calculate_lineprofile(
    s,
    x2,
    ShakuraSunyaev(m; eddington_ratio = 0.3),
    with_bins = false,
)
_, s_thin_xfm_2 = calculate_lineprofile(s, x2, ThinDisc(0.0, 100000.0), with_bins = false)

@info "3"
x3 = SVector(0.0, 1000.0, deg2rad(20), 0.0)
thick_bin_3, thick_xfm_3 = calculate_lineprofile(
    m,
    x3,
    ShakuraSunyaev(m; eddington_ratio = 0.3),
    with_bins = false,
)
_, thin_xfm_3 = calculate_lineprofile(m, x3, ThinDisc(0.0, 100000.0), with_bins = false)

s_thick_bin_3, s_thick_xfm_3 = calculate_lineprofile(
    s,
    x3,
    ShakuraSunyaev(m; eddington_ratio = 0.3),
    with_bins = false,
)
_, s_thin_xfm_3 = calculate_lineprofile(s, x3, ThinDisc(0.0, 100000.0), with_bins = false)

begin
    palette = _default_palette()
    fig = Figure(resolution = (530, 380), backgroundcolor = RGBAf(0.0,0.0,0.0,0.0,))
    ga = fig[1, 1] = GridLayout()

    ax1 = Axis(
        ga[2, 1],
        xlabel = L"E / E_\text{em}",
        ylabel = L"F",
        xticks = [0.25, 0.5, 0.75, 1.0, 1.25],
        title = L"a = 0.998",
        backgroundcolor = RGBAf(0.0,0.0,0.0,0.0,),
    )
    ax2 = Axis(
        ga[2, 2],
        xlabel = L"E / E_\text{em}",
        ylabel = L"F",
        xticks = [0.25, 0.5, 0.75, 1.0, 1.25],
        title = L"a = 0",
        backgroundcolor = RGBAf(0.0,0.0,0.0,0.0,),
    )
    hideydecorations!(ax2, grid = false)

    K = maximum(thin_xfm_2[2])
    K2 = maximum(s_thin_xfm_2[2])

    color = popfirst!(palette)
    color2 = :red
    # color2 = popfirst!(palette)
    l1 = plot_data!(ax1, color, color2, thick_bin_1, thick_xfm_1, thin_xfm_1; norm = K)
    plot_data!(ax2, color, color2, s_thick_bin_1, s_thick_xfm_1, s_thin_xfm_1; norm = K2)

    color = popfirst!(palette)
    # color2 = popfirst!(palette)
    l2 = plot_data!(ax1, color, color2, thick_bin_2, thick_xfm_2, thin_xfm_2; norm = K)
    plot_data!(ax2, color, color2, s_thick_bin_2, s_thick_xfm_2, s_thin_xfm_2; norm = K2)

    color = popfirst!(palette)
    # color2 = popfirst!(palette)
    l3 = plot_data!(ax1, color, color2, thick_bin_3, thick_xfm_3, thin_xfm_3; norm = K)
    plot_data!(ax2, color, color2, s_thick_bin_3, s_thick_xfm_3, s_thin_xfm_3; norm = K2)

    xlims!(ax1, extrema(thin_xfm_2[1])...)

    Legend(
        ga[1, 1:2],
        [l1, l2, l3],
        [L"70^\circ", L"45^\circ", L"20^\circ"],
        orientation = :horizontal,
        framevisible = false,
        padding = (0, 0, 0, 0),
    )

    rowgap!(ga, 10)
    colgap!(ga, 10)
    linkyaxes!(ax1, ax2)
    xlims!(ax2, 0.4, maximum(s_thin_xfm_2[1]))

    Makie.save("presentation/figs/thick-lineprofiles.svg", fig)

    fig
end
