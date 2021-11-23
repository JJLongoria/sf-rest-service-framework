/**
 * Class to wrap any Rest Service Error
 *
 */
public with sharing class RestServiceError {
    
    /**
     * JSONAPI Standard Error response with errors list
     *
     */
    public class JSONAPIErrors {
        public List<JSONAPIError> errors;
    }

    /**
     * JSONAPI Standard Error response
     *
     */
    public class JSONAPIError {
        public String id;
        public String status;
        public String code;
        public JSONAPIErrorSource source;
        public String title;
        public String detail;
        public Map<String, Object> meta;    // Object to add any custom data
    }

    /**
     * JSONAPI Standard Error source object
     *
     */
    public class JSONAPIErrorSource {
        public String pointer;
        public String parameter;
    }

}
