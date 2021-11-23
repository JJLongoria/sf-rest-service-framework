# [**REST Service Framework**]()

The REST Service Framework are designed to create a complete API REST on Salesforce easy, with only one entry point (one *@RestResource* class) to **manage an entire standard API REST** easy to focus your efforts on routes definition and implementation.

This framework simplify manage and handle any API REST because use one (or a few) api entry points and not need to remember all entry point classes, only define your routes, the routing and implement your routes, let the framework make the rest.

You only need to extends the class `RestServiceRoute` on any Rest API Route to create your API. 

# [**Implementation**]()

## [**Define Routes**]()

For example, we need to define the next routes on our API to work with Accounts, Opportunities and Contacts:

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

The Tree routes are the next:

                api/v1.0
            _______|_______
            |      |      |
            |   Accounts  |
            |______|______|
            |             |
        Contacts     Opportunities           

## [**Transform Routes to Classes**]()

According the tree routes, we have an entry point `api/v1.0` and, at least, three main routes (classes), `Accounts`, `Contacts` and `Opportunidades`

We can transform the routes on classes like this: 
- `api/v1.0` => `APIEntryPointRoute`
- `Accounts` => `AccountsRoute`
- `Contacts` => `ContactsRoute`
- `Opportunities` => `OpportunitiesRoute`

With this design, all main routes will be defined in `APIEntryPointRoute`, that is, `accounts`, `contacts` and `opportunities` routes and their controller classes (`AccountsRoute`, `ContactsRoute` and `OpportunitiesRoute`)

De esta forma la definición de las rutas principales de la API estarán en `APIEntryPointRoute` es decir, las rutas, `accounts`, `contacts` y `opportunities` estarán aqui definidas, así como su clase controladora respectivamente (`AccountsRoute`, `ContactsRoute` y `OpportunitiesRoute`)

Therefore, the **`AccountsRoute`** class will manage the next routes

- `api/v1.0/accounts/`
- `api/v1.0/accounts/:accountId`

and  **`ContactsRoute`**class will handle this routes

- `api/v1.0/accounts/:accountId/contacts`
- `api/v1.0/accounts/:accountId/contacts/:contactId`
- `api/v1.0/contacts`
- `api/v1.0/contacts/:contactId`

and last, the **`OpportunitiesRoute`** class will be respond to all this routes

- `api/v1.0/accounts/:accountId/opportunities`
- `api/v1.0/accounts/:accountId/opportunities/:oppId`
- `api/v1.0/opportunities`
- `api/v1.0/opportunities/:oppId`

--- 

## [**Define the API REST Entry Point `@RestResource`**]()

With this framework, we can define only one entry point to all our REST APIs on our Salesforce project, that is, onle one class with @RestResource tag, because the framework will handle and routing all requests.

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
No need implement any more on the entry point class, the entire implementation will be handle by `APIEntryPointRoute` as main router class.

--- 

## [**Implement your Routes**]()

To implement the routes, we must create the classes `APIEntryPointRoute`, `AccountsRoute`, `ContactsRoute` and `OpportunitiesRoute` to handle REST Requests.

### [**Implement API Entry Point Route**]()

```java
public class APIEntryRoute extends RestServiceRoute {

    // This class only need to implement (excep to handle other requests) the setupRoutes() method (inherited) to setup the API Routing

    public override void setupRoutes() {
        // use method addRoute() (inherited) to add any route to the API
        addRoute('accounts', new AccountsRoute());
        addRoute('contacts', new ContactsRoute());
        addRoute('opportunities', new OpportunitiesRoute());
    }
}
```

--- 

### [**Implement Account Route (accounts)**]()

The Account route implementation example are:

```java
public class AccountsRoute extends RestServiceRoute {

    // Setup child routes
    public override void setupRoutes() {
        // use method addRoute() (inherited) to add any child route to account endpoint
        addRoute('contacts', new ContactsRoute(getResourceId()));
        addRoute('opportunities', new OpportunitiesRoute(getResourceId()));
    }

    public override Object doGet() {
        if (!String.isEmpty(getResourceId())) {
            // Handle request when have resourceId on URL
            // Endpoint: api/v1.0/accounts/:accountId
            Account acc = new Account();
            // Implementation not shown
            return acc;
        } else if (containsQueryParameter('accountId')){
            String recordId = getQueryParameter('accountId');
            // Handle request when not has resourceId on URL but has resourceId on URL query parameter
            // Endpoint: api/v1.0/accounts?accountId=XXXXXXX
            Account acc = new Account();
            // Implementation not shown
            return acc;
        } else {
            // Handle request when not has resource Id on URL
            // Endpoint: api/v1.0/accounts
            List<Account> acc = new List<Account>();
            // Implementation not shown
            return acc;
        }
    }

    // Include methods doPost(), doPut() or doDelete() to handle other requests
}
```

--- 

### [**Implement Contacts Route (contacts)**]()

To implement the example contacts route, you can do the next:

```java
public class ContactsRoute extends RestServiceRoute {

    private String accountId;

    public ContactsRoute(){

    }

    public ContactsRoute(String accountId){
        this.accountId = accountId;
    }

    public override Object doGet() {
        // To get the account Id if has on URL Query parameters
        // Endpoint: api/v1.0/contacts?accountId=XXXXXX
        if (this.accountId == null && containsQueryParameter('accountId')) {
            this.accountId = getQueryParameter('accountId');
        }

        if (!String.isEmpty(getResourceId())) {
            // Handle request when have resourceId on URL
            // Endpoint: api/v1.0/accounts/:accountId/contacts/:contactId
            // or Endpoint: api/v1.0/contacts/:contactId
            Contact contact;
            if (!String.isEmpty(this.accountId)){
                // Handle request when has accountId
                // Endpoint: api/v1.0/accounts/:accountId/contacts/:contactId
                // or Endpoint: api/v1.0/contacts/:contactId/?accountId=XXXXXX
                // Implementation not shown
                return contact;
            } else{
                // Handle request when not has accountId
                // Endpoint: api/v1.0/contacts/:contactId/
                // Implementation not shown
                return contact;
            }
            return contact;
        } else if (!String.isEmpty(this.accountId)) {
            // Handle request when not has resourceId but with acoountId like query parameter
            // Endpoint: api/v1.0/contacts?accountId=XXXXXX
            List<Contact> contacts = List<Contact>();
            // Implementation not shown
            return contacts;
        } else {
            // Handle request when not has resourceId or accountId
            // Endpoint: api/v1.0/contacts
            List<Contact> contacts = List<Contact>();
            // Implementation not shown
            return contacts;
        }
    }

    // Include methods doPost(), doPut() or doDelete() to handle other requests
}
```

The `Opportunities` route implementation will be simillar like the other routes.

--- 

### [**Handling Errors**]()
This Framework are designed to handle errors automatically when you use any class that extends from `RestService.RestException` class, that is, you can crete your custom exceptions to handling errors.

By default, the framework work with the estandard **JSONAPI 1.0** to return errors, but your can return any other object as response when you want. Into `RestServiceError` has all classes to handle errors with **JSONAPI 1.0**

To create custom exceptions:

```java
public class MyCustomException extends RestServiceException {
    // The object errorResponse will be serialized and included into the response body automatically when you throw any exception.
    public MyCustomException(String message, Integer httpStatus, Object errorResponse) {
        super(message, httpStatus, errorResponse);
    }
}
```

You can throw or exception on any moment to handle errors and will be serialized and included into the response body automatically, including the httpStatus value into the response status code.

If you need to handle customized errors, can override the `handleException()` on any route to make your custom code error handling.

The actual method do the next:

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

And we can override and make anything with it

```java
public class ContactsRoute extends RestServiceRoute {

    public override Object doGet() {
        // Code
    }

    public override Object doPost() {
        // Mode Code
    }

    ///.... other methods

    // override method to handle errors customized
    protected override void handleException(Exception ex) {
        if (ex instanceof RestService.RestServiceException) {
            // Handle framework exceptions
        } else {
            // Handle other any exception
        }
    }

}
```

> --- 
> 
> Only on special cases you will need to override the `handleException()` method
>
> ---

--- 

### [**Return other Data types (`Content-Type`)**]()
The Rest Service Framework return by default JSON data (`Content-Type=application/json`), because serialize automatically the returned response object by the route methods to include on response body. If you need to return any other data type, can use the methods `setContentType('value')` and `setResponseBody()` (both inherited) to set the content type and body to your response. (You can use `this.response` like route property to modify anything of the response)

Example:
```java
public class CustomContentExampleRoute extends RestServiceRoute {
    protected override Object doGet() {
        setContentType('text/plain');
        setResponseBody('This response is not a JSON Response');
        // Return null to not include anything on body serialized as JSON (default behaviour)
        return null;
    }
}
```

>---
>
> If not return null, the response body setted with `setResponseBody()` method will be override.
> 
> ---

--- 

### [**Routes without ResourceId**]()

Sometimes, you need to implement the not standard REST routes like `/:RESOURCE_URI/:RESOURCE_ID`, for example, the next route:

- `/api/v1/routeWithoutParam/otherRoute`

The `routeWithoutParam` route has not resourceId, in this case the next route are `otraRuta`. To implement this cases, you can do:

```java
public class RouteWithoutResourceExampleRoute extends RestServiceRoute {

    public RouteWithoutResourceExampleRoute(){
        // On the constructor we call withoutResourceId() method to indicate to the framework that this route has not parameters
        withoutResourceId();
    }

    // setup child routes
    public override void setupRoutes() {
        // use addRoute() method (inherited) to add any route
        addRoute('otherRoute', new OtherRoute());
    }

    protected override Object doGet() {
       // Code...
    }
}
```

--- 

### [**Expand Response**]()
An interesting framework function is the ability to expand the response object, that is, get all child routes data into one single response object. For example we can call the endpoint `api/v1.0/accounts/:accountId` and get the entire data from:

- `api/v1.0/accounts/:accountId/contacts`
- `api/v1.0/accounts/:accountId/opportunities`

To choose the expand response, call endpoints like this: `api/v1.0/accounts/:accountId?expand=true` 
```java
public class AccountRoute extends RestServiceRoute {

    // Setu child routes
    public override void setupRoutes() {
        // use addRoute() method (inherited) to add any route
        addRoute('contacts', new ContactsRoute(getResourceId()));
        addRoute('opportunities', new OpportunitiesRoute(getResourceId()));
    }

    public override Object doGet() {
        if (!String.isEmpty(getResourceId())) 
            Account acc = // Get account
            // Use expandResponse() method to check if need to expand the response
            if (expandResponse()) {
                return expand(acc);
            }
            return acc;
        }
        //... collection
    }
}
```

The expanded response will be like this:

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

### [**Util inherited methods**]()
The `RestServiceRoute` class include to many inherited methods to use on any implement route to make easy implement APIs:

- **`withoutResourceId()`**: To indicate that the route has not resource Id
- **`getResourceId()`**: To get the resource id from URL 
- **`loadResource()`**: Method with several overloads to load a single resource (record) from database
- **`loadResources()`**: Method with several overloads to load a resources list (records) from database
- **`loadRelatedResource()`**: Method with several overloads to load a single related resource (record) from database
- **`loadRelatedResources()`**: Method with several overloads to load related resources (records) from database
- **`expandResponse()`**: Method to check if must return an expanded response
- **`expand()`**: Method to expand the response with all endpoint data (with child endpoints data)
- **`addRoute()`**: Method to add child routes to any route

The `RestServiceRoute` class also inherit from `RestService` class and contains other interesting methods to use on childs:

- **`request`**: Property to get the Rest Request object
- **`response`**: Property to get the Rest Response object
- **`getQueryParameters()`**: Method to get the request query parameters map
- **`containsQueryParameter()`**: Method to check if exists the selected request query parameter
- **`getQueryParameter()`**: Method to get the selected request query paramter value
- **`getRequestHeaders()`**: Method to get the request headers map
- **`containsRequestHeader()`**: Method check if the request contains the selected header
- **`getRequestHeader()`**: Method to get the request header selected value
- **`addResponseHeader()`**: Method to add headers to response
- **`setContentType()`**: To set the response content type (to use different from `application/json`)
- **`setResponseBody()`**: To set the response body content (to use different from JSON responses)

# Contributions

- Code: Juan José Longoria López - Kanko (juanjoselongoria@gmail.com)
- Inspired on REST Framework [**callawaycloud**](https://github.com/callawaycloud/apex-rest-route)