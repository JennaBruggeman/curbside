# Third-party code and fonts in this repository

Vendored in `tools/vendor/`, loaded by the page from there on first use (no CDN at run time):

| File | What | Version | Licence | Licence text |
|---|---|---|---|---|
| `jspdf-2.5.2.umd.min.js` | jsPDF, the report's PDF engine | 2.5.2 | MIT | `tools/vendor/jspdf-LICENSE.txt` |
| `svg2pdf-2.2.4.umd.min.js` | svg2pdf.js, the sheets' SVG into the PDF | 2.2.4 | MIT | `tools/vendor/svg2pdf-LICENSE.txt` |
| `DMSans-Regular.ttf`, `DMSans-SemiBold.ttf` | DM Sans, the report's typeface (embedded in the PDF) | — | SIL Open Font License 1.1 | `tools/vendor/DMSans-OFL.txt` |
| `xlsx-0.20.3.full.min.js` | SheetJS Community Edition, the cost estimate's Excel export | 0.20.3 (from cdn.sheetjs.com) | Apache License 2.0 | `tools/vendor/xlsx-LICENSE.txt` |

Loaded from a CDN at run time (not in the repository): three.js r128 and its OrbitControls, MapLibre GL, the Supabase
client, and the fonts from Google Fonts.
