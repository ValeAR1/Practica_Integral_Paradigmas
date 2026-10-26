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
