---
id: ci-config-para-jams
uuid: 52ecd52f-1bef-4429-a23f-3fda1aec5855
title: 'Configuración de CI para jams'
preview-image: $BASE_URL$/imgs/ci-config-para-jams/preview.jpeg
author: Juan Antonio Nepormoseno Rosales
category: tech
date: 2024-02-01T00:00:00Z
last-update: 2024-02-01T11:00:00Z
abstract: Una explicación de cómo configurar una build y deploys automáticos basada en la que uso en jams, con GitHub Actions y Godot

---

Hace un par de días [liberamos el código](https://twitter.com/antimundo21/status/1752454023565705710) de dos juegos que hemos hecho en equipo:

* [Rat and Furrius](https://github.com/antimundo/rat-and-furrius), para la [Mermelada Jam](https://itch.io/jam/mermelada-jam)
* [La Falda de la Montaña](https://github.com/nepo-dev/falda-montana), para la [MálagaJam Weekend 17](https://itch.io/jam/malagajam-weekend-17)

Tiene todas las ñapas que podáis esperar de una jam, pero también hay cosas que os pueden resultar útiles. Entre ellas, un archivo para **exportar** un proyecto de Godot a **web** y **subirlo a itch.io** automáticamente.

¿Por qué querrías hacer eso en una jam? Pues porque se hace en 5 minutos y te permite:

* **No bloquear** a une programadore cada vez que quieras hacer una build.
* **No depender** de une programadore para poder lanzar el juego.
* Hacer builds **más frecuentes** para hacer **playtesting** de los prototipos más rápido.
* Asegurarte de que **la build siempre será la misma**. Que no te habrás equivocado al exportar/subir el proyecto.
* En los últimos 5 minutos de jam, no tienes que estar comprimiendo archivos, yendo a una web y subiéndo archivos. Sólo haces **click en un botón** y esperas relajadamente 🍹

## Configuración

Lo que sigue es sólo una lista de instrucciones rápidas si ya sabes qué hay que hacer. Si no entiendes algo, en la [guía de configuración que hay más abajo](#guía-de-configuración-en-detalle) estará explicado 🙂

1. Copiar `.github/workflows/main.yml` a tu repositorio de GitHub.
2. Cambiar los valores de [estas variables](https://github.com/nepo-dev/falda-montana/blob/07955a0dd83e74703359850c7f6ba298838d4354/.github/workflows/main.yml#L5-L8). Si actualizas la versión de Godot, recuerda actualizar [la versión de la imagen de Docker](https://github.com/nepo-dev/falda-montana/blob/07955a0dd83e74703359850c7f6ba298838d4354/.github/workflows/main.yml#L15).
3. Genera una [API Key de Itch](https://itch.io/user/settings/api-keys) y añádela como secreto en el repositorio (`Settings > Secrets and variables > Repository secrets`).
4. Abre el proyecto en Godot y genera la configuración para exportar el proyecto a web (`Project > Export... > Add... > Web`). Como nombre de esa configuración deja `Web`, y como export path ponle `build/index.html`.

Sube los cambios al repositorio y ya está listo para usar.

> ¿No te funciona? ¡Quizá estás usando una versión nueva de Godot que no tiene imagen de Docker! [Aquí tienes un artículo]($BASE_URL$/blog/posts/ci-config-para-jams-2.html) que te explica más al detalle cómo funciona esto para que puedas actualizarlo.

## Probando que funciona

Esto puede hacerlo cualquier persona con acceso al repositorio, no sólo les programadores:

1. Entra en Actions.
2. Selecciona el workflow `Build + Deploy`.
3. Haz click en `Run workflow > Run workflow`.

<video muted autoplay controls loop>
 <source src="$BASE_URL$/vids/ci-config-para-jams/lanzar_builds.mp4" type="video/mp4"/>
</video>

Si todo sale bien, en unos minutos os saldrá la ejecución en verde. Y si váis a vuestra página de Itch, os debería aparecer vuestro juego.

![]($BASE_URL$/imgs/ci-config-para-jams/successful_run.png)

## ¿Y esto es gratis?
Hasta cierto límite. Tenéis [2.000 minutos de ejecución gratuitos](https://docs.github.com/en/billing/managing-billing-for-github-actions/about-billing-for-github-actions#included-storage-and-minutes) por mes en el plan gratis. Para Godot y para jams, es difícil de alcanzar. Y la ventaja de no depender de/bloquear a une programadore y que siempre se suba el proyecto de la misma manera es considerable. 

<br />

--------------------

<br />

## Guía de configuración en detalle
En esta guía se explica con pelos y señales cómo funciona esta automatización, por si tienes alguna duda o por si tienes curiosidad y quieres aprender más 😊

### Copiar main.yml
Lo primero que tienes que hacer es copiar el fichero `.github/workflows/main.yml` a tu repositorio en GitHub, dentro de esas mismas carpetas ".github" y "workflows".

<video muted autoplay loop>
 <source src="$BASE_URL$/vids/ci-config-para-jams/copy-file.mp4" type="video/mp4"/>
</video>

Esos son unos directorios especiales que GitHub interpreta como una configuración de su **sistema de CI** (Integración Continua), las **GitHub Actions**. Este permite automatizar todo tipo de procesos: desde las builds y subirlo (deploy) a Itch, hasta conversiones de ficheros, ejecución de pruebas, escribir mensajes en Discord/redes...

No puedo explicar en este post cómo funciona en detalle. Pero si te interesa aprender más, tienes [la documentación oficial](https://docs.github.com/en/actions). Recomiendo [aprender algo de Docker](https://docs.docker.com/guides/get-started/) de antemano para entender cómo se configuran las máquinas en las que se ejecutan estos procesos. Para esta guía sólo nos hace falta saber que una "imagen de Docker" es algo parecido a un ordenador que ya viene con cosas instaladas. 

¿Y qué es lo que hace este fichero? Pues define los pasos a seguir para generar esa build y subirla a Itch. Si lo abres, verás que tiene unos "steps" definidos. A grandes rasgos, esto es lo que hacen:

* **Checkout:** se descarga el código del repositorio.
* **Setup:** prepara las export templates de Godot. La imagen de Docker ya incluye esas templates, que a veces pesan ~1GB o más, dependiendo de la plataforma.
* **Web Build:** usa Godot desde la línea de comandos para exportar el proyecto para web.
* **Itch.io Deploy:** sube los ficheros exportados a Itch para que se puedan jugar.

### Editar las variables
#### Variables en main.yml
Una vez copiado, hará falta modificar los valores de [estas variables](https://github.com/nepo-dev/falda-montana/blob/07955a0dd83e74703359850c7f6ba298838d4354/.github/workflows/main.yml#L5-L8) en `main.yml` para que sean los de tu juego:

* `ITCHIO_USERNAME` y `ITCHIO_GAME` son tu nombre y el de tu juego que aparece en la url. Por ejemplo, para `https://edearth.itch.io/falda-montana` serían `edearth` y `falda-montana` respectivamente.
* `GODOT_VERSION` es la versión de Godot que estés usando. Si la actualizas, tendrás que actualizar también la versión en [la línea que define la imagen de Docker](https://github.com/nepo-dev/falda-montana/blob/07955a0dd83e74703359850c7f6ba298838d4354/.github/workflows/main.yml#L15). Puedes consultar las versiones disponibles en [este enlace](https://hub.docker.com/r/barichello/godot-ci/tags).
* La variable `BUTLER_API_KEY` es especial y está definida en otro lugar. No hace falta modificarla aquí. Te lo explico a continuación.

#### API Key
Una API Key es una **especie de "contraseña"** que permitirá a esta GitHub Action **usar vuestra cuenta de Itch**. Si te parece peligroso, es porque puede serlo. Por eso no podemos guardarla con el resto de variables, porque tiene que mantenerse en secreto.

Para configurarla, accede a `Settings > Secrets and variables > Actions > Repository secrets` y cread un nuevo secreto. Dentro, copia la [API key que generes desde itch](https://itch.io/user/settings/api-keys).

<video muted autoplay controls loop>
 <source src="$BASE_URL$/vids/ci-config-para-jams/create_secret.mp4" type="video/mp4"/>
</video>

Esta API Key se puede usar con [Butler](https://itch.io/docs/butler/), la herramienta para línea de comandos de Itch. Permite subir proyectos a Itch de maner super rápida, subiendo sólo los ficheros que se modificaron. Y es justo lo que nuestra automatización hará.

> Es **MUY importante** que mantengas esta **clave bien segura**. No la pases por Discord, ni WhatsApp, ni ningún sitio. Y si sospechas que se ha filtrado, tienes que ir al [dashboard](https://itch.io/user/settings/api-keys) y darle a "revoke" lo antes posible. Si alguien se hace con ella, puede llegar a acceder a tu cuenta de Itch y borrarte los juegos.

### Export en Godot
El último paso es decirle a Godot cómo y dónde tiene que generar esa build del juego. Para eso, abre el proyecto en Godot y navega hasta `Project > Export... > Add... > Web`. Si es la primera vez que vas a exportar tu juego, esta ventana estará vacía como en el video. Al darle al botón de `Add...` y seleccionar `Web` se generará la configuración para exportar el proyecto a web.

<video muted autoplay controls loop>
 <source src="$BASE_URL$/vids/ci-config-para-jams/config_export.mp4" type="video/mp4"/>
</video>

El fichero `main.yml` está configurado para que la build se exporte a una carpeta específica, por lo que tendrás que configurar el "export path" para que sea `build/index.html`. Ahí es donde se creará la build. No es por nada que necesite GitHub ni Godot. Es que usé ese directorio en `main.yml` y es más fácil dejarlo como está que modificarlo cada vez que crees un nuevo proyecto.

Una vez hecho esto, ya habrás terminado. ¡Lo único que te queda es [probar que funciona](#probando-que-funciona)!

### Más

Si quieres aprender más en profundidad cómo funciona esto, he escrito un [artículo complementario]($BASE_URL$/blog/posts/ci-config-para-jams-2.html) que explica cómo funciona Docker y cómo puedes crear tu propia imagen de Docker para hacer cosas en el CI. ¡Espero que te sirva!

