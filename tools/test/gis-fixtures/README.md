# Site-data fixtures

A copy of `fixtures/` from [curbside-data](https://github.com/JennaBruggeman/curbside-data) (commit 08de767; the `blockfaces` layer from curbside-data branch friday-round, 62b8e56): the
cells around the three test sites (Robson & Burrard, Commercial & 1st, W 41st & Dunbar) and an index of just those.
On a development host, `parklet-checker.html?gis=fixtures` reads them instead of the published cells, so every
VERIFY runs offline. Refresh them by running `node build/build.js` in curbside-data and copying its `fixtures/` here.

The data keeps its sources' licences (`LICENSE.md`, copied from curbside-data): © OpenStreetMap contributors (ODbL
1.0), City of Vancouver Open Data (Open Government Licence – Vancouver), TransLink GTFS (TransLink's terms of use).
