:- [outfit].

% Prueba breve del generador diverso con el catálogo Prolog.
test :-
    recomendar_outfits_diversos(18, no, casual, 6, Outfits),
    length(Outfits, Total),
    format('Combinaciones generadas: ~w~n', [Total]),
    maplist(writeln, Outfits).

:- initialization(test, main).
