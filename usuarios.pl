% usuarios.pl
% Modulo para gestion de usuarios, roperos personalizados y persistencia nativa en Prolog.

:- module(usuarios, [
    inicializar_db/0,
    autenticar_o_registrar/3,
    agregar_prenda/7,
    eliminar_prenda/2,
    listar_prendas_usuario/2,
    prenda_de/6,
    cargar_ejemplos_usuario/1,
    limpiar_ropero_usuario/1
]).

% Predicados dinamicos para almacenar usuarios y prendas
:- dynamic usuario/2.           % usuario(Usuario, PIN)
:- dynamic prenda_usuario/6.    % prenda_usuario(Usuario, PrendaID, Tipo, Color, Abrigo, Formalidad)

archivo_db('usuarios_data.pl').

% Inicializa la base de datos cargando el archivo de persistencia si existe
inicializar_db :-
    archivo_db(Archivo),
    (   exists_file(Archivo)
    ->  catch(usuarios:load_files(Archivo, [silent(true)]), Error,
              format('Error al cargar ~w: ~w~n', [Archivo, Error]))
    ;   true
    ).

% Guarda en disco todos los hechos de usuarios y prendas de forma nativa en Prolog
guardar_db :-
    archivo_db(Archivo),
    catch(
        (   tell(Archivo),
            listing(usuario/2),
            listing(prenda_usuario/6),
            told
        ),
        Error,
        (   told,
            format('Error al persistir DB: ~w~n', [Error])
        )
    ).

% Autentica a un usuario existente verificando su PIN, o lo registra si es nuevo
autenticar_o_registrar(Usuario, PIN, Estado) :-
    (   usuario(Usuario, PINGuardado)
    ->  (   PINGuardado == PIN
        ->  Estado = login_exitoso
        ;   Estado = pin_incorrecto
        )
    ;   % Usuario nuevo: se registra
        assertz(usuario(Usuario, PIN)),
        guardar_db,
        Estado = registrado_exitoso
    ).

% Agrega una prenda al ropero de un usuario
agregar_prenda(Usuario, PrendaID, Tipo, Color, Abrigo, Formalidad, Resultado) :-
    (   prenda_usuario(Usuario, PrendaID, _, _, _, _)
    ->  Resultado = error(ya_existe)
    ;   assertz(prenda_usuario(Usuario, PrendaID, Tipo, Color, Abrigo, Formalidad)),
        guardar_db,
        Resultado = ok
    ).

% Elimina una prenda del ropero de un usuario
eliminar_prenda(Usuario, PrendaID) :-
    retractall(prenda_usuario(Usuario, PrendaID, _, _, _, _)),
    guardar_db.

% Limpia todas las prendas de un usuario
limpiar_ropero_usuario(Usuario) :-
    retractall(prenda_usuario(Usuario, _, _, _, _, _)),
    guardar_db.

% Lista todas las prendas de un usuario como una lista de estructuras
listar_prendas_usuario(Usuario, Prendas) :-
    findall(
        prenda(ID, Tipo, Color, Abrigo, Formalidad),
        prenda_usuario(Usuario, ID, Tipo, Color, Abrigo, Formalidad),
        Prendas
    ).

% Predicado usado por el motor de inferencia para consultar las prendas del usuario
prenda_de(Usuario, PrendaID, Tipo, Color, Abrigo, Formalidad) :-
    prenda_usuario(Usuario, PrendaID, Tipo, Color, Abrigo, Formalidad).

% Carga un catalogo de ejemplo para usuarios que quieran probar rapidamente
cargar_ejemplos_usuario(Usuario) :-
    % Prendas basicas de demostracion
    PrendasDemo = [
        % Superiores
        prenda(blusa_seda_blanca, superior, blanco, 2, elegante),
        prenda(camisa_oxford_azul, superior, azul, 2, formal),
        prenda(top_negro_basico, superior, negro, 1, casual),
        prenda(sueter_oversized_beige, superior, beige, 4, casual),
        prenda(hoodie_rosa, superior, rosa, 3, deportivo),
        % Inferiores
        prenda(jeans_skinny_azul, inferior, azul, 2, casual),
        prenda(pantalon_vestir_beige, inferior, beige, 3, formal),
        prenda(pantalon_sastre_negro, inferior, negro, 3, formal),
        prenda(leggings_deportivos, inferior, negro, 2, deportivo),
        % Vestidos
        prenda(vestido_midi_negro, vestido, negro, 2, elegante),
        prenda(vestido_floral_verano, vestido, multicolor, 1, casual),
        % Calzado
        prenda(tenis_blancos, calzado, blanco, 1, casual),
        prenda(tenis_deportivos, calzado, negro, 2, deportivo),
        prenda(zapatos_tacon_negros, calzado, negro, 2, elegante),
        prenda(mocasines_beige, calzado, beige, 2, formal),
        prenda(botas_lluvia_negras, calzado, negro, 3, casual),
        % Abrigos
        prenda(gabardina_beige, abrigo, beige, 4, formal),
        prenda(chamarra_piel_negra, abrigo, negro, 3, casual),
        prenda(impermeable_transparente, abrigo, transparente, 3, casual),
        prenda(abrigo_invierno_negro, abrigo, negro, 5, casual),
        % Accesorios
        prenda(bolso_mano_negro, accesorio, negro, 1, elegante),
        prenda(bolso_cruzado_cafe, accesorio, cafe, 1, casual),
        prenda(gorra_deportiva, accesorio, negro, 1, deportivo),
        prenda(paraguas_negro, accesorio, negro, 1, casual)
    ],
    forall(
        member(prenda(ID, Tipo, Color, Abr, Form), PrendasDemo),
        (   \+ prenda_usuario(Usuario, ID, _, _, _, _)
        ->  assertz(prenda_usuario(Usuario, ID, Tipo, Color, Abr, Form))
        ;   true
        )
    ),
    guardar_db.
