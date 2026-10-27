% server.pl
% Servidor HTTP en SWI-Prolog para Closet Aura
% Asignatura: Paradigmas de Programación - ESCOM IPN
% Soporta: Recomendaciones diversas (cambiando todo), integración con API de Clima
%          y sincronización dinámica con prendas agregadas/eliminadas en la web.

:- use_module(library(http/http_server)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_files)).
:- use_module(library(solution_sequences)).
:- use_module(library(time)).
:- use_module(library(lists)).
:- use_module(library(apply)).

:- set_prolog_flag(encoding, utf8).

% Definir ruta base de estáticos (carpeta version-static)
:- multifile user:file_search_path/2.
:- dynamic user:file_search_path/2.
:- prolog_load_context(directory, Dir),
   atom_concat(Dir, '/version-static', StaticDir),
   assertz(user:file_search_path(static_dir, StaticDir)).

% Cargar configuración y motor de inferencia de outfits
:- [config].
:- [outfit].

% Número máximo de combinaciones diversas devueltas a la interfaz
max_soluciones(6).

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
    catch(set_stream(current_output, encoding(utf8)), _, true),
    (   catch(http_read_json_dict(Request, Datos), _, fail),
        is_dict(Datos)
    ->  procesar_recomendacion(Datos)
    ;   error_json(400, ['El cuerpo de la petición no es un JSON válido.'])
    ).

procesar_recomendacion(Datos) :-
    validar_datos(Datos, Temp, Lluvia, Ocasion, Errores),
    (   Errores \== []
    ->  error_json(400, Errores)
    ;   setup_call_cleanup(
            cargar_prendas_usuario(Datos),
            (   consultar_outfits(Temp, Lluvia, Ocasion, Resultado),
                responder_outfit(Resultado, Temp, Lluvia, Ocasion)
            ),
            retractall(prenda_usuario(_, _, _, _, _, _, _, _))
        )
    ).

% Cargar prendas del guardarropa enviadas desde el navegador
cargar_prendas_usuario(Datos) :-
    retractall(prenda_usuario(_, _, _, _, _, _, _, _)),
    (   get_dict(prendas, Datos, Prendas),
        is_list(Prendas),
        Prendas \== []
    ->  forall(member(P, Prendas), asertar_prenda_usuario(P))
    ;   true
    ).

asertar_prenda_usuario(P) :-
    (   get_dict(id, P, IdVal),
        get_dict(category, P, CatVal),
        get_dict(color, P, ColorVal),
        get_dict(warmth, P, WarmthVal),
        get_dict(style, P, StyleVal)
    ->  atom_string(Id, IdVal),
        atom_string(Cat, CatVal),
        atom_string(Color, ColorVal),
        (number(WarmthVal) -> Abrigo = WarmthVal ; atom_number(WarmthVal, Abrigo)),
        atom_string(Form, StyleVal),
        (get_dict(name, P, NameVal) -> atom_string(Name, NameVal) ; atom_string(Name, IdVal)),
        (get_dict(emoji, P, EmojiVal) -> atom_string(Emoji, EmojiVal) ; Emoji = "👚"),
        (get_dict(image, P, ImgVal) -> atom_string(Img, ImgVal) ; Img = ""),
        assertz(prenda_usuario(Id, Cat, Color, Abrigo, Form, Name, Emoji, Img))
    ;   true
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

% Inferencia con Prolog: genera combinaciones diversas cambiando prendas completas
consultar_outfits(Temp, Lluvia, Ocasion, Resultado) :-
    max_soluciones(Max),
    catch(
        (   call_with_time_limit(8,
                recomendar_outfits_diversos(Temp, Lluvia, Ocasion, Max, Soluciones)),
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
            mensaje: "No se encontró ninguna combinación compatible con las reglas actuales de clima y ocasión. Intenta agregando más prendas a tu guardarropa o cambiando los filtros."
        })
    ;   outfits_a_json(Soluciones, Temp, Lluvia, Ocasion, 1, OutfitsJSON),
        OutfitsJSON = [PrimerOutfit | _],
        format(string(Mensaje), "Se generaron ~w combinaciones variadas con SWI-Prolog cambiando prendas superiores, inferiores, calzado y accesorios.", [Total]),
        reply_json_dict(_{
            ok: true,
            total: Total,
            mensaje: Mensaje,
            outfits: OutfitsJSON,
            outfit: PrimerOutfit
        }, [encoding(utf8), content_type('application/json; charset=utf-8')])
    ).

outfits_a_json([], _, _, _, _, []).
outfits_a_json([outfit(Sup, Inf, Calz, Abr, Acc) | Resto], Temp, Lluvia, Ocasion, Indice, [Dict | RestoDicts]) :-
    outfit_a_items(Sup, Inf, Calz, Abr, Acc, Items),
    generar_titulo_outfit(Sup, Inf, Indice, Titulo),
    Dict = _{
        id: Indice,
        titulo: Titulo,
        items: Items,
        temperatura: Temp,
        lluvia: Lluvia,
        ocasion: Ocasion
    },
    Indice1 is Indice + 1,
    outfits_a_json(Resto, Temp, Lluvia, Ocasion, Indice1, RestoDicts).

generar_titulo_outfit(Vestido, no_aplica, Indice, Titulo) :- !,
    nombre_legible(Vestido, NomVest),
    format(string(Titulo), "Propuesta ~w: Look con ~w", [Indice, NomVest]).
generar_titulo_outfit(Sup, Inf, Indice, Titulo) :-
    nombre_legible(Sup, NomSup),
    nombre_legible(Inf, NomInf),
    format(string(Titulo), "Propuesta ~w: ~w con ~w", [Indice, NomSup, NomInf]).

outfit_a_items(Sup, Inf, Calz, Abr, Acc, Items) :-
    findall(_{id: AtomStr, name: NombreLimpio, category: CategoriaStr, color: ColorStr, emoji: Emoji, image: Image},
            (   (   Sup \== no_aplica, Sup \== ninguno, elemento_prenda(Sup, superior, NombreLimpio, ColorStr, CategoriaStr, Emoji, Image, AtomStr) )
            ;   (   Inf \== no_aplica, Inf \== ninguno, elemento_prenda(Inf, inferior, NombreLimpio, ColorStr, CategoriaStr, Emoji, Image, AtomStr) )
            ;   (   Calz \== ninguno, elemento_prenda(Calz, calzado, NombreLimpio, ColorStr, CategoriaStr, Emoji, Image, AtomStr) )
            ;   (   Abr \== ninguno, elemento_prenda(Abr, abrigo, NombreLimpio, ColorStr, CategoriaStr, Emoji, Image, AtomStr) )
            ;   (   Acc \== ninguno, elemento_prenda(Acc, accesorio, NombreLimpio, ColorStr, CategoriaStr, Emoji, Image, AtomStr) )
            ),
            Items).

elemento_prenda(ID, Tipo, Nombre, Color, Categoria, Emoji, Image, AtomStr) :-
    (   prenda_usuario(ID, CategoriaAtomo, ColorAtomo, _, _, NombreUsuario, EmojiUsuario, ImageUsuario)
    ->  atom_string(ID, AtomStr),
        atom_string(CategoriaAtomo, Categoria),
        atom_string(ColorAtomo, Color),
        atom_string(NombreUsuario, Nombre),
        atom_string(EmojiUsuario, Emoji),
        atom_string(ImageUsuario, Image)
    ;   prenda(ID, CategoriaAtomo, ColorAtomo, _, _),
        atom_string(ID, AtomStr),
        atom_string(CategoriaAtomo, Categoria),
        atom_string(ColorAtomo, Color),
        formatear_nombre(ID, Nombre),
        emoji_por_tipo(Tipo, Emoji),
        Image = ""
    ).

nombre_legible(ID, Nombre) :-
    (   prenda_usuario(ID, _, _, _, _, NombreUsuario, _, _)
    ->  atom_string(NombreUsuario, Nombre)
    ;   formatear_nombre(ID, Nombre)
    ).

% Formatear identificador_con_guiones a "Nombre con Espacios"
formatear_nombre(ID, Nombre) :-
    atomic_list_concat(Palabras, '_', ID),
    atomic_list_concat(Palabras, ' ', Texto),
    atom_string(Texto, S),
    (   string_chars(S, [C|Resto])
    ->  upcase_atom(C, CU),
        string_chars(Nombre, [CU|Resto])
    ;   Nombre = ID
    ).

emoji_por_tipo(superior, "top").
emoji_por_tipo(inferior, "bottom").
emoji_por_tipo(vestido, "dress").
emoji_por_tipo(calzado, "shoes").
emoji_por_tipo(abrigo, "coat").
emoji_por_tipo(accesorio, "acc").

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
    (   current_prolog_flag(break_level, _)
    ->  true
    ;   thread_get_message(_)
    ).

:- initialization(iniciar).
