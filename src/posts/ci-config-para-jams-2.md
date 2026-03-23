---
id: ci-config-para-jams-2
uuid: 90040563-2513-43cf-a6fe-1cd116defdff
title: 'Configuración de CI pt. 2: Docker, imágenes, contenedores'
preview-image: $BASE_URL$/imgs/ci-config-para-jams-2/portada.jpg
author: Juan Antonio Nepormoseno Rosales
category: tech
date: 2026-03-23T00:00:00Z
last-update: 2026-03-23T11:00:00Z
abstract: Artículo complementario al de Configuración de CI para Jams en el que aprenderemos qué es Docker y cómo actualizar nuestro CI para que funcione con nuevas versiones de Godot.

---

En un artículo anterior expliqué cómo configurar un workflow de CI para hacer una build de un juego de Godot y publicarlo en Itch.io. Podéis encontrarlo en [este enlace]($BASE_URL$/posts/ci-config-para-jams.html).

Varias personas me han comentado que ya no funciona con nuevas versiones de Godot. Así que en lugar de actualizar el post con cada nueva versión de Godot, voy a explicaros cómo podéis actualizarlo vosotres. Así no dependéis de mi para usarlo y aprendéis algo que os resultará útil durante mucho tiempo 😄

### ¿Cómo actualizar a una nueva versión de Godot?

La respuesta es muy sencilla: para usar una nueva versión de Godot, sólo tenemos que descargarla y usarla cuando creamos nuestro juego. 

Y en principio ya estaría, ¿no? ¿Por qué sigue el artículo?

Aunque la respuesta sea muy sencilla, hace falta entender varias cosas antes para saber cómo llevarla a cabo. Así es como lo haríamos en nuestro ordenador, pero tenemos que recordar que el CI se ejecutan en ~~el ordenador de otro~~ el cloud (en este caso, de Microsoft). Es por eso que cuando salió la versión 4.3 de Godot y actualicé mi proyecto sin pensar, la build con el CI del artículo anterior (que usaba la 4.2.1) falló porque el juego era para una versión superior a la del CI.

En la definición del workflow de Github Actions hay una variable llamada `GODOT_VERSION: 4.2.1` y otra llamada `barichello/godot-ci:4.2.1`. Intenté cambiarlas para que usaran la 4.3, pero lanzaba un error porque la versión 4.3 de Godot aún no estaba disponible en esa imagen de Docker que uso. Pero espera, ¿qué es eso de Docker y de una imagen?

### ¿Qué es Docker?

Docker, un motor de **virtualización** usado ampliamente en la industria del software. Docker es parecido a una [máquina virtual](https://es.wikipedia.org/wiki/M%C3%A1quina_virtual) (o VM, del inglés Virtual Machine), como cuando usas VirtualBox, VMWare o qemu. Esencialmente, es como tener un ordenador virtual, que no existe en el mundo físico, dentro de tu PC. Este ordenador puede tener su propio disco duro, acceso a red e incluso tarjeta gráfica y CPU. Pero estos no tienen porqué existir, sinó que nuestro ordenador le reserva un espacio en su disco duro, le comparte la conexión a internet y comparte la tarjeta gráfica y CPU con él. Esto nos permite controlar el entorno donde se ejecutan nuestros programas. En nuestro caso, por ejemplo, nos interesa que esté instalada una versión concreta de Godot para poder generar la build.

Docker tiene varias ventajas en un entorno de CI respecto a una VM clásica. Una de ellas es que Docker es **más ligero**. Una VM requiere su propio sistema operativo y todos los programas que este necesita para funcionar. Con Docker se reutilizan partes del sistema operativo original, por lo que se inicia más rápido que una VM clásica y consume menos recursos.

Otra de las ventajas es el concepto de las *imágenes*. Si tuviéramos que configurar una VM, tendríamos que instalar el sistema operativo y luego instalar Godot en él. Pero no hemos tenido que hacer nada de eso para nuestro CI. ¿Por qué? Porque la imagen que usamos ya los lleva instalados.

### ¿Qué es una imagen de Docker? ¿Y un contenedor?

Una **imagen** es un concepto que usa Docker para referirse a un conjunto de instrucciones para configurar un contenedor. Este **contenedor** es el que ejecuta el programa que quieres ejecutar. Por hacer un símil, la imagen es como un patrón y el contenedor es la ropa que haces con él. Con el mismo patrón (imagen) puedes hacer varios pantalones (contenedores).

Esencialmente esto nos permite definir en un único sitio qué se necesita para generar una build de Godot. Así no tenemos que repetir esa instalación cada vez que vamos a hacer una build. Además, si cambia la versión de Godot, sólo hay que actualizar la imagen y no tenemos que cambiar nada de los diferentes scripts de CI que tengamos en nuestros proyectos.

#### ¿Qué imagen estoy usando?

Vamos a empezar aprendiendo a leer la etiqueta de una imagen. En el artículo anterior estábamos usando `barichello/godot-ci:4.2.1`. Esta etiqueta tiene 3 partes:
- `barichello`, es la persona u organización que ha creado esa imagen. Normalmente es una cuenta de Github (en este caso, podemos agradecerle a [esta persona de aquí](https://github.com/abarichello/)).
- `godot-ci` es el nombre de la imagen. Podría ser que una misma persona u organización tenga varias imágenes disponibles. Por ejemplo, `godot-ci` y `godot-csharp-ci`.
- `4.2.1` es la versión de la imagen. No tiene porqué coincidir con la versión del programa que nos interesa, pero en esta lo hace para hacernos la vida más fácil.

Vale, entonces alguien que se hace llamar `barichello` ha creado la imagen de `godot-ci` con la versión `4.2.1`. ¿Podemos usar la `4.3`? Depende. En la fecha en la que escribo este post, sí, porque ya la ha creado. Pero podría ser que tarde en crearla porque está con otras cosas o que no lo haga porque ha dejado el desarrollo de videojuegos. Entonces, ¿cómo podríamos hacer para crear nuestra propia imagen de Docker y no depender de esta persona?

#### ¿Cómo se crea una imagen de Docker?

Una imagen se define en un fichero que se llama Dockerfile. Aprender la sintaxis y cómo funciona se sale del scope de este artículo. Hay [mucha documentación](https://docs.docker.com/) al respecto y aprenderemos más de ellos que de mi. Pero sí estaría bien que entendamos qué hace para desmitificarlo un poco.

Vamos a verlo con un ejemplo de Hello World:

```docker
FROM ubuntu:latest
CMD ["echo", "hello world"]
```

Este pequeño archivo de texto define una imagen super sencilla. Lo único que hace es crear un contenedor con Ubuntu instalado y mostrar un hello world en pantalla.

Casi todas las imágenes usan otra de base. Hacen esto mediante el comando `FROM`, que en esta caso le dice que use la última imagen de Ubuntu disponible para construir el contenedor que queremos. Después, usamos `CMD` para ejecutar un comando en la línea de comandos. En este caso, sólo hacemos el equivalente a un print, `echo "hello world"`.

Podemos hacer una build de esta imagen con el comando `docker build -t hello-world` y ejecutarla con `docker run hello-world`. Entonces deberíamos ver por pantalla un "hello world".

Volviendo al CI de Godot, la [imagen de Docker de `barichello`](https://github.com/abarichello/godot-ci/blob/master/Dockerfile) es una imagen que usa ubuntu de base, que instala Godot para poder hacer builds y que además tiene el [Butler de itchio](https://itch.io/docs/butler/) para poder subir la build. Si a `barichello` le diera por dejar de actualizarla, sólo tendríamos que hacer un fork y actualizar los comandos para instalar la nueva versión de Godot por nuestra cuenta.

### Dockerhub

Hay una última pieza del puzzle que hace falta conocer, pero no tan al detalle como el resto. Docker no tiene ni idea de qué es GitHub, y hay imágenes de Docker que se mantienen en otros servidores de Git (Gitlab o BitBucket, por ejemplo), ¿así que cómo sabe Docker que tiene que descargar la imagen de una cuenta de Github que se llama `barichello`?

La respuesta es que no tiene que saberlo porque no tiene que bajarse nada de Github. Cuando creas una imagen la subes a un repositorio centralizado de imágenes de Docker. El que se usa por defecto es **DockerHub**, pero hay otros, como el de Github o incluso algunos que puedes hostear en tu propia red.

DockerHub tiene además una interfaz web en la que puedes buscar imágenes de Docker (y sus versiones). Así puedes descubrir otras imágenes con características distintas, como la versión de Godot de C#, o quizá algo de Unity.

![foto de unos resultados en el buscador de imágenes de Docker de DockerHub]($BASE_URL$/imgs/ci-config-para-jams-2/dockerhub.png)

Dicho esto, no os fiéis de cualquier imagen que veáis. Yo uso la de `barichello` porque es la imagen de Godot más conocida, tiene buena documentación y su código está disponible y visible de forma abierta en [su repositorio en GitHub](https://github.com/abarichello/godot-ci). Cualquier persona podría crear una imagen que mande una copia del proyecto a su servidor y publicarla, así que investigad y vigilad con qué usáis.

## Cierre

No tengo ninguna conclusión para este artículo, sólo quiero invitaros a crear vuestras propias imágenes de Docker. O, como mínimo, que sepáis cómo investigar o actualizar si estáis usando alguna y deja de funcionaros.

Por si acaso repito que el repositorio donde se define la imagen de `godot-ci` de `barichello` está [aquí](https://github.com/abarichello/godot-ci), así que os animo también a leer la documentación y ver qué se puede hacer con ella. ¡La podéis usar incluso para proyectos de Android o que usen la versión de C# de Godot!

