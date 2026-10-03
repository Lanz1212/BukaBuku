# DESIGN SYSTEM: Toko Buku Budi Mobile UI

## 1. Brand & Style
This design system embodies the serene, curated presence of an independent brick-and-mortar bookstore translated into a high-touch Android commerce experience.
- **Emotional Tone:** Calming, tactile, trustworthy, welcoming.
- **Aesthetic Direction:** Modern Minimalist Bookstore (crisp sans-serif, organic earth tones, generous negative space).

## 2. Colors
The palette relies on tactile earth tones rather than synthetic digital primaries, balancing contrast with low eye fatigue.
- **Primary (`#5B4636`):** Foundational anchor (roasted coffee/seasoned timber) for buttons, selected bottom nav, key progress states.
- **Secondary (`#A67C52`):** Soft brown accent for category pills, badge backdrops.
- **Background (`#F8F6F2`):** Warm off-white (acid-free archival paper). Base canvas.
- **Surface (`#FFFFFF`):** Pure white for cards, input interiors, modal bottom sheets.
- **Outline / Border (`#E8E3DC`):** Organic muted parchment line.
- **Text Primary (`#242424`):** Soft charcoal.
- **Text Secondary (`#737373`):** Neutral gray.
- **Success (`#3F8F5F`):** Muted laurel green.
- **Warning (`#D99A35`):** Warm amber.
- **Error (`#D9534F`):** Terracotta crimson.
- **Info (`#4E7FA6`):** Muted slate blue.

## 3. Typography
Font Family: **Plus Jakarta Sans**
- `headline-lg`: 24px, Semi-Bold (600), Line Height: 32px (View titles, themes, modal headers)
- `headline-md`: 20px, Semi-Bold (600), Line Height: 28px
- `headline-sm`: 18px, Semi-Bold (600), Line Height: 24px (Section titles)
- `title-md`: 16px, Semi-Bold (600), Line Height: 22px
- `body-lg`: 16px, Regular (400), Line Height: 24px
- `body-md`: 14px, Regular (400), Line Height: 20px (Synopses, reviews, summaries)
- `label-lg`: 15px, Semi-Bold (600), Line Height: 20px (Buttons, tabs)
- `label-md`: 13px, Medium (500), Line Height: 18px
- `caption`: 12px, Regular (400), Line Height: 16px (Microcopy, ISBN, stock levels)

## 4. Layout & Spacing
- **Gutter:** `16px`
- **Outer Margin:** `16px`
- **Vertical Rhythm:** 4px micro step
  - `4px` (`space-xs`): Micro grouping
  - `8px` (`space-sm`): Content-to-metadata spacing
  - `16px` (`space-md`): Standard inter-card gaps, padding
  - `20px` (`space-lg`): Section separation
  - `24px` (`space-xl`): Module boundaries

## 5. Elevation & Depth
- **Level 0 (Flat Canvas):** Base background `#F8F6F2`.
- **Level 1 (Cards):** Pure white `#FFFFFF`, `1px solid #E8E3DC`, Soft Shadow (e.g., `0 4px 12px rgba(91, 70, 54, 0.06)`).
- **Level 2 (Dropdowns, Nav):** Soft Shadow (e.g., `0 4px 20px rgba(91, 70, 54, 0.08)`).
- **Level 3 (Modals):** Scrim `#242424` at 40%. Shadow (e.g., `0 -8px 24px rgba(91, 70, 54, 0.12)`).

## 6. Shapes (Border Radius)
- **Small (`8px`):** Badges, book spine tags.
- **Medium (`12px`):** Inputs, inline banners.
- **Large (`16px`):** Core visual signature (buttons, cards, bottom sheets).
- **Pill (`9999px`):** Filters, quantity toggles, notification counters.

## 7. UI Components
### Buttons
- **Primary:** Height 50px, Background `#5B4636`, Text `#FFFFFF`, Radius 16px, `label-lg`.
- **Secondary:** Height 50px, Background transparent, Border `1px solid #5B4636`, Text `#5B4636`, Radius 16px.
- **Text Button:** Text `#5B4636`, `label-lg`.

### Inputs
- Height 50px, Background `#FFFFFF`, Border `1px solid #E8E3DC`, Radius 12px.
- Padding: 16px horizontally.
- Focused: Border `#5B4636`.

### Cards (Books)
- Surface `#FFFFFF`, Border `1px solid #E8E3DC`, Soft Shadow. Radius 16px.
- Cover Image: 2:3 ratio, inner radius 8px.

### Chips (Filters)
- Default: `#FFFFFF`, Border `#E8E3DC`, Text `#737373`, Radius 9999px. Height 36px.
- Selected: Background `#5B4636`, Border `#5B4636`, Text `#FFFFFF`.

### Checkboxes & Radios
- Size: 20x20px. Checked fill: `#5B4636`.
