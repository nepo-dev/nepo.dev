---
id: unix-disable-discord-autoupdate
uuid: f65b4de3-0a81-4182-a081-089c493ebdb6
title: '*nix trick: desactivar auto-updates de Discord'
preview-image: $BASE_URL$/imgs/nix-tricks-discord-autoupdate/portada.jpg
author: Juan Antonio Nepormoseno Rosales
category: tech
date: 2026-03-10T00:00:00Z
last-update: 2026-03-10T11:00:00Z
abstract: Un truco chulo ("neat trick", "*nix-trick...") para evitar los updates automáticos de Discord en Linux.

---

Si te mueves en el mundo gamedev o de gaming es bastante probable que tengas que usar la aplicación de Discord. Puede gustarte más o menos, pero al final es donde se encuentra la mayor parte de la comunidad. El problema es que en Linux, cada vez que detecta una nueva versión, pide que te descargues un archivo `.deb` de su web y que lo instales manualmente. ¡Como si estuviéramos en la prehistoria (es decir, en Windows)!

Si sólo te interesa cómo desactivar eso, salta el [apartado de desactivar auto-update](#desactivar auto-update).

## ¿Por qué es un problema? (opinión)

Esto es super molesto porque la filosofía de Linux respecto a instalar el software y actualizarlo es completamente distinta a lo que quieren las empresas. Para empezar, no descargas cosas de su web directamente, sinó de un repositorio de programas gestionado y mantenido (normalmente) por los desarrolladores de tu [distro](https://es.wikipedia.org/wiki/Distribuci%C3%B3n_Linux). Nada de descargar un ejecutable de una web random que hace el setup, eso es super inseguro y por eso Windows tiene mala fama por tener muchos virus. En Linux usamos gestores de paquetes como `apt` o `pacman`.

Pero la parte más hiriente es que en Linux **tú decides** cuándo instalas y actualizas. ¿Sabéis cuando queréis encender o apagar un PC con Windows/Mac y a veces te toca esperar hasta 30 minutos (¡si no más!) porque Microsoft/Apple decidieron que hoy tocaba update? Eso en Linux no existe. El sistema de avisa de que hay actualizaciones y tú, desde la terminal o un botón visual, decides cuándo vas a actualizarlo.

Eso es así en la mayoría de programas, pero eso a Discord no le parece bien, porque es una empresa que quiere tener el mayor control posible de cómo se comporta tu máquina. Cuando abres Discord, este se conecta a un servidor para verificar si hay actualizaciones nuevas. Y si las hay, te avisa de que tienes que actualizar la versión realizando un proceso super manual. Esto es inseguro, igual que en Windows, además de muy molesto. La gente que usamos Linux lo hacemos porque huímos de estas situaciones en las que perdemos el control de nuestro propio hardware. Por eso os comparto cómo desactivar este auto-update.

## Desactivar auto-update

1. Localizar la carpeta de configuración de Discord. Normalmente está en `~/.config/discord/`
2. Dentro, hay un fichero `settings.json`. Ábrelo con tu editor de texto favorito. Si no existe créalo.
3. Añade la línea `"SKIP_HOST_UPDATE": true,`. Ten en cuenta que es un [fichero JSON](https://es.wikipedia.org/wiki/JSON), así que tiene que estar entre un `{` y un `}` que debería estar ya en el fichero.
4. Cierra Discord y vuelve a abrirlo.

Este es mi fichero `settings.json`, de referencia:

<details><summary>settings.json</summary>

```json
{
  "BACKGROUND_COLOR": "#2c2d32",
  "IS_MAXIMIZED": true,
  "IS_MINIMIZED": false,
  "SKIP_HOST_UPDATE": true,
  "WINDOW_BOUNDS": {
    "x": 1880,
    "y": 0,
    "width": 1796,
    "height": 1035
  },
  "chromiumSwitches": {},
  "offloadAdmControls": true,
  "enableHardwareAcceleration": true,
  "asyncVideoInputDeviceInit": false,
  "enableLibOpenH264Electron": false
}
```

</details>

Ahora Discord debería de actualizarse sólo cuando lo actualices con el gestor de paquetes de tu distro. Y si no quieres hacer esto, siempre te queda entrar desde el navegador 😛

