using Gradus, Makie, CairoMakie

struct HotSpot{T} <: AbstractAccretionDisc{T}
    radius::T
    position::SVector{3,T}
end

# convenience constructor
HotSpot(R::T, r::T, ϕ::T) where {T} = HotSpot(R, SVector(r, π/2, ϕ))

# we don't have an intersection criteria: instead, the calculations 
# are treated as if we are always within geometry
Gradus.is_finite_disc(::Type{<:HotSpot}) = false

# Keplerian circular orbit fixed velocity
function Gradus.fluid_velocity(
    m::AbstractMetric, 
    hs::HotSpot, 
    x, 
    r_isco, 
    λ
)
    CircularOrbits.fourvelocity(m, hs.position[1])
end

function Gradus.fluid_absorption_emission(
    m::AbstractMetric,
    hs::HotSpot,
    x,
    ν,
    v_disc,
)
    # use coordinate time, given the disc velocity, to advance the position
    # as in the slow light regime
    x_disc = hs.position - SVector(0, 0, v_disc[4] / v_disc[1] * x[1])

    dist = cartesian_squared_distance(m, x_disc, x)
    ε = exp(-dist / (2 * hs.radius^2))
    # return absorption, emissivity, disc velocity
    (zero(eltype(x)), ε)
end

m = KerrMetric(1.0, 0.998)
x = SVector(0.0, 10_000.0, deg2rad(75), 0.0)
hs = HotSpot(0.7, Gradus.isco(m) + 3, -2.0)

a, b, img = rendergeodesics(
    m, 
    x, 
    hs, 
    20_000.0, 
    verbose = true, 
    αlims = (-10, 10),
    βlims = (-10, 10),
    image_width = 800,
    image_height = 800,
    trace = Gradus.TraceRadiativeTransfer(I₀ = 0.0),
    pf = PointFunction((m, gp, t) -> gp.aux[1]),
)

begin
    fig = Figure(size = (400, 400), backgroundcolor = RGBAf(0.0,0.0,0.0,0.0))
    ax = Axis(fig[1,1], aspect = DataAspect(), ylabel = "β", xlabel = "α")

    img2 = copy(img)
    heatmap!(a, b, img2', colormap = :batlow)
    Makie.save("presentation/figs/hot-spot.png", fig, px_per_unit = 3)
    fig
end