<<<<<<< HEAD
CLOSET AURA — Guardarropa Inteligente & Asistente de Outfits
Asignatura: Paradigmas de Programación - ESCOM IPN

=========================================================================
DESCRIPCIÓN GENERAL
=========================================================================
Closet Aura es una aplicación web y sistema experto basado en lógica
(SWI-Prolog) que permite a las personas:
1. Subir y organizar su ropa (con subida de fotos desde su dispositivo o URLs,
   categoría, color, nivel térmico 1-5 y estilo).
2. Eliminar prendas fácilmente de su guardarropa.
3. Consultar el clima en tiempo real mediante una API meteorológica (Open-Meteo)
   por geolocalización GPS o búsqueda de cualquier ciudad.
4. Generar múltiples combinaciones de outfits según el clima y ocasión,
   garantizando que cambian las prendas principales (superior, inferior,
   vestido, calzado y accesorios) y no solo los accesorios.
5. Ver todas las opciones generadas en una cuadrícula o cambiar entre ellas
   por pestañas, además de poder guardar looks favoritos.

=========================================================================
ARCHIVOS DEL PROYECTO
=========================================================================
- server.pl: Servidor HTTP en SWI-Prolog con endpoints REST JSON:
    * GET  /api/salud: Estado del servidor.
    * GET  /api/opciones: Catálogos válidos.
    * POST /api/recomendar: Motor de inferencia Prolog que recibe clima,
           ocasión y la lista de prendas del clóset del usuario.
- outfit.pl: Base de conocimiento y reglas de inferencia con el algoritmo
  de selección diversa (penalización de solapamiento) y generador
  interactivo para backtracking.
- closet.pl: Versión ampliada de la base de conocimiento con más de 180 prendas
  (más de 30 por categoría).
- config.pl: Configuración de rangos válidos (temperatura, lluvia, ocasiones).
- version-static/index.html: Estructura de la interfaz web (Dashboard, Mi Clóset,
  Crear Conjunto, Widget de Clima, Modal de Subida de Fotos).
- version-static/styles.css: Diseño responsivo, elegante y adaptable.
- version-static/app.js: Conexión con la API meteorológica (Open-Meteo),
  gestión de prendas (subida con FileReader a base64, eliminación),
  comunicación con SWI-Prolog y motor de respaldo local.

=========================================================================
CÓMO EJECUTAR EL PROYECTO
=========================================================================

OPCIÓN A: CON SERVIDOR SWI-PROLOG (Recomendada para la evaluación)
1. Abre una terminal en la carpeta del proyecto.
2. Ejecuta el servidor Prolog con:
     swipl server.pl
3. Abre tu navegador en:
     http://localhost:8080
4. Verás el indicador "● Prolog Conectado" en la esquina superior derecha.

OPCIÓN B: MODO ESTÁTICO DIRECTO (Sin terminal)
1. Abre el archivo version-static/index.html en cualquier navegador.
2. Funciona de manera independiente con un motor de inferencia local en
   JavaScript que replica las mismas reglas de diversidad y lógica de Prolog.
3. La API del clima en vivo funciona directamente desde el navegador.

=========================================================================
PREDICADOS DISPONIBLES EN PROLOG (outfit.pl / closet.pl)
=========================================================================
Para probar desde la consola interactiva de SWI-Prolog:

1. Generar 5 outfits diversos cambiando todo:
   ?- recomendar_outfits_diversos(20, no, casual, 5, Outfits).

2. Generador interactivo con backtracking (al pulsar ';', cada solución
   cambia de prenda superior, inferior, calzado y accesorios):
   ?- recomendar_outfit_cambiando_todo(20, no, casual, Sup, Inf, Calz, Abr, Acc).

3. Consulta estándar:
   ?- recomendar_outfit(18, no, trabajo, Sup, Inf, Calz, Abr, Acc).
=======
CLOSET AURA — guardarropa inteligente

ARCHIVOS
- index.html: estructura de las pantallas.
- styles.css: diseño adaptable.
- app.js: interacciones, datos de demostración y recomendaciones prototipo.

CÓMO PROBAR
1. Descomprime la carpeta.
2. Abre index.html en un navegador moderno.
3. Crea una cuenta con correo y contraseña.
4. Entra a Mi guardarropa para agregar o quitar prendas.
5. En Crear conjunto, selecciona temperatura, lluvia y ocasión.
6. Guarda conjuntos favoritos; los datos se almacenan en localStorage del navegador.

IMPORTANTE SOBRE PROLOG
Esta versión es una interfaz funcional de demostración. Para facilitar la prueba, las reglas de recomendación están aproximadas en JavaScript a partir de las reglas y prendas del archivo Prolog recibido. No ejecuta todavía el archivo .pl directamente. La contraseña se almacena localmente y sin cifrado: no usar con datos reales.

Para conectar la lógica original de SWI-Prolog, se debe crear un servidor HTTP en Prolog que reciba temperatura, lluvia y ocasión, ejecute recomendar_outfit/8 y devuelva las recomendaciones en JSON. Después, app.js se modifica para llamar a ese endpoint con fetch(). También se requiere una API meteorológica y ubicación/permisos si se desea obtener el clima automáticamente; en esta demo la temperatura y lluvia se ingresan manualmente.

NOTA SOBRE LOS HECHOS
La lista de ejemplo se basa en las prendas que aparecen en el código Prolog. Se incluyeron las prendas más representativas para que el prototipo sea manejable y editable desde la página. La base inicial se crea por usuario en el navegador; al registrar una cuenta nueva, se muestra el guardarropa de demostración.

DISEÑO ACTUALIZADO
La interfaz ahora usa tonos pastel lavanda y azul cielo, banners fotográficos, una franja de inspiración y fotos de prendas por categoría. Las imágenes de ejemplo se cargan desde Unsplash y requieren conexión a internet. En el formulario de agregar prenda puedes incluir una URL directa de imagen.
>>>>>>> 22ab16d6f04a8c03ab2a540954fd331b43b2e613
