<!-- common CSS -->

<style>
.container{
    display: flex;
}
.col{
    flex: 1;
}
</style>

## Automatización <br/> y CI para <img style="margin: 0px 0px 0px 0px; height: 100px;" src="images/godot_icon_color.webp" />

Fernando (<a href="https://mastodon.gamedev.place/@taletronic" target="_blank">taletronic@mastodon</a>)
<br/>
Nepo (<a href="https://mastodon.gamedev.place/@nepo@gamedev.lgbt" target="_blank">nepo@mastodon</a>)

---

### ¿Te ha pasado?

* Rehacer build al olvidarte un cambio
<!-- .element: class="fragment" data-fragment-index="1" -->
* Correr en los últimos 10 minutos de jam
<!-- .element: class="fragment" data-fragment-index="2" -->
* "En mi ordenador funciona"™️
<!-- .element: class="fragment" data-fragment-index="3" -->
* El programador está de vacaciones/enfermo
<!-- .element: class="fragment" data-fragment-index="4" -->

---

## ¡Que lo haga <br/>una máquina!

![bender chilling](images/bender.jpg)

---

### CI (Integración Continua)

* Con cada cambio del proyecto: build + publicar

* Código en la nube:
    * Automático
    * No depende de una persona
    * No hace falta configurarlo en tu PC
    * No se olvida pasos

---

### Github Actions

* Ya estábamos usando Github
* Microsoft lo da gratis
* workflow.yml: fichero de configuración

---

### workflow.yml

* Descarga proyecto e img Docker
* Descarga datos + caché
* Versionado
* Setup export templates
* Build
* Deploy
* Notificación en Discord ✅/❌ 

<img 
    style="width: 20%; position: fixed; top:40%; right: 0%;" 
    src="images/qr_workflow.svg"
    />

--

![QR code linking to the workflow.yml file](images/qr_workflow.svg) <!-- .element height="50%" width="50%" -->

[workflow.yml](https://github.com/fegabe/godot-ci-ayay/blob/main/.github/workflows/main.yml)

---

# Demo

<a href="https://github.com/fegabe/godot-ci-ayay/actions/workflows/main.yml" target="_blank" style="padding-right: 20px;">Actions</a>
<a href="https://taletronic.itch.io/godot-ci-ayay" target="_blank" style="padding-left: 20px;">Itch.io</a>

---

### Nuestra experiencia: problemillas

* Queremos usar FMOD en el proyecto
    * Descargar la librería
    * Importarla en el motor

---

### Problema 1: descargar la librería

* Muy pesada (300MB)
    * No podemos subirla a git directamente
    * No podemos descargarla cada vez
* Lo ideal sería usar LFS
    * Límite en proyectos gratuitos (1GB/mes)
* Aún queda descargar los banks

---

### Problema 1: descargar la librería

* ¿Solución? → Cachear ✅
* ¿Miss de caché?
    * Descarga
    * Guarda en caché

---

### Problema 2: importar librería FMOD

* Godot tiene que importar la librería
* Bug: no espera a terminar de importar antes de empezar la build del proyecto

---

### Problema 2: importar librería FMOD

* Forzar una espera con un hack
    * Esperar a que el procesador esté pausado
    * Matar el proceso para volver a lanzarlo
* <a href="https://github.com/godotengine/godot-proposals/issues/1362" target="_blank">Issue 1362</a> (¡abierta desde 2020! 👴)
* Aún estamos esperando a Godot
    * La próxima versión siempre es la buena

---

### ¿Conclusiones?

<img style="height: 500px;" src="./images/juez.jpg" />

---

### ¡Debate!

* ¿Os mola el tema? ¿Os pica aprender de CI?
* ¿Cómo descargaríais la librería vosotres?
* ¿Os apuntáis a darle 👍 a la issue para que la resuelvan antes? 👀 → <a href="https://github.com/godotengine/godot-proposals/issues/1362" target="_blank">Issue 1362</a>

---

### Más info

* Pipeline de desarrollo con Godot 4: https://www.youtube.com/watch?v=ZclZTdIf_K0
* Docker image + actions Github y Gitlab: https://github.com/abarichello/godot-ci
* Tutorial + template de CI: https://blog.jnepo.dev/posts/ci-config-para-jams.html

---

### ¡Graciñas!

<div class="container">

  <div class="col">

  Nepo <br> (<a href="https://mastodon.gamedev.place/@nepo@gamedev.lgbt" target="_blank">nepo@mastodon</a>)
  Fernando <br> (<a href="https://mastodon.gamedev.place/@taletronic" target="_blank">taletronic@mastodon</a>)
  David <br> (<a href="https://twitter.com/drnlab" target="_blank">drnlab@twitter</a>)

  🗣️🔈 ¡Háblanos!

  </div>

  <div class="col">
    <a href="https://blog.jnepo.dev/slides/godot-ci-ayay/" target="_blank"><img style="height: 300px" src="images/qr_slides.svg" /></a>
  </div>

</div>

🔗 <a href="https://blog.jnepo.dev/slides/godot-ci-ayay/" target="_blank">https://blog.jnepo.dev/slides/godot-ci-ayay/</a> 🔗

--- 

<!-- .slide: data-visibility="uncounted" -->
<!-- .slide: data-background="#ff0000" -->

<h1>
<img 
    src="images/notpass.png" 
    />
</h1>

---

# Casos de uso

<!-- .slide: data-visibility="uncounted" -->

* Día a día generar build de test <!-- .element: class="fragment" data-fragment-index="1" -->
* Últimos 10 minutos de jam <!-- .element: class="fragment" data-fragment-index="2" -->
* Item 1 <!-- .element: class="fragment" data-fragment-index="3" -->

<div class="fragment"  data-fragment-index="4" style="display:inline-block; text-align:right;">
things here are all

right aligned

blabla

---

# dos columnas

<!-- .slide: data-visibility="uncounted" -->

<div class="container">

  <div class="col">

  ```python
  print("Is the rendering bad?")
  print("Yeah!")
  print("How can you be sure?")
  print("Look at the beak of Tux")
  ```
  <!-- .element: style="width: 100%;" -->

  </div>

  <div class="col">
    <img style="height: 300px;" src="https://upload.wikimedia.org/wikipedia/commons/thumb/2/2b/Tux-simple.svg/768px-Tux-simple.svg.png" />
  </div>

</div>

<span style="font-size: 30px;">Recurso para Github y Gitlab: https://github.com/abarichello/godot-ci</span>

---

# tabla
<!-- .slide: data-visibility="uncounted" -->

<table>
  <thead>
    <tr>
      <th>variable</th>
      <th>class</th>
      <th>description</th>
    </tr>
  </thead>
  <tbody>
    <tr class="fragment" data-fragment-index="1">
      <td>character_1_gender</td>
      <td>character</td>
      <td>The gender of the older character</td>
    </tr>
    <tr class="fragment" data-fragment-index="2">
      <td>character_2_gender</td>
      <td>character</td>
      <td>The gender of the younger character</td>
    </tr>
  </tbody>
</table>

---
<!-- .slide: data-visibility="uncounted" -->

* Github Actions
* Selecciona workflow
* Lanzar (hacer rama para <br/>q se vea q pasa cuando falla / <br/>hacer como sorpresa)

<img 
style="width: 20%; position: fixed; top:20%; right: 0%;" 
src="https://s3.amazonaws.com/static.slid.es/logo/v2/slides-symbol-512x512.png" 
/> 

```js [1-2|3|4]
let a = 1;
let b = 2;
let c = x => 1 + 2 + x;
c(3);
```
