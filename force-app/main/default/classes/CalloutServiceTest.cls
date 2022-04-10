@isTest
public with sharing class CalloutServiceTest {
    @isTest
    public static void testDoGet() {
        Test.setMock(HttpCalloutMock.class, new TestMock());
        HttpResponse response = CalloutService.doGet().toEndpoint('www.google.es').withParam('name', 'value').withHeader('name', 'value').timeoutLimit(1000).execute();
        system.assertEquals(200, response.getStatusCode());
    }

    @isTest
    public static void testDoGetEndpoint() {
        Test.setMock(HttpCalloutMock.class, new TestMock());
        HttpResponse response = CalloutService.doGet('www.google.es').withParam('name', 'value').withHeader('name', 'value').timeoutLimit(1000).execute();
        system.assertEquals(200, response.getStatusCode());
    }

    @isTest
    public static void testDoPost() {
        Test.setMock(HttpCalloutMock.class, new TestMock());
        HttpResponse response = CalloutService.doPost().toEndpoint('www.google.es').withContentType('text/plain').withParam('name', 'value').withParam('name1', 'value1').withHeader('name', 'value').withBody('body').timeoutLimit(1000).execute();
        system.assertEquals(200, response.getStatusCode());
    }

    @isTest
    public static void testDoPostEndpoint() {
        Test.setMock(HttpCalloutMock.class, new TestMock());
        HttpResponse response = CalloutService.doPost('www.google.es').withParam('name', 'value').withParam('name1', 'value1').withHeader('name', 'value').withBody('body').timeoutLimit(1000).execute();
        system.assertEquals(200, response.getStatusCode());
    }

    @isTest
    public static void testBlobBody() {
        Test.setMock(HttpCalloutMock.class, new TestMock());
        HttpResponse response = CalloutService.doPost().toEndpoint('www.google.es?id=abc').withParam('name', 'value').withHeader('name', 'value').withBody(Blob.valueOf('body')).timeoutLimit(1000).compressed().execute();
        system.assertEquals(200, response.getStatusCode());
    }

    @isTest
    public static void testBlobDocument() {
        Test.setMock(HttpCalloutMock.class, new TestMock());
        HttpResponse response = CalloutService.doPost().toEndpoint('www.google.es').withParam('name', 'value').withHeader('name', 'value').withBody(new Dom.Document()).timeoutLimit(1000).execute();
        system.assertEquals(200, response.getStatusCode());
    }

    @isTest
    public static void testOtherSetters() {
        Test.setMock(HttpCalloutMock.class, new TestMock());
        CalloutService.doPost().toEndpoint('www.google.es').withParam('name', 'value').withHeader('name', 'value').withBody(new Dom.Document()).timeoutLimit(1000).withCertificate('certName').compressed();
    }

    @isTest
    public static void testDoPut() {
        Test.setMock(HttpCalloutMock.class, new TestMock());
        HttpResponse response = CalloutService.doPut().toEndpoint('www.google.es').withParam('name', 'value').withHeader('name', 'value').withBody('body').timeoutLimit(1000).execute();
        system.assertEquals(200, response.getStatusCode());
    }

    @isTest
    public static void testDoPutEndpoint() {
        Test.setMock(HttpCalloutMock.class, new TestMock());
        HttpResponse response = CalloutService.doPut('www.google.es').withParam('name', 'value').withHeader('name', 'value').withBody('body').timeoutLimit(1000).execute();
        system.assertEquals(200, response.getStatusCode());
    }

    @isTest
    public static void testDoDelete() {
        Test.setMock(HttpCalloutMock.class, new TestMock());
        HttpResponse response = CalloutService.doDelete().toEndpoint('www.google.es').withParam('name', 'value').withHeader('name', 'value').timeoutLimit(1000).execute();
        system.assertEquals(200, response.getStatusCode());
    }

    @isTest
    public static void testDoDeleteEndpoint() {
        Test.setMock(HttpCalloutMock.class, new TestMock());
        HttpResponse response = CalloutService.doDelete('www.google.es').withParam('name', 'value').withHeader('name', 'value').timeoutLimit(1000).execute();
        system.assertEquals(200, response.getStatusCode());
    }

    @isTest
    public static void testExecuteRequest() {
        Test.setMock(HttpCalloutMock.class, new TestMock());
        CalloutService.CalloutBuilder builder = CalloutService.doDelete().toEndpoint('www.google.es').withParam('name', 'value').withHeader('name', 'value').timeoutLimit(1000);
        HttpResponse response = CalloutService.execute(builder);
        system.assertEquals(200, response.getStatusCode());
    }

    @isTest
    public static void testNoEntpoint() {
        Test.setMock(HttpCalloutMock.class, new TestMock());
        try {
            HttpResponse response = CalloutService.doGet().withParam('name', 'value').withHeader('name', 'value').timeoutLimit(1000).execute();
        } catch (Exception e) {
            system.assert(e.getMessage().contains('Endpoint not provided'));
        }
    }

    public class TestMock implements HttpCalloutMock {
        public HttpResponse respond(System.HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            return res;
        }
    }
}