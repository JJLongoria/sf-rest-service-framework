/**
 * Class to create any Rest Service
 *
 */
public abstract class RestService {

    private static final String REST_BASE_URL = '/services/apexrest';

    public RestRequest request {
        get {
            if (RestContext.request == null)
                RestContext.request = new RestRequest();
            return RestContext.request;
        }
        private set;
    }

    public RestResponse response {
        get {
            if (RestContext.response == null)
                RestContext.response = new RestResponse();
            return RestContext.response;
        }
        private set;
    }

    /**
     * Method to get the URL Base path
     *
     * @return String: Return the URL base path
     */
    @TestVisible
    protected String getBasePath(){
        return this.request.resourcePath.replace(REST_BASE_URL, '').replace('/*', '');
    }

    /**
     * Method to get the URL relative paths from Base path
     *
     * @param basePath (String): Base path to get relative paths
     * @return List<String>: Return the relative paths list
     */
    @TestVisible
    protected List<String> getRelativePaths(String basePath){
        return this.request.requestURI.replace(basePath, '').split('\\/');
    }

    /**
     * Method to get the Query parameters map from the Rest request
     *
     * @return Map<String, String>: Query parameters map
     */
    @TestVisible
    protected Map<String, String> getQueryParameters() {
        return this.request.params;
    }

    /**
     * Method to check if exists the selected query parameter
     *
     * @param name (String): Query parameter name to check
     * @return Boolean: True if exists, false in otherwise
     */
    @TestVisible
    protected Boolean containsQueryParameter(String name) {
        return this.request.params.containsKey(name);
    }

    /**
     * Method to get any query parameter value using the parameter name
     *
     * @param name (String): Query parameter name to get the value
     * @return String: Return the selected query parameter value
     */
    @TestVisible
    protected String getQueryParameter(String name) {
        return this.request.params.get(name);
    }
    
    /**
     * Method to get the Headers map from the Rest request
     *
     * @return Map<String, String>: Headers map
     */
    @TestVisible
    protected Map<String, String> getRequestHeaders() {
        return this.request.headers;
    }

    /**
     * Method to check if exists the selected request header
     *
     * @param name (String): Header name to check
     * @return Boolean: True if exists, false in otherwise
     */
    @TestVisible
    protected Boolean containsRequestHeader(String name) {
        return this.request.headers.containsKey(name);
    }

    /**
     * Method to get any header value using the header name from the Rest request
     *
     * @param name (String): Header name to get the value
     * @return String: Return the selected header value
     */
    @TestVisible
    protected String getRequestHeader(String name) {
        return this.request.headers.get(name);
    }

    /**
     * Method to add Header value to the rest response
     *
     * @param name (String): Header name
     * @param value (String): Header value
     */
    @TestVisible
    protected void addResponseHeader(String name, String value) {
        this.response.headers.put(name, value);
    }

    /**
     * Method to set the Content Type response header
     *
     * @param type (String): Content-type value like 'text/plain' or 'application/json'
     */
    protected void setContentType(String type){
        addResponseHeader('Content-Type', type);
    }

    /**
     * Method to set the response body as String format
     *
     * @param body (String): String response body
     */
    protected void setResponseBody(String body){
        if(body != null)
            setResponseBody(Blob.valueOf(body));
    }

    /**
     * Method to set the response body as Blob format
     *
     * @param body (Blob): Blob response body
     */
    protected void setResponseBody(Blob body){
        this.response.responseBody = body;
    }

    /**
     * Rest exception class as superclass to any rest exception
     *
     */
    public virtual class RestServiceException extends Exception {
        public Object errorResponse;
        public Integer status;
        public RestServiceException(String message, Integer status, Object errorResponse) {
            this.setMessage(message);
            this.errorResponse = errorResponse;
            this.status = status;
        }

        public RestServiceException(String message, String code, Integer status) {
            this.setMessage(message);
            this.errorResponse = new RestServiceError.JSONAPIErrors();
            ((RestServiceError.JSONAPIErrors)this.errorResponse).errors = new List<RestServiceError.JSONAPIError>();
            ((RestServiceError.JSONAPIErrors)this.errorResponse).errors.add(new RestServiceError.JSONAPIError());
            ((RestServiceError.JSONAPIErrors)this.errorResponse).errors[0].code = code;
            ((RestServiceError.JSONAPIErrors)this.errorResponse).errors[0].title = message;
            this.status = status;
        }
    }

    /**
     * Exception to throw when not found any route to execute
     *
     */
    public class RouteNotFoundException extends RestServiceException {
        public RouteNotFoundException(RestRequest req) {
            super('Could not find route for: ' + req.requestURI, 'NOT_FOUND', 404);
        }
    }

    /**
     * Exception to throw when the method is not supported (or implemented)
     *
     */
    public class MethodNotSupportedException extends RestServiceException {
        public MethodNotSupportedException(RestRequest req) {
            super('Method ' + req.httpMethod + ' is not supported', 'NOT_SUPPORTED', 400);
        }

        public MethodNotSupportedException(CalloutService.CalloutBuilder builder) {
            super('Method ' + builder.getHttpMethod() + ' is not supported', 'NOT_SUPPORTED', 400);
        }
    }

    /**
     * Exception to throw when not found the resource Id
     *
     */
    public class ResourceIdNotFoundException extends RestServiceException {
        public ResourceIdNotFoundException(RestRequest req) {
            super('Resource Id not found', 'NOT_FOUND', 404);
        }
    }

    /**
     * Exception to throw when not found the searched resource
     *
     */
    public class ResourceNotFoundException extends RestServiceException {
        public ResourceNotFoundException(RestRequest req, String resourceId) {
            super('Resource does not exist with Id: ' + resourceId, 'NOT_FOUND', 404);
        }
    }
}