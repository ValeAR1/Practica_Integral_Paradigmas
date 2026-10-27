% server.pl
% Servidor HTTP en SWI-Prolog para Closet Aura (asistente de outfit).
%
% Hace de puente entre la interfaz web y el motor Prolog:
%   - sirve la interfaz (carpeta version-static/)
%   - cuentas con correo y contrasena (la contrasena se guarda cifrada)
%   - guardarropa por usuario (agregar, ver, eliminar)
%   - recomendaciones: llama a recomendar_outfit/8 de outfit.pl
%     (o a recomendar_outfit/9 con el usuario, si el equipo la define)
%
% Este archivo es de integracion. La logica del sistema experto (hechos,
% reglas y predicados de recomendacion) vive en outfit.pl.

:- use_module(library(http/http_server)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_files)).
:- use_module(library(http/http_header)).
:- use_module(library(solution_sequences)).
:- use_module(library(time)).
:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(crypto)).

% Carpeta del proyecto, para ubicar la interfaz.
:- multifile user:file_search_path/2.
:- dynamic user:file_search_path/2.
:- prolog_load_context(directory, Dir),
   assertz(user:file_search_path(app, Dir)).

% Leer los archivos .pl como UTF-8 (acentos y enies).
:- set_prolog_flag(encoding, utf8).

:- use_module(usuarios).
:- [config].
:- [outfit].

max_soluciones(6).
max_prendas_por_usuario(200).

% ---------------------------------------------------------------- rutas

:- http_handler(root(.),                servir_estatico,  [prefix]).
:- http_handler(root(api/salud),        api_salud,        []).
:- http_handler(root(api/opciones),     api_opciones,     []).
:- http_handler(root(api/registro),     api_registro,     [method(post)]).
:- http_handler(root(api/login),        api_login,        [method(post)]).
:- http_handler(root(api/logout),       api_logout,       [method(post)]).
:- http_handler(root(api/prendas),      api_prendas,      []).
:- http_handler(root(api/prendas/demo), api_prendas_demo, [method(post)]).
:- http_handler(root(api/recomendar),   api_recomendar,   [method(post)]).

servir_estatico(Request) :-
    memberchk(path(Path), Request),
    (   Path == '/'
    ->  http_redirect(moved_temporary, root('index.html'), Request)
    ;   absolute_file_name(app('version-static'), Dir,
                           [file_type(directory), access(read)]),
        http_reply_from_files(Dir, [], Request)
    ).

api_salud(_) :-
    reply_json_dict(_{estado: "ok"}).

api_opciones(_) :-
    temperatura_rango(Min, Max),
    lluvias_permitidas(Lluvias),
    ocasiones_permitidas(Ocasiones),
    tipos_prenda_permitidos(Tipos),
    colores_permitidos(Colores),
    formalidades_permitidas(Formalidades),
    reply_json_dict(_{ temperatura: _{min: Min, max: Max},
                       lluvia: Lluvias, ocasiones: Ocasiones,
                       tipos_prenda: Tipos, colores: Colores,
                       formalidades: Formalidades }).

error_json(Estado, Errores) :-
    reply_json_dict(_{ok: false, errores: Errores}, [status(Estado)]).

% Hay que leer el cuerpo de la peticion aunque no se use; si no, queda
% pendiente en la conexion y la siguiente peticion falla con error 400.
descartar_cuerpo(Request) :-
    catch(http_read_json_dict(Request, _), _, true).

leer_json(Request, Datos) :-
    catch(http_read_json_dict(Request, Datos), _, fail),
    is_dict(Datos).

% ------------------------------------------------------- cuentas y sesion
% Una sesion es un token aleatorio que vive en la memoria del servidor.
% Si el servidor se reinicia, hay que volver a iniciar sesion.

:- dynamic sesion/2.      % sesion(Token, Usuario)

api_registro(Request) :-
    (   leer_json(Request, Datos),
        credenciales(Datos, Usuario, Clave, Errores)
    ->  (   Errores \== []
        ->  error_json(400, Errores)
        ;   usuarios:usuario(Usuario, _)
        ->  error_json(409, ['Ya existe una cuenta con ese correo.'])
        ;   with_mutex(closet_db,
                autenticar_o_registrar(Usuario, Clave, _)),
            abrir_sesion(Usuario, Token),
            reply_json_dict(_{ok: true, token: Token, usuario: Usuario})
        )
    ;   error_json(400, ['Faltan el correo o la contrasena.'])
    ).

api_login(Request) :-
    (   leer_json(Request, Datos),
        credenciales(Datos, Usuario, Clave, Errores)
    ->  (   Errores \== []
        ->  error_json(400, Errores)
        ;   usuarios:usuario(Usuario, _),
            with_mutex(closet_db,
                autenticar_o_registrar(Usuario, Clave, login_exitoso))
        ->  abrir_sesion(Usuario, Token),
            reply_json_dict(_{ok: true, token: Token, usuario: Usuario})
        ;   error_json(401, ['Correo o contrasena incorrectos. Si es tu primera vez, crea una cuenta.'])
        )
    ;   error_json(400, ['Faltan el correo o la contrasena.'])
    ).

api_logout(Request) :-
    descartar_cuerpo(Request),
    (   token_de(Request, Token)
    ->  retractall(sesion(Token, _))
    ;   true
    ),
    reply_json_dict(_{ok: true}).

% Lee y valida correo y contrasena. Clave es el cifrado de la contrasena.
credenciales(Datos, Usuario, Clave, Errores) :-
    get_dict(email, Datos, Email0),
    get_dict(password, Datos, Pass0),
    text_to_string(Email0, EmailS0),
    text_to_string(Pass0, Pass),
    string_lower(EmailS0, EmailS1),
    normalize_space(string(Email), EmailS1),
    string_length(Email, LE),
    string_length(Pass, LP),
    (   LE >= 5, LE =< 100, sub_string(Email, _, _, _, "@"),
        \+ sub_string(Email, _, _, _, " ")
    ->  E1 = []
    ;   E1 = ['Escribe un correo valido.']
    ),
    (   LP >= 6, LP =< 100
    ->  E2 = []
    ;   E2 = ['La contrasena debe tener entre 6 y 100 caracteres.']
    ),
    append(E1, E2, Errores),
    atom_string(Usuario, Email),
    cifrar(Usuario, Pass, Clave).

% Contrasena cifrada con HMAC-SHA256. La llave secreta sale de la variable
% de entorno CLOSET_SECRETO; si no existe se usa una de desarrollo.
cifrar(Usuario, Pass, Clave) :-
    (   getenv('CLOSET_SECRETO', Secreto) -> true
    ;   Secreto = 'llave-de-desarrollo-cambiar-en-produccion'
    ),
    atomic_list_concat([Usuario, Pass], ':', Mensaje),
    crypto_data_hash(Mensaje, Clave,
                     [algorithm(sha256), hmac(Secreto), encoding(utf8)]).

abrir_sesion(Usuario, Token) :-
    crypto_n_random_bytes(24, Bytes),
    hex_bytes(Hex, Bytes),
    atom_string(Token, Hex),
    assertz(sesion(Token, Usuario)).

token_de(Request, Token) :-
    memberchk(authorization(Auth), Request),
    atom_string(Auth, S),
    sub_string(S, 0, 7, _, "Bearer "),
    sub_string(S, 7, _, 0, TokenS),
    atom_string(Token, TokenS).

usuario_de(Request, Usuario) :-
    token_de(Request, Token),
    sesion(Token, Usuario).

% Ejecuta Goal(Usuario) solo si hay sesion valida.
con_usuario(Request, Goal) :-
    (   usuario_de(Request, Usuario)
    ->  call(Goal, Usuario)
    ;   error_json(401, ['Tu sesion expiro. Inicia sesion de nuevo.'])
    ).

% -------------------------------------------------------------- prendas

api_prendas(Request) :-
    memberchk(method(Metodo), Request),
    con_usuario(Request, manejar_prendas(Metodo, Request)).

manejar_prendas(get, _Request, Usuario) :-
    respuesta_prendas(Usuario).
manejar_prendas(post, Request, Usuario) :-
    (   leer_json(Request, Datos)
    ->  crear_prenda(Datos, Usuario)
    ;   error_json(400, ['JSON invalido.'])
    ).
manejar_prendas(put, Request, Usuario) :-
    (   leer_json(Request, Datos),
        memberchk(search(Params), Request),
        memberchk(id=Id0, Params),
        text_to_string(Id0, IdText),
        atom_string(IdActual, IdText)
    ->  actualizar_prenda(Datos, Usuario, IdActual)
    ;   error_json(400, ['Datos de actualizacion invalidos.'])
    ).
manejar_prendas(delete, Request, Usuario) :-
    (   memberchk(search(Params), Request),
        memberchk(id=Id0, Params),
        text_to_string(Id0, IdText),
        atom_string(Id, IdText)
    ->  with_mutex(closet_db, eliminar_prenda(Usuario, Id)),
        reply_json_dict(_{ok: true})
    ;   error_json(400, ['Falta el id de la prenda.'])
    ).
manejar_prendas(Otro, _, _) :-
    Otro \== get, Otro \== post, Otro \== put, Otro \== delete,
    error_json(405, ['Metodo no permitido.']).

respuesta_prendas(Usuario) :-
    listar_prendas_usuario(Usuario, Prendas),
    maplist(prenda_a_dict, Prendas, Dicts),
    reply_json_dict(_{ok: true, prendas: Dicts}).

prenda_a_dict(prenda(Id, Tipo, Color, Abrigo, Form),
              _{id: Id, tipo: Tipo, color: Color, abrigo: Abrigo, formalidad: Form}).

crear_prenda(Datos, Usuario) :-
    tipos_prenda_permitidos(Tipos),
    colores_permitidos(Colores),
    formalidades_permitidas(Forms),
    (   get_dict(nombre, Datos, Nombre0),
        get_dict(tipo, Datos, T0), opcion(T0, Tipos, Tipo),
        get_dict(color, Datos, C0), opcion(C0, Colores, Color),
        get_dict(formalidad, Datos, F0), opcion(F0, Forms, Form),
        get_dict(abrigo, Datos, Abrigo), integer(Abrigo),
        Abrigo >= 1, Abrigo =< 5,
        identificador(Nombre0, Id)
    ->  max_prendas_por_usuario(Max),
        listar_prendas_usuario(Usuario, Actuales),
        length(Actuales, N),
        (   N >= Max
        ->  error_json(400, ['Llegaste al maximo de prendas permitidas.'])
        ;   with_mutex(closet_db,
                agregar_prenda(Usuario, Id, Tipo, Color, Abrigo, Form, Res)),
            (   Res == ok
            ->  reply_json_dict(_{ok: true, id: Id})
            ;   error_json(409, ['Ya tienes una prenda con ese nombre.'])
            )
        )
    ;   error_json(400, ['Datos de prenda invalidos. Revisa nombre, categoria, color, abrigo y estilo.'])
    ).

actualizar_prenda(Datos, Usuario, IDActual) :-
    tipos_prenda_permitidos(Tipos),
    colores_permitidos(Colores),
    formalidades_permitidas(Forms),
    (   get_dict(nombre, Datos, Nombre0),
        get_dict(tipo, Datos, T0), opcion(T0, Tipos, Tipo),
        get_dict(color, Datos, C0), opcion(C0, Colores, Color),
        get_dict(formalidad, Datos, F0), opcion(F0, Forms, Form),
        get_dict(abrigo, Datos, Abrigo), integer(Abrigo),
        Abrigo >= 1, Abrigo =< 5,
        identificador(Nombre0, IDNuevo)
    ->  with_mutex(closet_db,
            usuarios:actualizar_prenda(Usuario, IDActual, IDNuevo, Tipo, Color, Abrigo, Form, Res)),
        (   Res == ok
        ->  reply_json_dict(_{ok: true, id: IDNuevo})
        ;   Res == error(ya_existe)
        ->  error_json(409, ['Ya tienes una prenda con ese nombre.'])
        ;   error_json(404, ['No se encontro la prenda que quieres editar.'])
        )
    ;   error_json(400, ['Datos de prenda invalidos. Revisa nombre, categoria, color, abrigo y estilo.'])
    ).

api_prendas_demo(Request) :-
    descartar_cuerpo(Request),
    con_usuario(Request, cargar_demo).

cargar_demo(Usuario) :-
    with_mutex(closet_db, cargar_ejemplos_usuario(Usuario)),
    respuesta_prendas(Usuario).

% El valor debe estar en la lista de permitidos; el atomo sale de la lista,
% nunca se crea a partir del texto del usuario.
opcion(Valor, Permitidas, Atomo) :-
    text_to_string(Valor, S0),
    string_lower(S0, S1),
    normalize_space(string(S2), S1),
    member(Atomo, Permitidas),
    atom_string(Atomo, S2),
    !.

% "Blusa de Seda" -> blusa_de_seda
identificador(Texto, Id) :-
    text_to_string(Texto, S0),
    string_lower(S0, S1),
    string_codes(S1, Codes),
    maplist(sin_acento, Codes, Codes1),
    maplist(solo_alfanum, Codes1, Codes2),
    string_codes(S2, Codes2),
    split_string(S2, "_", "_", Partes0),
    exclude(==(""), Partes0, Partes),
    Partes \== [],
    atomic_list_concat(Partes, '_', Id0),
    atom_length(Id0, L), L =< 60,
    Id = Id0.

% Letras con acento a su version simple (por codigo, para no depender de la codificacion).
sin_acento(0xE1, 0'a) :- !.            % a con acento
sin_acento(0xE9, 0'e) :- !.            % e con acento
sin_acento(0xED, 0'i) :- !.            % i con acento
sin_acento(0xF3, 0'o) :- !.            % o con acento
sin_acento(0xFA, 0'u) :- !.            % u con acento
sin_acento(0xFC, 0'u) :- !.            % u con dieresis
sin_acento(0xF1, 0'n) :- !.            % enie
sin_acento(0xC1, 0'a) :- !.            % mayusculas con acento
sin_acento(0xC9, 0'e) :- !.
sin_acento(0xCD, 0'i) :- !.
sin_acento(0xD3, 0'o) :- !.
sin_acento(0xDA, 0'u) :- !.
sin_acento(0xDC, 0'u) :- !.
sin_acento(0xD1, 0'n) :- !.
sin_acento(C, C).

solo_alfanum(C, C) :- C >= 0'a, C =< 0'z, !.
solo_alfanum(C, C) :- C >= 0'0, C =< 0'9, !.
solo_alfanum(_, 0'_).

% ------------------------------------------------------- recomendaciones

api_recomendar(Request) :-
    (   leer_json(Request, Datos)
    ->  (   usuario_de(Request, Usuario)
        ->  validar(Datos, Temp, Lluvia, Ocasion, Errores),
            (   Errores \== []
            ->  error_json(400, Errores)
            ;   consultar(Usuario, Temp, Lluvia, Ocasion, Resultado),
                responder(Resultado, Usuario, Temp, Lluvia, Ocasion)
            )
        ;   error_json(401, ['Inicia sesion para recomendar un conjunto.'])
        )
    ;   error_json(400, ['El cuerpo de la peticion no es un JSON valido.'])
    ).

validar(Datos, Temp, Lluvia, Ocasion, Errores) :-
    temperatura_rango(Min, Max),
    (   get_dict(temperatura, Datos, V),
        (   number(V) -> Temp = V
        ;   string(V), catch(number_string(Temp, V), _, fail)
        ),
        number(Temp), Temp >= Min, Temp =< Max
    ->  E1 = []
    ;   format(atom(M1), 'La temperatura debe ser un numero entre ~w y ~w.', [Min, Max]),
        E1 = [M1]
    ),
    lluvias_permitidas(Lluvias),
    (   get_dict(lluvia, Datos, L0), opcion(L0, Lluvias, Lluvia)
    ->  E2 = []
    ;   E2 = ['Lluvia debe ser si o no.']
    ),
    ocasiones_permitidas(Ocasiones),
    (   get_dict(ocasion, Datos, O0), opcion(O0, Ocasiones, Ocasion)
    ->  E3 = []
    ;   E3 = ['La ocasion no es valida.']
    ),
    append([E1, E2, E3], Errores).

% Si outfit.pl define recomendar_outfit/9 (con el usuario como primer
% argumento) y hay sesion, se usa; si no, se usa recomendar_outfit/8.
personalizado(Usuario) :-
    Usuario \== global,
    current_predicate(recomendar_outfit/9).

motor(Usuario, T, L, O, Sup, Inf, Calz, Abr, Acc) :-
    (   personalizado(Usuario)
    ->  recomendar_outfit(Usuario, T, L, O, Sup, Inf, Calz, Abr, Acc)
    ;   recomendar_outfit(T, L, O, Sup, Inf, Calz, Abr, Acc)
    ).

consultar(Usuario, T, L, O, Resultado) :-
    with_mutex(outfit_mutex,
        setup_call_cleanup(
            cargar_ropero_para_recomendacion(Usuario),
            consultar_ropero(Usuario, T, L, O, Resultado),
            retractall(user:prenda_usuario(_, _, _, _, _, _, _, _))
        )).

% El motor de la amiga usa prendas dinamicas durante la consulta. Se cargan
% desde el guardarropa persistente del usuario y se retiran al terminar.
cargar_ropero_para_recomendacion(Usuario) :-
    retractall(user:prenda_usuario(_, _, _, _, _, _, _, _)),
    usuarios:listar_prendas_usuario(Usuario, Prendas),
    forall(member(prenda(Id, Tipo, Color, Abrigo, Formalidad), Prendas),
           assertz(user:prenda_usuario(Id, Tipo, Color, Abrigo, Formalidad,
                                      Id, '👚', ''))).

consultar_ropero(Usuario, T, L, O, Resultado) :-
    usuarios:listar_prendas_usuario(Usuario, Prendas),
    (   Prendas == []
    ->  Resultado = ok([])
    ;   max_soluciones(Max),
        catch(call_with_time_limit(8,
                  recomendar_outfits_diversos(T, L, O, Max, Outfits)),
              Error,
              Outfits = error(Error)),
        (   Outfits = error(Error)
        ->  Resultado = error(Error)
        ;   list_to_set(Outfits, Unicos),
            Resultado = ok(Unicos)
        )
    ).

responder(error(Error), _, _, _, _) :-
    print_message(error, Error),
    error_json(500, ['Error en el motor de inferencia Prolog.']).
responder(ok([]), _, _, _, _) :-
    reply_json_dict(_{ok: true, total: 0, outfits: [],
                      mensaje: "Tu guardarropa esta vacio o no tiene una combinacion compatible."}).
responder(ok(Outfits), Usuario, Temp, Lluvia, Ocasion) :-
    outfits_a_json(Outfits, Usuario, Temp, Lluvia, Ocasion, 1, Dicts),
    length(Dicts, Total),
    Dicts = [Primero|_],
    reply_json_dict(_{ok: true, total: Total, personalizado: true,
                      mensaje: "Recomendaciones generadas por SWI-Prolog.",
                      outfits: Dicts, outfit: Primero}).

outfits_a_json([], _, _, _, _, _, []).
outfits_a_json([outfit(Sup, Inf, Calz, Abr, Acc)|Resto], Usuario,
               Temp, Lluvia, Ocasion, N, [Dict|Dicts]) :-
    findall(Item,
            ( member(Pieza, [Sup, Inf, Calz, Abr, Acc]),
              \+ memberchk(Pieza, [ninguno, no_aplica]),
              item_de(Usuario, Pieza, Item)
            ), Items),
    format(string(Titulo), "Propuesta ~w", [N]),
    Dict = _{id: N, titulo: Titulo, items: Items,
            temperatura: Temp, lluvia: Lluvia, ocasion: Ocasion},
    N1 is N + 1,
    outfits_a_json(Resto, Usuario, Temp, Lluvia, Ocasion, N1, Dicts).

% Datos de una prenda para mostrarla en la interfaz.
item_de(Usuario, Id, _{id: Id, name: Nombre, category: Tipo, color: Color}) :-
    (   usuarios:prenda_usuario(Usuario, Id, Tipo0, Color0, _, _)
    ->  Tipo = Tipo0, Color = Color0
    ;   prenda(Id, Tipo0, Color0, _, _)
    ->  Tipo = Tipo0, Color = Color0
    ;   Tipo = superior, Color = negro
    ),
    nombre_bonito(Id, Nombre).

nombre_bonito(Id, Nombre) :-
    atomic_list_concat(Palabras, '_', Id),
    atomic_list_concat(Palabras, ' ', Texto),
    atom_string(Texto, S),
    string_chars(S, [C|Resto]),
    upcase_atom(C, CU),
    string_chars(Nombre, [CU|Resto]).

% -------------------------------------------------------------- arranque

iniciar :-
    inicializar_db,
    (   getenv('PORT', P), atom_number(P, Puerto) -> true ; Puerto = 8080 ),
    (   current_predicate(recomendar_outfit/8)
    ;   current_predicate(recomendar_outfit/9)
    ->  true
    ;   format(user_error, 'AVISO: outfit.pl no define recomendar_outfit.~n', [])
    ),
    http_server([port(Puerto)]),
    format(user_error, 'Servidor escuchando en el puerto ~w~n', [Puerto]),
    thread_get_message(_).

:- initialization(iniciar, main).
