/**
 * Class to make and handle Async Callouts using continuations
 */
public with sharing class AsyncCalloutService {

    private static final Integer CONT_REQUEST_LIMIT = 3;
    private static final Integer CONT_MAX_TIMEOUT = 120;
    private static final String CONT_DEFAULT_STATUS = 'Default';

    /**
     * Class to store the continuation state and data to every request to handle it on response
     *
     */
    public class ContinuationState {
        public String status { get; set; }

        public Object data { get; set; }

        /**
         * Default constructor
         */
        public ContinuationState() {
            this.status = CONT_DEFAULT_STATUS;
        }

        /**
         * Constructor to set the continuation state value
         *
         * @param status (String): Continuation status value
         */
        public ContinuationState(String status) {
            this.status = status;
        }

        /**
         * Constructor to set the continuation state value and the related data
         *
         * @param status (String): Continuation status value
         * @param data (Object): Continuation status related data
         */
        public ContinuationState(String status, Object data) {
            this.status = status;
            this.data = data;
        }
    }

    private List<String> requestLabels;
    private Transient List<HTTPRequest> requests;
    private Integer timeout;
    private ContinuationState continuationState;

    public AsyncCalloutService() {
        requestLabels = new List<String>();
        continuationState = new ContinuationState();
        timeout = CONT_MAX_TIMEOUT;
        requests = new List<HTTPRequest>();
    }

    public AsyncCalloutService(Integer timeout) {
        this();
        this.timeout = timeout;
    }

    public AsyncCalloutService(Integer timeout, List<HTTPRequest> requests) {
        this();
        this.timeout = timeout;
        this.requests = requests;
        if (this.requests.size() >= 3)
            throw new ContinuationRequestLimitExcededException('Continuation request limit execeed. Max request ' + CONT_REQUEST_LIMIT);
    }
    
    public List<String> getRequestLabels(){
        return this.requestLabels;
    }

    /**
     * Method to set the continuation state for this async call
     *
     * @param status (String): Write the parameter description
     *
     * @return AsyncCalloutService: Return the AsyncCalloutService instance
     */
    public AsyncCalloutService withState(String status) {
        continuationState = new ContinuationState(status);
        return this;
    }

    /**
     * Method to set the continuation state for this async call
     *
     * @param status (String): Write the parameter description
     * @param data (Object): Write the parameter description
     *
     * @return AsyncCalloutService: Return the AsyncCalloutService instance
     */
    public AsyncCalloutService withState(String status, Object data) {
        continuationState = new ContinuationState(status, data);
        return this;
    }

    /**
     * Method to set the timeout milliseconds
     *
     * @param timeout (Integer): Milliseconds before timeout
     *
     * @return CalloutBuilder: Return the AsyncCalloutService instance
     */
    public AsyncCalloutService timeoutLimit(Integer timeout) {
        this.timeout = (timeout > CONT_MAX_TIMEOUT || timeout < 0) ? CONT_MAX_TIMEOUT : timeout;
        return this;
    }

    /**
     * Method to add a request using callout builder instance
     *
     * @param builder (CalloutService.CalloutBuilder): Callout builder instance to execute the async request
     *
     * @return AsyncCalloutService: Return the AsyncCalloutService instance
     */
    public AsyncCalloutService addRequest(CalloutService.CalloutBuilder builder) {
        return addRequest(builder.build());
    }

    /**
     * Method to add http requests to execute
     *
     * @param request (HttpRequest): HTTP Request to execute async
     *
     * @return AsyncCalloutService: Return the AsyncCalloutService instance
     */
    public AsyncCalloutService addRequest(HttpRequest request) {
        if (this.requests.size() >= 3)
            throw new ContinuationRequestLimitExcededException('Continuation request limit execeed. Max request ' + CONT_REQUEST_LIMIT);
        this.requests.add(request);
        return this;
    }

    /**
     * Method to execute the async requests
     *
     * @param continuationMethod (String): Method name to handle continuation reponse
     *
     * @return Continuation: Return the continuation instance
     */
    public Continuation execute(String continuationMethod) {
        if(requests.size() == 0)
            throw new ContinuationHasNoRequestException('Continuation has no request to execute');
        Continuation cont = new Continuation(this.timeout);
        cont.continuationMethod = continuationMethod;
        cont.state = this.continuationState;
        for(HTTPRequest request : requests){
            requestLabels.add(cont.addHttpRequest(request));
        }
        return cont;
    }

    /**
     * Method to get a reponse from a Continuation Async Request
     *
     * @param label (String): Unique Label to get the response
     *
     * @return HttpResponse: HTTP Response from the selected request
     */
    public static HttpResponse getResponse(String label){
        return Continuation.getResponse(label);
    }

    /**
     * Method to get several reponses from a Continuation Async Request
     *
     * @param requestLabels (List<String>): List with unique labels to get responses
     *
     * @return List<HttpResponse>: List with continuation request from the selected labels (in same order)
     */
    public static List<HttpResponse> getResponses(List<String> requestLabels){
        List<HTTPResponse> responses = new List<HTTPResponse>();
        for(String label : requestLabels) {
            responses.add(getResponse(label));
        }
        return responses;
    }

    /**
     * Method to get several reponses from a Continuation Async Request on map format
     *
     * @param requestLabels (List<String>): List with unique labels to get responses
     *
     * @return Map<String, HttpResponse>: Map with the request label as key and response as value.
     */
    public static Map<String, HttpResponse> getResponsesMap(List<String> requestLabels){
        Map<String, HttpResponse> responses = new Map<String, HttpResponse>();
        for(String label : requestLabels) {
            responses.put(label, getResponse(label));
        }
        return responses;
    }

    
    public class ContinuationRequestLimitExcededException extends Exception {
    }

    public class ContinuationHasNoRequestException extends Exception {
    }
}