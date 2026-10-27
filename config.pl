% config.pl
% Valores permitidos que acepta el servidor HTTP para Closet Aura.
% Paradigmas de Programación - ESCOM IPN

% Rango de temperatura (grados Celsius)
temperatura_rango(-20, 55).

% Valores permitidos para lluvia
lluvias_permitidas([si, no]).

% Ocasiones reconocidas por las reglas de Prolog
ocasiones_permitidas([casual, universidad, trabajo, fiesta, deporte]).

% Categorias, colores y formalidades permitidas
tipos_prenda_permitidos([superior, inferior, vestido, calzado, abrigo, accesorio]).
colores_permitidos([negro, blanco, gris, beige, cafe, azul, rojo, rosa, verde, amarillo, dorado, plateado, naranja, morado, multicolor, transparente, camel, marron, crema]).
formalidades_permitidas([casual, formal, elegante, deportivo]).
