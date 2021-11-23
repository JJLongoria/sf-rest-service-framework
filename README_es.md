# [**REST Service Framework**]()

El Framework para API REST diseñado, permite con **un sólo punto de entrada** (una sóla clase *@RestResource*) gestionar **toda una API Rest** Estandar de forma fácil y preocupandose sólo de la implementación y definición de rutas.

Por lo tanto, se simplifica la gestión e implementación de API's REST en Salesforce al usar un sólo punto de entrada, o un número muy reducido (@RestResource) para generar una o varias API's REST y pudiendo definir de forma fácil un conjunto de rutas, mantenerlas y hacer un seguimiento de éstas sin necesidad de recordar cuales de las N clases del proyecto eran @RestResource y cuales no...

Esto se hace mediante la implementación de la clase `RestServiceRoute` en cada una de las clases que serán parte de la API y actuarán como rutas en ésta y las clases hijas deberan implementar apenas unos pocos métodos (si lo necesitan)

# [**Implementación**]()

## [**Definición de Rutas**]()

Pongamos que queremos definir las siguientes rutas en nuestro sistema siguiendo el estandard de REST para trabajar con Cuentas, Oportunidades y Contactos:

- `api/v1.0/accounts/`
- `api/v1.0/accounts/:accountId`

<br/>

- `api/v1.0/accounts/:accountId/contacts`
- `api/v1.0/accounts/:accountId/contacts/:contactId`
- `api/v1.0/contacts`
- `api/v1.0/contacts/:contactId`

<br/>

- `api/v1.0/accounts/:accountId/opportunities`
- `api/v1.0/accounts/:accountId/opportunities/:oppId`
- `api/v1.0/opportunities`
- `api/v1.0/opportunities/:oppId`

El arbol de Rutas quedaría de la siguiente forma

                api/v1.0
            _______|_______
            |      |      |
            |   Accounts  |
            |______|______|
            |             |
        Contacts     Opportunities           

## [**Convertir Rutas en Clases**]()

Segun el arbol de rutas, podemos deducir que al menos, tendremos el punto de entrada `api/v1.0` y al menos, tres rutas (Clases) principales, `Accounts`, `Contacts` y `Opportunidades`

Podemos traducir esto a las siguientes clases: 
- `api/v1.0` => `APIEntryPointRoute`
- `Accounts` => `AccountsRoute`
- `Contacts` => `ContactsRoute`
- `Opportunities` => `OpportunitiesRoute`

De esta forma la definición de las rutas principales de la API estarán en `APIEntryPointRoute` es decir, las rutas, `accounts`, `contacts` y `opportunities` estarán aqui definidas, así como su clase controladora respectivamente (`AccountsRoute`, `ContactsRoute` y `OpportunitiesRoute`)

Por lo tanto, la clase **`AccountsRoute`** responderá a las rutas

- `api/v1.0/accounts/`
- `api/v1.0/accounts/:accountId`

La clase **`ContactsRoute`** gestionará las rutas

- `api/v1.0/accounts/:accountId/contacts`
- `api/v1.0/accounts/:accountId/contacts/:contactId`
- `api/v1.0/contacts`
- `api/v1.0/contacts/:contactId`

y por último, la clase **`OpportunitiesRoute`** se encargará de responder a las peticiones a las rutas

- `api/v1.0/accounts/:accountId/opportunities`
- `api/v1.0/accounts/:accountId/opportunities/:oppId`
- `api/v1.0/opportunities`
- `api/v1.0/opportunities/:oppId`

--- 

## [**Definir Punto de Entrada `@RestResource`**]()

Como hemos comentado, podemos definir toda una API Rest con un sólo punto de entrada, es decir, con una sola clase con la etiqueta @RestResource ya que el Framework se encargará de gestinar las peticiones y rutas para redirigirlo al controlador correpondiente:

```java
@RestResource(urlMapping='/api/*')
global class APIRestEntryPoint{

    private static void handleRequest(){
      APIEntryPointRoute route = new APIEntryPointRoute();
      route.execute();
    }

    @HttpGet
    global static void handleGet() {
        handleRequest();
    }

    @HttpPost
    global static void handlePost() {
        handleRequest();
    }

    @HttpPut
    global static void handlePut() {
        handleRequest();
    }

    @HttpDelete
    global static void handleDelete() {
        handleRequest();
    }
}
```

No necesitaremos implementar más en la clase como punto de entrada, el resto de la implementación será gestionado por la clase `APIEntryPointRoute`.

--- 

## [**Implementar las distintas rutas**]()

Para la implementación de las rutas, deberemos crear las distinas classes, `APIEntryPointRoute`, `AccountsRoute`, `ContactsRoute` y `OpportunitiesRoute` para gestionar las llamadas REST.

Comenzaremos definiendo la ruta de entrada, que será de la que parta toda la API Rest. (Todas las rutas deben heredar de la clase `RestServiceRoute`)

### [**Implementar Ruta de Entrada de la API**]()

```java
public class APIEntryRoute extends RestServiceRoute {

    // Esta clase solo necesitará implementar (salvo que se quiera atender otras peticiones) el método setupRoutes (heredado) para configurar el enrutamiento de la API

    public override void setupRoutes() {
        // Usamos el método addRoute() (heredado) para añadir todas las rutas de la API
        addRoute('accounts', new AccountsRoute());
        addRoute('contacts', new ContactsRoute());
        addRoute('opportunities', new OpportunitiesRoute());
    }
}
```

--- 

### [**Implementar Ruta de Cuentas (Accounts)**]()

Para implementar la ruta de accounts, deberemos hacer lo siguiente

```java
public class AccountsRoute extends RestServiceRoute {

    // Configuramos las rutas hijas de la ruta de account
    public override void setupRoutes() {
        // Usamos el método addRoute() (heredado) para añadir todas las rutas de la API
        addRoute('contacts', new ContactsRoute(getResourceId()));
        addRoute('opportunities', new OpportunitiesRoute(getResourceId()));
    }

    public override Object doGet() {
        if (!String.isEmpty(getResourceId())) {
            // Tratar la respuesta cuando existe Id de recurso en la URL
            // Endpoint: api/v1.0/accounts/:accountId
            Account acc = new Account();
            // Implementación
            return acc;
        } else if (containsQueryParameter('accountId')){
            String recordId = getQueryParameter('accountId');
            // Tratar la respuesta cuando no viene Id del recurso en la URL, pero viene a través de un parámetro de query de la URL
            // Endpoint: api/v1.0/accounts?accountId=XXXXXXX
            Account acc = new Account();
            // Implementación
            return acc;
        } else {
            // Tratar la respuesta cuando no existe Id de recurso en la URL
            // Endpoint: api/v1.0/accounts
            List<Account> acc = new List<Account>();
            // Implementación
            return acc;
        }
    }

    // Incluir métodos doPost(), doPut() o doDelete() para tratar otro tipo de peticiones
}
```

--- 

### [**Implementar Ruta de Contactos (Contacts)**]()

Para implementar la ruta de contacts, deberemos hacer lo siguiente. (El código de implementación es sólo un ejemplo, no es obligatorio tratar los endpoints como en los ejemplos, o tratar tantas rutas o tipos de rutas)

```java
public class ContactsRoute extends RestServiceRoute {

    private String accountId;

    public ContactsRoute(){

    }

    public ContactsRoute(String accountId){
        this.accountId = accountId;
    }

    public override Object doGet() {
        // Para tratar obtener el Id de cuenta si viene por parámetro query de URL
        // Endpoint: api/v1.0/contacts?accountId=XXXXXX
        if (this.accountId == null && containsQueryParameter('accountId')) {
            this.accountId = getQueryParameter('accountId');
        }

        if (!String.isEmpty(getResourceId())) {
            // Tratar la respuesta si existe Id del recurso en la URL
            // Endpoint: api/v1.0/accounts/:accountId/contacts/:contactId
            // o Endpoint: api/v1.0/contacts/:contactId
            Contact contact;
            if (!String.isEmpty(this.accountId)){
                // Tratar la respuesta si tenemos Id de cuenta
                // Endpoint: api/v1.0/accounts/:accountId/contacts/:contactId
                // o Endpoint: api/v1.0/contacts/:contactId/?accountId=XXXXXX
                // implementación
                return contact;
            } else{
                // Tratar la respuesta si no tenemos Id de cuenta
                // Endpoint: api/v1.0/contacts/:contactId/
                // implementación
                return contact;
            }
            return contact;
        } else if (!String.isEmpty(this.accountId)) {
            // Tratar la respuesta si no existe Id del recurso en la URL, pero tenemos Id de cuenta
            // Endpoint: api/v1.0/contacts?accountId=XXXXXX
            List<Contact> contacts = List<Contact>();
            // Implementación
            return contacts;
        } else {
            // Tratar la respuesta si no existe Id del recurso en la URL y no tenemos id de cuenta
            // Endpoint: api/v1.0/contacts
            List<Contact> contacts = List<Contact>();
            // Implementación
            return contacts;
        }
    }

    // Incluir métodos doPost(), doPut() o doDelete() para tratar otro tipo de peticiones
}
```

La implementación de las rutas de `Opportunities` se harán de forma similar, así como cualquier otra ruta.

--- 

### [**Gestion de Errores**]()
El Framework está diseñado para gestionar los errores de forma automática siempre que se lancen excepciones que herende de la clase `RestService.RestException`, es decir, se pueden crear excepciones personalizadas para mejorar la gestión del framework, que éste sabrá tratarlas automáticamente.

Por defecto, está diseñado para trabajar con el estandar **JSONAPI 1.0** para el envio de errores, pero siempre se puede personalizar la gestión de errores del framework para cualquier ruta. Dentro de la clase `RestServiceError` tendremos todas las clases para enviar errores en el formato JSONAPI 1.0

Para crear una excepción personaliazda, simplemente deberemos hacer lo siguiente:

```java
public class MyCustomException extends RestServiceException {
    // El objeto errorResponse (de tipo Object) se serializará y se incluirá en el body automáticamente en caso de lanzar una excepción. Permite inclir cualquier objeto como respuesta
    public MyCustomException(String message, Integer httpStatus, Object errorResponse) {
        super(message, httpStatus, errorResponse);
    }
}
```

podremos lanzarla en cualquier momento del tratamiento de las llamadas para gestionar errores, los errores serán serializados automáticamente en la respuesta y se incluira el código de estado http, sin que nosotros nos preocupemos de nada más que lanzar la excepción con la información correspondiente.

Si queremos gestionar de forma personalizada el tratamiento de errores cuando se lanzan y no delegar en el framework el 100% de la responsabilidad, podemos sobreescribir en cada ruta el método `handleException()` para gestionar las excepciones lanzadas durante el proceso (tanto por salesforce como por nosotros)

El métod actualmente hace lo siguiente:

```java
protected virtual void handleException(Exception ex) {
    if (ex instanceof RestService.RestServiceException) {
        RestService.RestServiceException restErr = (RestService.RestServiceException)ex;
        response.statusCode = restErr.status;
        response.responseBody = (restErr.errorResponse != null) ? Blob.valueOf(JSON.serialize(restErr.errorResponse)) : response.responseBody;
    } else {
        throw ex;
    }
}
```

Pero podemos sobreescribirlo y tratar las excepciones como deseemos

```java
public class ContactsRoute extends RestServiceRoute {

    public override Object doGet() {
        // Código
    }

    public override Object doPost() {
        // Más código
    }

    ///.... otros métodos

    // Método sobreescrito para la gestión de excepciones
    protected override void handleException(Exception ex) {
        if (ex instanceof RestService.RestServiceException) {
            // Tratar la excepción del framework de forma personalizada
        } else {
            // Tratar las excepciones de Salesforce de forma personalizada
        }
    }

}
```

> --- 
> 
>Salvo casos puntuales, la gestión estandar de errores es más que suficiente para cubrir la mayoría de situaciones, por lo que no será necesario sobreescribir e implementar el método `handleException()`
>
> ---

--- 

### [**Devolviendo otros tipos de datos (`Content-Type`)**]()
Por defecto, el Framework devuelve objetos de tipo JSON, serializados automáticamente en el cuerpo de la respuesta, por lo que establece por defecto el `Content-Type=application/json`, pero si deseamos devolver otro tipo de content type, podemos establecerlo a través del método `setContentType('value')` (heredado) y usar el método `setResponseBody()` (heredado) para establecer el cuerpo de la respuesta (También podemos hacer uso de la propieda `this.response`, heredada tambien, para establecer cualquier parámetro en la respuesta)

Por ejemplo
```java
public class CustomContentExampleRoute extends RestServiceRoute {
    protected override Object doGet() {
        setContentType('text/plain');
        setResponseBody('This response is not a JSON Response');
        // Devolvemos null al establecer el response body y así no incluir nada en la respuesta
        return null;
    }
}
```

>---
>
> Si en lugar de devolver null, devolvemos cualquier otro objeto, este será serializado e inluido en el cuerpo de la respuesta automáticamente, esto es util para enviar respuestas JSON, pero para tipos personalizados, devolver un valor sobreescribiria la respuesta.   
> 
> ---

--- 

### [**Rutas sin recursos**]()

En algunos momentos, es necesario implementar rutas que no cumplen estrictamente el estandar rest `/:RESOURCE_URI/:RESOURCE_ID`, por ejemplo la siguiente ruta:

- `/api/v1/rutaSinParametros/otraRuta`

La ruta `rutaSinParametros` no contiene ningún parámetro, sino que está seguida de la ruta `otraRuta`. Para esto deberemos implementar la ruta de la siguiente forma:

```java
public class RouteWithoutResourceExampleRoute extends RestServiceRoute {

    public RouteWithoutResourceExampleRoute(){
        // En el constructor, llamamos al método withoutResourceId() para indicar que la ruta no tiene Id de recurso que procesar, así pasar a la siguiente ruta si es necesario.
        withoutResourceId();
    }

    // Configuramos las rutas hijas de la ruta de rutaSinParametros
    public override void setupRoutes() {
        // Usamos el método addRoute() (heredado) para añadir todas las ruta
        addRoute('otraRuta', new OtherRoute());
    }

    protected override Object doGet() {
       // Código...
    }
}
```

--- 

### [**Expandir la respuesta**]()
Una función que implementa el Framework de forma automática, es la posibilidad de crear respuestas expandidas, es decir, respuesta que incluyan toda la información disponible, y no sólo la del enpoint solicitado. Por ejemplo, para el endpoint `api/v1.0/accounts/:accountId` tenemos otros endpoints disponibles como:

- `api/v1.0/accounts/:accountId/contacts`
- `api/v1.0/accounts/:accountId/opportunities`

Si elegimos la opción de expand, llamando al endpoint `api/v1.0/accounts/:accountId?expand=true` podemos recibir automáticamente la información del resto de endpoints e incluirla en el cuerpo de la respuesta:
```java
public class AccountRoute extends RestServiceRoute {

    // Configuramos las rutas hijas de la ruta de account
    public override void setupRoutes() {
        // Usamos el método addRoute() (heredado) para añadir todas las rutas de la API
        addRoute('contacts', new ContactsRoute(getResourceId()));
        addRoute('opportunities', new OpportunitiesRoute(getResourceId()));
    }

    public override Object doGet() {
        if (!String.isEmpty(getResourceId())) {
            // Para tratar el endpoint: api/v1.0/accounts/:accountId
            Account acc = // Get account
            // Usámos el método expandResponse() para comprobar si se quiere expandir la respuesta
            if (expandResponse()) {
                return expand(acc);
            }
            return acc;
        }
        //... collection
    }
}
```

El cuerpo expandido quedaría de la siguiente forma:

```json
{
    "Id": "XXXXXXXXXXXX",
    "Name": "Account Example Name",
    "OtherAccountField": "Value",
    "contacts": [
        {
            "Id": "YYYYYYYYYYYYYY",
            "FirtName": "Contact 1 Firt Name",
            "LastName": "Contact 1 Last Name"
        },
        {
            "Id": "YYYYYYYYYYYYYY",
            "FirtName": "Contact 2 Firt Name",
            "LastName": "Contact 2 Last Name"
        }
    ],
    "opportunities": [
        {
            "Id": "ZZZZZZZZZZZZZ",
            "Name": "Opportunity Name",
            "StageName": "Won"
        }
    ]
}
```

--- 

### [**Método Útiles Heredados**]()
La clase `RestServiceRoute` incluye una gran cantidad de métodos heredados útiles y con varias sobrecargas algunos de ellos que permite trabajar de forma más fácil y aportan mayor semántica a la implementación de las clases REST.

- **`withoutResourceId()`**: Metodo para indicar que el endpoint no tiene un Id de recurso
- **`getResourceId()`**: Método para obtener el Id del recurso del la URL
- **`loadResource()`**: Método con múltiples sobrecargas para cargar cualquier recurso de la base de datos
- **`loadResources()`**: Método con múltiples sobrecargas para cargar una lista de recursos de la base de datos
- **`loadRelatedResource()`**: Método con múltiples sobrecargas para cargar un sólo recurso relacionado de la base de datos
- **`loadRelatedResources()`**: Método con múltiples sobrecargas para cargar una lista de recursos relacionados de la base de datos
- **`expandResponse()`**: Método para comprobar si se quiere exandir la respuesta
- **`expand()`**: Método para expandir la respuesta
- **`addRoute()`**: Método para añadir rutas hijas para cada endpoint donde sea necesario

La clase `RestServiceRoute` hereda a su vez de la clase `RestService` que contiene otra serie de métodods útiles y propiedades que heredan todas las rutas implementadas:

- **`request`**: Propiedad para obtener el objeto Rest Request de cada petición
- **`response`**: Propiedad para obtener el objeto Rest Response de cada petición
- **`getQueryParameters()`**: Método para obtener el mapa de parámetros de la URL
- **`containsQueryParameter()`**: Método para comprobar si existe un parámetro concreto en la URL
- **`getQueryParameter()`**: Método para obtenerel valor de un parámetro concreto de la URL
- **`getRequestHeaders()`**: Método para obtener el mapa de valores del header de la petición
- **`containsRequestHeader()`**: Método para comprobar si existe un determinado header en la petición
- **`getRequestHeader()`**: Método para obtener el valor de un header concreto de la petición
- **`addResponseHeader()`**: Método para añadir valores al header de la respuesta
- **`setContentType()`**: Método para establecer el Content-Type de la respuesta si es distinto de `application/json`
- **`setResponseBody()`**: Metodo con sobrecargas para establecer un cuerpo en la respuesta distinto de un JSON

# Contribuciones

- Código: Juan José Longoria López - Kanko (juanjoselongoria@gmail.com)
- Inspirado en el Framework REST [**callawaycloud**](https://github.com/callawaycloud/apex-rest-route)