---
name: Cozy Neighborhood Ride-Sharing
colors:
  surface: '#fbf9f6'
  surface-dim: '#dbdad7'
  surface-bright: '#fbf9f6'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f5f3f0'
  surface-container: '#efeeeb'
  surface-container-high: '#eae8e5'
  surface-container-highest: '#e4e2df'
  on-surface: '#1b1c1a'
  on-surface-variant: '#414943'
  inverse-surface: '#30312f'
  inverse-on-surface: '#f2f0ed'
  outline: '#717973'
  outline-variant: '#c0c9c1'
  surface-tint: '#3a674f'
  primary: '#14422d'
  on-primary: '#ffffff'
  primary-container: '#2d5a43'
  on-primary-container: '#9fcfb2'
  inverse-primary: '#a1d1b4'
  secondary: '#a33d23'
  on-secondary: '#ffffff'
  secondary-container: '#ff8162'
  on-secondary-container: '#731a04'
  tertiary: '#5d2e00'
  on-tertiary: '#ffffff'
  tertiary-container: '#7e4205'
  on-tertiary-container: '#ffb57c'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#bceecf'
  primary-fixed-dim: '#a1d1b4'
  on-primary-fixed: '#002112'
  on-primary-fixed-variant: '#224f39'
  secondary-fixed: '#ffdad2'
  secondary-fixed-dim: '#ffb4a2'
  on-secondary-fixed: '#3c0700'
  on-secondary-fixed-variant: '#83260e'
  tertiary-fixed: '#ffdcc4'
  tertiary-fixed-dim: '#ffb780'
  on-tertiary-fixed: '#2f1400'
  on-tertiary-fixed-variant: '#6f3800'
  background: '#fbf9f6'
  on-background: '#1b1c1a'
  surface-variant: '#e4e2df'
typography:
  headline-xl:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg:
    fontFamily: Inter
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 34px
  headline-md:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 30px
  headline-sm:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 26px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 21px
  body-sm:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 19px
  label-lg:
    fontFamily: Inter
    fontSize: 15px
    fontWeight: '600'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '600'
    lineHeight: 18px
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1.25rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2.25rem
---

## Brand & Style

The design system establishes a warm, approachable, and intrinsically trustworthy atmosphere designed for neighborhood-based intimate travel. The product enables neighbors to gather in small groups of three to four to embark on casual, rejuvenating road trips. 

The aesthetic is anchored in an Organic Tactile & Soft Modern sensibility. It synthesizes the reassurance of neighborhood familiarity with the earthy, refreshing serenity of nature and outdoor retreats. Visual density remains comfortable and breathing, intentionally rejecting sterile corporate fintech conventions in favor of grounded, human-scale warmth. High-frequency interactions evoke comfort, mutual safety, and genuine hospitality through organic corner curves, warm atmospheric shadows, and gentle physical elevation cues.

## Colors

The palette balances restorative natural tones with inviting communal warmth:

- **Primary (`#2D5A43` / Forest Canopy)**: Evokes nature, groundedness, and dependable safety. Used for core interactive items, primary button surfaces, affirmative states, and verified host credentials.
- **Secondary (`#E76F51` / Terracotta Campfire)**: Injects warmth, energy, and human connection. Deployed for high-interest calls-to-action, active seat reservation badges, urgency highlights, and instant booking accents.
- **Tertiary (`#F4A261` / Warm Sunset)**: Soft companion accent for celebratory badges, manner temperature meters, and soft ambient highlights.
- **Neutral Surface & Background (`#FAF8F5` / Cream Sandstone)**: Forms the soothing canvas tone, supplemented by `#F2EDE4` for recessed containers and clean `#FFFFFF` for elevated foreground cards.
- **Typography & Structural Neutrals**: Headings and primary copy leverage rich botanical charcoal (`#1E2320`), supporting labels use balanced forest slate (`#4A524D`), and subtle metadata utilizes quiet stone grey (`#87928B`).
- **Semantic Badges**: Positive/Available status leverages primary green variants; Sold Out / Closed uses muted stone grey (`#E2DFD9`); Settled / Accounted uses serene lake blue (`#3D7EAA`).

## Typography

Inter serves as the unified typographic engine, configured with tight character spacing for Korean and multilingual clarity. Font hierarchies are optimized strictly for glanceable mobile orientation during outdoor or in-transit scenarios:

- **Headlines (`headline-xl` through `headline-sm`)**: Feature a deliberate semi-bold to bold weight with tight leading (`1.2`–`1.3x`), allowing travel titles, neighborhood pickup points, and itinerary landmarks to project prominence without wrapping awkwardly across compact screens.
- **Body (`body-lg`, `body-md`, `body-sm`)**: Tuned for relaxed legibility with a comfortable `1.45`–`1.5x` line-height ratio. Paragraphs retain consistent rhythm when detailing driver notes, luggage boundaries, or split-expense policies.
- **Labels & Microcopy (`label-lg`, `label-md`, `label-sm`)**: High-contrast, medium-to-bold weights intended for status chips, seat capacity counts, manner temperature indicators, and map pill overlays.

## Layout & Spacing

The layout is built around a single-column fluid mobile viewport spanning a standard maximum width of 440px on handheld devices, fluidly expanding with safe outer margins on tablets.

- **Grid & Margins**: Base margin is set to `1.25rem` (20px) from the screen edge, safeguarding interactive touch targets from screen edge distortion. Internal component columns use a 4-column fluid mobile grid with `1rem` (16px) gutters.
- **Vertical Spacing Rhythm**: Uses strict multiples of 4px. Structural cards and discrete ride feeds separate by `space-lg` (24px). Interactive groupings within cards, such as host profile snippets and itinerary milestones, maintain `space-md` (16px) separation. Tightly bound metadata (seat counter dots, cost per seat breakdowns) utilize `space-xs` (4px) to `space-sm` (8px).
- **Responsive Adaptations**: When rendered on wider screen environments or tablet preview sheets, content remains locked to a centered 480px structural shell with expanded canvas margins (`2.5rem`), preserving thumb ergonomics.

## Elevation & Depth

Visual hierarchy rejects sharp black drop shadows in favor of tinted ambient warmth reflecting the earthen environment:

- **Level 0 (Base Surface)**: Ground plane tinted in Warm Sandstone (`#FAF8F5`). Completely shadow-free.
- **Level 1 (Card & Module Layer)**: Pure `#FFFFFF` surfaces layered over the background with subtle contour diffusion: `0 4px 16px -2px rgba(45, 90, 67, 0.06), 0 2px 6px -1px rgba(30, 35, 32, 0.04)`. This creates a tactile, floating-cushion appearance.
- **Level 2 (Interactive Floating Actions & Sheets)**: Active bottom action bars, floating ride-match buttons, and bottom modal drawers: `0 10px 30px -4px rgba(45, 90, 67, 0.12), 0 4px 12px -2px rgba(30, 35, 32, 0.06)`.
- **Low-Contrast Micro-Borders**: All elevated white containers feature an ultra-soft perimeter line (`1px solid rgba(45, 90, 67, 0.07)`) ensuring precise edge contrast against light sandstone backgrounds under bright outdoor sunlight.

## Shapes

The interface embraces a pronounced rounded, pill-forward design language (`roundedness: 3`).

- **Base Cards & Sheets**: Container surfaces and ride itinerary cards apply large `rounded-3xl` radii (24px–28px), reinforcing a casual, welcoming, friendly feel devoid of aggressive sharp corners.
- **Interactive Buttons & Badges**: Primary buttons, quick-filter chips, and seat count pills utilize fully continuous rounded-pill shapes (`rounded-full`), providing instant mobile tactile affordance.
- **Nested Inner Items**: Vehicle photos, passenger avatars, and map thumbnails use soft `rounded-2xl` (16px) radii to maintain proportion with their parent cards.

## Components

- **Buttons**:
  - *Primary Action*: Solid Forest Green (`#2D5A43`) background, crisp white typography (`#FFFFFF`), full pill curvature, 52px touch-friendly height, with subtle active-state scale compression (0.98).
  - *Secondary / Warm CTA*: Terracotta (`#E76F51`) background for instant ride reservations or message confirmations.
  - *Ghost / Outlined*: Bordered with `1.5px solid rgba(45, 90, 67, 0.2)` over transparent or Sandstone backgrounds.

- **Drive Tags & Filter Chips**:
  - Pill-shaped (`rounded-full`) tags displaying road-trip vibes (e.g., `#WeekendCoffee`, `#PetFriendly`, `#NoSmoking`).
  - Active: Tinted Forest Green surface (`rgba(45, 90, 67, 0.12)`) with Forest Green text and a subtle check icon.
  - Inactive: Clean white background with neutral border (`#E2DFD9`) and charcoal-slate text.

- **Seat Occupancy Visualization**:
  - Compact badge displaying car layout icon alongside interactive visual status (e.g., "2/4석 남음").
  - Available slots represented by solid green indicator dots; reserved slots rendered as soft warm peach; unavailable or driver slots rendered in slate outline.

- **Trip Settlement Card**:
  - Recessed card container (`#F2EDE4`) featuring a receipt-cut subtle edge or dashed divider.
  - Line-item breakdown of gas, highway tolls, and shared parking, displaying calculated transparent per-person splits with a distinct Settlement Complete badge in calm Lake Blue (`#3D7EAA`).

- **Manner Temperature & Trust Gauge**:
  - Displays host verification with neighborhood residency badge.
  - Manner temperature score paired with a dynamic warm tone thermometer bar transitioning from soft gold to deep terracotta (`#F4A261` to `#E76F51`), accompanied by small neighborhood endorsement chips (e.g., "Safe Driver", "Punctual").

- **Itinerary Timeline**:
  - Vertical dotted line connecting neighborhood departure location, waypoint stops, and destination retreat.
  - Departure and arrival nodes highlighted with solid forest and terracotta circular indicators.