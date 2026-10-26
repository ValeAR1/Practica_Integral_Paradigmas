% =========================================================================
% SISTEMA EXPERTO: Asistente de Outfit Inteligente (Moda Femenina y Clima)
% Asignatura: Paradigmas de Programación - ESCOM IPN[span_4](start_span)[span_4](end_span)[span_5](start_span)[span_5](end_span)
% =========================================================================

% --- 1. HECHOS: GUARDARROPA Y ATRIBUTOS (Más de 40 hechos) ---
% Formato: prenda(ID, Tipo, Color, NivelAbrigo[1-5], Formalidad).

% Partes superiores
prenda(blusa_seda_blanca, superior, blanco, 2, elegante).
prenda(camisa_oxford_azul, superior, azul, 2, formal).
prenda(top_negro_basico, superior, negro, 1, casual).
prenda(sueter_oversized_beige, superior, beige, 4, casual).
prenda(cardigan_gris, superior, gris, 3, casual).
prenda(hoodie_rosa, superior, rosa, 3, deportivo).
prenda(body_negro_elegante, superior, negro, 2, elegante).
prenda(top_verde_esmeralda, superior, verde, 2, elegante).
prenda(blusa_estampada_floral, superior, multicolor, 2, casual).

% Partes inferiores
prenda(jeans_skinny_azul, inferior, azul, 2, casual).
prenda(jeans_mom_negros, inferior, negro, 2, casual).
prenda(pantalon_vestir_beige, inferior, beige, 3, formal).
prenda(pantalon_sastre_negro, inferior, negro, 3, formal).
prenda(falda_midi_plisada, inferior, verde, 2, elegante).
prenda(minifalda_cuadros, inferior, rojo, 2, casual).
prenda(leggings_deportivos_negros, inferior, negro, 2, deportivo).
prenda(short_denim, inferior, azul, 1, casual).

% Vestidos y enterizos
prenda(vestido_midi_negro, vestido, negro, 2, elegante).
prenda(vestido_floral_verano, vestido, multicolor, 1, casual).
prenda(vestido_coctel_rojo, vestido, rojo, 3, elegante).

% Calzado
prenda(tenis_blancos, calzado, blanco, 1, casual).
prenda(tenis_deportivos, calzado, negro, 2, deportivo).
prenda(zapatos_tacon_negros, calzado, negro, 2, elegante).
prenda(mocasines_beige, calzado, beige, 2, formal).
prenda(botas_altas_negras, calzado, negro, 4, elegante).
prenda(botines_cafes, calzado, cafe, 3, casual).
prenda(sandalias_doradas, calzado, dorado, 1, casual).
prenda(botas_lluvia_amarillas, calzado, amarillo, 3, casual).
prenda(botas_lluvia_negras, calzado, negro, 3, casual).

% Abrigos externos
prenda(gabardina_beige, abrigo, beige, 4, formal).
prenda(chamarra_piel_negra, abrigo, negro, 3, casual).
prenda(abrigo_lana_gris, abrigo, gris, 5, elegante).
prenda(chamarra_de_mezclilla, abrigo, azul, 2, casual).
prenda(cardigan_largo_marron, abrigo, cafe, 3, casual).
prenda(impermeable_transparente, abrigo, transparente, 3, casual).
prenda(chamarra_impermeable_azul, abrigo, azul, 4, casual).

% Accesorios
prenda(bolso_mano_negro, accesorio, negro, 1, elegante).
prenda(mochila_casual, accesorio, gris, 1, casual).
prenda(bolso_cruzado_cafe, accesorio, cafe, 1, casual).
prenda(bufanda_lana_roja, accesorio, rojo, 4, casual).
prenda(collar_dorado_elegante, accesorio, dorado, 1, elegante).
prenda(cinturon_negro_piel, accesorio, negro, 1, formal).
prenda(gorra_deportiva, accesorio, negro, 1, deportivo).
prenda(paraguas_negro, accesorio, negro, 1, casual).
prenda(paraguas_transparente, accesorio, transparente, 1, elegante).


% --- 2. REGLAS DE CLIMA Y ABRIGO (Rangos con diferencia de 3 grados) ---
requerimiento_abrigo(Temp, 5) :- Temp < 10.
requerimiento_abrigo(Temp, 4) :- Temp >= 10, Temp < 13.
requerimiento_abrigo(Temp, 3) :- Temp >= 13, Temp < 16.
requerimiento_abrigo(Temp, 2) :- Temp >= 16, Temp < 19.
requerimiento_abrigo(Temp, 1) :- Temp >= 19.  % Soporta 25°C y más de forma óptima

necesita_abrigo_externo(Temp) :- Temp < 16.


% --- 3. MÓDULO DE TEORÍA Y ARMONÍA DE COLORES ---
es_neutro(negro).
es_neutro(blanco).
es_neutro(gris).
es_neutro(beige).
es_neutro(marron).
es_neutro(crema).
es_neutro(transparente).

combina_colores(C1, C2) :- C1 == C2.
combina_colores(C1, C2) :- es_neutro(C1) ; es_neutro(C2).
combina_colores(C1, C2) :- combina_par(C1, C2).
combina_colores(C1, C2) :- combina_par(C2, C1).

combina_colores(multicolor, C2) :- es_neutro(C2).
combina_colores(C1, multicolor) :- es_neutro(C1).

combina_par(azul, rosa).
combina_par(azul, beige).
combina_par(azul, dorado).
combina_par(verde, dorado).
combina_par(verde, beige).
combina_par(rojo, cafe).
combina_par(rosa, gris).
combina_par(cafe, beige).
combina_par(cafe, dorado).
combina_par(amarillo, negro).

armonia_global(ColorSup, ColorInf, ColorCalz, ColorAcc) :-
    combina_colores(ColorSup, ColorInf),
    combina_colores(ColorSup, ColorCalz),
    combina_colores(ColorInf, ColorCalz),
    combina_colores(ColorSup, ColorAcc).


% --- 4. REGLAS DE OCASIÓN Y FORMALIDAD ---
adecuado_para(casual, casual).
adecuado_para(trabajo, formal).
adecuado_para(trabajo, elegante).
adecuado_para(fiesta, elegante).
adecuado_para(fiesta, formal).
adecuado_para(deporte, deportivo).
adecuado_para(universidad, casual).


% --- 5. REGLAS PRINCIPALES DE INFERENCIA (Con Backtracking Total) ---

% -------------------------------------------------------------------------
% CASO A1: DÍA CON LLUVIA Y CONJUNTO DE DOS PIEZAS
% -------------------------------------------------------------------------
recomendar_outfit(Temperatura, si, Ocasion, Superior, Inferior, Calzado, AbrigoExterno, Accesorio) :-
    requerimiento_abrigo(Temperatura, AbrigoMinimo),
    prenda(Superior, superior, ColorSup, AbrigoSup, FormSup),
    prenda(Inferior, inferior, ColorInf, AbrigoInf, FormInf),
    
    prenda(Calzado, calzado, ColorCalz, _, FormCalz),
    (Calzado = botas_lluvia_amarillas ; Calzado = botas_lluvia_negras),
    
    prenda(AbrigoExterno, abrigo, ColorAbrigo, AbrigoExtVal, FormAbrigo),
    (AbrigoExterno = impermeable_transparente ; AbrigoExterno = chamarra_impermeable_azul),
    AbrigoExtVal >= AbrigoMinimo,
    adecuado_para(Ocasion, FormAbrigo),
    combina_colores(ColorSup, ColorAbrigo),
    
    prenda(Accesorio, accesorio, ColorAcc, _, _),
    (Accesorio = paraguas_negro ; Accesorio = paraguas_transparente),
    
    TotalAbrigo is AbrigoSup + AbrigoInf,
    TotalAbrigo >= AbrigoMinimo,
    adecuado_para(Ocasion, FormSup),
    adecuado_para(Ocasion, FormInf),
    adecuado_para(Ocasion, FormCalz),
    armonia_global(ColorSup, ColorInf, ColorCalz, ColorAcc).


% -------------------------------------------------------------------------
% CASO A2: DÍA SIN LLUVIA Y CONJUNTO DE DOS PIEZAS (Soporta hasta 25°C y más)
% -------------------------------------------------------------------------
recomendar_outfit(Temperatura, no, Ocasion, Superior, Inferior, Calzado, AbrigoExterno, Accesorio) :-
    requerimiento_abrigo(Temperatura, AbrigoMinimo),
    prenda(Superior, superior, ColorSup, AbrigoSup, FormSup),
    prenda(Inferior, inferior, ColorInf, AbrigoInf, FormInf),
    
    prenda(Calzado, calzado, ColorCalz, _, FormCalz),
    Calzado \= botas_lluvia_amarillas,
    Calzado \= botas_lluvia_negras,
    
    (   necesita_abrigo_externo(Temperatura)
    ->  prenda(AbrigoExterno, abrigo, ColorAbrigo, AbrigoExtVal, FormAbrigo),
        AbrigoExterno \= impermeable_transparente,
        AbrigoExterno \= chamarra_impermeable_azul,
        AbrigoExtVal >= AbrigoMinimo,
        adecuado_para(Ocasion, FormAbrigo),
        combina_colores(ColorSup, ColorAbrigo)
    ;   AbrigoExterno = ninguno
    ),
    
    prenda(Accesorio, accesorio, ColorAcc, _, _),
    Accesorio \= paraguas_negro,
    Accesorio \= paraguas_transparente,
    
    TotalAbrigo is AbrigoSup + AbrigoInf,
    TotalAbrigo >= AbrigoMinimo,
    adecuado_para(Ocasion, FormSup),
    adecuado_para(Ocasion, FormInf),
    adecuado_para(Ocasion, FormCalz),
    armonia_global(ColorSup, ColorInf, ColorCalz, ColorAcc).


% -------------------------------------------------------------------------
% CASO B1: DÍA CON LLUVIA Y VESTIDO
% -------------------------------------------------------------------------
recomendar_outfit(Temperatura, si, Ocasion, Vestido, no_aplica, Calzado, AbrigoExterno, Accesorio) :-
    requerimiento_abrigo(Temperatura, AbrigoMinimo),
    prenda(Vestido, vestido, ColorVest, AbrigoVest, FormVest),
    
    prenda(Calzado, calzado, ColorCalz, _, FormCalz),
    (Calzado = botas_lluvia_amarillas ; Calzado = botas_lluvia_negras),
    
    prenda(AbrigoExterno, abrigo, ColorAbrigo, AbrigoExtVal, FormAbrigo),
    (AbrigoExterno = impermeable_transparente ; AbrigoExterno = chamarra_impermeable_azul),
    AbrigoExtVal >= AbrigoMinimo,
    adecuado_para(Ocasion, FormAbrigo),
    combina_colores(ColorVest, ColorAbrigo),
    
    prenda(Accesorio, accesorio, ColorAcc, _, _),
    (Accesorio = paraguas_negro ; Accesorio = paraguas_transparente),
    
    AbrigoVest >= AbrigoMinimo,
    adecuado_para(Ocasion, FormVest),
    adecuado_para(Ocasion, FormCalz),
    combina_colores(ColorVest, ColorCalz),
    combina_colores(ColorVest, ColorAcc).


% -------------------------------------------------------------------------
% CASO B2: DÍA SIN LLUVIA Y VESTIDO (Soporta hasta 25°C y más)
% -------------------------------------------------------------------------
recomendar_outfit(Temperatura, no, Ocasion, Vestido, no_aplica, Calzado, AbrigoExterno, Accesorio) :-
    requerimiento_abrigo(Temperatura, AbrigoMinimo),
    prenda(Vestido, vestido, ColorVest, AbrigoVest, FormVest),
    
    prenda(Calzado, calzado, ColorCalz, _, FormCalz),
    Calzado \= botas_lluvia_amarillas,
    Calzado \= botas_lluvia_negras,
    
    (   necesita_abrigo_externo(Temperatura)
    ->  prenda(AbrigoExterno, abrigo, ColorAbrigo, AbrigoExtVal, FormAbrigo),
        AbrigoExterno \= impermeable_transparente,
        AbrigoExterno \= chamarra_impermeable_azul,
        AbrigoExtVal >= AbrigoMinimo,
        adecuado_para(Ocasion, FormAbrigo),
        combina_colores(ColorVest, ColorAbrigo)
    ;   AbrigoExterno = ninguno
    ),
    
    prenda(Accesorio, accesorio, ColorAcc, _, _),
    Accesorio \= paraguas_negro,
    Accesorio \= paraguas_transparente,
    
    AbrigoVest >= AbrigoMinimo,
    adecuado_para(Ocasion, FormVest),
    adecuado_para(Ocasion, FormCalz),
    combina_colores(ColorVest, ColorCalz),
    combina_colores(ColorVest, ColorAcc).