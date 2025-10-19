# Namma Metro Route Finder (Prolog + Static Frontend)

This project is a small demo that uses SWI-Prolog as a backend logic engine and serves a static frontend. The backend exposes a JSON API to compute the shortest route (fewest stops) between two GPS coordinates by mapping them to nearest metro stations and running a BFS on the metro graph.

Files:

- `metro.pl` - SWI-Prolog program: knowledge base, BFS route finder, haversine nearest-station, and HTTP server.
- `static/index.html` - Simple web UI.
- `static/app.js` - Frontend logic to call the Prolog API.
- `static/style.css` - Minimal styles.

How to run:

1. Install SWI-Prolog (https://www.swi-prolog.org/) for Windows.
2. Open a PowerShell and change directory into the project folder:

```powershell
cd 'c:\Users\Lenovo\Documents\prolog_project'
``` 

3. Start SWI-Prolog and load `metro.pl`:

```powershell
swipl -s metro.pl
```

4. At the Prolog prompt, run:

```prolog
?- start_server(8080).
```

5. Open your browser and navigate to http://localhost:8080/ to use the UI.

API:

POST /api/get_route
JSON body: { "start": {"lat": <num>, "lon": <num>}, "end": {"lat": <num>, "lon": <num>} }
Response: { "route": [stations], "start_station": "...", "end_station": "...", "message": "ok" }

Example Prolog queries (for debugging):

?- nearest_station(12.9755,77.6067, S).
?- path_bfs('indiranagar','majestic', P).

Notes / Next steps:

- Add error handling for missing static files.
- Return line-change metadata in the JSON response so the frontend can highlight transfers.
- Add CORS headers if you serve the frontend from another origin.
