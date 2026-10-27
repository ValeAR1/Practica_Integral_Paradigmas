% =========================================================================
% SISTEMA EXPERTO: Asistente de Outfit Inteligente (Moda Femenina y Clima)
% Asignatura: Paradigmas de Programación - ESCOM IPN
% Versión completa con más de 180 prendas y motor de diversidad
% =========================================================================

:- multifile prenda/5.
:- dynamic prenda/5.
:- dynamic prenda_usuario/8.

% --- 1. HECHOS: GUARDARROPA Y ATRIBUTOS (Más de 30 prendas por categoría) ---
% Formato: prenda(ID, Tipo, Color, NivelAbrigo[1-5], Formalidad).

% --- PARTES SUPERIORES (31 elementos) ---
prenda(blusa_seda_blanca, superior, blanco, 2, elegante).
prenda(camisa_oxford_azul, superior, azul, 2, formal).
prenda(top_negro_basico, superior, negro, 1, casual).
prenda(sueter_oversized_beige, superior, beige, 4, casual).
prenda(cardigan_gris, superior, gris, 3, casual).
prenda(hoodie_rosa, superior, rosa, 3, deportivo).
prenda(body_negro_elegante, superior, negro, 2, elegante).
prenda(top_verde_esmeralda, superior, verde, 2, elegante).
prenda(blusa_estampada_floral, superior, multicolor, 2, casual).
prenda(camisa_lino_blanca, superior, blanco, 1, casual).
prenda(blusa_satinada_roja, superior, rojo, 2, elegante).
prenda(sueter_cuello_tortuga_negro, superior, negro, 4, formal).
prenda(top_sport_gris, superior, gris, 1, deportivo).
prenda(blusa_manga_larga_azul, superior, azul, 2, formal).
prenda(crop_top_blanco, superior, blanco, 1, casual).
prenda(camisa_cuadros_roja, superior, rojo, 2, casual).
prenda(blusa_hombros_descubiertos_negra, superior, negro, 2, elegante).
prenda(sueter_tejido_amarillo, superior, amarillo, 4, casual).
prenda(body_encaje_rojo, superior, rojo, 2, elegante).
prenda(blusa_chifon_beige, superior, beige, 2, elegante).
prenda(camisa_denim_azul, superior, azul, 2, casual).
prenda(top_halter_rosa, superior, rosa, 1, casual).
prenda(sueter_cardigan_corto_blanco, superior, blanco, 3, casual).
prenda(blusa_animal_print, superior, multicolor, 2, casual).
prenda(top_asimetrico_negro, superior, negro, 2, elegante).
prenda(camisa_formal_gris, superior, gris, 2, formal).
prenda(blusa_satinada_verde, superior, verde, 2, elegante).
prenda(hoodie_oversized_gris, superior, gris, 3, deportivo).
prenda(top_deportivo_blanco, superior, blanco, 1, deportivo).
prenda(sueter_naranja_tejido, superior, naranja, 4, casual).
prenda(blusa_plumeti_negra, superior, negro, 2, elegante).

% --- PARTES INFERIORES (31 elementos) ---
prenda(jeans_skinny_azul, inferior, azul, 2, casual).
prenda(jeans_mom_negros, inferior, negro, 2, casual).
prenda(pantalon_vestir_beige, inferior, beige, 3, formal).
prenda(pantalon_sastre_negro, inferior, negro, 3, formal).
prenda(falda_midi_plisada, inferior, verde, 2, elegante).
prenda(minifalda_cuadros, inferior, rojo, 2, casual).
prenda(leggings_deportivos_negros, inferior, negro, 2, deportivo).
prenda(short_denim, inferior, azul, 1, casual).
prenda(pantalon_cargo_verde, inferior, verde, 2, casual).
prenda(falda_larga_negra, inferior, negro, 2, elegante).
prenda(pantalon_cuero_negro, inferior, negro, 3, elegante).
prenda(jeans_rotos_azul, inferior, azul, 2, casual).
prenda(short_sport_gris, inferior, gris, 1, deportivo).
prenda(pantalon_chinos_beige, inferior, beige, 2, casual).
prenda(falda_tubo_gris, inferior, gris, 3, formal).
prenda(pantalon_wide_leg_blanco, inferior, blanco, 2, elegante).
prenda(jeans_skinny_negros, inferior, negro, 2, casual).
prenda(pantalon_sastre_azul, inferior, azul, 3, formal).
prenda(minifalda_jean, inferior, azul, 1, casual).
prenda(leggings_grises, inferior, gris, 2, deportivo).
prenda(pantalon_lino_beige, inferior, beige, 2, casual).
prenda(short_deportivo_rosa, inferior, rosa, 1, deportivo).
prenda(pantalon_jogger_negro, inferior, negro, 2, deportivo).
prenda(falda_plisada_rosa, inferior, rosa, 2, elegante).
prenda(jeans_mom_azul_claro, inferior, azul, 2, casual).
prenda(pantalon_vestir_gris, inferior, gris, 3, formal).
prenda(falda_satinada_negra, inferior, negro, 2, elegante).
prenda(pantalon_cargo_negro, inferior, negro, 2, casual).
prenda(short_sastre_beige, inferior, beige, 2, formal).
prenda(jeans_acampanados_azul, inferior, azul, 2, casual).
prenda(pantalon_sastre_blanco, inferior, blanco, 3, formal).

% --- VESTIDOS Y ENTERIZOS (31 elementos) ---
prenda(vestido_midi_negro, vestido, negro, 2, elegante).
prenda(vestido_floral_verano, vestido, multicolor, 1, casual).
prenda(vestido_coctel_rojo, vestido, rojo, 3, elegante).
prenda(vestido_largo_azul, vestido, azul, 2, elegante).
prenda(vestido_casual_rayas, vestido, multicolor, 1, casual).
prenda(vestido_punto_beige, vestido, beige, 4, casual).
prenda(vestido_fiesta_dorado, vestido, dorado, 3, elegante).
prenda(vestido_camisero_blanco, vestido, blanco, 2, casual).
prenda(vestido_satinado_verde, vestido, verde, 2, elegante).
prenda(vestido_denim_azul, vestido, azul, 2, casual).
prenda(vestido_tubo_negro, vestido, negro, 3, formal).
prenda(vestido_ajustado_rosa, vestido, rosa, 2, elegante).
prenda(vestido_bohemio_multicolor, vestido, multicolor, 1, casual).
prenda(vestido_velvet_negro, vestido, negro, 4, elegante).
prenda(vestido_corto_amarillo, vestido, amarillo, 1, casual).
prenda(vestido_formal_gris, vestido, gris, 3, formal).
prenda(vestido_tirantes_negro, vestido, negro, 1, casual).
prenda(vestido_encaje_blanco, vestido, blanco, 2, elegante).
prenda(vestido_tropical, vestido, multicolor, 1, casual).
prenda(vestido_casual_gris, vestido, gris, 2, casual).
prenda(vestido_lana_marron, vestido, marron, 5, casual).
prenda(vestido_escote_v_azul, vestido, azul, 2, elegante).
prenda(vestido_plisado_beige, vestido, beige, 2, elegante).
prenda(vestido_cuero_negro, vestido, negro, 3, elegante).
prenda(vestido_coctel_verde, vestido, verde, 3, elegante).
prenda(vestido_playero_blanco, vestido, blanco, 1, casual).
prenda(vestido_midi_rosa, vestido, rosa, 2, casual).
prenda(vestido_sastre_gris, vestido, gris, 3, formal).
prenda(vestido_asimetrico_negro, vestido, negro, 2, elegante).
prenda(vestido_holgado_multicolor, vestido, multicolor, 1, casual).
prenda(vestido_largo_rojo, vestido, rojo, 3, elegante).

% --- CALZADO (31 elementos) ---
prenda(tenis_blancos, calzado, blanco, 1, casual).
prenda(tenis_deportivos, calzado, negro, 2, deportivo).
prenda(zapatos_tacon_negros, calzado, negro, 2, elegante).
prenda(mocasines_beige, calzado, beige, 2, formal).
prenda(botas_altas_negras, calzado, negro, 4, elegante).
prenda(botines_cafes, calzado, cafe, 3, casual).
prenda(sandalias_doradas, calzado, dorado, 1, casual).
prenda(botas_lluvia_amarillas, calzado, amarillo, 3, casual).
prenda(botas_lluvia_negras, calzado, negro, 3, casual).
prenda(zapatillas_rojas, calzado, rojo, 2, elegante).
prenda(zapatos_oxford_negros, calzado, negro, 2, formal).
prenda(sandalias_planas_negras, calzado, negro, 1, casual).
prenda(botas_vaqueras_cafe, calzado, cafe, 3, casual).
prenda(tenis_plataforma_blancos, calzado, blanco, 1, casual).
prenda(zapatos_tacon_nude, calzado, beige, 2, elegante).
prenda(mocasines_negros, calzado, negro, 2, formal).
prenda(botines_cortos_grises, calzado, gris, 2, casual).
prenda(sandalias_tacon_doradas, calzado, dorado, 2, elegante).
prenda(tenis_running_negros, calzado, negro, 2, deportivo).
prenda(botas_nieves_blancas, calzado, blanco, 5, casual).
prenda(zapatos_charol_negros, calzado, negro, 2, formal).
prenda(sandalias_plataforma_beige, calzado, beige, 1, casual).
prenda(botines_piel_negra, calzado, negro, 3, casual).
prenda(zapatos_bajos_azul, calzado, azul, 1, casual).
prenda(tenis_retro_multicolor, calzado, multicolor, 1, casual).
prenda(sandalias_deportivas_negras, calzado, negro, 1, deportivo).
prenda(zapatillas_tacon_rosa, calzado, rosa, 2, elegante).
prenda(botas_militares_negras, calzado, negro, 3, casual).
prenda(mocasines_blancos, calzado, blanco, 2, formal).
prenda(zapatos_salon_rojos, calzado, rojo, 2, elegante).
prenda(sandalias_elegantes_plata, calzado, gris, 1, elegante).

% --- ABRIGOS EXTERNOS (31 elementos) ---
prenda(gabardina_beige, abrigo, beige, 4, formal).
prenda(chamarra_piel_negra, abrigo, negro, 3, casual).
prenda(abrigo_lana_gris, abrigo, gris, 5, elegante).
prenda(chamarra_de_mezclilla, abrigo, azul, 2, casual).
prenda(cardigan_largo_marron, abrigo, cafe, 3, casual).
prenda(impermeable_transparente, abrigo, transparente, 3, casual).
prenda(chamarra_impermeable_azul, abrigo, azul, 4, casual).
prenda(abrigo_largo_negro, abrigo, negro, 5, elegante).
prenda(blazer_oversized_gris, abrigo, gris, 3, formal).
prenda(chamarra_puffer_negra, abrigo, negro, 4, casual).
prenda(chaleco_acolchado_beige, abrigo, beige, 3, casual).
prenda(abrigo_lana_camel, abrigo, camel, 5, elegante).
prenda(chamarra_bomber_verde, abrigo, verde, 3, casual).
prenda(gabardina_negra, abrigo, negro, 4, formal).
prenda(capa_tejida_gris, abrigo, gris, 3, casual).
prenda(blazer_blanco_formal, abrigo, blanco, 3, formal).
prenda(chamarra_cuero_cafe, abrigo, cafe, 3, casual).
prenda(abrigo_rojo_elegante, abrigo, rojo, 5, elegante).
prenda(chaleco_peluche_beige, abrigo, beige, 4, casual).
prenda(chamarra_sport_rosa, abrigo, rosa, 2, deportivo).
prenda(abrigo_cuadros, abrigo, multicolor, 4, casual).
prenda(chamarra_acolchada_rosa, abrigo, rosa, 3, casual).
prenda(blazer_negro_formal, abrigo, negro, 3, formal).
prenda(poncho_tejido, abrigo, multicolor, 3, casual).
prenda(abrigo_beige_largo, abrigo, beige, 5, elegante).
prenda(chamarra_mezclilla_negra, abrigo, negro, 2, casual).
prenda(abrigo_azul_marino, abrigo, azul, 5, formal).
prenda(chaleco_sastre_gris, abrigo, gris, 2, formal).
prenda(impermeable_amarillo, abrigo, amarillo, 3, casual).
prenda(chamarra_rompevientos, abrigo, negro, 2, deportivo).
prenda(abrigo_blanco_elegante, abrigo, blanco, 5, elegante).

% --- ACCESORIOS (31 elementos) ---
prenda(bolso_mano_negro, accesorio, negro, 1, elegante).
prenda(mochila_casual, accesorio, gris, 1, casual).
prenda(bolso_cruzado_cafe, accesorio, cafe, 1, casual).
prenda(bufanda_lana_roja, accesorio, rojo, 4, casual).
prenda(collar_dorado_elegante, accesorio, dorado, 1, elegante).
prenda(cinturon_negro_piel, accesorio, negro, 1, formal).
prenda(gorra_deportiva, accesorio, negro, 1, deportivo).
prenda(paraguas_negro, accesorio, negro, 1, casual).
prenda(paraguas_transparente, accesorio, transparente, 1, elegante).
prenda(lentes_sol_negros, accesorio, negro, 1, casual).
prenda(sombrero_playa_beige, accesorio, beige, 1, casual).
prenda(bufanda_seda_azul, accesorio, azul, 2, elegante).
prenda(aretes_perla, accesorio, blanco, 1, elegante).
prenda(pulsera_plateada, accesorio, gris, 1, elegante).
prenda(cinturon_cafe_delgado, accesorio, cafe, 1, casual).
prenda(mochila_cuero_negra, accesorio, negro, 1, casual).
prenda(bolso_fiesta_dorado, accesorio, dorado, 1, elegante).
prenda(gorro_lana_gris, accesorio, gris, 4, casual).
prenda(guantes_piel_negros, accesorio, negro, 4, formal).
prenda(reloj_dorado, accesorio, dorado, 1, elegante).
prenda(panuelo_cuello, accesorio, multicolor, 1, casual).
prenda(diadema_terciopelo, accesorio, negro, 1, elegante).
prenda(choker_negro, accesorio, negro, 1, casual).
prenda(lentes_sol_cateye, accesorio, negro, 1, casual).
prenda(bolso_shopper_beige, accesorio, beige, 1, casual).
prenda(rinonera_deportiva, accesorio, negro, 1, deportivo).
prenda(sombrilla_blanca, accesorio, blanco, 1, casual).
prenda(bufanda_beige_larga, accesorio, beige, 4, casual).
prenda(cinturon_dorado, accesorio, dorado, 1, elegante).
prenda(bolso_cruzado_rojo, accesorio, rojo, 1, casual).
prenda(gorra_rosa, accesorio, rosa, 1, casual).

% Predicado para acceder a prendas: si el usuario subió prendas dinámicas se usan esas,
% de lo contrario se usan los hechos estáticos base.
obtener_prenda(ID, Tipo, Color, Abrigo, Formalidad) :-
    (   prenda_usuario(_, _, _, _, _, _, _, _)
    ->  prenda_usuario(ID, Tipo, Color, Abrigo, Formalidad, _, _, _)
    ;   prenda(ID, Tipo, Color, Abrigo, Formalidad)
    ).

% --- 2. REGLAS DE CLIMA Y ABRIGO ---
requerimiento_abrigo(Temp, 5) :- Temp < 10.
requerimiento_abrigo(Temp, 4) :- Temp >= 10, Temp < 13.
requerimiento_abrigo(Temp, 3) :- Temp >= 13, Temp < 16.
requerimiento_abrigo(Temp, 2) :- Temp >= 16, Temp < 19.
requerimiento_abrigo(Temp, 1) :- Temp >= 19.

necesita_abrigo_externo(Temp) :- Temp < 16.

% Búsqueda insensible a mayúsculas
sub_atom_icase(AtomOrString, Sub) :-
    (atom(AtomOrString) -> atom_string(AtomOrString, S) ; S = AtomOrString),
    string_lower(S, SLow),
    atom_string(Sub, SubStr),
    string_lower(SubStr, SubLow),
    sub_string(SLow, _, _, _, SubLow).

% Reconocimiento inteligente de prendas de lluvia (inspecciona tanto ID como Nombre de usuario)
es_calzado_lluvia(ID) :-
    prenda_usuario(ID, _, _, _, _, Nombre, _, _), !,
    (   sub_atom_icase(Nombre, lluvia)
    ;   sub_atom_icase(ID, lluvia)
    ).
es_calzado_lluvia(botas_lluvia_amarillas) :- !.
es_calzado_lluvia(botas_lluvia_negras) :- !.
es_calzado_lluvia(ID) :-
    atom(ID),
    sub_atom(ID, _, _, _, lluvia), !.

es_abrigo_lluvia(ID) :-
    prenda_usuario(ID, _, _, _, _, Nombre, _, _), !,
    (   sub_atom_icase(Nombre, impermeable)
    ;   sub_atom_icase(ID, impermeable)
    ).
es_abrigo_lluvia(impermeable_transparente) :- !.
es_abrigo_lluvia(chamarra_impermeable_azul) :- !.
es_abrigo_lluvia(impermeable_amarillo) :- !.
es_abrigo_lluvia(ID) :-
    atom(ID),
    sub_atom(ID, _, _, _, impermeable), !.

es_paraguas(ID) :-
    prenda_usuario(ID, _, _, _, _, Nombre, _, _), !,
    (   sub_atom_icase(Nombre, paraguas)
    ;   sub_atom_icase(Nombre, sombrilla)
    ;   sub_atom_icase(ID, paraguas)
    ;   sub_atom_icase(ID, sombrilla)
    ).
es_paraguas(paraguas_negro) :- !.
es_paraguas(paraguas_transparente) :- !.
es_paraguas(sombrilla_blanca) :- !.
es_paraguas(ID) :-
    atom(ID),
    (sub_atom(ID, _, _, _, paraguas) ; sub_atom(ID, _, _, _, sombrilla)), !.

% --- 3. MÓDULO DE TEORÍA Y ARMONÍA DE COLORES (DETERMINÍSTICO SIN DUPLICADOS) ---
es_neutro(negro).
es_neutro(blanco).
es_neutro(gris).
es_neutro(beige).
es_neutro(marron).
es_neutro(cafe).
es_neutro(crema).
es_neutro(transparente).
es_neutro(camel).
es_neutro(dorado).
es_neutro(plateado).

combina_colores(C1, C2) :- C1 == C2, !.
combina_colores(multicolor, _) :- !.
combina_colores(_, multicolor) :- !.
combina_colores(C1, C2) :- (es_neutro(C1) ; es_neutro(C2)), !.
combina_colores(C1, C2) :- combina_par(C1, C2), !.
combina_colores(C1, C2) :- combina_par(C2, C1), !.

combina_par(azul, rosa).
combina_par(azul, beige).
combina_par(azul, dorado).
combina_par(azul, amarillo).
combina_par(azul, rojo).
combina_par(azul, verde).
combina_par(verde, dorado).
combina_par(verde, beige).
combina_par(verde, amarillo).
combina_par(verde, cafe).
combina_par(rojo, cafe).
combina_par(rojo, rosa).
combina_par(rosa, gris).
combina_par(cafe, beige).
combina_par(cafe, dorado).
combina_par(amarillo, negro).
combina_par(naranja, azul).
combina_par(morado, amarillo).
combina_par(morado, rosa).

armonia_global(ColorSup, ColorInf, ColorCalz, ColorAcc) :-
    combina_colores(ColorSup, ColorInf),
    (   combina_colores(ColorInf, ColorCalz)
    ;   combina_colores(ColorSup, ColorCalz)
    ;   es_neutro(ColorCalz)
    ),
    (   combina_colores(ColorSup, ColorAcc)
    ;   combina_colores(ColorInf, ColorAcc)
    ;   es_neutro(ColorAcc)
    ).

% --- 4. REGLAS DE OCASIÓN Y FORMALIDAD ---
adecuado_para(casual, casual).
adecuado_para(casual, deportivo).
adecuado_para(universidad, casual).
adecuado_para(universidad, deportivo).
adecuado_para(trabajo, formal).
adecuado_para(trabajo, elegante).
adecuado_para(fiesta, elegante).
adecuado_para(fiesta, formal).
adecuado_para(deporte, deportivo).
adecuado_para(deporte, casual).

% --- 5. REGLAS PRINCIPALES DE INFERENCIA ---

% CASO A1: DÍA CON LLUVIA Y CONJUNTO DE DOS PIEZAS
recomendar_outfit(Temperatura, si, Ocasion, Superior, Inferior, Calzado, AbrigoExterno, Accesorio) :-
    requerimiento_abrigo(Temperatura, AbrigoMinimo),
    obtener_prenda(Superior, superior, ColorSup, AbrigoSup, FormSup),
    adecuado_para(Ocasion, FormSup),
    obtener_prenda(Inferior, inferior, ColorInf, AbrigoInf, FormInf),
    adecuado_para(Ocasion, FormInf),
    
    obtener_prenda(Calzado, calzado, ColorCalz, _, _),
    es_calzado_lluvia(Calzado),
    
    obtener_prenda(AbrigoExterno, abrigo, ColorAbrigo, AbrigoExtVal, _),
    es_abrigo_lluvia(AbrigoExterno),
    combina_colores(ColorSup, ColorAbrigo),
    
    obtener_prenda(Accesorio, accesorio, ColorAcc, _, _),
    es_paraguas(Accesorio),
    
    TotalAbrigo is AbrigoSup + AbrigoInf + AbrigoExtVal,
    TotalAbrigo >= AbrigoMinimo,
    armonia_global(ColorSup, ColorInf, ColorCalz, ColorAcc).

% CASO A2: DÍA SIN LLUVIA Y CONJUNTO DE DOS PIEZAS
recomendar_outfit(Temperatura, no, Ocasion, Superior, Inferior, Calzado, AbrigoExterno, Accesorio) :-
    requerimiento_abrigo(Temperatura, AbrigoMinimo),
    obtener_prenda(Superior, superior, ColorSup, AbrigoSup, FormSup),
    adecuado_para(Ocasion, FormSup),
    obtener_prenda(Inferior, inferior, ColorInf, AbrigoInf, FormInf),
    adecuado_para(Ocasion, FormInf),
    
    obtener_prenda(Calzado, calzado, ColorCalz, _, FormCalz),
    \+ es_calzado_lluvia(Calzado),
    adecuado_para(Ocasion, FormCalz),
    
    (   necesita_abrigo_externo(Temperatura)
    ->  obtener_prenda(AbrigoExterno, abrigo, ColorAbrigo, AbrigoExtVal, FormAbrigo),
        \+ es_abrigo_lluvia(AbrigoExterno),
        adecuado_para(Ocasion, FormAbrigo),
        combina_colores(ColorSup, ColorAbrigo),
        TotalAbrigo is AbrigoSup + AbrigoInf + AbrigoExtVal
    ;   AbrigoExterno = ninguno,
        TotalAbrigo is AbrigoSup + AbrigoInf
    ),
    
    TotalAbrigo >= AbrigoMinimo,
    obtener_prenda(Accesorio, accesorio, ColorAcc, _, _),
    \+ es_paraguas(Accesorio),
    armonia_global(ColorSup, ColorInf, ColorCalz, ColorAcc).

% CASO B1: DÍA CON LLUVIA Y VESTIDO
recomendar_outfit(Temperatura, si, Ocasion, Vestido, no_aplica, Calzado, AbrigoExterno, Accesorio) :-
    requerimiento_abrigo(Temperatura, AbrigoMinimo),
    obtener_prenda(Vestido, vestido, ColorVest, AbrigoVest, FormVest),
    adecuado_para(Ocasion, FormVest),
    
    obtener_prenda(Calzado, calzado, ColorCalz, _, _),
    es_calzado_lluvia(Calzado),
    
    obtener_prenda(AbrigoExterno, abrigo, ColorAbrigo, AbrigoExtVal, _),
    es_abrigo_lluvia(AbrigoExterno),
    combina_colores(ColorVest, ColorAbrigo),
    
    obtener_prenda(Accesorio, accesorio, ColorAcc, _, _),
    es_paraguas(Accesorio),
    
    TotalAbrigo is AbrigoVest + AbrigoExtVal,
    TotalAbrigo >= AbrigoMinimo,
    combina_colores(ColorVest, ColorCalz),
    combina_colores(ColorVest, ColorAcc).

% CASO B2: DÍA SIN LLUVIA Y VESTIDO
recomendar_outfit(Temperatura, no, Ocasion, Vestido, no_aplica, Calzado, AbrigoExterno, Accesorio) :-
    requerimiento_abrigo(Temperatura, AbrigoMinimo),
    obtener_prenda(Vestido, vestido, ColorVest, AbrigoVest, FormVest),
    adecuado_para(Ocasion, FormVest),
    
    obtener_prenda(Calzado, calzado, ColorCalz, _, FormCalz),
    \+ es_calzado_lluvia(Calzado),
    adecuado_para(Ocasion, FormCalz),
    
    (   necesita_abrigo_externo(Temperatura)
    ->  obtener_prenda(AbrigoExterno, abrigo, ColorAbrigo, AbrigoExtVal, FormAbrigo),
        \+ es_abrigo_lluvia(AbrigoExterno),
        adecuado_para(Ocasion, FormAbrigo),
        combina_colores(ColorVest, ColorAbrigo),
        TotalAbrigo is AbrigoVest + AbrigoExtVal
    ;   AbrigoExterno = ninguno,
        TotalAbrigo is AbrigoVest
    ),
    
    TotalAbrigo >= AbrigoMinimo,
    obtener_prenda(Accesorio, accesorio, ColorAcc, _, _),
    \+ es_paraguas(Accesorio),
    combina_colores(ColorVest, ColorCalz),
    combina_colores(ColorVest, ColorAcc).

% =========================================================================
% 6. ALGORITMO DE SELECCIÓN DIVERSA: CAMBIANDO TODO (SUPERIOR, INFERIOR...)
% =========================================================================

% Medir penalización por repetición de prendas entre dos conjuntos
penalizacion_par(outfit(S1, I1, C1, Ab1, Ac1), outfit(S2, I2, C2, Ab2, Ac2), P) :-
    (S1 \== no_aplica, S1 == S2 -> P1 = 7 ; P1 = 0),
    (I1 \== no_aplica, I1 == I2 -> P2 = 7 ; P2 = 0),
    % Gran penalización si la combinación base (superior + inferior) es idéntica
    (S1 \== no_aplica, S1 == S2, I1 \== no_aplica, I1 == I2 -> P_base = 20 ; P_base = 0),
    (C1 == C2 -> P3 = 4 ; P3 = 0),
    (Ab1 \== ninguno, Ab1 == Ab2 -> P4 = 2 ; P4 = 0),
    (Ac1 \== ninguno, Ac1 == Ac2 -> P5 = 2 ; P5 = 0),
    P is P1 + P2 + P_base + P3 + P4 + P5.

penalizacion_total(_, [], 0).
penalizacion_total(O, [H|T], Total) :-
    penalizacion_par(O, H, P1),
    penalizacion_total(O, T, P2),
    Total is P1 + P2.

seleccionar_siguiente(Candidatos, Seleccionados, Mejor) :-
    findall(P-C, (member(C, Candidatos), penalizacion_total(C, Seleccionados, P)), Pares),
    keysort(Pares, [_-Mejor | _]).

diversificar([], _, _, []).
diversificar(_, _, 0, []) :- !.
diversificar(Candidatos, Seleccionados, N, [Elegido | Resto]) :-
    seleccionar_siguiente(Candidatos, Seleccionados, Elegido),
    delete(Candidatos, Elegido, NuevosCandidatos),
    N1 is N - 1,
    diversificar(NuevosCandidatos, [Elegido | Seleccionados], N1, Resto).

% Predicado principal: devuelve una lista con hasta Max combinaciones diversas
% garantizando que cambian las prendas superiores, inferiores, calzado y accesorios.
recomendar_outfits_diversos(Temp, Lluvia, Ocasion, Max, Outfits) :-
    findall(outfit(S,I,C,Ab,Ac), recomendar_outfit(Temp, Lluvia, Ocasion, S, I, C, Ab, Ac), Todos),
    (   Todos \== []
    ->  list_to_set(Todos, Unicos),
        diversificar(Unicos, [], Max, Outfits)
    ;   % Respaldo flexible: si no hay con lluvia estricta o combinaciones exactas, buscar combinaciones compatibles
        findall(outfit(S2,I2,C2,Ab2,Ac2), recomendar_outfit_flexible(Temp, Lluvia, Ocasion, S2, I2, C2, Ab2, Ac2), Fallback),
        (   Fallback \== []
        ->  list_to_set(Fallback, UnicosFallback),
            diversificar(UnicosFallback, [], Max, Outfits)
        ;   Outfits = []
        )
    ).

% Reglas flexibles de recomendación cuando el guardarropa tiene pocas prendas o filtros estrictos
recomendar_outfit_flexible(Temperatura, si, Ocasion, Superior, Inferior, Calzado, AbrigoExterno, Accesorio) :-
    obtener_prenda(Superior, superior, ColorSup, AbrigoSup, FormSup),
    adecuado_para(Ocasion, FormSup),
    obtener_prenda(Inferior, inferior, ColorInf, AbrigoInf, FormInf),
    adecuado_para(Ocasion, FormInf),
    obtener_prenda(Calzado, calzado, ColorCalz, _, _),
    (   obtener_prenda(AbrigoExterno, abrigo, _, AbrigoExtVal, _)
    ;   AbrigoExterno = ninguno, AbrigoExtVal = 0
    ),
    (   obtener_prenda(Accesorio, accesorio, ColorAcc, _, _)
    ;   Accesorio = ninguno, ColorAcc = negro
    ),
    TotalAbrigo is AbrigoSup + AbrigoInf + AbrigoExtVal,
    requerimiento_abrigo(Temperatura, AbrigoMin),
    TotalAbrigo >= AbrigoMin - 2,
    armonia_global(ColorSup, ColorInf, ColorCalz, ColorAcc).

recomendar_outfit_flexible(Temperatura, no, _Ocasion, Superior, Inferior, Calzado, AbrigoExterno, Accesorio) :-
    obtener_prenda(Superior, superior, ColorSup, _, _),
    obtener_prenda(Inferior, inferior, ColorInf, _, _),
    obtener_prenda(Calzado, calzado, ColorCalz, _, _),
    (   necesita_abrigo_externo(Temperatura), obtener_prenda(AbrigoExterno, abrigo, _, _, _)
    ;   AbrigoExterno = ninguno
    ),
    (   obtener_prenda(Accesorio, accesorio, ColorAcc, _, _), \+ es_paraguas(Accesorio)
    ;   Accesorio = ninguno, ColorAcc = negro
    ),
    armonia_global(ColorSup, ColorInf, ColorCalz, ColorAcc).

recomendar_outfit_flexible(Temperatura, _, _Ocasion, Vestido, no_aplica, Calzado, AbrigoExterno, Accesorio) :-
    obtener_prenda(Vestido, vestido, ColorVest, _, _),
    obtener_prenda(Calzado, calzado, ColorCalz, _, _),
    (   necesita_abrigo_externo(Temperatura), obtener_prenda(AbrigoExterno, abrigo, _, _, _)
    ;   AbrigoExterno = ninguno
    ),
    (   obtener_prenda(Accesorio, accesorio, ColorAcc, _, _)
    ;   Accesorio = ninguno, ColorAcc = negro
    ),
    combina_colores(ColorVest, ColorCalz),
    combina_colores(ColorVest, ColorAcc).

% Generador interactivo de backtracking (útil para la consola de SWI-Prolog al pulsar ';')
recomendar_outfit_cambiando_todo(Temp, Lluvia, Ocasion, Sup, Inf, Calz, Abr, Acc) :-
    recomendar_outfits_diversos(Temp, Lluvia, Ocasion, 25, Outfits),
    member(outfit(Sup, Inf, Calz, Abr, Acc), Outfits).
