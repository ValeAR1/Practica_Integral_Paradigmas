# Closet Aura — Guardarropa Inteligente & Asistente de Outfits
**Práctica Integral de Paradigmas de Programación — ESCOM IPN**

Sistema experto y aplicación web para la recomendación inteligente de conjuntos de ropa basados en el clima en tiempo real y la ocasión de uso, desarrollado con **SWI-Prolog**, **JavaScript (ES6+)**, **HTML5** y **CSS3**.

---

## 🌟 Características Principales

1. **API de Clima en Tiempo Real (Open-Meteo)**:
   - Detección automática de clima mediante geolocalización GPS.
   - Búsqueda de cualquier ciudad del mundo (CDMX, Guadalajara, Madrid, Monterrey, etc.).
   - Sincronización automática de temperatura y detección de lluvia con el recomendador de ropa.

2. **Gestión Completa de Prendas (Subir y Eliminar)**:
   - **Subida de fotos**: Selección directa de imágenes desde la computadora o celular (con previsualización instantánea) o enlace URL.
   - Atributos completos: Categoría (superior, inferior, vestido, calzado, abrigo, accesorio), color, nivel térmico (1 a 5), estilo y emoji.
   - **Eliminación de prendas**: Botón visible para borrar prendas del clóset personal.
   - **Sincronización con Prolog**: Las prendas agregadas o eliminadas por el usuario se transmiten al motor de inferencia Prolog para generar los looks con la ropa real del usuario.

3. **Múltiples Combinaciones Generadas**:
   - Muestra todas las opciones válidas generadas (no solo una).
   - Vista en cuadrícula o por pestañas para comparar ("Look 1", "Look 2", "Look 3", etc.).
   - Posibilidad de guardar looks individuales en una lista de favoritos.

4. **Motor de Inferencia con Diversidad en SWI-Prolog**:
   - Algoritmo de penalización por solapamiento: cada outfit generado prioriza prendas superiores, inferiores, vestidos y calzado diferentes.
   - **"Cambiando todo no solo los accesorios"**: Cada combinación varía la ropa base en lugar de limitarse a cambiar bolsos o collares.
   - Reglas de armonía cromática, abrigo térmico y lluvia determinísticas (sin duplicados infinitos).

---

## 🚀 Cómo Ejecutar

### Opción 1: Con Servidor SWI-Prolog (Recomendado)
Requiere tener instalado [SWI-Prolog](https://www.swi-prolog.org/).

1. Abre una terminal en esta carpeta.
2. Inicia el servidor Prolog:
   ```bash
   swipl server.pl
   ```
3. Abre tu navegador web en:
   ```
   http://localhost:8080
   ```
4. En la interfaz verás el indicador **`● Prolog Conectado`**.

### Opción 2: Modo Directo en Navegador (Respaldo)
1. Haz doble clic en `version-static/index.html` para abrirlo en cualquier navegador moderno.
2. El sistema incluye un motor local de respaldo en JavaScript con las mismas reglas de diversidad para pruebas inmediatas sin necesidad de terminal.

---

## 🧠 Consultas Interactivas en Prolog

Si deseas probar la base de conocimientos directamente desde la consola interactiva de Prolog:

```prolog
% Cargar la base de conocimiento
?- [outfit].   % o ?- [closet].

% 1. Obtener una lista con 5 combinaciones completamente diversas:
?- recomendar_outfits_diversos(20, no, casual, 5, Outfits).

% 2. Generador interactivo con backtracking (pulsa ';' para ver cómo cambia todo el conjunto):
?- recomendar_outfit_cambiando_todo(20, no, casual, Sup, Inf, Calz, Abr, Acc).

% 3. Consulta estándar:
?- recomendar_outfit(18, no, trabajo, Sup, Inf, Calz, Abr, Acc).
```
