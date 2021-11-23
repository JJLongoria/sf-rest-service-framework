# [**Callout Service**]()

Dentro de la carpeta de classes en esta misma carpeta, tenemos la clase `CalloutService` (y su correspondiente test) que permite ejecutar cualqueir llamada HTTP de forma muy simple a través del patrón builder que tiene implementado y que aporta una gran semántica a la hora de enteder una llamda Http.

# [**Uso**]()

El uso de esta clase es tremendamente simple, lo que juega en su favor para implementar llamadas callout a otros sistemas. Como se ha comentado, implementa el patron builder para la creación de llamadas HTTP, lo que significa que podemos llamar a todos sus métodos en cadena, salvo los métodos `build()` y `execute()`.

## [**GET**]()

Para ejecutar una llamada GET, simplemente ejecutamos el siguiente código:

```java
HttpResponse response = CalloutService.doGet()
                                      .toEndpoint('www.google.es')
                                      .withParam('name', 'value')
                                      .withHeader('name', 'value')
                                      .timeoutLimit(1000)
                                      .execute();
```

Si lo que queremos es contruir únicamente la llamada, para ejecutarla más tarde, podemos ejecutar lo siguiente

```java
HttpRequest request = CalloutService.doGet()
                                    .toEndpoint('www.google.es')
                                    .withParam('name', 'value')
                                    .withHeader('name', 'value')
                                    .timeoutLimit(1000)
                                    .build();

HttpResponse response = CalloutService.execute(request);
```

Incluso podemos ejecutar directamente el objeto CalloutBuilder devuelto por el método doGet()
```java
CalloutService.CalloutBuilder builder = CalloutService.doGet()
                                                      .toEndpoint('www.google.es')
                                                      .withParam('name', 'value')
                                                      .withHeader('name', 'value')
                                                      .timeoutLimit(1000);
                                      
HttpResponse response = CalloutService.execute(builder);
```

## [**POST**]()

Para ejecutar una llamada POST, ejecutamos el código:
```java
HttpResponse response = CalloutService.doPost()
                                      .toEndpoint('www.google.es')
                                      .withParam('name', 'value')
                                      .withParam('name1', 'value1')
                                      .withHeader('name', 'value')
                                      .withBody('body')
                                      .timeoutLimit(1000)
                                      .execute();
```

Se puede usar de las mismas formas que el método doGet()

## [**PUT**]()

Para ejecutar una llamada PUT, ejecutamos el código:
```java
HttpResponse response = CalloutService.doPut()
                                      .toEndpoint('www.google.es')
                                      .withParam('name', 'value')
                                      .withParam('name1', 'value1')
                                      .withHeader('name', 'value')
                                      .withBody('body')
                                      .timeoutLimit(1000)
                                      .execute();
```

Se puede usar de las mismas formas que el método doGet()

## [**DELETE**]()

Para ejecutar una llamada DELETE, ejecutamos el código:
```java
HttpResponse response = CalloutService.doDelete()
                                      .toEndpoint('www.google.es')
                                      .withParam('name', 'value')
                                      .withHeader('name', 'value')
                                      .timeoutLimit(1000)
                                      .execute();
```

Se puede usar de las mismas formas que el método doGet()

## [**Otros Métodos**]()

La clase `CalloutService.CalloutBuilder` tiene más métodos además de los mostrados en los ejemplos para realizar cualquier llamada HTTP desde Salesforce, incluyendo certificados, cuerpos en formato Blob o Doc.Document, etc.