# Reto QA Backend - Usuarios ServeRest

Suite de Karate DSL para los cinco endpoints de Usuarios del reto: 11 escenarios de diseño y 19 ejemplos positivos y negativos. Cada ejemplo utiliza datos propios y la ejecución es secuencial.

## Requisitos y ejecución

JDK 17, Maven 3.9 o superior y acceso a `https://serverest.dev`. Verificar que Maven use el JDK correcto:

```sh
java -version
javac -version
mvn -version
```

Desde la raíz del proyecto:

```sh
mvn test-compile
mvn test "-DdryRun=true"
mvn test
```

`test-compile` compila el runner. `dryRun` comprueba los pasos de los 19 ejemplos sin peticiones a ServeRest. Maven también ejecuta la comprobación local del hook de limpieza. `mvn test` ejecuta la suite real.

En Windows, configurar `JAVA_HOME` hacia JDK 17 y agregar los directorios `bin` de Java y Maven al `PATH`. Abrir una terminal nueva después del cambio.

Para seleccionar casos o cambiar de ambiente:

```sh
mvn test "-Dtags=@smoke"
mvn test "-Dtags=@BE-S06"
mvn test "-DbaseUrl=http://localhost:3000"
```

Las comillas permiten usar estas propiedades en PowerShell. Los tags `BE-S` seleccionan escenarios de diseño; los IDs `BE-EX` identifican los ejemplos en el reporte. La propiedad opcional `proxyUri` permite configurar un proxy cuando la red lo requiere. Se mantiene la validación TLS.

## Estructura

```text
src/test/
  java/
    usuarios/UsuariosTest.java       Runner de la suite funcional
    helpers/                        Hook y comprobación de limpieza
  resources/
    features/usuarios/              Un feature por operación
    schemas/                        Contratos JSON de las respuestas
    requests/usuarios/              Body base para registro y actualización
    helpers/                        Datos UUID, preparación y limpieza
    validation/                     Comprobación local, sin HTTP
    karate-config.js                URL y configuración común
.github/workflows/                  Ejecución manual y reportes
```

Se mantiene la distribución estándar de Maven para separar Java de los recursos. Las tablas pequeñas permanecen junto a sus escenarios.

## Cobertura

| Operación | Validaciones |
| --- | --- |
| GET `/usuarios` | Lista completa, filtro por email propio y resultado vacío |
| POST `/usuarios` | Administrador y no administrador, duplicado, campos obligatorios y formatos inválidos |
| GET `/usuarios/{_id}` | Usuario propio e ID inexistente |
| PUT `/usuarios/{_id}` | Cambios persistidos, email duplicado y rechazo sin modificar datos originales |
| DELETE `/usuarios/{_id}` | Eliminación, ausencia posterior e ID inexistente |

Los mensajes y campos se mantienen en portugués según el contrato. `administrador` es una cadena `"true"` o `"false"`. GET de un ID inexistente devuelve 400; DELETE devuelve 200. PUT de un ID ausente puede crear, por eso las actualizaciones preparan un usuario existente. Estos endpoints no requieren token.

El helper reemplaza el email de `requests/usuarios/create.json` por uno con UUID antes de enviar el body. Se guardan los IDs antes de las aserciones y se intenta limpiar cada usuario al terminar, incluso ante fallos. El runner también falla si la limpieza informa errores. Una pérdida de conexión antes de recibir el ID puede dejar un registro sin identificar.

## Reportes

### Panel lateral de VS Code

Instalar la extensión **Karate Runner** (`kirkslota.karate-runner`). En la barra lateral, abrir su icono y desplegar **Reports**. Al seleccionar `karate-summary.html` se abre el reporte en la aplicación predeterminada para HTML. La vista de árbol permite distinguir las carpetas con fecha de cada ejecución.

La configuración local de `.vscode/settings.json` detecta los reportes de `target` y las evidencias guardadas, y evita que la extensión limpie los reportes antes de ejecutar. Si el icono no aparece después de instalar, usar **Ctrl + Shift + P → Developer: Reload Window**. Para actualizar la lista, usar el botón de refrescar de **Reports**. Esta configuración del editor está excluida de Git.

### Reportes de ejecución

Cada ejecución conserva su reporte nativo en `target/karate-reports/AAAA-MM-DD_HH-mm-ss-SSS_real/karate-summary.html`, con fecha y hora de Lima. El dry run utiliza el sufijo `_dryrun`. Las carpetas anteriores se conservan al ejecutar `mvn test`; `mvn clean` elimina `target`.

Al terminar se abre el reporte en el navegador local cuando el equipo dispone de escritorio y navegador, incluso si hay casos fallidos. Se puede desactivar con `mvn test "-DopenReport=false"`; en CI no se abre navegador. `target/karate-reports/karate-summary.html` dirige al reporte más reciente y también se puede abrir manualmente.

El resumen de Karate muestra los features y sus estados. Al abrir un feature aparecen los nombres e IDs de cada caso, su estado, duración y pasos. Al desplegar la petición se ve el código HTTP real y la respuesta; el paso `Then status` contiene el código esperado. Los pasos `match` muestran las validaciones y, si fallan, la diferencia entre el resultado esperado y el real.

Cada carpeta incluye `ejecucion.txt` con fecha, hora, ambiente y modo, además de JSON Cucumber y XML JUnit. La consola muestra la ruta del reporte generado. Los resultados de Surefire quedan en `target/surefire-reports/`.

La comprobación local tiene su propio reporte en `target/cleanup-hook-reports/`. Incluye un error simulado con `@fail`: debe detectarse para que la comprobación apruebe. No agrega peticiones ni casos al alcance funcional.

Un resultado de `dryRun` no acredita ejecución real. Cada reporte conserva la fecha, el ambiente y los parámetros de su ejecución en `ejecucion.txt`.

## Entrega

El `.gitignore` permite incluir únicamente:

- `src/test/`: código Java, features, schemas, requests, helpers y configuración.
- `pom.xml`, `.gitignore` y este `README.md`.
- `.github/workflows/pruebas.yml`: ejecución manual y reportes como artefactos.

Las herramientas locales, dependencias descargadas, compilados, reportes, archivos del editor y credenciales quedan excluidos. Los reportes se pueden descargar como artefactos de GitHub Actions.
