% server.pl
% Servidor HTTP en SWI-Prolog para Closet Aura
% Asignatura: Paradigmas de Programación - ESCOM IPN

:- use_module(library(http/http_server)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_files)).
:- use_module(library(solution_sequences)).
:- use_module(library(time)).
:- use_module(library(lists)).
:- use_module(library(apply)).

% Definir ruta base de estáticos (carpeta version-static)
:- multifile user:file_search_path/2.
:- dynamic user:file_search_path/2.
:- prolog_load_context(directory, Dir),
   atom_concat(Dir, '/version-static', StaticDir),
   assertz(user:file_search_path(static_dir, StaticDir)).

% Cargar configuración y motor de inferencia de outfits
:- [config].
:- [outfit].

% Número máximo de combinaciones devueltas a la interfaz
max_soluciones(50).

% -------------------------------------------------------------------------
% RUTAS Y HANDLERS HTTP
% -------------------------------------------------------------------------

:- http_handler(root(.),              servir_index,       []).
:- http_handler(root('index.html'),    servir_index,       []).
:- http_handler(root('styles.css'),    servir_styles,      []).
:- http_handler(root('app.js'),        servir_app_js,      []).
:- http_handler(root('README.txt'),    servir_readme,      []).
:- http_handler(root(api/salud),      api_salud,          []).
:- http_handler(root(api/opciones),   api_opciones,       []).
:- http_handler(root(api/recomendar), api_recomendar,     [method(post)]).
:- http_handler(root(static),         http_reply_from_files(static_dir(.)), [prefix]).

% Servir archivos de la carpeta version-static/
servir_index(Request) :-
    http_reply_file(static_dir('index.html'), [], Request).

servir_styles(Request) :-
    http_reply_file(static_dir('styles.css'), [], Request).

servir_app_js(Request) :-
    http_reply_file(static_dir('app.js'), [], Request).

servir_readme(Request) :-
    http_reply_file(static_dir('README.txt'), [], Request).

% Health check del backend
api_salud(_Request) :-
    reply_json_dict(_{estado: "ok", motor: "SWI-Prolog"}).

% Opciones y catálogos válidos
api_opciones(_Request) :-
    temperatura_rango(Min, Max),
    lluvias_permitidas(Lluvias),
    ocasiones_permitidas(Ocasiones),
    tipos_prenda_permitidos(Tipos),
    colores_permitidos(Colores),
    formalidades_permitidas(Formalidades),
    reply_json_dict(_{
        temperatura: _{min: Min, max: Max},
        lluvia: Lluvias,
        ocasiones: Ocasiones,
        tipos_prenda: Tipos,
        colores: Colores,
        formalidades: Formalidades
    }).

% -------------------------------------------------------------------------
% API DE RECOMENDACIÓN CON SWI-PROLOG
% -------------------------------------------------------------------------

api_recomendar(Request) :-
    (   catch(http_read_json_dict(Request, Datos), _, fail),
        is_dict(Datos)
    ->  procesar_recomendacion(Datos)
    ;   error_json(400, ['El cuerpo de la petición no es un JSON válido.'])
    ).

procesar_recomendacion(Datos) :-
    validar_datos(Datos, Temp, Lluvia, Ocasion, Errores),
    (   Errores \== []
    ->  error_json(400, Errores)
    ;   consultar_outfits(Datos, Temp, Lluvia, Ocasion, Resultado),
        responder_outfit(Resultado, Temp, Lluvia, Ocasion)
    ).

validar_datos(Datos, Temp, Lluvia, Ocasion, Errores) :-
    temperatura_rango(Min, Max),
    (   validar_temperatura(Datos, Min, Max, Temp)
    ->  E1 = []
    ;   format(atom(M1), 'La temperatura debe estar entre ~w y ~w °C.', [Min, Max]),
        E1 = [M1]
    ),
    lluvias_permitidas(LluviasPermitidas),
    (   validar_opcion(Datos, lluvia, LluviasPermitidas, Lluvia)
    ->  E2 = []
    ;   E2 = ['El campo lluvia debe ser "si" o "no".']
    ),
    ocasiones_permitidas(OcasionesPermitidas),
    (   validar_opcion(Datos, ocasion, OcasionesPermitidas, Ocasion)
    ->  E3 = []
    ;   E3 = ['La ocasión seleccionada no es válida.']
    ),
    append([E1, E2, E3], Errores).

validar_temperatura(Datos, Min, Max, Temp) :-
    get_dict(temperatura, Datos, V),
    (   number(V) -> Temp = V
    ;   string(V), catch(number_string(Temp, V), _, fail)
    ),
    number(Temp),
    Temp >= Min,
    Temp =< Max.

validar_opcion(Datos, Clave, Permitidas, Atomo) :-
    get_dict(Clave, Datos, V),
    (   string(V) ; atom(V) ),
    atom_string(Atomo, V),
    memberchk(Atomo, Permitidas).

% Inferencia con Prolog
consultar_outfits(_Datos, Temp, Lluvia, Ocasion, Resultado) :-
    max_soluciones(Max),
    catch(
        (   call_with_time_limit(5,
                findall(outfit(Sup, Inf, Calz, Abr, Acc),
                        limit(Max, recomendar_outfit(Temp, Lluvia, Ocasion, Sup, Inf, Calz, Abr, Acc)),
                        Todos)),
            list_to_set(Todos, Soluciones),
            Resultado = ok(Soluciones)
        ),
        Error,
        Resultado = error(Error)
    ).

responder_outfit(error(Error), _, _, _) :-
    print_message(error, Error),
    error_json(500, ['Error en el motor de inferencia Prolog.']).

responder_outfit(ok(Soluciones), Temp, Lluvia, Ocasion) :-
    length(Soluciones, Total),
    (   Total =:= 0
    ->  reply_json_dict(_{
            ok: false,
            total: 0,
            mensaje: "No se encontró ninguna combinación compatible con las reglas actuales de clima y ocasión."
        })
    ;   % Tomar la mejor/primera solución para mostrar en la interfaz
        Soluciones = [outfit(Sup, Inf, Calz, Abr, Acc) | _],
        outfit_a_items(Sup, Inf, Calz, Abr, Acc, Items),
        reply_json_dict(_{
            ok: true,
            total: Total,
            mensaje: "Recomendación generada exitosamente por el motor de inferencia SWI-Prolog.",
            outfit: _{
                items: Items,
                temperatura: Temp,
                lluvia: Lluvia,
                ocasion: Ocasion
            }
        })
    ).

outfit_a_items(Sup, Inf, Calz, Abr, Acc, Items) :-
    findall(_{id: AtomStr, name: NombreLimpio, category: CategoriaStr, color: ColorStr, emoji: Emoji},
            (   (   Sup \== no_aplica, Sup \== ninguno, elemento_prenda(Sup, superior, NombreLimpio, ColorStr, CategoriaStr, Emoji, AtomStr)
                ;   Sup == no_aplica, false
                )
            ;   (   Inf \== no_aplica, Inf \== ninguno, elemento_prenda(Inf, inferior, NombreLimpio, ColorStr, CategoriaStr, Emoji, AtomStr) )
            ;   (   Calz \== ninguno, elemento_prenda(Calz, calzado, NombreLimpio, ColorStr, CategoriaStr, Emoji, AtomStr) )
            ;   (   Abr \== ninguno, elemento_prenda(Abr, abrigo, NombreLimpio, ColorStr, CategoriaStr, Emoji, AtomStr) )
            ;   (   Acc \== ninguno, elemento_prenda(Acc, accesorio, NombreLimpio, ColorStr, CategoriaStr, Emoji, AtomStr) )
            ),
            Items).

elemento_prenda(ID, Tipo, Nombre, Color, Categoria, Emoji, IDStr) :-
    prenda(ID, CategoriaAtomo, ColorAtomo, _, _),
    atom_string(ID, IDStr),
    atom_string(CategoriaAtomo, Categoria),
    atom_string(ColorAtomo, Color),
    formatear_nombre(ID, Nombre),
    emoji_por_tipo(Tipo, Emoji).

% Formatear identificador_con_guiones a "Nombre con Espacios"
formatear_nombre(ID, Nombre) :-
    atomic_list_concat(Palabras, '_', ID),
    atomic_list_concat(Palabras, ' ', Texto),
    atom_string(Texto, S),
    string_chars(S, [C|Resto]),
    upcase_atom(C, CU),
    string_chars(Nombre, [CU|Resto]).

emoji_por_tipo(superior, "👚").
emoji_por_tipo(inferior, "👖").
emoji_por_tipo(vestido, "👗").
emoji_por_tipo(calzado, "👟").
emoji_por_tipo(abrigo, "🧥").
emoji_por_tipo(accesorio, "👜").

error_json(Status, Errores) :-
    reply_json_dict(_{ok: false, errores: Errores}, [status(Status)]).

% -------------------------------------------------------------------------
% INICIO DEL SERVIDOR
% -------------------------------------------------------------------------

iniciar :-
    (   getenv('PORT', P), atom_number(P, Puerto)
    ->  true
    ;   Puerto = 8080
    ),
    http_server(http_dispatch, [port(Puerto)]),
    format('~n======================================================~n'),
    format('  CLOSET AURA con SWI-Prolog activo en:~n'),
    format('  http://localhost:~w~n', [Puerto]),
    format('  (Presiona Ctrl+C para detener el servidor)~n'),
    format('======================================================~n~n'),
    % Mantener el hilo principal vivo si se ejecuta como script no interactivo
    (   current_prolog_flag(break_level, _)
    ->  true
    ;   thread_get_message(_)
    ).

:- initialization(iniciar).
