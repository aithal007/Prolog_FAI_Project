% ===================================================================
% A Namma Metro Route Finder for Bengaluru - SWI-Prolog Backend
% Author: Gemini (generated)
% Date: 19 October 2025
%
% This file provides a small HTTP API using SWI-Prolog's http libraries.
% Endpoint: POST /api/get_route
% Body (JSON): { "start": {"lat": <num>, "lon": <num>}, "end": {"lat": <num>, "lon": <num>} }
% Response (JSON): { "route": [station,...], "message": "..." }
% ===================================================================

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_server_files)).
:- use_module(library(http/http_files)).

:- multifile user:file_search_path/2.
user:file_search_path(webroot, '.') .

% ------------------ Knowledge base (stations + adjacency) ------------------
% Station locations (Station, Lat, Lon).
station_location('baiyappanahalli', 12.9904, 77.6527).
station_location('swami vivekananda road', 12.9882, 77.6433).
station_location('indiranagar', 12.9784, 77.6408).
station_location('halasuru', 12.9782, 77.6256).
station_location('trinity', 12.9732, 77.6158).
station_location('mg road', 12.9755, 77.6067).
station_location('cubbon park', 12.9782, 77.5971).
station_location('majestic', 12.9767, 77.5713).
station_location('city railway station', 12.9784, 77.5639).
station_location('magadi road', 12.9774, 77.5512).
station_location('mysore road', 12.9559, 77.5312).

station_location('nagasandra', 13.0453, 77.5097).
station_location('dasarahalli', 13.0378, 77.5181).
station_location('jalahalli', 13.0337, 77.5273).
station_location('peenya industry', 13.0315, 77.5350).
station_location('yeshwanthpur', 13.0238, 77.5558).
station_location('sandal soap factory', 13.0138, 77.5583).
station_location('mantri square', 12.9902, 77.5714).
station_location('chickpete', 12.9681, 77.5752).
station_location('lalbagh', 12.9482, 77.5828).
station_location('jayanagar', 12.9304, 77.5833).
station_location('banashankari', 12.9234, 77.5726).

% Adjacency: adjacent(Station1, Station2, Line).
adjacent('baiyappanahalli', 'swami vivekananda road', purple_line).
adjacent('swami vivekananda road', 'indiranagar', purple_line).
adjacent('indiranagar', 'halasuru', purple_line).
adjacent('halasuru', 'trinity', purple_line).
adjacent('trinity', 'mg road', purple_line).
adjacent('mg road', 'cubbon park', purple_line).
adjacent('cubbon park', 'majestic', purple_line).
adjacent('majestic', 'city railway station', purple_line).
adjacent('city railway station', 'magadi road', purple_line).
adjacent('magadi road', 'mysore road', purple_line).

adjacent('nagasandra', 'dasarahalli', green_line).
adjacent('dasarahalli', 'jalahalli', green_line).
adjacent('jalahalli', 'peenya industry', green_line).
adjacent('peenya industry', 'yeshwanthpur', green_line).
adjacent('yeshwanthpur', 'sandal soap factory', green_line).
adjacent('sandal soap factory', 'mantri square', green_line).
adjacent('mantri square', 'majestic', green_line).
adjacent('majestic', 'chickpete', green_line).
adjacent('chickpete', 'lalbagh', green_line).
adjacent('lalbagh', 'jayanagar', green_line).
adjacent('jayanagar', 'banashankari', green_line).

% Bidirectional connectivity helper.
connected(A,B) :- adjacent(A,B,_).
connected(A,B) :- adjacent(B,A,_).

% ------------------ BFS for shortest path (in number of stops) ------------------
% path_bfs(Start, Goal, Path).
path_bfs(Start, Goal, Path) :-
    ( Start == Goal -> Path = [Start]
    ; bfs([[Start]], Goal, Rev), reverse(Rev, Path)
    ).

bfs([[Goal|T]|_], Goal, [Goal|T]).
bfs([Path|Paths], Goal, Result) :-
    extend(Path, NewPaths),
    append(Paths, NewPaths, Paths2),
    bfs(Paths2, Goal, Result).

extend([Node|Path], NewPaths) :-
    findall([NewNode,Node|Path], (connected(Node, NewNode),\+ member(NewNode, [Node|Path])), NewPaths).

% ------------------ Nearest station by haversine ------------------
% haversine distance in kilometers
deg2rad(Deg, Rad) :- Rad is Deg * pi / 180.
haversine(Lat1, Lon1, Lat2, Lon2, Km) :-
    deg2rad(Lat1, La1), deg2rad(Lon1, Lo1),
    deg2rad(Lat2, La2), deg2rad(Lon2, Lo2),
    Dlat is La2 - La1, Dlon is Lo2 - Lo1,
    A is sin(Dlat/2)*sin(Dlat/2) + cos(La1)*cos(La2)*sin(Dlon/2)*sin(Dlon/2),
    C is 2 * atan2(sqrt(A), sqrt(1-A)),
    R is 6371.0, Km is R * C.

nearest_station(Lat, Lon, Station) :-
    findall(D-S, (station_location(S, SL, SLon), haversine(Lat, Lon, SL, SLon, D)), Pairs),
    sort(Pairs, Sorted), Sorted = [ _D-Station | _ ].

% ------------------ Pretty route conversion (list of stations) ------------------
route_as_json(Path, json([route=Path])).

% ------------------ HTTP server and handlers ------------------
:- http_handler(root(.), serve_files_in_directory('./static'), [prefix]).
:- http_handler('/api/get_route', get_route_handler, []).

get_route_handler(Request) :-
    http_read_json_dict(Request, DictIn),
    ( _{start: Start, end: End} :< DictIn -> true ; send_error('Invalid JSON body', 400) ),
    ( get_dict(lat, Start, SLat), get_dict(lon, Start, SLon),
      get_dict(lat, End, ELat), get_dict(lon, End, ELon) -> true ; send_error('Missing lat/lon', 400) ),
    nearest_station(SLat, SLon, StartStation),
    nearest_station(ELat, ELon, EndStation),
    ( path_bfs(StartStation, EndStation, Path) ->
        reply_json_dict(_{route: Path, start_station: StartStation, end_station: EndStation, message: 'ok'})
    ; reply_json_dict(_{route: [], message: 'no route found', start_station: StartStation, end_station: EndStation}, [status(200)])
    ).

send_error(Msg, Status) :-
    reply_json_dict(_{error: Msg}, [status(Status)]), !, fail.

% ------------------ Server entry point ------------------
start_server(Port) :-
    format('Starting server on port ~w...~n', [Port]),
    http_server(http_dispatch, [port(Port)]).

:- if(current_prolog_flag(argv, Args), false).
:- endif.

% Provide a convenience to run the server from the toplevel: ?- start_server(8080).
