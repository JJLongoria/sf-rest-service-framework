@isTest
public with sharing class AsyncCalloutServiceTest {
    
    @isTest
    public static void testAsyncCalloutServiceDefaultConstructor(){
        Test.setMock(HttpCalloutMock.class, new TestMock());
        Test.startTest();
        AsyncCalloutService service = new AsyncCalloutService();
        service.timeoutLimit(100);
        service.withState('status');
        service.addRequest(CalloutService.doGet('www.google.es').withParam('name', 'value').withHeader('name', 'value').timeoutLimit(1000).build());
        service.execute('continuationMethod');
        AsyncCalloutService.getResponses(service.getRequestLabels());
        Test.stopTest();
    }

    @isTest
    public static void testAsyncCalloutServiceTimeoutConstructor(){
        Test.setMock(HttpCalloutMock.class, new TestMock());
        Test.startTest();
        AsyncCalloutService service = new AsyncCalloutService(100);
        service.withState('status', 'data');
        service.addRequest(CalloutService.doGet('www.google.es').withParam('name', 'value').withHeader('name', 'value').timeoutLimit(1000));
        service.execute('continuationMethod');
        AsyncCalloutService.getResponse(service.getRequestLabels()[0]);
        Test.stopTest();
    }

    @isTest
    public static void testAsyncCalloutServiceFullConstructor(){
        Test.setMock(HttpCalloutMock.class, new TestMock());
        Test.startTest();
        List<HttpRequest> request = new List<HttpRequest>();
        request.add(CalloutService.doGet('www.google.es').withParam('name', 'value').withHeader('name', 'value').timeoutLimit(1000).build());
        AsyncCalloutService service = new AsyncCalloutService(100, request);
        service.withState('status', 'data');
        service.execute('continuationMethod');
        AsyncCalloutService.getResponsesMap(service.getRequestLabels());
        Test.stopTest();
    }

    @isTest
    public static void testAsyncCalloutServiceNoRequest(){
        Test.setMock(HttpCalloutMock.class, new TestMock());
        Test.startTest();
        try {
            List<HttpRequest> request = new List<HttpRequest>();
            AsyncCalloutService service = new AsyncCalloutService(100, request);
            service.withState('status', 'data');
            service.execute('continuationMethod');   
        } catch (Exception e) {
            system.assert(e.getMessage().contains('Continuation has no request to execute'));
        }
        Test.stopTest();
    }

    @isTest
    public static void testAsyncCalloutServiceNoRequestLimitConstructor(){
        Test.setMock(HttpCalloutMock.class, new TestMock());
        Test.startTest();
        try {
            List<HttpRequest> request = new List<HttpRequest>();
            request.add(CalloutService.doGet('www.google.es').withParam('name', 'value').withHeader('name', 'value').timeoutLimit(1000).build());
            request.add(CalloutService.doGet('www.google.es').withParam('name', 'value').withHeader('name', 'value').timeoutLimit(1000).build());
            request.add(CalloutService.doGet('www.google.es').withParam('name', 'value').withHeader('name', 'value').timeoutLimit(1000).build());
            request.add(CalloutService.doGet('www.google.es').withParam('name', 'value').withHeader('name', 'value').timeoutLimit(1000).build());
            AsyncCalloutService service = new AsyncCalloutService(100, request);
            service.withState('status', 'data');
            service.execute('continuationMethod');   
        } catch (Exception e) {
            system.assert(e.getMessage().contains('Continuation request limit execeed'));
        }
        Test.stopTest();
    }

    @isTest
    public static void testAsyncCalloutServiceNoRequestLimit(){
        Test.setMock(HttpCalloutMock.class, new TestMock());
        Test.startTest();
        try {
            AsyncCalloutService service = new AsyncCalloutService(100);
            service.withState('status', 'data');
            service.addRequest(CalloutService.doGet('www.google.es').withParam('name', 'value').withHeader('name', 'value').timeoutLimit(1000).build());
            service.addRequest(CalloutService.doGet('www.google.es').withParam('name', 'value').withHeader('name', 'value').timeoutLimit(1000).build());
            service.addRequest(CalloutService.doGet('www.google.es').withParam('name', 'value').withHeader('name', 'value').timeoutLimit(1000).build());
            service.addRequest(CalloutService.doGet('www.google.es').withParam('name', 'value').withHeader('name', 'value').timeoutLimit(1000).build());
            service.execute('continuationMethod');   
        } catch (Exception e) {
            system.assert(e.getMessage().contains('Continuation request limit execeed'));
        }
        Test.stopTest();
    }

    public class TestMock implements HttpCalloutMock {
        public HttpResponse respond(System.HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            return res;
        }
    }

}
