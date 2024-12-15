#import "tamburlaine.typ": *

#let HANDOUT_MODE = true
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

#slide(title: "Take home messages")[
  #text(size: 40pt)[
    #v(2em)
    1. Including *general relativistic* effects is _easier_ than you'd think #text(size: 28pt)[_thanks to ray-tracing_].
    \
    2. We need to move past the simple black hole *accretion disc* and *corona models*.
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

      TODO: figure showing how we construct an image
      also something about constants of motion $E$, $Q$, $L_z$

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
        vs,
        # max integration time
        20_000,
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

  // Talk about the projection effects and the light travel times
  // TODO: a slide with different observer inclinations and spins: "The observer changes how the disc is seen"
]

#slide(title: "Aside: the photon ring")[

  #grid(columns: (68%, 1fr),
  column-gutter: 20pt,
  [
    *Winding* of geodesics around the black hole:
    #{
      set text(size: 15pt)
      grid(columns: (55%, 1fr),
        figure(
          image("./figs/photon-ring-schwarzschild.svg", width: 100%),
          gap: 0pt,
          caption: [Photons rings of the equatorial plane.]
        ),
        [
          #v(2.0em)
          #figure(
            image("./figs/eht-m87-image.jpg", width: 90%),
            caption: [M87\*, imaged by the Event Horizon Telescope CC BY 4.0],
          )
          #v(1em)
        ]
      )
    }
    #v(1em)
    Bright central ring in EHT images is the *photon ring*.
  ],
  [
    #set text(size: 15pt)
    #set align(center)
    #move(dy: -10pt, figure(
      image("./figs/m-von-laue-1921.png", width: 90%),
      caption: [#link("https://archive.org/details/dierelativitts02laueuoft/page/226/mode/2up")[M. von Laue], 1921]
    ))
    #v(-10pt)
    #figure(
      move(dx: -15pt, image("./figs/photon-ring-paths.svg", width: 100%)),
      gap: 0pt,
      caption: [After\ M. von Laue, 2024]
    )
  ]
  )
]

#slide(title: "Calculating observables")[
  Need to start making *assumptions* about the *astrophysics*:
  - For simplicity, disc elements rotating on *Keplerian orbits*
  - Emission within the *innermost stable circular orbit (ISCO)* are negligible
  // this is physically motivated: at the ISCO, is the plunging region where there is no longer a viscous stress in the disc. Imagine differentially rotating slipping rings that grind against eachother and carry angular momentum. At the ISCO, the radial component cannot be zero, so it's like the rings start shrinking
  // If the bulk of the radiation we see from the disc is from viscous / thermal processes, then within the ISCO there is nothing for us to see

  // TODO: quick figure showing how ISCO changes with spin, and what happens in the plunging region

  Are these good assumptions? *Probably not...*

  Ongoing debates about what happens within the ISCO
  - Ongoing debate about the velocity structure of the discs

  But you can *always justify simplicity*!
]

#slide(title: "Redshift")[
  Need to know how to relate *emitted quantities* to *observed quantities*:
  - *Key*: Liouville's Theorem: #h(1em) $I_"obs" (E_"obs") = g^3 I_"em" (E_"em")$ #h(1em) #text(size: 15pt)[(phase-space density is constant)]
  - Define the *redshift*:
  #grid(columns: (50%, 1fr),
  [
    $
    g := E_"em" / E_"obs" = (bold(u)_"disc" dot bold(k)_"final") / (bold(u)_"obs" dot bold(k)_"initial"),
    $
  ],
  [
    Intuition: $E prop m v^2 = p v$
  ])

  #v(-0.7em)
  #{
    set text(size: 15pt)
    figure(
      image("./figs/redshift.png", width:90%),
      gap: -5pt,
      caption: [Redshift maps with contours.]
    )
  }

  #v(10pt)
  // todo some figures of redshift maps
  #align(center, text()[
    ```julia
    pf = ConstPointFunctions.redshift(m, observer) ∘ filter_intersected()
    ```
  ])
  #v(10pt)

  Sources of redshift: *Doppler*, *special relativity*, *gravitational redshift*
  #v(5pt)
  #align(center, cbox(fill: PRIMARY_COLOR, text(fill: SECONDARY_COLOR)[
    *All redshift sources* are accounted for in a *single equation*.
  ]))
]

#slide(title: "The observer changes how the disc is seen")[
  #{
    set text(size: 15pt)
    figure(
      image("./figs/redshift-grid.png", width: 86%),
      gap: -5pt,
      caption: [TODO]
    )
  }
]

#slide(title: "Page & Thorne")[
  A "simple" model for *temperature* and *flux* for a *Novikov-Thorne* accretion disc:
  $
  T ~ (F / sigma_"B")^(1\/4), #h(3em) F ~ #h(-0.8em) underbrace(lr(angle.l q^z angle.r) #h(5pt) r^(-1), #text()[Avg *radiation* in\  vertical direction per $r$]) #h(-0.8em) ~ r^(-3)
  $

  #{
    set text(size: 15pt)
    set align(center)
    move(dx: -10pt, grid(columns: (55%, 1fr),
      move(dy: -30pt, figure(
        image("./figs/temperature-maps.png", width: 85%),
        gap: 0pt,
        caption: [TODO]
      )),
      figure(
        image("./figs/page-thorne.svg", width: 85%),
        gap: 0pt,
        caption: [TODO]
      ),
    ))
  }

  These are the first steps to models like `kerrbb` Li et al.
]

#subtitle-slide(bg: TEXT_COLOR)[
  #set text(size: 15pt)
  #figure(
    image("./figs/our-version-of-luminet.png"),
    caption: text(weight:"regular")[Schwarzschild black hole with Page & Thorne accretion disc,\ after J-P. Luminet, 2024],
  )

  // the titular bright side of a black hole
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

  - Thought to be formed through threaded *magnetic fields*
  - Super-heated electron plasma\ $T ~ 10^9$K

  - *Seed-photons* from the disc are *Compton upscattered* to higher energies
]

#slide(title: [Preview: The _lamppost_ model])[
  #set text(size: 15pt)
  #grid(columns: (60%, 1fr),
    {
      set align(horizon)
      only-last-handout(
        figure(
          image("./figs/lp-2.png", width: 95%),
          caption: [A literal lamppost corona.]
        ),
        figure(
          image("./figs/lp-3.png", width: 95%),
          caption: [A literal lamppost corona is observed *together* with the disc.]
        ),
        handout: HANDOUT_MODE
      )
    },
    [
      #set text(size: 20pt)
      Single *point-like* source on the *spin axis* of the black hole:
      - Only "free parameter" is the *height above the disc* $h$

      #v(1em)
      When we observe the system:
      - Hard *direct emission* from the corona
      - Softer *reflected emission* from the disc
      - Can only be *observed in ensemble*

      #v(1em)
      But...
      - Spectra can be *modelled independently*
    ]
  )
  // mention something about light crossing time
]

#slide(title: "The corona changes the emissivity of the disc")[
  #grid(
    columns: (45%, 1fr),
    [
        #v(2em)
        #set align(center)
        #animsvg(
          read("./figs/corona-heights.svg"),
          (i, im) => only(i)[
            #image.decode(im, width: 80%)
          ],
          (hide: ("g114", "g115", "g116-3")),
          (display: ("g116-3",)),
          (display: ("g115",)),
          (display: ("g114",)),
          (),
          handout: HANDOUT_MODE,
        )
        #v(1em)
    ],
    [
      #v(1em)
        #animsvg(
          read("./figs/emissivity-heights.svg"),
          (i, im) => only(i)[
            #image.decode(im, width: 100%)
          ],
          (hide: ("g370", "g371", "g372", "g373", "g374", "g375", "g227", "g312")),
          (display: ("g372",)),
          (display: ("g371",)),
          (display: ("g370", "g369")),
          // (display: ("g373", "g374", "g375", "g227", "g312")),
          (),
          handout: HANDOUT_MODE,
        )
    ],
  )
  #v(1em)
  #uncover("4-")[
    Emissivities are sensitive to the *geometry of the corona* (Gonzalez et al., 2017).
  ]
  #v(0.5em)
  #uncover("5-")[
  Observe *steep emissivity profile* (e.g. Fabian et al., 2004)
  - Can be fitted by the *lamp post* model (e.g. Wilkins & Fabian, 2012)
  ]
]

#slide(title: "Lineprofile calculations")[
  #align(center)[
    #image("./figs/building-reflection-profiles.svg", width: 100%)
  ]

  Use the redshift maps together with the emissivity functions; no longer consider a single photon, but a bundle -- need Liouville's theorem

  Sensitive to parameters of the corona through the emissivity
  - Sensitive to parameters of the spacetime through the GR effects
  - Sensitive to the parameters of the disc (inner and outer radius)
]

#slide(title: "4. Detour: disc models")[
  // TODO: references for all of this
  In computational models, use *infinitely thin* disc.
  #text(size: 20pt)[
  - But... standard *theoretical models* have some vertical *height* that scales with *accretion rate* (Shakura-Sunyaev model)
  - Thin disc applies for "cold" discs
  - *Magnetically supported* discs or *hot discs* will *puff up*
  ]

  Implications for geometry, and therefore *ray-tracing results*:
  // disc cools faster than the dynamical timescale: all heat radiated away
  #{
    set text(size: 15pt)
    figure(
      image("./figs/disc-paramterisation.svg", width: 100%),
      gap: -20pt,
      caption: [],
    )
  }
  Leads to *obscuration effects* at certain observer inclinations.
  Already in the literature, Taylor and Reynolds in particular
  //  - We're trying to make it easy to compute the transfer function tables
  //  needed for arbitrary thick discs: it can be really important in hidden
  //  little corners of your parameter spaces
]

#slide(title: "Thick discs and the line profile")[
  *Obscuration* effects prominent at $theta_"obs" gt.tilde 60 degree$:

  But even at low inclination, lampposts model *"sees" the disc differently*, changing the *emissivity of the disc*:

  #v(1fr)
  #align(center, cbox(fill: PRIMARY_COLOR, width: 90%, text(fill: SECONDARY_COLOR)[
    *Disc thickness* can have *strong effects* from geometry alone!
  ]))
]

#slide(title: "5. Reverberation lags")[
  #let im_lamppost = read("figs/lamp-post-explanation.svg")
  #align(center)[
    #animsvg(
      im_lamppost,
      (i, im) => only(i)[
        #image.decode(im, width: 60%)
      ],
      (),
      (hide: ("g75", "g49")),
      (hide: ("g1",)),
      (display: ("g5",)),
      (hide: ("g6", "g2"), display: ("g7",)),
      (display: ("g73", "g72", "g4")),
      (display: ("path63", "g3")),
      handout: HANDOUT_MODE,
    )
  ]

  *Time delay* between the *reflected* and *continuum* components
  - *High-frequency, short lags*, softer energies behind harder energies
  \
  For posterity: not the only types of lags seen (e.g. also low-frequency, long lags)
  - Propagating fluctuations in accretion disc TODO: ref
]

#slide(title: "Reverberation transfer functions")[
  Use the *lineprofile flux* along with the *photon travel times*:

  #v(1em)
  #{
    set text(size: 15pt)
    grid(
      columns: (33%, 33%, 1fr),
      column-gutter: -5pt,
      [
        // TODO: make this flux not redshift
        #figure(
          image("./figs/apparent-image.png", width: 100%),
          caption: [TODO]
        )
      ],
      [
        #figure(
          image("./figs/apparent-image-arrival.png", width: 100%),
          caption: [TODO],
        )
      ],
      [
        #figure(
          move(dx: -0.5em, image("./figs/apparent-image-transfer.png", width: 94%)),
          caption: [TODO],
        )
      ]
    )
  }
  \
  Depends on properties of the *disc*, *corona* and location of the *observer*.
]


#slide(title: "Lags as a phase shift")[
  #{
    set text(size: 15pt)
    figure(
      image("./figs/impulse-reverb.svg", height: 75%),
      caption: []
    )
  }
]

#slide(title: "Lags as a function of energy")[
]

#slide(title: "Disc thickness and lags")[
  Similar as to *lineprofiles*: obscuration will cut-off the lag:
]

#slide(title: "Tall disc, shallow corona")[
  Can dramatically reduce the lag if the *corona becomes embedded* in the disc:
]

#slide(title: "6. Beyond the lamppost model")[

]

#slide(title: "7. Going further")[
  // what we didn't speak about today: reflection spectra
  // folding instrument response
  // - what polarisation can offer us
  what else can you do with GRRT
  - hot spots
  - precessing discs

  We've only talked about optically thick discs, but one can include optically thin ones too
  - radiative transfer
  - polarisation properties
]

// BH cannot be resolved (except for two notable cases), so images are pretty
// but we can't use them. Ray tracing also useful for spectral and timing
// calculations

#slide(title: align(center)[Thank you], background: PRIMARY_COLOR, foreground: SECONDARY_COLOR, accent: PRIMARY_COLOR)[
  #set text(fill: SECONDARY_COLOR)
    #v(1em)
  #align(center)[
    #block(width: 90%)[
      == Summary
      #align(left)[
        Gradus.jl can efficiently compute *extended cornae*
        - Construct models that are *performant enough* for parameter fitting
        #v(0.5em)
        *Extended coronae* have *time-dependent* emissivity profiles
        - Timescale of variations on the order of 10s of $t_"g"$
        - Disk-like coronae increase reflection spectrum flux around $E\/E_0 = 1$
      ]
    ]
  ]
  #v(1em)
  #set text(size: 18pt)

  #cbox(fill: SECONDARY_COLOR, width: 100%)[
    #set text(fill: TEXT_COLOR)
    Gradus.jl source code (GPL-3.0):
    - #link("https://github.com/astro-group-bristol/Gradus.jl")
    #v(0.5em)
    Documentation:
    - #link("https://astro-group-bristol.github.io/Gradus.jl/")
    #v(0.5em)
    Source for slides and figures:
    - #link("https://github.com/fjebaker/newcastle-2024")
    #v(0.5em)
    #align(right)[
    Contact: \
    #link("fergus.baker@bristol.ac.uk")
    ]
  ]

]
