---
id: espresso
uuid: 1040853a-1971-4f74-9a78-d4a7ccd1b0b8
title: 'Caso de estudio: Espresso Framework'
preview-image: $BASE_URL$/imgs/espresso/portada.jpg
author: Nepo
category: tech
date: 2026-01-21T00:00:00Z
last-update: 2026-01-21T11:00:00Z
abstract: Analizamos algunos conceptos que maneja Espresso, un framework de testing para apps Android, para aprender qué herramientas usa. Así podemos implementarlas y utilizarlas en nuestros proyectos.

---

En este artículo analizaremos algunos conceptos que maneja [Espresso](https://developer.android.com/training/testing/espresso), un framework de testing para aplicaciones Android, para escribir y optimizar tests en Android.

El objetivo es entender la idea general de estos conceptos, para poder recrearlos en nuestros proyectos. Así podemos añadirlos a nuestra caja de herramientas y usarlos cuando lo necesitemos. ¡Vamos a ello!

> **Nota: ** todos los ejemplos de código de este artículo están escritos en Kotlin.

## ¿Qué es Espresso?

Antes de entrar con los conceptos, definamos Espresso. Como dije antes, es un framework de testing para Android. Está pensado para hacer **UI testing**, un tipo de testing de alto nivel en el que interactuamos con la aplicación realizando las acciones que haría el usuario final en la aplicación: tocar botones, leer textos, deslizar la pantalla.

Un detalle importante que separa a Espresso de otro tipo de frameworks es que sus tests son de **caja blanca/gris** (al contrario de Selenium/Appium, por ejemplo, que son de caja negra). Esto significa que tenemos acceso al código de la aplicación, por lo que podemos hacer optimizaciones interesantes que nos **facilitan escribir tests** y mejoran su **fiabilidad**.

### Matchers, Actions, Assertions -> BDD

Son la versión de BDD de Espresso. Match-Act-Assert son lo mismo que Given-When-Then, pero están integrados en el propio framework, por lo que el propio framework te hace organizar tus interacciones con la aplicación como escenarios de BDD.

Un detalle chulo de los ViewMatchers y ViewAssertions de Espresso es que usan los [matchers de Hamcrest](https://hamcrest.org/), lo cual nos garantiza el acceso a un lenguaje ([DSL](https://en.wikipedia.org/wiki/Domain-specific_language)) super rico y flexible. En los ViewMatchers se usan para encontrar elementos de forma flexible y en las ViewAssertions para hacer comprobaciones sobre ellos. Estos matchers permiten combinarse entre sí para formar expresiones complejas y que dejan clara la intención. Por ejemplo, podemos buscar un elemento por su ID, porque no hay nada más claro que eso, queremos _ese_ elemento en concreto:

```kotlin
onView(withId(R.id.login_button))
```

También podemos encontrarlos basándonos, por ejemplo, en su posición en el DOMTree o su contenido y propiedades. Imaginad que tenemos un mensaje de error que es hijo del botón de login y no tiene ID. Podríamos encontrarlo de esta manera:

```kotlin
allOf(
	isDescendantOfA(R.id.login_button),
	withText(containsString(R.text.login_error_message))
)
```

Fijaos que tenemos acceso a los _resource files_ (`R`) de Android. ¡Es genial para el testing poder reutilizar las partes que forman la aplicación! Si un developer cambia el texto del error, el test ni se enteraría y seguiría funcionando. Lo cual es genial si no estás verificando ese texto en concreto.

Si combinamos esto con un [patrón Page Object](https://martinfowler.com/bliki/PageObject.html), podemos organizar la interacción con la aplicación en una capa abstracta y reutilizable. De esta manera, conseguimos también que nuestros tests no tengan conceptos del framework de testing y no estén acoplados a él:

```kotlin
class LoginPage {

	val loginButton = onView(withId(R.id.login_button))
	val errorMessage = allOf(
		isDescendantOfA(R.id.login_button,
		withText(containsString("error"))
	)

	fun login() {
		loginButton.click()
	}

	fun checkHasError(errorText: String) {
		errorMessage.check(
			allOf(
				isDisplayed(),
				withText(containsString(errorText))
			)
		)
	}

}
```

```kotlin
class LoginTest {

	val loginPage = LoginPage()

	fun testLoginFailsWithoutCredentials() {
		loginPage.login()
		loginPage.checkHasError("enter credentials")
	}
}
```

### Idling Resources

Los [Idling Resources](https://developer.android.com/training/testing/espresso/idling-resource) son un mecanismo que tiene Espresso para esperar a que terminen procesos lentos.

Siempre digo que hay que evitar `wait` y `sleep` con una unidad de tiempo hardcodeada. Esto acaba siendo un `magic number` que **no explica la intención** que tenemos detrás de esa espera, así que **está condenado a quedar desactualizado** y sin explicación. En lugar de eso, deberíamos esperar de forma explícita a que cambien las condiciones necesarias para seguir ejecutando el test. Por ejemplo, si acabamos de rellenar un formulario de login, no deberíamos esperar 3 o 7 segundos, deberíamos esperar a que cargue la página de bienvenida.

Los Idling Resources integran un patrón de multithreading directamente con el framework de test: un [semáforo](https://en.wikipedia.org/wiki/Semaphore_(programming)). Nos dice cuándo la ejecución debe esperar (luz roja 🔴) y cuándo puede continuar (luz verde 🟢).

Dicho de otra forma, es un chivato que le dice a Espresso cuándo debe esperarse antes de seguir ejecutando el test. Vamos a ver esto con un ejemplo.

#### Ejemplo: Cliente HTTP

Si nuestra aplicación usa un cliente HTTP, como por ejemplo [OkHttp](https://github.com/square/okhttp), podemos querer detener la ejecución del test mientras se están mandando mensajes al backend (o, mejor aún, a un servidor HTTP mock).

En el caso de OkHttp podemos usar el concepto de los `Interceptor`, una clase que escucha a cada petición-respuesta que hagamos y que nos permite reaccionar a ellas. Esto se vería así cuando creamos la instancia del cliente:

```kotlin
val httpClient: OkHttpClient = OkHttpClient.Builder()
    .addInterceptor(IdlingResourceInterceptor())
    .build()
```

Y esta sería la clase, ya con su `IdlingResource` que contará cuántas peticiones faltan por resolver: 

```kotlin
class IdlingResourceInterceptor: Interceptor {

	@Override
	@Throws(IOException::class)
	fun intercept(Interceptor.Chain chain): Response {
		// A request is received, therefore we increase the count
		request: Request = chain.request()
		countingIdlingResource.increment()
		
		// A request is resolved, therefore we decrease the count
		response: Response = chain.proceed(request)
		countingIdlingResource.decrement()
		
		return response
	}

	companion object {
		val countingIdlingResource: CountingIdlingResource = CountingIdlingResource()
	}
}
```

Fijaos que hemos hecho que el `IdlingResource` sea estático (en Kotlin esto se hace con el `companion object`). Esto es porque aún no hemos acabado: para que Espresso sepa a qué `IdlingResource` hay que esperar, hace falta registrarlos desde la clase del test. Esto lo podemos hacer de esta manera:

```kotlin
fun setUp() {
	Espresso.registerIdlingResource(
		IdlingResourceInterceptor.countingIdlingResource
	)
}
```

> **Nota:** Si no queréis estar copiando código de un test a otro, recomiendo usar una clase de Test base que se encargue de registrar todos los `IdlingResource` necesarios de nuestra aplicación. 

¡Y bam! Así de fácil los tests esperan a que la aplicación deje de estar ocupada para continuar. En cuanto la aplicación empieza a mandar peticiones por internet, el número se incrementa, deteniendo la ejecución. Espresso sólo seguirá ejecutando las instrucciones del test cuando este número vuelva a bajar a 0.

### Intents para lanzar View específica

En muchos progamas y juegos nos encontramos con que hay un único punto de entrada. La aplicación empieza en la pantalla principal y hay que seguir un recorrido de pasos para llegar a la vista que queremos probar.

Esto es bastante problemático para los tests, porque implica que cuando más profundo en la aplicación esté una vista, más dependencias tiene el test que la verifica. Si tenemos que hacer una prueba de unas opciones escondidas en un menú al que sólo se puede acceder después de un login, el test fallará si cambia el login o la forma de acceder al menú.

Espresso utiliza dos conceptos para evitar eso:

* Android configuran las vistas de las aplicaciones en [Activities](https://developer.android.com/guide/components/activities/intro-activities). Cada una puede lanzarse por separado y podemos inyectarle los datos necesarios para popularla (por ejemplo, el usuario que ha hecho login).
* Las [Rules](https://junit.org/junit4/javadoc/4.12/org/junit/Rule.html) son una herramienta de JUnit (versión 4, se renombraron a `ExtendWith` y `RegisterExtension` en versiones posteriores). Usan reflection para ejecutar código antes y después del test. En concreto, Espresso tiene la [ActivityScenarioRule](https://developer.android.com/guide/components/activities/testing), que lanza una Activity al empezar el test y la cierra al terminarlo.

Aprovechando estas dos ideas, nos queda una sintaxis muy recogida:

```kotlin
@RunWith(AndroidJUnit4::class)
class InstrumentedTest {

    @get:Rule
    val activityScenarioRule = ActivityScenarioRule(LoginActivity::class.java)

    @Test
    fun myTestMethod() {
        // ...
    }
}
```

 Declaramos la Rule como campo de clase y así no "ensuciamos" el código de setup/teardown con código para abrir la aplicación. Como norma general, siempre que podáis separar la lógica del test (ej. "hacer login", "saltar", "abrir un menú"...) de la lógica del framework (ej. conceptos como "label" o métodos como "sendKeys" en `getUserLabel().sendKeys(username)`).  Igual que con el [Page Object Pattern](https://martinfowler.com/bliki/PageObject.html) del que hablábamos antes.

Además, al abrir la vista directamente sin tener que pasar por todas las anteriores nos libramos de las dependencias que podrían romper nuestro test. Así conseguimos que el test sea más rápido y menos flaky.

## Cierre

No tengo ninguna conclusión, pero quería dejar claro que el post termina aquí y así.

Llevaba mucho tiempo queriendo escribir este post, porque trabajé con Espresso durante años y quería compartir mi apreciación por algunas ideas que me parecen buenas. Espero que podáis reutilizar estas ideas en los frameworks de testing de vuestros proyectos.

Me planteé escribir otros posts antes para presentar los conceptos poco a poco, pero no tenía ganas de escribir esas guías y por eso lo fui dejando pasar 😄

