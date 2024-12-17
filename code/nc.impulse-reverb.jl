using Gradus, Makie, CairoMakie, LaTeXStrings, Printf

function _default_palette()
    Iterators.Stateful(Iterators.Cycle(Makie.wong_colors()))
end

function _format_model(model)
    hh = Printf.@sprintf "%.0f" model.h
    L"h = %$hh r_\text{g}"
end


function calculate_2d_transfer_function(m, x, model, itb, prof, radii)
    bins = collect(range(0.0, 1.5, 300))
    tbins = collect(range(0, 2000.0, 3000))

    t0 = continuum_time(m, x, model)
    @show t0

    flux = @time Gradus.integrate_lagtransfer(
        prof,
        itb,
        bins,
        tbins;
        t0 = t0,
        n_radii = 8000,
        rmin = minimum(radii),
        rmax = maximum(radii),
        h = 1e-8,
        g_grid_upscale = 10,
    )

    flux[flux.==0] .= NaN
    bins, tbins, flux
end

function calculate_lag_transfer(m, d, model, radii, itb)
    prof = @time emissivity_profile(m, d, model; n_samples = 100_000)
    E, t, f = @time calculate_2d_transfer_function(m, x, model, itb, prof, radii)
    ψ = Gradus.sum_impulse_response(f)
    freq, τ = @time lag_frequency(t, f)
    freq, τ, ψ, t
end

m = KerrMetric(1.0, 0.998)
x = SVector(0.0, 10_000.0, deg2rad(45), 0.0)
radii = Gradus.Grids._inverse_grid(Gradus.isco(m), 1000.0, 200)

# models
model1 = LampPostModel(h = 2.0)
model2 = LampPostModel(h = 5.0)
model3 = LampPostModel(h = 10.0)
model4 = LampPostModel(h = 20.0)

# thin disc
d = ThinDisc(0.0, Inf)

itb = Gradus.interpolated_transfer_branches(m, x, d, radii; verbose = true, β₀ = 2.0)

freq1, τ1, impulse1, time1 = calculate_lag_transfer(m, d, model1, radii, itb)
freq2, τ2, impulse2, time2 = calculate_lag_transfer(m, d, model2, radii, itb)
freq3, τ3, impulse3, time3 = calculate_lag_transfer(m, d, model3, radii, itb)
freq4, τ4, impulse4, time4 = calculate_lag_transfer(m, d, model4, radii, itb)

data = [
    (freq1, τ1, impulse1, time1),
    (freq2, τ2, impulse2, time2),
    (freq3, τ3, impulse3, time3),
    (freq4, τ4, impulse4, time4)
]

thick_d = ShakuraSunyaev(m)

thick_itb = Gradus.interpolated_transfer_branches(m, x, d, radii; verbose = true, β₀ = 2.0)

thick_freq1, thick_τ1, thick_impulse1, thick_time1 =
    calculate_lag_transfer(m, thick_d, model1, radii, thick_itb)
thick_freq2, thick_τ2, thick_impulse2, thick_time2 =
    calculate_lag_transfer(m, thick_d, model2, radii, thick_itb)
thick_freq3, thick_τ3, thick_impulse3, thick_time3 =
    calculate_lag_transfer(m, thick_d, model3, radii, thick_itb)
thick_freq4, thick_τ4, thick_impulse4, thick_time4 =
    calculate_lag_transfer(m, thick_d, model4, radii, thick_itb)

data_thick = [
    (thick_freq1, thick_τ1, thick_impulse1, thick_time1),
    (thick_freq2, thick_τ2, thick_impulse2, thick_time2),
    (thick_freq3, thick_τ3, thick_impulse3, thick_time3),
    (thick_freq4, thick_τ4, thick_impulse4, thick_time4)
]

begin
    palette = _default_palette()

    fig = Figure(resolution = (400, 550), backgroundcolor=RGBAf(0.0,0.0,0.0,0.0))
    ga = fig[1, 1] = GridLayout()

    ax1 = Axis(ga[2, 1], yscale = log10, xlabel="Time", ylabel="Impulse Response", backgroundcolor=RGBAf(0.0,0.0,0.0,0.0))
    ylims!(ax1, 2e-5, 0.2)
    xlims!(ax1, 0, 120)

    ax2 = Axis(ga[3, 1], xscale = log10, xlabel = "Phase Frequency", ylabel = "Lag", backgroundcolor=RGBAf(0.0,0.0,0.0,0.0))
    xlims!(ax2, 5e-5, 0.3)
    ylims!(ax2, -10, 50)
    hlines!(ax2, [0.0], color = :black)

    thin_lines = []
    thick_lines = []

    palette = _default_palette()

    labels = [ "h=2", "h=5", "h=10", "h=20", ]

    for (lbl, d) in zip(labels, data)
        freq, tau, _imp, time = d
        imp = copy(_imp)
        imp[imp .< 2e-5] .= 2e-5

        c = popfirst!(palette)
        l = lines!(
            ax1,
            time,
            imp,
            color = c,
            linewidth = 2.0,
        )
        push!(thin_lines, l)
        lines!(
            ax2,
            freq,
            tau,
            color = c,
            linewidth = 2.0,
        )
    end

    palette = _default_palette()
    for (lbl, d) in zip(labels, data_thick)
        freq, tau, _imp, time = d
        imp = copy(_imp)
        imp[imp .< 2e-5] .= 2e-5

        c = popfirst!(palette)
        l = lines!(
            ax1,
            time,
            imp,
            color = c,
            linewidth = 1.0,
            linestyle = :dash,
        )
        push!(thick_lines, l)
        lines!(
            ax2,
            freq,
            tau,
            color = c,
            linewidth = 1.0,
            linestyle = :dash,
        )
    end

    Legend(
        ga[1, 1],
        thin_lines,
        map(_format_model, [model1, model2, model3, model4]),
        orientation = :horizontal,
        height = 10,
        framevisible = false,
        padding = (0, 0, 0, 0),
    )

    Legend(
        ga[3, 1],
        [thin_lines[1], thick_lines[1]],
        ["Thin", "Thick"],
        height = Relative(0.3),
        width = Relative(0.2),
        valign = 0.85,
        halign = 0.8,
        framevisible = false,
        backgroundcolor=RGBAf(0.0,0.0,0.0,0.0),
    )

    Makie.save("presentation/figs/impulse-reverb.svg", fig)
    fig
end
