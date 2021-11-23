@isTest
public class RestServiceRouteTest {
    private static final String REQUEST_URI = '/api/*';
    private static final String RESOURCE_PATH = '/services/apexrest' + REQUEST_URI;
    public static Account acc {
        get {
            if (acc == null)
                acc = [Select Id, Name from Account];
            return acc;
        }

        set;
    }

    public static Contact contact {
        get {
            if (contact == null)
                contact = [Select Id, LastName from Contact where LastName = 'LastName1'];
            return contact;
        }

        set;
    }

    public static Contact contact2 {
        get {
            if (contact2 == null)
                contact2 = [Select Id, LastName from Contact where LastName = 'LastName2'];
            return contact2;
        }

        set;
    }

    @TestSetup
    public static void setupTest() {
        acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        contact = new Contact();
        contact.LastName = 'LastName1';
        contact.AccountId = acc.Id;
        contact2 = new Contact();
        contact2.LastName = 'LastName2';
        contact2.AccountId = acc.Id;
        insert new List<Contact>{ contact, contact2 };
    }

    @isTest
    public static void testEntryPointRoute() {
        initREST(RESOURCE_PATH, '/api/v1');
        APIEntryRoute router = new APIEntryRoute();
        router.execute();
        System.assertEquals(400, router.response.statusCode);
    }

    @isTest
    public static void testEntryRouteCollections() {
        initREST(RESOURCE_PATH, '/api');
        APIEntryRoute router = new APIEntryRoute();
        router.execute();
        System.assertEquals(400, router.response.statusCode);
    }

    @isTest
    public static void testBaseRouteCollection() {
        initREST(RESOURCE_PATH, '/api/v1/accounts/');
        APIEntryRoute router = new APIEntryRoute();
        router.execute();
        System.assertEquals(200, router.response.statusCode);
        Account[] response = (Account[])JSON.deserialize(router.response.responseBody.toString(), List<Account>.class );
        System.assertEquals(1, response.size());
    }

    @isTest
    public static void testNoResourceRoute() {
        initREST(RESOURCE_PATH, '/api/v1/routeWOP/NextRoute');
        APIEntryRoute router = new APIEntryRoute();
        router.execute();
        System.assertEquals(200, router.response.statusCode);
        System.assertEquals('NextRouteValue', router.response.responseBody.toString());
    }

    @isTest
    public static void testBaseRouteSingle() {
        initREST(RESOURCE_PATH, '/api/v1/accounts/' + acc.Id);
        APIEntryRoute router = new APIEntryRoute();
        router.execute();
        System.assertEquals(200, router.response.statusCode);
        Account response = (Account) JSON.deserialize(router.response.responseBody.toString(), Account.class );
        System.assertEquals(acc.Id, response.Id);
    }

    @isTest
    public static void testSingleExpanded() {
        initREST(RESOURCE_PATH, '/api/v1/accounts/' + acc.Id, new Map<String, String>{ 'expand' => 'true' });
        APIEntryRoute router = new APIEntryRoute();
        router.execute();
        System.assertEquals(200, router.response.statusCode);
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(router.response.responseBody.toString());
        System.assertEquals(acc.Id, response.get('Id'));
    }

    @isTest
    public static void testNestedRouteCollection() {
        initREST(RESOURCE_PATH, '/api/v1/accounts/' + acc.Id + '/contacts');
        APIEntryRoute router = new APIEntryRoute();
        router.execute();
        System.assertEquals(200, router.response.statusCode);
        List<Contact> response = (List<Contact>)JSON.deserialize(router.response.responseBody.toString(), List<Contact>.class );
        System.assertEquals(2, response.size());
    }

    @isTest
    public static void testAlternativeRouteCollection() {
        initREST(RESOURCE_PATH, '/api/v1/contacts', new Map<String, String>{ 'accountId' => acc.Id });
        APIEntryRoute router = new APIEntryRoute();
        router.execute();
        System.assertEquals(200, router.response.statusCode);
        List<Contact> response = (List<Contact>)JSON.deserialize(router.response.responseBody.toString(), List<Contact>.class );
        System.assertEquals(2, response.size());
    }

    @isTest
    public static void testNestedRouteSingle() {
        initREST(RESOURCE_PATH, '/api/v1/accounts/' + acc.Id + '/contacts/' + contact.Id);
        APIEntryRoute router = new APIEntryRoute();
        router.execute();
        System.assertEquals(200, router.response.statusCode);
        Contact response = (Contact) JSON.deserialize(router.response.responseBody.toString(), Contact.class );
        System.assertEquals(contact.Id, response.Id);
    }

    @isTest
    public static void testNestedAlternativeRouteSingle() {
        initREST(RESOURCE_PATH, '/api/v1/contacts/' + contact.Id, new Map<String, String>{ 'accountId' => acc.Id });
        APIEntryRoute router = new APIEntryRoute();
        router.execute();
        System.assertEquals(200, router.response.statusCode);
        Contact response = (Contact) JSON.deserialize(router.response.responseBody.toString(), Contact.class );
        System.assertEquals(contact.Id, response.Id);
    }

    @isTest
    public static void testPostMethod() {
        initREST('POST', RESOURCE_PATH, '/api/v1/accounts', null, null);
        APIEntryRoute router = new APIEntryRoute();
        router.execute();
        System.assertEquals(400, router.response.statusCode);
    }

    @isTest
    public static void testPutMethod() {
        initREST('PUT', RESOURCE_PATH, '/api/v1/accounts', null, null);
        APIEntryRoute router = new APIEntryRoute();
        router.execute();
        System.assertEquals(400, router.response.statusCode);
    }

    @isTest
    public static void testDeleteMethod() {
        initREST('DELETE', RESOURCE_PATH, '/api/v1/accounts', null, null);
        APIEntryRoute router = new APIEntryRoute();
        router.execute();
        System.assertEquals(400, router.response.statusCode);
    }

    @isTest
    public static void testOtherMethod() {
        initREST('PATCH', RESOURCE_PATH, '/api/v1/accounts', null, null);
        APIEntryRoute router = new APIEntryRoute();
        router.execute();
        System.assertEquals(400, router.response.statusCode);
    }

    @isTest
    public static void testLoadResourcesMethods() {
        APIEntryRoute router = new APIEntryRoute();
        SObject result = router.loadResource('Account', new List<String>{'Id', 'Name'}, 'Id', acc.Id);
        system.assertEquals(acc.Id, result.Id);
        router.resourceId = acc.Id;
        result = router.loadResource('Account', new List<String>{'Id', 'Name'}, 'Id');
        system.assertEquals(acc.Id, result.Id);
        result = router.loadResource(new List<String>{'Id', 'Name'});
        system.assertEquals(acc.Id, result.Id);
        result = router.loadResource();
        system.assertEquals(acc.Id, result.Id);
        List<SObject> results = router.loadResources('Account', new List<String>{'Id', 'Name'}, 'Id', acc.Id, 1);
        system.assertEquals(1, results.size());
        results = router.loadResources('Account', new List<String>{'Id', 'Name'}, 1);
        system.assertEquals(1, results.size());
        results = router.loadResources('Account', 1);
        system.assertEquals(1, results.size());
        results = router.loadResources('Account');
        system.assertEquals(1, results.size());
        results = router.loadResources();
        system.assertEquals(1, results.size());
        router.resourceId = contact.Id;
        result = router.loadRelatedResource('Contact', new List<String>{'Id', 'FirstName'}, 'AccountId', acc.Id, 'Id', contact.Id);
        system.assertEquals(contact.Id, result.Id);
        result = router.loadRelatedResource('Contact', 'AccountId', acc.Id, 'Id', contact.Id);
        system.assertEquals(contact.Id, result.Id);
        result = router.loadRelatedResource(new List<String>{'Id', 'FirstName'}, 'AccountId', acc.Id);
        system.assertEquals(contact.Id, result.Id);
        result = router.loadRelatedResource('AccountId', acc.Id);
        system.assertEquals(contact.Id, result.Id);
        results = router.loadRelatedResources('Contact', new List<String>{'Id', 'Name'}, 'AccountId', acc.Id, 2);
        system.assertEquals(2, results.size());
        results = router.loadRelatedResources('Contact', new List<String>{'Id', 'Name'}, 'AccountId', acc.Id);
        system.assertEquals(2, results.size());
        results = router.loadRelatedResources('Contact', 'AccountId', acc.Id);
        system.assertEquals(2, results.size());
    }

    @isTest
    public static void testLoadResourcesMethodsWithoutResources() {
        APIEntryRoute router = new APIEntryRoute();
        SObject result = router.loadResource('Account', new List<String>{'Id', 'Name'}, 'Id', null);
        system.assertEquals(null, result);
        router.resourceId = contact.Id;
        result = router.loadResource('Account', new List<String>{'Id', 'Name'}, 'Id');
        system.assertEquals(null, result);
        List<SObject> results = router.loadResources('Account', new List<String>{'Id', 'Name'}, 'Id', contact.Id, 1);
        system.assertEquals(0, results.size());
        router.resourceId = acc.Id;
        result = router.loadRelatedResource('Contact', new List<String>{'Id', 'FirstName'}, 'AccountId', contact.Id, 'Id', acc.Id);
        system.assertEquals(null, result);
        result = router.loadRelatedResource('Contact', 'AccountId', contact.Id, 'Id', acc.Id);
        system.assertEquals(null, result);
        result = router.loadRelatedResource(new List<String>{'Id', 'FirstName'}, 'AccountId', contact.Id);
        system.assertEquals(null, result);
        result = router.loadRelatedResource('AccountId', contact.Id);
        system.assertEquals(null, result);
        results = router.loadRelatedResources('Contact', new List<String>{'Id', 'Name'}, 'AccountId', contact.Id, 2);
        system.assertEquals(0, results.size());
        results = router.loadRelatedResources('Contact', new List<String>{'Id', 'Name'}, 'AccountId', contact.Id);
        system.assertEquals(0, results.size());
        results = router.loadRelatedResources('Contact', 'AccountId', contact.Id);
        system.assertEquals(0, results.size());
        delete contact;
        delete contact2;
        router.resourceId = contact.Id;
        result = router.loadResource(new List<String>{'Id', 'Name'});
        system.assertEquals(null, result);
        result = router.loadResource();
        system.assertEquals(null, result);
        delete acc;
        results = router.loadResources('Account', new List<String>{'Id', 'Name'}, 1);
        system.assertEquals(0, results.size());
        results = router.loadResources('Account', 1);
        system.assertEquals(0, results.size());
        results = router.loadResources('Account');
        system.assertEquals(0, results.size());
        results = router.loadResources();
        system.assertEquals(0, results.size());
    }


    public class APIEntryRoute extends RestServiceRoute {
        public override void setupRoutes() {
            addRoute('accounts', new AccountsRoute());
            addRoute('contacts', new AccountContactRoute());
            addRoute('routeWOP', new RouteWithoutParam());
        }
    }

    public class RouteWithoutParam extends RestServiceRoute {
        public RouteWithoutParam() {
            withoutResourceId();
        }

        public override void setupRoutes() {
            addRoute('NextRoute', new NextRouteAsParam());
        }
    }

    public class NextRouteAsParam extends RestServiceRoute {
        public override Object doGet() {
            response.responseBody = Blob.valueOf('NextRouteValue');
            return null;
        }
    }

    public class AccountsRoute extends RestServiceRoute {
        public override void setupRoutes() {
            addRoute('contacts', new AccountContactRoute(getResourceId()));
        }

        public override Object doGet() {
            if (!String.isEmpty(getResourceId())) {
                Account account = (Account) loadResource();
                if (expandResponse()) {
                    return expand(account) ;
                }
                return account;
            } else {
                List<Account> accounts = (List<Account>)loadResources('Account');
                return accounts;
            }
        }
    }

    public class AccountContactRoute extends RestServiceRoute {
        private String accountId;

        public AccountContactRoute(){
            this(null);
        }

        public AccountContactRoute(String accountId) {
            this.accountId = accountId;
        }

        protected override Object doGet() {
            if (this.accountId == null && containsQueryParameter('accountId')) {
                this.accountId = getQueryParameter('accountId');
            }
            system.debug(getResourceId());
            if (!String.isEmpty(getResourceId())) {
                Contact contact;
                if (!String.isEmpty(this.accountId))
                    contact = (Contact) loadRelatedResource('Contact', 'AccountId', this.accountId, 'Id', getResourceId());
                else
                    contact = (Contact) loadResource();
                return contact;
            } else if (!String.isEmpty(this.accountId)) {
                List<Contact> contacts = (List<Contact>)loadRelatedResources('Contact', 'AccountId', this.accountId);
                return contacts;
            } else {
                List<Contact> contacts = (List<Contact>)loadResources('Contact');
                return contacts;
            }
        }
    }

    public static void initREST(String resourcePath, String requestUri) {
        initREST('GET', resourcePath, requestUri, null, null);
    }

    public static void initREST(String resourcePath, String requestUri, Map<String, String> queryParams) {
        initREST('GET', resourcePath, requestUri, queryParams, null);
    }

    public static void initREST(String httpMethod, String resourcePath, String requestUri, String body) {
        initREST(httpMethod, resourcePath, requestUri, null, body);
    }

    public static void initREST(String httpMethod, String resourcePath, String requestUri, Map<String, String> queryParams, String body) {
        RestRequest request = new RestRequest();
        request.resourcePath = resourcePath;
        request.requestURI = requestUri;
        request.httpMethod = httpMethod;
        if (queryParams != null) {
            request.params.putAll(queryParams);
        }
        if (body != null) {
            request.requestBody = Blob.valueOf(body);
        }

        RestContext.Request = request;
        RestContext.Response = new RestResponse();
    }

    public static RestServiceError.JSONAPIErrors parseResponseErrors(RestResponse resp) {
        return (RestServiceError.JSONAPIErrors)JSON.deserialize(resp.responseBody.toString(), RestServiceError.JSONAPIErrors.class );
    }
}