---
id: unix-trick-wrappers
uuid: 152ebb82-63f6-4099-87ad-58e717610ca1
title: '*nix trick: command wrappers'
preview-image: $BASE_URL$/imgs/unix-trick-wrappers.png
author: Juan Antonio Nepormoseno Rosales
category: tech
date: 2025-11-04T00:00:00Z
last-update: 2025-11-04T11:00:00Z
abstract: Un truco chulo ("neat trick", "*nix-trick...") para shells de tipo UNIX que permite sobreescribir/extender el comportamiento de comandos existentes sin modificar su código fuente.

---

¡Hola! Lo que me encanta de la terminal es que no hace falta que recuerdes cómo funciona cada comando. Si hay algo que vas a usar 2 veces al mes, lo guardas en un script y usas eso directamente. No tienes que recordar en qué submenú, en qué botón con un icono estaba esa funcionalida. Y lo mejor es que no te van a cambiar con un update, porque son scripts que tienes en tu PC. ¡Es como escribir notas que pueden ejecutarse y validar que siguen funcionando! ❤️‍🔥

Hoy quería traeros un truco super sencillo pero super útil. Es una manera de **sobreescribir/extender el comportamiento de comandos existentes en shells de tipo UNIX** (o sea, os funcionará en Linux, Mac y WSL de Windows). Al finalizar el post habremos extendido `git diff` para poder llamarlo con un parámetro "godot" (es decir, `git diff godot`), que nos mostrará un diff únicamente de ficheros de escenas y código. Nada de binarios ni ficheros de configuración de importación de assets.

Pues si os interesa esto, lo primero que necesitamos es conocer el comando alias.

### Comando alias

Existe un comando `alias` con el que puedes decir "cada vez que te diga esto, llama a este comando". Por ejemplo:

```bash
alias some="echo 'body once told me the world is gonna roll me'"
```

Con eso, cada vez que escribamos `some` en la terminal, ejecutará el `echo` que le hemos puesto después:

```
$ some
body once told me the world is gonna roll me
```

Normalmente, los cambios que hacemos con este programa sólo duran mientras la sesión de la shell esté abierta. Eso quiere decir que si cerramos la terminal y la volvemos a abrir **perderemos ese alias** que hemos creado.

Para hacer que este cambio sea **permanente** podemos añadir la línea del alias a nuestro fichero `.rc`. Suele depender de la shell que estemos usando: si es bash estará en `~/.bashrc`, si es zsh estará en `~/.zshrc`...

Por ejemplo, yo tengo una sección en mi `.zshrc` para configurar estos aliases:

```bash
# ...

####
# Aliases
####

alias please="sudo"
alias open="xdg-open"
alias code="codium"

# ...
```

Ahora que ya conocemos qué hace este comando y cómo usarlo, podemos empezar a extender otros programas.

### Explicación del caso de ejemplo

Godot genera algunos archivos como configuraciones de importación de imágenes, audio y modelos 3D (`"*.import"`) o ficheros binarios de materiales y recursos (`"*.res"`). La mayoría del tiempo me interesa saber si ha habido cambios en esos ficheros, pero hay momentos en los que sólo quiero ver los cambios que se han hecho en los ficheros de escenas y código (`*.tscn` y `*.gd`), por lo que ver los cambios de los ficheros de importación y recursos me molesta.

Lo primero que pensé es que `git` debe tener alguna forma de filtrar los archivos que no me interesan, y así es. El problema es que **es muy largo** como para tener que reescribirlo (¡y acordarme!) cada vez que quiera usarlo:

```bash
git diff -- . ':!**/*.import' ':!**/*.res'
```

Podemos añadir un alias para ejecutar esta línea. Por ejemplo, un `alias godot-diff` o `alias git-diff-godot` en nuestro achivo `.rc`. Pero podemos hacerlo aún más bonito con un script que nos haga de wrapper.

### Wrapper scripts

¿Qué es esto de un script que hace de wrapper? La idea principal es que en lugar de llamar al script como `git-diff-godot`, podríamos llamarlo **siguiendo la API de git** y hacer un: `git diff godot`.

Esto también nos permite **definir varios casos**. Quizá tenemos un diff distinto para Unity, otro para Unreal, otro para un engine custom... Si simplemente usáramos aliases, deberíamos tener varios (`git-diff-unity`, `git-diff-unreal`...), mientras que si hacemos el wrapper script estos serían casos de un switch-case. ¿Y si queremos sobreescribir la funcionalidad de `git status` o `git commit`? ¡También podríamos usar nuestro script para detectar los casos en los que tiene que hacer algo distinto!

La idea principal es que este script se encargue de 2 cosas:
1. Saber **cuándo** tiene que llamar al **programa original** y cuándo hacer **algo distinto**.
2. **Ejecutar el caso distinto** para el que lo estamos construyendo. En este caso, el diff complicado.

Podemos complicarlo mucho, pero para empezar con algo sencillo deberíamos aprender a usar el comando `if` y el comando `case` (docs de [condiciones](https://www.gnu.org/software/bash/manual/html_node/Bash-Conditional-Expressions.html) e [ifs y cases](https://www.gnu.org/software/bash/manual/html_node/Conditional-Constructs.html)). Por ejemplo, con este script podríamos hacer que al llamar a `git diff godot` se lance el comando que encontramos en la sesión anterior:

```bash
#!/usr/bin/env bash

GIT="/usr/bin/git" # el comando de git original
ARGS=("$@") # los parámetros originales

function forward_to_git {
	$GIT "${ARGS[@]}"
}

if [ $# -gt 0 ] && [ "$1" = "diff" ]; then
	if [ $2 = "godot" ]; then
		$GIT diff -- . ':!**/*.import' ':!**/*.res'
	else
		forward_to_git
	fi
else
	forward_to_git
fi
```

Al ejecutarse este script, pueden darse 3 posibilidades distintas:

1. Es el comando git, pero no tiene parámetros (es decir, `git` a secas; no cumple `$# -gt 0`) o el primer parámetro no es "diff" (por ejemplo, `git status`; no cumple `"$1" = "diff"`). En este caso, llamamos al comando original `git` y le pasamos los parámetros recibidos.
2. Es el comando git, su primer parámetro es "diff" y su segundo parámetro es la opción que nos hemos inventado, "godot" (es decir, `git diff godot`). En este caso, llamamos al comando que queremos llamar.
3. Es el comant git, su primer parámetro es "diff", pero su segundo parámetro no es la opción "godot" (por ejemplo, `git diff --staged`). En este caso, llamamos al comando `git` con los parámetros que hemos recibido.

**¡Recordad una cosa!** Este script por sí mismo **no hace nada**. Tenemos que ponerle el `alias git=$(path hasta el script)` en nuestro fichero `.rc` para que se llame a este script en lugar de al comando de `git` original.

### El wrapper script que uso yo

El script que uso no es exactamente el que os he compartido. Ese está simplificado para que sea más fácil de seguir. Os dejo aquí el mío por si os da más ideas o por si queréis usarlo de base para empezar a extender git a vuestra manera.

¿Qué ideas se os ocurren? ¿Hacer un pretty print para ver el árbol de commits con `git log`? ¿Comprobar que los archivos están nombrados como queremos antes de hacer un commit? ¿Lanzar los tests antes de cada push? ¿Usarlo con otro comando que os cuesta aprender? ¡Compartidme las ideas que se os ocurran por el Fedi o Discord! 😄

```bash
#!/usr/bin/env bash

# This script works by setting up an alias in you .rc file ("~/.bashrc", "~/.zshrc"...).
#
# ```bash
# alias git $(path_to_this_script)
# ```
#
# That way you can override git's call to use it like:
#
# ```bash
# git diff godot
# ```

GIT="/usr/bin/git"
ARGS=("$@")

function forward_to_git {
	$GIT "${ARGS[@]}"
}

function diff {
	case $2 in
		"godot")
			$GIT diff -- . ':!**/*.import' ':!**/*.res'
			;;
		*)
			forward_to_git
			;;
	esac
}

function main {
	if [ $# -gt 0 ]; then 
		case "$1" in
			"diff")
				diff $*
				;;
			"nuke")
				$GIT reset --hard && $GIT clean -fd
				;;
			*)
				forward_to_git
				;;
		esac
	else
		forward_to_git
	fi

}

main ${ARGS[@]}

```
