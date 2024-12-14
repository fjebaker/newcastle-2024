#import "tamburlaine.typ": *

#let HANDOUT_MODE = false
#enable-handout-mode(HANDOUT_MODE)

#show figure.caption: c => block(width: 80%)[
  #text(fill:PRIMARY_COLOR, weight: "black")[#c.supplement #counter(figure).display(c.numbering): ]#c.body
]

#show: tamburlaine-theme.with(aspect-ratio: "4-3")
#show link: item => underline(text(blue)[#item])

#let COLOR_CD = color.rgb("#56B4E9")
#let COLOR_REFL = color.rgb("#D55E00")
#let COLOR_CONT = color.rgb("#0072B2")

#set par(spacing: 0.5em, leading: 0.5em)
#set text(tracking: -0.5pt, size: 22pt)

#let uob_logo = read("./figs/UoB_CMYK_24.svg")

#let todo(item) = text(fill: red, [#item])

#title-slide(
  title_size: 30pt,
  title: [
    #image("./figs/title-text.svg", width: 100%)
  ],
  authors: ([Fergus Baker], text(weight: "regular", [Andrew Young])),
  where: "Newcastle",
)[
  #align(right)[#image.decode(uob_logo, width: 20%)]
]

#slide(title: "Take home message")[
  #text(size: 40pt)[
    #v(3em)
    Including general relativistic effects is _easier_ than you'd think #text(size: 28pt)[_thanks to ray-tracing_].
  ]
]

#slide(title: "Overview")[
  This will be a modelling talk:
  #v(1em)
  0. Introduction
  #v(1em)
  1. *General relativistic ray-tracing* #h(1fr) What is it, how does it work?
  #v(1em)
  2. *Toy accretion models* #h(1fr) I have a ray-tracer! How do I make it useful?
  3. *The black hole corona*
  #v(1em)
  4. *Detour: disc models*
  #v(1em)
  5. *Reverberation lags & the lamppost model*
  6. *... _beyond_ the lamppost model*
  #v(1em)
  7. *Going further and conclusions*
]

#slide(title: "0. Black holes for the initiated")[
  Why are *black holes* important / why study them?
  #set text(size: 18pt)
  - Because they are _really cool!_
  // to study black holes is to study fundemental gravity itself, no other object is so extreme, and in no other place can we observe such macroscopic representations of a fundemental force
  // anchor points in the cosmic web, related to the formation and evolution of the universe, basically every galaxy has one, drive galaxy evolution, feedback mechanisms interact with the surrounding material and regulate star formation
  // represent a number of paradoxes, a fancy way of saying a place where our theories break down, from causality paradoxes to the cosmic censorship conjecture and the absolute mystery of the central singularity
  \
  #grid(columns: (50%, 1fr),
    [
    For (EM) astronomers, generally *classify two\* types* of black holes:
    1. Active Galactic Nuclei (*AGN*)
    2. Black hole binaries (*BHB*)
    3. \*Merging / systems of black holes, primordial / micro / rogue black holes
    \
    Except for two notable exceptions, *cannot resolve the systems*
    - Characteristic scale is $r_g = (G M) / c^2$, so for 1\" at 1pc would need $10^9 M_dot.circle$
    - M87\* is $10^9 M_dot.circle$ but at $D approx$ 16 Mpc
    - Closest is Gaia BH1 at \~ 470 pc and \~ 1 $M_dot.circle$

    #v(1fr)
    #align(center, cbox(fill: PRIMARY_COLOR, text(fill: SECONDARY_COLOR)[
      Today: ideas apply to *any black hole* \
      #text(size: 15pt)[(not enough time to go into discriminating details)]
    ]))
    #v(30pt)
    ],
    [
      #set align(center)
      #set text(size: 11pt)
      #move(
        dy: -50pt,
        figure(
          image("./figs/NGC4151_Galaxy_from_the_Mount_Lemmon_SkyCenter_Schulman_Telescope_courtesy_Adam_Block.jpg", width: 160pt),
          caption: [NGC4151 by #link("https://en.wikipedia.org/wiki/NGC_4151#/media/File:NGC4151_Galaxy_from_the_Mount_Lemmon_SkyCenter_Schulman_Telescope_courtesy_Adam_Block.jpg")[Adam Block/Mount Lemmon SkyCenter/\ University of Arizona], CC BY-SA 4.0],
        )
      )
      #move(
        dy: -30pt,
        figure(
          image("./figs/Gaia_BH1_PanSTARRS.jpg", width: 160pt),
          caption: [Gaia BH1 by #link("https://en.wikipedia.org/wiki/Gaia_BH1#/media/File:Gaia_BH1_PanSTARRS.jpg")[Meli thev], CC BY-SA 4.0],
        )
      )
    ]
  )

  // so no state cycle for BHB, no ionisation differences
]

#slide(title: "Ray tracing")[
  #{
    set text(size: 15pt)
    figure(
      image("./figs/albrecht-durer.jpg"),
      caption: [Woodcut of Jacob de Keyser's invention, by #link("https://archive.org/details/website_201909")[Albrecht Dürer], Public Domain]
    )
  }

  #v(0.5em)

  When we talk about *ray-tracing*, what do we mean?
  - General technique for projecting the appearance of 3 (or more) dimensional geometry.
  - Today, synonymous with tracing *photons* through a system
]

#slide(title: "Ray tracing applications")[
  #grid(columns: (62%, 1fr),
    [
      Used extensively in *computer graphics*
      #v(0.5em)
      Also used extensively in *science*:
      - *Instrument design*, for simulating detector efficiency
      - *Radiative transfer*, including extinctions
      - For calculating *atmospheric effects*

      #{
        set align(center)
        set text(size: 15pt)
        figure(
          image("./figs/peterson-et-al-fig2.jpg"),
          caption: [Hello]
        )
      }
    ],
    [
      #set text(size: 15pt)
      #set align(center)
      #figure(
        image("./figs/Ray_trace_diagram.svg"),
        caption: [Graphical ray tracing, by #link("https://en.wikipedia.org/wiki/Ray_tracing_(graphics)#/media/File:Ray_trace_diagram.svg")[Henrik], CC BY-SA 4.0]
      )
    ]
  )


  #v(1fr)
  #align(center, cbox(fill: PRIMARY_COLOR, text(fill: SECONDARY_COLOR)[
    In *astronomy*: e.g. *observation simulation* or *gravitational lensing*.
  ]))
]

#slide(title: "1. General relativistic ray-tracing")[
  Einstein's theories predict that matter curves spacetime

  - Light no longer travels in straight lines
  - Follow geodesics (shortest paths)

  - The basic mathematics that we need actually follows from the Equivalence Principle and requiring that the speed of light is the same in all frames

  #let hl(t) = text(fill: PRIMARY_COLOR, t)
  $
  (partial^2 x^mu) / (partial tau^2) &= - Gamma^mu_(nu sigma) (partial x^nu) / (partial tau) (partial x^sigma) / (partial tau), \
  #hl[$m underbrace(#text(fill: TEXT_COLOR)[$(partial^2 x^mu) / (partial tau^2)$], a)$] &= #hl[F]
  $

  *Curvature acts as to impart a force, deviating trajectories from Euclidean straight paths*
  - we call this force gravity

  The curvature term $Gamma^mu_(nu sigma)$ is a function *only of the metric*, $g_(mu nu)$. The metric depends on the distribution of matter.
]


#subtitle-slide[
  #let wh(t) = text(fill:SECONDARY_COLOR, t)
  #text(size: 50pt, weight: "bold")[Kerr metric]
  #v(5pt)
  #text(size: 100pt, fill: black)[
  $g_(mu nu)( #wh[M], #wh[a] )$
  ]

  #block[
    #align(left, text(size: 30pt, weight:"regular")[
      #quote[The black holes of nature are the *most perfect macroscopic objects* in the universe \[...\]. And since the general theory of relativity provides only a single unique family of solutions \[...\], they are the *simplest objects* as well.]
      #align(right, [-- S. Chandrasekhar\ #text(size: 18pt)[prologue to The Mathematical Theory of Black Holes]])
    ])
  ]
]

#subtitle-slide(bg: TEXT_COLOR)[
  #set text(size: 15pt, weight: "regular")
  #figure(
    image("./figs/luminet.png", width: 80%),
    caption: [*J-P. Luminet* (1978): Image of a Spherical Black Hole with Thin Accretion Disc]
  )
]

#slide(title: "Putting together the machinery")[
  #set text(size: 15pt)
  #grid(columns: (68%, 1fr),
    [
      #figure(
        image("./figs/geodesic-paths.svg", width: 100%),
        caption: [Geodesics traces from asymptotic observers for different spacetimes.]
      )

      todo: figure showing how we construct an image
    ],
    [
      ```julia
      using Gradus
      # 1. Flat
      m = SphericalMetric()
      # 2. Schwarzschild
      m = KerrMetric(M = 1.0, a = 0.0)
      # 3. Kerr
      m = KerrMetric(M = 1.0, a = 1.0)

      # spherical 4 vector
      observer = SVector(
        0, 1e4, π/2, 0
      )

      # set up impact parameter space
      α = collect(
        range(-10.0, 10.0, 20)
      )
      β = fill(0, size(α))

      # calc initial velocities
      vs = map_impact_parameters(
        m, observer, α, β
      )

      sols = tracegeodesics(
        m,
        observer,
        init_vels
      )
      ```
    ]
  )
]

#slide(title: "The shadow of a black hole")[
  show shadow for schwarzschild and kerr solutions: coordinate time
  - show code example with the point function
  #grid(columns: (68%, 1fr),
    [
      #set text(size: 15pt)
      #figure(
        image("./figs/shadows.png", width: 100%),
        caption: [Hello],
      )
    ],
    [
      #set text(size: 15pt)
      Construct a grid of *impact parameters*, a pair for each pixel:
      #v(1em)
      ```julia
      pf = PointFunction(
        (m, p, tau) -> p.x[1]
      )

      # evaluate point function
      # for each geodesic
      α, β, img = rendergeodesics(
          m,
          observer,
          # max integration time
          20_000.0,
          image_width = 800,
          image_height = 800,
          pf = pf,
          αlims = (-6, 6),
          βlims = (-6, 6),
      )
      ```
    ])
]

#slide(title: "2. Toy accretion models")[
  #set text(size: 15pt)
  #grid(columns: (68%, 1fr),
    {
      figure(
        image("./figs/thin-disc-projection.png", width: 100%),
        caption: [TODO]
      )
    },
    [
      An *infinitely thin* disc model in the equatorial plane:
      #v(1em)
      ```julia
      d = ThinDisc(Gradus.isco(m), 20.0)
      # only those that intersect the disc
      pf = PointFunction(
        (m, p, t) -> p.x[1]
      ) ∘ filter_intersected()

      α, β, img = rendergeodesics(
          m,
          observer,
          d,
          # maximum integration time
          20_000.0,
          βlims = (-13, 14),
          αlims = (-23, 23),
          image_width = 1080,
          image_height = 720,
          pf = pf,
      )
      ```

    ]
  )

  (also include code example)
  put an infinitely thin disc around the black hole
  Talk about the projection effects and the light travel times
]

#slide(title: "Aside: the photon ring")[
  at one particular radius the geodesics can wrap around the black hole several times
  Bright ring feature

  #set text(size: 12pt)
  #grid(columns: (63%, 1fr),
  [

    #figure(
      image("./figs/photon-ring-paths.svg", width: 60%),
      caption: [TODO]
    )
  ],
  [
    #set align(center)
    #figure(
      image("./figs/m-von-laue-1921.png", height: 60%),
      caption: [#link("https://archive.org/details/dierelativitts02laueuoft/page/226/mode/2up")[M. Von Laue], 1921]
    )
  ]
  )

  include EHT images
]

#slide(title: "Calculating observables")[
  The accretion disc is rotating around the black hole in Keplerian orbits. This means we can
  calculate the relative energy shift due to Doppler effect, special relativity, and general relativity

  show redshift maps
  show redshift histograms
]

#slide(title: "Novikov-Thorne")[
  - an example of how we can calculate the flux of the disc at different radii
  using a black body emission model
]

#subtitle-slide(bg: TEXT_COLOR)[
  Our version of Luminet
]

#subtitle-slide[
  #v(-100pt)
  \3.
  #v(30pt)
  The Black Hole Corona
]

#slide(title: "A black hole and its crown")[
  We have our basic accretion disc model, and now we add the corona
  - some theories as to how it forms
  - illuminates the system in high energy X-rays
]

#slide(title: [Preview: The _lamppost_ model])[

]

#slide(title: "Reflected emission")[
  - the corona changes the emissivity of the disc
]

#slide(title: "Lineprofile calculations")[
  Use the redshift maps together with the emissivity functions; no longer consider a single photon, but a bundle -- need Liouville's theorem

  Sensitive to parameters of the corona through the emissivity
  - Sensitive to parameters of the spacetime through the GR effects
  - Sensitive to the parameters of the disc (inner and outer radius)
]

#slide(title: "4. Detour: disc models")[
  We've so far only used an infinitely thin accretion disc
  not physical

  next best thing is to use the shakura sunyaev disc models
  - *any scale height in the disc* will introduce *obscuration effects* at steep enough inclinations
]

#slide(title: "5. Reverberation lags")[

]

#slide(title: "6. Beyond the lamppost model")[
]

#slide(title: "6. Going further")[
  what else can you do with GRRT
  - hot spots
  - precessing discs
  - SED models

  We've only talked about optically thick discs, but one can include optically thin ones too
  - radiative transfer
  - polarisation properties
]

// BH cannot be resolved (except for two notable cases), so images are pretty
// but we can't use them. Ray tracing also useful for spectral and timing
// calculations

#slide(title: "Thank you")[
    #v(1em)
  #align(center)[
  #cbox(fill: PRIMARY_COLOR, width: 90%, text(fill: SECONDARY_COLOR)[
    == Summary
    #align(left)[
      Gradus.jl can efficiently compute *extended cornae*
      - Construct models that are *performant enough* for parameter fitting
      #v(0.5em)
      *Extended coronae* have *time-dependent* emissivity profiles
      - Timescale of variations on the order of 10s of $t_"g"$
      - Disk-like coronae increase reflection spectrum flux around $E\/E_0 = 1$
    ]
  ])
  ]
  #v(1em)
  #set text(size: 18pt)
  Gradus.jl source code (GPL-3.0):
  - https://github.com/astro-group-bristol/Gradus.jl
  #v(0.5em)
  Documentation:
  - https://astro-group-bristol.github.io/Gradus.jl/
  #v(0.5em)
  Source for slides and figures:
  - https://github.com/fjebaker/new-results-in-xray-2024
  #v(0.5em)
  #align(right)[
  Contact: \
  #link("fergus.baker@bristol.ac.uk")
  ]

]
