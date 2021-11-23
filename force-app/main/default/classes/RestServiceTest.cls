@isTest
public with sharing class RestServiceTest {

    public class RestRerviceTestClass extends RestService{

    }

    @isTest
    public static void testMethods(){
        RestRerviceTestClass service = new RestRerviceTestClass();
        service.request.resourcePath = '/services/apexrest/api/*';
        service.request.requestURI = '/api/v1/account/accId';
        service.request.params.put('testParamName1', 'testParamValue1');
        service.request.addHeader('testHeaderName1', 'testHeaderValue1');
        service.addResponseHeader('testHeaderName1', 'testHeaderValue1');
        system.assert(service.containsQueryParameter('testParamName1'));
        system.assertEquals(service.getQueryParameters(), new Map<String, String>{ 'testParamName1' => 'testParamValue1' });
        system.assertEquals(service.getQueryParameter('testParamName1'), 'testParamValue1');
        system.assert(service.containsRequestHeader('testHeaderName1'));
        system.assertEquals(service.getRequestHeaders(), new Map<String, String>{ 'testHeaderName1' => 'testHeaderValue1' });
        system.assertEquals(service.getRequestHeader('testHeaderName1'), 'testHeaderValue1');
        system.assertEquals(service.response.headers, new Map<String, String>{ 'testHeaderName1' => 'testHeaderValue1' });
        system.assertEquals(service.getRelativePaths(service.getBasePath()), new List<String>{'', 'v1', 'account', 'accId'});
        system.assertEquals(service.getRequestHeader('testHeaderName1'), 'testHeaderValue1');
        new RestService.RestServiceException('Could not find route for: ' + service.request.requestURI, 404, new RestServiceError.JSONAPIErrors());
        new RestService.RestServiceException('Could not find route for: ' + service.request.requestURI, 'NOT_FOUND', 404);
        new RestService.RouteNotFoundException(service.request);
        new RestService.MethodNotSupportedException(service.request);
        new RestService.ResourceIdNotFoundException(service.request);
        new RestService.ResourceNotFoundException(service.request, 'id');
    }

}
