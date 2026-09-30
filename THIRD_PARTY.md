# Third-party software, fonts and data

Curbside's own code is MIT-licensed (see `LICENSE`). It uses the following, each under its own licence.

## Bundled in this repository

| Component | Version | Where | Licence |
|---|---|---|---|
| jsPDF | 2.5.2 | `tools/vendor/jspdf-2.5.2.umd.min.js` | MIT (`tools/vendor/jspdf-LICENSE.txt`) |
| svg2pdf.js | 2.2.4 | `tools/vendor/svg2pdf-2.2.4.umd.min.js` | MIT (`tools/vendor/svg2pdf-LICENSE.txt`) |
| DM Sans | Regular, SemiBold | `tools/vendor/DMSans-*.ttf` (also embedded in the report) | SIL Open Font License 1.1 (`tools/vendor/DMSans-OFL.txt`) |

## Loaded from a CDN at runtime (pinned versions)

| Component | Version | Source | Licence |
|---|---|---|---|
| three.js (+ OrbitControls, GLTFLoader, OBJLoader, GLTFExporter from its examples) | r128 / 0.128.0 | cdnjs, jsDelivr | MIT |
| MapLibre GL JS | 4.7.1 | jsDelivr | BSD-3-Clause |
| supabase-js | 2.x | jsDelivr | MIT |
| rhino3dm.js | 8.x | jsDelivr | MIT |
| PDF.js (tracing underlays; spec-card attachments in the report) | 2.16.105 | cdnjs | Apache-2.0 |
| DM Sans, Inter, Barlow Condensed | - | Google Fonts | SIL Open Font License 1.1 |

## Data and services

| Source | Used for | Terms |
|---|---|---|
| OpenStreetMap (map tiles, Nominatim search, Overpass) | the site map, address search, streets | Data (c) OpenStreetMap contributors, ODbL 1.0; tile and API usage policies apply |
| City of Vancouver Open Data (building footprints, street trees, public streets, parks, site objects, right-of-way widths) | site context | Open Government Licence - Vancouver |
| `tools/fixtures/commercial/` (recorded responses of the above for one site) | redrawing the landing images | as its source: ODbL 1.0 for OpenStreetMap data and tiles, Open Government Licence - Vancouver for City data |
| Mapillary (optional, the user's own token) | street context photos for renders | Images CC BY-SA 4.0, credited on each render |
| Replicate (optional, the user's own key) | photoreal renders | the user's own Replicate account and its terms |
| Anthropic (optional, the user's own key) | the Design Assistant | the user's own Anthropic account and its terms |

Standards quoted in the checks (the Vancouver Parklet Manual, the Engineering Design Manual, the Standard Detail Drawings) belong to the City of Vancouver; Curbside cites them and does not redistribute them.
