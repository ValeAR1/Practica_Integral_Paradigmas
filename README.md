# Closet Aura

Práctica integradora de Paradigmas de Programación, ESCOM IPN.

Closet Aura combina SWI-Prolog con una interfaz web para guardar prendas por cuenta y recomendar conjuntos según temperatura, lluvia y ocasión.

## Funciones

- Registro e inicio de sesión. El servidor verifica las contraseñas con HMAC-SHA256 y `CLOSET_SECRETO`.
- Guardarropa por cuenta: agregar, editar y eliminar prendas. Las cuentas nuevas empiezan vacías.
- Recomendaciones de varias combinaciones generadas por el motor Prolog.
- Consulta opcional del clima mediante Open-Meteo, por ciudad o ubicación; también se pueden capturar temperatura y lluvia manualmente.
- Los favoritos, fotos e iconos se guardan en el navegador. Las cuentas y datos principales de prendas se guardan en `usuarios_data.pl`, excluido de Git.

## Ejecución local

Desde la carpeta del proyecto, inicia PowerShell y configura una llave local antes de iniciar SWI-Prolog:

```powershell
$env:CLOSET_SECRETO = "una-clave-local-larga"
swipl server.pl
```

Abre <http://localhost:8080/>. Conserva la misma llave al reiniciar el servidor para poder verificar las cuentas existentes. No guardes la llave ni `usuarios_data.pl` en Git.

## Prueba del recomendador

La consulta manual está en `test_req.pl`. Para ejecutarla:

```bash
swipl -q -s test_req.pl
```

También se puede probar la aplicación creando una cuenta, agregando prendas de varias categorías y solicitando recomendaciones para clima seco y lluvioso.

## Archivos principales

- `server.pl`: servidor HTTP, sesiones, guardarropa y API de recomendaciones.
- `usuarios.pl`: cuentas, prendas por usuario y persistencia local.
- `outfit.pl`, `closet.pl`, `config.pl`: hechos, reglas y parámetros del sistema experto.
- `version-static/`: interfaz web y estilos.
