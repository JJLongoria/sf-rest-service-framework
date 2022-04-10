/**
 * Class to maky any callout request easy with the builder pattern implemented on CalloutBuilder class
 *
 */
public class CalloutService {
    
    public static final String GET_METHOD = 'GET';
    public static final String POST_METHOD = 'POST';
    public static final String PUT_METHOD = 'PUT';
    public static final String DELETE_METHOD = 'DELETE';

    

    /**
     * Class to build any callout request. This class implements the builder pattern to make callouts calls, easy to use and easy to understand
     * beacuse has semantic methods like withBody(), toEndpoint()...
     *
     */
    public class CalloutBuilder {
        private final Map<String, String> headers;
        private final Map<String, String> params;
        private String method = 'GET';
        private String endpoint;
        private String body;
        private Object objBody;
        private Blob blobBody;
        private Dom.Document bodyDocument;
        private String certificate;
        private Boolean compressed = false;
        private Integer timeout = 0;
        private HttpRequest request;
        /**
         * CalloutBuilder constructor
         *
         * @param method (String): HTTP Method to make the request
         */
        public CalloutBuilder(String method) {
            this.method = method;
            this.headers = new Map<String, String>();
            this.params = new Map<String, String>();
        }

        /**
         * Method to build the HttpRequest object with the builder data
         *
         * @return HttpRequest: Return the HttpRequest builded and prepared to execute
         */
        public HttpRequest build() {
            if (this.endpoint == null || String.isBlank(this.endpoint))
                throw new EndpointNotProvidedException('Endpoint not provided');
            request = new HttpRequest();
            request.setMethod(this.method);
            if (body != null)
                request.setBody(body);
            else if (objBody != null)
                request.setBody(JSON.serialize(objBody));
            else if (blobBody != null)
                request.setBodyAsBlob(blobBody);
            else if (bodyDocument != null)
                request.setBodyDocument(bodyDocument);
            if (this.headers.size() > 0) {
                for (String key : headers.keySet()) {
                    String value = headers.get(key);
                    if (!String.isEmpty(key) && !String.isEmpty(value))
                        request.setHeader(key, headers.get(key));
                }
            }
            if (this.params.size() > 0) {
                String paramsQuery = '';
                Integer index = 0;
                for (String key : params.keySet()) {
                    if (index > 0)
                        paramsQuery += '&';
                    paramsQuery += EncodingUtil.urlEncode(key, 'UTF-8') + '=' + EncodingUtil.urlEncode(params.get(key), 'UTF-8');
                    index++;
                }
                if (this.endpoint.contains('?'))
                    this.endpoint += '&' + paramsQuery;
                else
                    this.endpoint += '?' + paramsQuery;
            }
            request.setEndpoint(this.endpoint);
            if (this.certificate != null)
                request.setClientCertificateName(this.certificate);
            if (this.compressed)
                request.setCompressed(this.compressed);
            if (this.timeout > 0)
                request.setTimeout(this.timeout);
            return request;
        }

        public String getHttpMethod() {
            return this.method;
        }

        /**
         * Method to execute the request (If request not builded, this method will build it)
         *
         * @return HttpResponse: Return the HttpResponse after execute the request
         */
        public HttpResponse execute() {
            if (this.request == null)
                this.build();
            return CalloutService.execute(this.request);
        }

        /**
         * Method to set the request endpoint
         *
         * @param endpoint (String): Request URL Endpoint
         * @return CalloutBuilder: Return the callout builder instance to allow concat method calls
         */
        public CalloutBuilder toEndpoint(String endpoint) {
            this.endpoint = endpoint;
            return this;
        }

        /**
         * Method to add query parameters to the endpoint
         *
         * @param name (String): Query parameter name
         * @param value (String): Query parameter value
         * @return CalloutBuilder: Return the callout builder instance to allow concat method calls
         */
        public CalloutBuilder withParam(String name, String value) {
            this.params.put(name, value);
            return this;
        }

        /**
         * Method to add a header value to the request
         *
         * @param name (String): Header name
         * @param value (String): Header value
         * @return CalloutBuilder: Return the callout builder instance to allow concat method calls
         */
        public CalloutBuilder withHeader(String name, String value) {
            this.headers.put(name, value);
            return this;
        }

        /**
         * Method to set the request content type
         *
         * @param value (String): Content-Type value
         * @return CalloutBuilder: Return the callout builder instance to allow concat method calls
         */
        public CalloutBuilder withContentType(String value) {
            this.headers.put('Content-Type', value);
            return this;
        }

        /**
         * Method to set the timeout milliseconds
         *
         * @param timeout (Integer): Milliseconds befare timeout
         * @return CalloutBuilder: Return the callout builder instance to allow concat method calls
         */
        public CalloutBuilder timeoutLimit(Integer timeout) {
            this.timeout = timeout;
            return this;
        }

        /**
         * Method to add a String body to the request
         *
         * @param body (String): Body on String format
         * @return CalloutBuilder: Return the callout builder instance to allow concat method calls
         */
        public CalloutBuilder withBody(String body) {
            if (this.method != 'GET' && this.method != 'DELETE')
                this.body = body;
            return this;
        }

        /**
         *  Method to set any Object as body to serialize it when build the request
         *
         * @param body (Object): Body as object to serialize it when build the request
         * @return CalloutBuilder: Return the callout builder instance to allow concat method calls
         */
        public CalloutBuilder withBody(Object body) {
            if (this.method != 'GET' && this.method != 'DELETE')
                this.objBody = body;
            return this;
        }

        /**
         * Method to set blob content as request body
         *
         * @param body (Blob): Body as blob
         * @return CalloutBuilder: Return the callout builder instance to allow concat method calls
         */
        public CalloutBuilder withBody(Blob body) {
            if (this.method != 'GET' && this.method != 'DELETE')
                this.blobBody = body;
            return this;
        }

        /**
         * Method to set HTML Document as request body
         *
         * @param body (Dom.Document): HTML Document body
         * @return CalloutBuilder: Return the callout builder instance to allow concat method calls
         */
        public CalloutBuilder withBody(Dom.Document body) {
            if (this.method != 'GET' && this.method != 'DELETE')
                this.bodyDocument = body;
            return this;
        }

        /**
         * Method to add certificates stored on Named Credentials to the request
         *
         * @param certDevName (String): Cert name to add to the request
         * @return CalloutBuilder: Return the callout builder instance to allow concat method calls
         */
        public CalloutBuilder withCertificate(String certDevName) {
            this.certificate = certDevName;
            return this;
        }

        /**
         * Method to indicate that the request content is compressed
         *
         * @return CalloutBuilder: Return the callout builder instance to allow concat method calls
         */
        public CalloutBuilder compressed() {
            this.compressed = true;
            return this;
        }
    }


    /**
     * Method to make any GET request using the CalloutBuilder
     *
     * @return CalloutBuilder: Return a callout builder to create and execute the request
     */
    public static CalloutBuilder doGet() {
        return new CalloutBuilder(GET_METHOD);
    }

    /**
     * Method to make any GET request using the CalloutBuilder
     *
     * @param endpoint (String): Request endpoint
     * @return CalloutBuilder: Return a callout builder to create and execute the request
     */
    public static CalloutBuilder doGet(String endpoint) {
        return new CalloutBuilder(GET_METHOD).toEndpoint(endpoint);
    }

    /**
     * Method to make any POST request using the CalloutBuilder
     *
     * @return CalloutBuilder: Return a callout builder to create and execute the request
     */
    public static CalloutBuilder doPost() {
        return new CalloutBuilder(POST_METHOD);
    }

    /**
     * Method to make any POST request using the CalloutBuilder
     *
     * @param endpoint (String): Request endpoint
     * @return CalloutBuilder: Return a callout builder to create and execute the request
     */
    public static CalloutBuilder doPost(String endpoint) {
        return new CalloutBuilder(POST_METHOD).toEndpoint(endpoint);
    }

    /**
     * Method to make any PUT request using the CalloutBuilder
     *
     * @return CalloutBuilder: Return a callout builder to create and execute the request
     */
    public static CalloutBuilder doPut() {
        return new CalloutBuilder(PUT_METHOD);
    }

    /**
     * Method to make any PUT request using the CalloutBuilder
     *
     * @param endpoint (String): Request endpoint
     * @return CalloutBuilder: Return a callout builder to create and execute the request
     */
    public static CalloutBuilder doPut(String endpoint) {
        return new CalloutBuilder(PUT_METHOD).toEndpoint(endpoint);
    }

    /**
     * Method to make any DELETE request using the CalloutBuilder
     *
     * @return CalloutBuilder: Return a callout builder to create and execute the request
     */
    public static CalloutBuilder doDelete() {
        return new CalloutBuilder(DELETE_METHOD);
    }

    /**
     * Method to make any DELETE request using the CalloutBuilder
     *
     * @param endpoint (String): Request endpoint
     * @return CalloutBuilder: Return a callout builder to create and execute the request
     */
    public static CalloutBuilder doDelete(String endpoint) {
        return new CalloutBuilder(DELETE_METHOD).toEndpoint(endpoint);
    }

    /**
     * Method to execute any Http Request using a CalloutBuilder instance
     *
     * @param builder (CalloutBuilder): CalloutBuilder instance to make the request
     * @return HttpResponse: Http response returned by the request
     */
    public static HttpResponse execute(CalloutBuilder builder) {
        return execute(builder.build());
    }

    /**
     * Method to execute any Http Request using the HttpRequest object (or using CalloutBuilder instance.build() to build and save the request)
     *
     * @param request (HttpRequest): HttpRequest instance to execute
     * @return HttpResponse: Http response returned by the request
     */
    public static HttpResponse execute(HttpRequest request) {
        Http http = new Http();
        return http.send(request);
    }

    public class EndpointNotProvidedException extends Exception {
    }

    public class RequestNotBuildException extends Exception {
    }
}