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

// introduce self
//
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

// there are effects that we need to be including in our models that currently we do not
//
#slide(title: "Take home messages")[
  #text(size: 40pt)[
    #v(2em)
    1. Including *general relativistic* effects is _easier_ than you'd think #text(size: 28pt)[_thanks to ray-tracing_].
    \
    2. We need to move past the simple black hole *accretion disc* and *corona models*.
  ]

]

// because they are cool:
// - the permanent, pristine corpse of a star
// - study fundemental gravity itself
// - no other object so extreme
// - intrinsically related to evolution of our universe
// - drive galaxy evolution, star formation rate
// - mathematically: represent a number of paradoxes
// - where theory can break down / causality paradoxes
// - mystery of the central singularity
//
// one thing they all have in common
//
// sgr a*: our local supermassive black hole
// m87: someone else's local supermassive black hole
//
// because we cannot resolve, modelling is important
// - only get a point source
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
]

// Projecting:
// - earliest form is Albrecht
// - all ray tracing is in the spirit of this
// - is kind of what we approximate today with computers
//
// ((
//   synonymous today:
//   - modern, computational intensive problem
//   - artists have been using the technique for centuries
//   - what we're about to do is just the latest incantation
//   - following in the spirit of Albrecht Dürer
// ))
//
// Computer graphics: video games, movies, Blender
//
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
  - General technique for projecting the appearance of 3D geometry
  - Today, synonymous with tracing *photons* through a system and *computer graphics*
]


// extension of ray tracing to curved space
//
// follow geodesics:     (how to pronounce)
// - earth example
//
// Geodesic Eq:
// - initial value problem
//
// Try to calculate metric for general macroscopic object
// - account for full distribution of matter
// - quite involved, loads of parameters
//
#slide(title: "1. General relativistic ray-tracing")[
  Einstein's theories predict that *matter curves surrounding spacetime*
  - Photons follow *geodesics* (shortest path between two points)
  - In curved space, not *Euclidean straight lines*
  \
  *Geodesic equation:*

  #let hl(t) = text(fill: PRIMARY_COLOR, t)
  $
  (partial^2 x^mu) / (partial tau^2) &= - Gamma^mu_(nu sigma) (partial x^nu) / (partial tau) (partial x^sigma) / (partial tau), \
  #hl[$m underbrace(#text(fill: TEXT_COLOR)[$(partial^2 x^mu) / (partial tau^2)$], a)$] &= #hl[F].
  $

  *Curvature* acts as to *impart a force*, deviating trajectories from Euclidean straight paths:
  - We call this force *gravity*.
  \
  Curvature term $Gamma^mu_(nu sigma)$ is a function *only of the metric*, $g_(mu nu)$, which depends on the distribution of matter.
]


// profound thing about black holes
// - only two scalar parameters
// - no other astronomical object is that simple to parameterise
//
// mass doesn't care if it's regular matter or anti-matter, or a sphere of photons
//
// i wanted to include this quote
//
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

// instead of describing the features of this image
// - show you how to calculate them
#subtitle-slide(bg: TEXT_COLOR)[
  #set text(size: 15pt, weight: "regular")
  #figure(
    image("./figs/luminet.png", width: 80%),
    caption: [*J-P. Luminet* (1978): Image of a Spherical Black Hole with Thin Accretion Disc]
  )
]

// to solve geodesic equation
// - initial position + initial velocity
//
// instead of describing just with imprecise english
// - include the code to produce the figures
// - pick a spacetime
//
// - location for origin
//
// impact params
// - show in figure
//
// - runge kutta
//
// Schwarzschild:
// - object behind the black hole appear around it
// - spherical symmetry
//
// Kerr:
// - pulls horizon in + introduce frame dragging effect
// - left/right axymmetry
// - some photons able to pass much closer
// - frame dragging effect
//
// Hypothesise that event horizon would appear
//
//
// This is a single X/Y plane slice
// - To construct an image, we just stack a whole load of these slices together
//
//
#slide(title: "Putting together the machinery")[
  #set text(size: 15pt)
  #grid(columns: (68%, 1fr),
    [
      #text(size: 20pt)[
        For each geodesic: pick an *initial position* and *initial velocity*:
      ]

      #v(2em)
      #figure(
        image("./figs/geodesic-paths.svg", width: 100%),
        caption: [Geodesics traces from asymptotic observers for different spacetimes.]
      )
      #v(2em)

      #text(size: 20pt)[
        To make an image, *stack slices* of impact parameters together
      ]
    ],
    [
      #v(-5pt)
      ```julia
      using Gradus
      # 1. Flat
      m = SphericalMetric()
      # 2. Schwarzschild
      m = KerrMetric(M = 1.0, a = 0.0)
      # 3. Kerr
      m = KerrMetric(M = 1.0, a = 1.0)

      # spherical 4 vector
      origin = SVector(
        0, 1e4, π/2, 0
      )

      # set up impact parameter space
      α = collect(
        range(-10.0, 10.0, 20)
      )
      β = fill(0, size(α))

      # calc initial velocities
      vs = map_impact_parameters(
        m, origin, α, β
      )

      sols = tracegeodesics(
        m,
        origin,
        vs,
        # max integration time
        20_000,
      )
      ```
    ]
  )
]

// again using code
// - colour each pixel by the coordinate time
//
// in the parlance of the code, we use a PointFunction
//
// - brighter is longer
// - background is black
//
// Computationally intensive sphere you can rendered
#slide(title: "The shadow of a black hole")[
  #v(2em)
  #grid(columns: (68%, 1fr),
    [
      #set text(size: 15pt)
      #figure(
        image("./figs/shadows.png", width: 100%),
        caption: [Shadows of the *Schwarzschild* and *Kerr* black holes, viewed by an observer in the equatorial plane.],
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
          origin,
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

/// again using the code
//
// - left shadow in for clarity
// - warping above the black hole
// - false image underneath the black hole
//
// Next, we want to start calculating observables of the disc
#slide(title: "2. Toy accretion models")[
  An *infinitely thin* disc model in the equatorial plane:
  \
  #set text(size: 15pt)
  #grid(columns: (68%, 1fr),
    {
      figure(
        image("./figs/thin-disc-projection.png", width: 90%),
        caption: [Projection of a *thin accretion disc* surrounding a moderately spinning black hole.]
      )
    },
    [
      #v(2em)
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
]

// assumptions about the disc
// - velocity structure, follows Keplerian
// - assume the disc is entirely opaque
//
#slide(title: "Redshift")[
  Need to know how to relate *emitted quantities* to *observed quantities*:
  - *Key*: Reciprocity Theorem: #h(1em) $I_"obs" (E_"obs") = g^3 I_"em" (E_"em")$ #h(1em) #text(size: 15pt)[(phase-space density is invariant)]
  - Calculate the *redshift*:
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
      caption: [*Redshift maps* with contours.]
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
      caption: [*Redshift maps* for observers at different *inclinations*.]
    )
  }
]

// Lets use the redshift and reciprocity theorem to do something useful
//
// Page & Thorne model:
// - viscous dissipation rate == gradient of the heat flux
// ++ Stefan-Boltzmann law
//
// See how spin changes temperature profile of disc
// - project this onto an accretion disc
// - Now we have a temperature model that includes all relativistic effects
//
// First steps towards multitemperature black body models
#slide(title: "Page & Thorne")[
  Use *redshift* to relate *emitted and observed* quantities:
  - A "simple" model for *flux* and *temperature*:
  #v(-10pt)
  $
  F ~ #h(-0.8em) underbrace(lr(angle.l q^z angle.r) #h(5pt) r^(-1), #text()[Avg *radiation* in\  vertical direction per $r$]) #h(-0.8em) ~ r^(-3) #h(3em) T ~ (F / sigma_"B")^(1\/4),
  $


  #{
    set text(size: 15pt)
    set align(center)
    move(dx: -10pt, grid(columns: (45%, 1fr),
      figure(
        image("./figs/page-thorne.svg", width: 85%),
        gap: 0pt,
        caption: [*Temperature* of the accretion disc.]
      ),
      move(dy: -30pt, figure(
        image("./figs/temperature-maps.png", width: 85%),
        gap: 0pt,
        caption: [Projection of the *temperature* on the accretion disc.]
      )),
    ))
  }

  These are the first steps to models like `kerrbb` Li et al.
]

// Hopefully you now understand how all of the different features arrive
//
// This is the titular "bright side of the black hole"
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

// want to include corona
// - start studying it with our ray-tracer
//
//
// Illuminates the accretion system
// - changes the emissivity of the disc
// - these high energy X-rays come from Compton-upscattering
#slide(title: "A black hole and its crown")[
  We have our basic *accretion disc model*, and now we want to add *the corona*.
  - Source of hard X-rays (Fabian et al., 2000)
  #v(1em)
  The *corona* is a hot ($T ~ 10^9$K) electron plasma in the vicinity of the black hole
  - Geometry and conditions are still debated (see TODO for review)
  - Thought to be formed through threaded *magnetic fields*
  - Maybe the base of a jet? (synchrotron self-Compton, Markoff et al., 2005)
  - *Heated accretion disc layers* that form a *large warm corona* (e.g. sandwhich model, Paczynski 1978)

  #v(1em)
  Importantly: changes how the disc would be 'seen'
  - Illuminates the accretion system system in high energy X-rays
  - *Compton-upscattering* of softer *seed photons*
  - Implying some connection between the disc and the corona
]


// The most ubiquitously used model
// - because it's easiest to compute due to high degree of symmetry
//
//
// If we were to observe this system
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
      Two model components:
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

// emissivity is the reflected flux coming from a given patch on the disc
// - due to symmetry, can just look at the radius on the disc
//
// as we change source height
//
// notable feature is that at small radii, we have a lensing effect increasing the emissivity
#slide(title: "The corona changes the emissivity of the disc")[
  #v(2em)
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
]

// how does this reflected flux appear to the observer
// - for that, we use lineprofiles
//
// - the line profile tells us how a given energy emitted at the disc is measured by an observer
// - may have encountered this as the so-called broad-iron line
//
// this is one way we can infer structure from a point-source
// - by looking at the specta
#slide(title: "Lineprofile calculations")[
  #v(2em)
  #align(center)[
    #set text(size: 15pt)
    #figure(
      image("./figs/building-reflection-profiles.svg", width: 100%),
      caption: [Illustration of how *lineprofiles* are calculated.]
    )
  ]

  #v(1em)
  Sensitive to *parameters of the corona* through the emissivity
  - Sensitive to *parameters of the spacetime* through the GR effects
  - Sensitive to the *parameters of the disc*, i.e. inner and outer radius, but also...

  #v(0.5em)
  #align(right)[Excellent method for probing various components]
]

// - furthermore, thin disc only applies for cold discs
//
// obscuration effects exacerbated by gravitational lensing
// - mask contributions to our line profiles
// - changes the emissivity
//
// has been explored quite well by taylor and reynolds in two excellent papers
// - but to go further, as they do not use a self-consistent emissivity
#slide(title: "4. Detour: disc models")[
  // TODO: references for all of this
  In computational models, use *infinitely thin* disc.
  #text(size: 20pt)[
  - But... standard *theoretical models* have some vertical *height* that scales with *accretion rate* (Shakura-Sunyaev model)
  - Thin disc applies for "cold" discs
  - A *hot* or *magnetically supported* discs will *puff up*
  ]

  Implications for geometry, and therefore *ray-tracing results*:
  // disc cools faster than the dynamical timescale: all heat radiated away
  #{
    set text(size: 15pt)
    figure(
      image("./figs/disc-paramterisation.svg", width: 100%),
      gap: -20pt,
      caption: [Contours of *radius* and *normalised redshift* for a thin and thick accretion disc.],
    )
  }
  Leads to *obscuration effects* at certain observer inclinations.
  - Taylor and Reynolds
  //  - We're trying to make it easy to compute the transfer function tables
  //  needed for arbitrary thick discs: it can be really important in hidden
  //  little corners of your parameter spaces
]

// The big changes come from changes in emissivity
//
// First:  right most column, obscuration
// - insensitive to corona height, and well known result
//
//
// But even at low inclinations,
// - a shallow corona can have a dramatic effect
// - from emissivity changes
//
// Disc thickness, without even considering velocity structure
#slide(title: "Thick discs and the line profile")[
  #set align(center)

  #{
    set text(size: 15pt)
    figure(
      image("./figs/thick-lineprofiles-grid.svg", width: 80%),
      gap:0pt,
      caption: [*Yellow* is a *thick disc*, *blue* is thin. *Obscuration* effects prominent even at low inclination, lampposts model *"sees" the disc differently*, changing the *emissivity of the disc*.]
    )
  }

  #v(1em)
  #align(center, cbox(fill: PRIMARY_COLOR, width: 90%, text(fill: SECONDARY_COLOR)[
    *Disc thickness* can have *strong effects* from geometry alone!
  ]))
]

// Leaving line-profiles behind for a moment
//
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

  #v(2em)
  *Time delay* between the *reflected* and *continuum* components generates lags
]

// The bread and butter of reverberation modelling are
// - 2d transfer functions
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
          caption: [Redshift maps]
        )
      ],
      [
        #figure(
          image("./figs/apparent-image-arrival.png", width: 100%),
          caption: [Arrival times],
        )
      ],
      [
        #figure(
          move(dx: -0.5em, image("./figs/apparent-image-transfer.png", width: 94%)),
          caption: [Transfer functions],
        )
      ]
    )
  }
  \
  Depends on properties of the *disc*, *corona* and location of the *observer*.
  - Importantly, *lags* provide an approach to measure *mass of the black hole*
]


#slide(title: "Lags as phase and energy")[
  #grid(columns: (40%, 1fr),
    {
      set text(size: 15pt)
      figure(
        image("./figs/impulse-reverb.svg", height: 75%),
        caption: [Impulse responses and phase-lags.]
      )
    },
    {
      v(3em)
      set text(size: 15pt)
      figure(
        image("./figs/reverberation-lag-energy.svg", width: 73%),
        caption: [Lag as a function of energy for a thin and thick accretion disc.]
      )
    }
  )
]

#slide(title: "Disc thickness and lags")[
  Similar as to *lineprofiles*: obscuration will cut-off the lag:

  #set text(size: 15pt)
  #figure(
    image("./figs/obscuration-lag.svg"),
    caption: [Obscuration masks the high energy lag.],
  )
]

#slide(title: "Tall disc, shallow corona")[
  Can dramatically reduce the lag if the *corona becomes embedded* in the disc:

  #set text(size: 15pt)
  #figure(
    image("./figs/shallow-corona-lags.svg"),
    caption: [Shallow corona dramatically changes the lag.],
  )
]

// we like the lamppost because it's easy to compute
// - high degree of symmetry
//
// - want to continue to try and exploit the symmetries where we can
#slide(title: "6. Beyond the lamppost model")[
  Assume *axis-symmetric* for computational simplicity.
  #grid(columns: (50%, 1fr),
    [
    #v(2em)
    *Decomposition* scheme:
    #text(size: 20pt)[
       - Slice any volume into discs with height $delta h$.
       - Each disc can be split into annuli \ $(x, x + delta x)$.
       - Weight contribution of each annulus by its volume.
     ]
    ],
    [
      #set text(size: 15pt)
      #align(center,
        figure(
          image("./figs/decomposition.svg", width: 88%),
          caption:[],
      ))
    ]
  )

  #v(1fr)
  #cbox(fill: PRIMARY_COLOR, width: 100%, text(fill: SECONDARY_COLOR)[
    Each ring *modelled by a single point source*. Totals are weighted sums: e.g. emissivity
    $
     epsilon_"tot" (rho, t) = integral_0^R V(x) epsilon_x (rho, t) dif x,
    $
    where $V(x)$ is the volume of the annulus in $(x, x + dif x)$.
  ])

]

#slide(title: "Time-dependent approach")[
  *Emissivity* is now *time dependent*. Why? Consider 2D slice of one annulus:
  #place(move(dy: 0.5em, dx: 2em, uncover("3-", block(width: 58%, text(size: 18pt)[
    Sweep 2D plane around the axis to find a geodesic that hits each $phi.alt$. Plotted is the arrival time $t_("corona" -> "disc")$.
  ]))))

  #let im_extendpost = read("figs/extended.traces-export.svg")
  #set text(size: 15pt)
  #align(center)[
    #animsvg(
      im_extendpost,
      (i, im) => only(i)[
        #image.decode(im, width: 70%),
      ],
      (),
      (hide: ("g126",), display: ("g142",)),
      (display: ("g143", "g133")),
      handout: HANDOUT_MODE,
    )
  ]
]

#slide(title: "Time-dependent emissivity")[
  For a *single, off-axis point source*, calculate the *emissivity* for each annulus:

  #set text(size: 17pt)

  #grid(
    columns: (60%, 1fr),
    [
      #align(center)[
        #set text(size: 15pt)
        #figure(
          image("./figs/ring-corona-emissivity.png", width: 80%),
          gap: 0pt,
          caption: [Ring-like corona.],
        )
      ]
    ],
    [
      #v(2em)
      Two separate annuli, one at $x = 3 r_"g"$ (green-pink), another at $x = 11 r_"g"$ (purple-orange).
    ]
  )

  #v(-10pt)
  #uncover("2-")[
  #grid(
    columns: (60%, 1fr),
    [
      #align(center)[
        #set text(size: 15pt)
        #figure(
          image("./figs/disc-corona-emissivity.png", width: 80%),
          gap: 0pt,
          caption: [Disc-like corona.],
        )
      ]
    ],
    [
      #v(2em)
      Combine (i.e. $plus.circle$) all $epsilon_i (r, t)$ to calculate *disc-like corona*:
      here, between $x = 0 r_"g"$ and $x = 11 r_"g"$.

      #v(2em)

      #cbox(fill: PRIMARY_COLOR, width: 100%, text(fill: SECONDARY_COLOR)[
        Emissivity variations on the timescale on tens of $t_"g"$
      ])
    ]
  )
  ]
]

#slide(title: "Illustrative results")[
  #v(0.3em)

  #grid(
    columns: (63%, 1fr),
    column-gutter: 10pt,
    [
      #align(center)[
        #set text(size: 15pt)
        #figure(
          image("figs/extended-transfer-comparison.png", width: 90%),
          caption: [Transfer functions.],
        )
        #v(10pt)
        #figure(
          image("./figs/extended-line-profiles.svg", width: 95%),
          caption: [Line profiles at different inclinations.],
        )
      ]
    ],
    [
      #set text(size: 18pt)
      #v(2em)
      Draws out the 2D transfer function
      - Element of a negative lag
      - Components of *reflection* can arrive *before* continuum

      #v(7em)
      Overall effect: *increases flux* contribution around $E \/ E_"0" = 1$
      - Elements of degeneracy with *thick accretion discs*
    ]
  )
]

#slide(title: "Timing")[
  #v(-20pt)
  #grid(columns: (51%, 1fr),
    {
      set text(size: 15pt)
      v(-5pt)
      figure(
        image("figs/extended-comparison.svg"),
        gap: 0pt,
        caption: [Top: Lamp post corona. Bottom: disc-like extended corona.],
      )
    },
    [

      #v(1em)
      #block(inset: (left: 10pt))[
        But the *direct component* has a transfer function now also:
      ]
      #{
        set text(size: 15pt)
        figure(
          image("./figs/continuum.transfer-function.png"),
          caption: [Left: $theta_"obs" = 45 degree$, right: $theta_"obs" = 75 degree$],
        )
      }
    ]
  )

  #grid(columns: (68%, 1fr),
    [
    #v(0.5em)
    Need a model for the *coronal velocity structure* (assume co-rotating?)
    \
    Include *source fluctuations* (different annuli "flash" at
    different times)
    - Does the *corona* obscure the *disc*?
    ],
    move(dy: -30pt, dx: 15pt, {
      set align(right)
      set text(size: 14pt)
      figure(
        image("./figs/source-propagation.svg", width: 78%),
        caption: [Source fluctuations]
      )
    })
  )

]

#slide(title: "7. Going further")[
  // what we didn't speak about today: reflection spectra
  // folding instrument response
  // - what polarisation can offer us
  //
  // talk about modelling the continuum

  #grid(columns: (50%, 1fr),
  [
    What else are we doing with *general relatvistic ray-tracing*?
    #set text(size: 18pt)
    - Studying *hot spot* models
    - Quasi-periodic oscillations with *precessing disc* models

    Today, only looked at *optically thick* discs:
    - Optically thin are fascinating to study too
    - E.g. Radiately inefficient accretion discs (RIAFs), hot discs


    #set text(size: 14pt)
    #v(1em)
    #figure(
      image("./figs/teapot.png", width: 75%),
      gap: -5pt,
      caption: [An advanced GRMHD simulation.]
    )
  ],
  [
    #set text(size: 14pt)
    #v(-1em)
    #figure(
      image("./figs/hot-spot.png", width: 70%),
      gap: -5pt,
      caption: [Hot spot orbiting a Kerr black hole]
    )
    #v(2em)
    #set text(size: 18pt)
    With *radiative transfer* built into the ray-tracer:
    - Absorption and winds
    - Calculating observational quantities from *GRMHD mesh* simulations
  ])
]


// Had meetings where Andy or I would have a dumb idea and by the end of the
// meeting we have results for it (and indeed conclude it was dumb)
#slide(title: "Going further: Gradus.jl")[
  #grid(columns: (50%, 1fr),
  [
    What else *can you do* with ray-tracing?

    #v(2em)
    *Gradus.jl*: a Julia, spacetime-agnostic relativistic ray-tracer
    - Open Source GPL-3.0

    #v(1em)
    #set text(size: 18pt)
    Why another ray-tracer?
    - Designed to be *general* and *extensible*
    - Make few assumptions in our implementations, provide friendly abstractions
    - *Quick* to generate results for new ideas


    #v(2em)
    Welcome collaborations and comments \<3
  ],
  [
    #v(2em)
    #align(center, image("./figs/gradus_logo.png", width: 60%))
    #v(1fr)
    #set text(size: 15pt)
    *Baker & Young*, in prep
    - Introducing Gradus, almost ready to be submitted!
    *Baker & Young*, in prep
    - Extending Cunningham transfer functions
    *Baker & Young*, in prep
    - Fast extended corona models
    #v(1em)
  ]
  )
]

#slide(title: align(center)[Thank you], background: PRIMARY_COLOR, foreground: SECONDARY_COLOR, accent: PRIMARY_COLOR)[
  #set text(fill: SECONDARY_COLOR)
  #align(center)[
    #block(width: 90%)[
      == Summary
      #align(left)[
        - *General relativistic ray-tracing* makes it _easier_ to include GR effects

        Moving away from simple disc and corona models introduces degeneracies:
        - *Disc thickness* can lead to obscuration
        - *Coronal geometry* dramatically changes timing
        #v(0.5em)
        *Gradus.jl* is a new tool for building ray-traced models
      ]
    ]
  ]
  #v(1em)

  #cbox(fill: SECONDARY_COLOR, width: 100%)[
    #set text(fill: TEXT_COLOR, size: 17pt)
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
    \
    #set text(size: 15pt)
    Typeset using #link("https://typst.app/")[Typst]. Figures rendered with #link("https://docs.makie.org/stable/")[Makie.jl].
    ]
  ]

]


// -------------------------------------------------------------------------------------------- //
// -                                                                                          - //
// -                                      BACKUP SLIDES                                       - //
// -                                                                                          - //
// -------------------------------------------------------------------------------------------- //

#subtitle-slide(bg: TEXT_COLOR)[
  Backup Slides
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
    In *astronomy*: used for e.g. *observation simulation*.
  ]))
]


#slide(title: "The photon ring")[

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

#slide(title: "Towards a flux model")[
  Need to start making *assumptions* about the *astrophysics*:
  - For simplicity, disc elements rotating on *Keplerian orbits*
  - Emission within the *innermost stable circular orbit (ISCO)* are negligible
  // this is physically motivated: at the ISCO, is the plunging region where there is no longer a viscous stress in the disc. Imagine differentially rotating slipping rings that grind against eachother and carry angular momentum. At the ISCO, the radial component cannot be zero, so it's like the rings start shrinking
  // If the bulk of the radiation we see from the disc is from viscous / thermal processes, then within the ISCO there is nothing for us to see

  Are these good assumptions? *Probably not...*

  Ongoing debates about what happens within the ISCO
  - Ongoing debate about the velocity structure of the discs

  But you can *always justify simplicity*!
]


    // We developed a method using *time-dependent Cunningham transfer functions* for quickly computing timing features such as *reverberation lags*
  // - Approach takes calculations from $cal(O)(1" s")$ to $cal(O)(1" ms")$
