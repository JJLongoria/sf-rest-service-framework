/**
 * Class to create Rest Routes and implement a robust Rest API Framework
 * Any Rest class (as exposed REST resource, not callout resource) will be extends from this class
 * Any child class must to implement, at least, one of this methods to handle REST resources (Not required on intermediate routes with no processing required):
 *  - doGet()
 *  - doPost()
 *  - doPut()
 *  - doDelete()
 *
 * Other methods that you can implement if need:
 *  - setupRoutes(): To setup child routes to any endpoint
 *  - nextRoute(): To change the route handling (only recommended on special cases)
 *  - handleException(): Override only if need to create your exceptions handling
 *
 * Other utils methods to use on childs. (Inherited, do not required implementation and can't override it)
 *  - withoutResourceId(): To indicate that the route has not resource Id
 *  - getResourceId(): To get the resource id from URL 
 *  - loadResource(): Method with several overloads to load a single resource (record) from database
 *  - loadResources(): Method with several overloads to load a resources list (records) from database
 *  - loadRelatedResource(): Method with several overloads to load a single related resource (record) from database
 *  - loadRelatedResources(): Method with several overloads to load related resources (records) from database
 *  - expandResponse(): Method to check if must return an expanded response
 *  - expand(): Method to expand the response with all endpoint data (with child endpoints data)
 *  - addRoute(): Method to add child routes to any route
 * 
 *  This class inherits from RestService class, and has the next methods and properties to use on childs:
 * 
 *  - request: Property to get the Rest Request object
 *  - response: Property to get the Rest Response object
 *  
 *  - getQueryParameters(): Method to get the request query parameters map
 *  - containsQueryParameter(String name): Method to check if exists the selected request query parameter
 *  - getQueryParameter(String name): Method to get the selected request query paramter value
 *  - getRequestHeaders(): Method to get the request headers map
 *  - containsRequestHeader(String name): Method check id the request contains the selected header
 *  - getRequestHeader(String name): Method to get the request header selected value
 *  - addResponseHeader(String name, String value): Method to add headers to response
 *  - setContentType(): To set the response content type (to use different from application/json)
 *  - setResponseBody(): To set the response body content (to use different from JSON responses)
 * 
 * 
 * Can use the MethodNotSupportedException class to throw exceptions on not implemented methods (because must exists on child class)
 * Also can use other RestService exception or create your own exceptions but must inherit from RestServiceException from RestService class
 *
 * Inspired in callawaycloud Rest Framework: https://github.com/callawaycloud/apex-rest-route
 */
public abstract class RestServiceRoute extends RestService {
    @TestVisible
    protected String[] routePaths;
    @TestVisible
    protected String resourceId;
    @TestVisible
    protected Map<String, RestServiceRoute> routesMap;
    @TestVisible
    protected Boolean hasResourceId = true;
    /**
     * Method to execute the route (automatically will get the correct method to execute)
     *
     */
    public void execute() {
        try {
            processRoutePaths();
            setContentType('application/json');
            Object responseObject = executeRoute();
            response.responseBody = (responseObject != null) ? Blob.valueOf(JSON.serialize(responseObject)) : response.responseBody;
            response.statusCode = (response.statusCode != null) ? response.statusCode : 200;
        } catch (Exception e) {
            system.debug(e);
            handleException(e);
        }
    }

    /**
     * METHODS TO IMPLEMENT ON CHILDS
     */
    // IMPLEMENTATION OPTIONAL
    /**
     * Method to implemente and execute GET Requests
     *
     * @return Object: Return the response data
     */
    protected virtual Object doGet() {
        throw new RestService.MethodNotSupportedException(request);
    }

    /**
     * Method to implemente and execute POST Requests
     *
     * @return Object: Return the response data
     */
    protected virtual Object doPost() {
        throw new RestService.MethodNotSupportedException(request);
    }

    /**
     * Method to implemente and execute PUT Requests
     *
     * @return Object: Return the response data
     */
    protected virtual Object doPut() {
        throw new RestService.MethodNotSupportedException(request);
    }

    /**
     * Method to implemente and execute DELETE Requests
     *
     * @return Object: Return the response data
     */
    protected virtual Object doDelete() {
        throw new RestService.MethodNotSupportedException(request);
    }

    /**
     * Method to setup the child routes for the RestService
     * user addRoute() method to add routes to this methods
     */
    protected virtual void setupRoutes() {
    }

    /**
     * Method to get the next route to execute. Override only on special cases
     *
     * @return RestServiceRoute: Return the next route to execute
     */
    protected virtual RestServiceRoute nextRoute() {
        String nextPath = peakNextPath();
        setupRoutes();
        if (routesMap != null && routesMap.containsKey(nextPath)) {
            RestServiceRoute route = routesMap.get(nextPath);
            route.routePaths = this.routePaths;
            return routesMap.get(nextPath);
        }
        throw new RestService.RouteNotFoundException(request);
    }

    /**
     * Method to handle any exception
     *
     * @param ex (Exception): Exception to handle
     */
    protected virtual void handleException(Exception ex) {
        if (ex instanceof RestService.RestServiceException) {
            RestService.RestServiceException restErr = (RestService.RestServiceException)ex;
            response.statusCode = restErr.status;
            response.responseBody = (restErr.errorResponse != null) ? Blob.valueOf(JSON.serialize(restErr.errorResponse)) : response.responseBody;
        } else {
            throw ex;
        }
    }

    /**
     * END METHODS TO IMPLEMENT ON CHILDS
     */
    /**
     * Method to indicate that the route has not resource Id
     */
    protected void withoutResourceId() {
        this.hasResourceId = false;
    }

    /**
     * Method to load the resource id from URL
     *
     */
    protected void loadResourceId() {
        this.resourceId = (hasResourceId && this.routePaths.size() >= 1) ? this.peakNextPath() : this.resourceId;
    }

    /**
     * Method to get thhe loaded resource id from URL
     *
     * @return String: Return the resource Id
     */
    protected String getResourceId() {
        return this.resourceId;
    }

    /**
     * Method to load any single resource from the Database
     *
     * @param objName (String): Object API Name to load
     * @param fields (List<String>): Projection fields to load
     * @param fieldKey (String): Field to search using resourceId value
     * @param resourceId (String): Resource Id value
     * @return SObject: Return the found SObject
     */
    @TestVisible
    protected SObject loadResource(String objName, List<String> fields, String fieldKey, String resourceId) {
        if (!String.isEmpty(resourceId)) {
            String query = 'Select ' + String.join(fields, ',') + ' from ' + objName + ' where ' + fieldKey + ' = :resourceId limit 1';
            List<SObject> result = Database.query(query);
            return (result.size() == 1) ? result[0] : null;
        }
        return null;
    }

    /**
     * Method to load any single resource from the Database using the resource Id value from URL
     *
     * @param objName (String): Object API Name to load
     * @param fields (List<String>): Projection fields to load
     * @param fieldKey (String): Field to search using resourceId value
     * @return SObject: Return the found SObject
     */
    @TestVisible
    protected SObject loadResource(String objName, List<String> fields, String fieldKey) {
        return loadResource(objName, fields, fieldKey, this.resourceId);
    }

    /**
     * Method to load any single resource from the Database by Id using the resource Id value from URL
     *
     * @param fields (List<String>): Projection fields to load
     * @return SObject: Return the found SObject
     */
    @TestVisible
    protected SObject loadResource(List<String> fields) {
        try {
            if (!String.isEmpty(this.resourceId)) {
                Id idVal = Id.valueOf(this.resourceId);
                SObjectType objType = idVal.getSobjectType();
                if (objType != null) {
                    Map<String, Schema.SObjectField> fieldsMap = objType.getDescribe().fields.getMap();
                    return loadResource(objType.getDescribe().getName(), fields, 'Id', this.resourceId);
                }
            }
        } catch (Exception e) {
        }
        return null;
    }

    /**
     * Method to load any single resource with all fields from the Database by Id using the resource Id value from URL
     *
     * @return SObject: Return the found SObject
     */
    @TestVisible
    protected SObject loadResource() {
        try {
            if (!String.isEmpty(this.resourceId)) {
                Id idVal = Id.valueOf(this.resourceId);
                SObjectType objType = idVal.getSobjectType();
                if (objType != null) {
                    Map<String, Schema.SObjectField> fieldsMap = objType.getDescribe().fields.getMap();
                    return loadResource(objType.getDescribe().getName(), new List<String>(fieldsMap.keySet()), 'Id', this.resourceId);
                }
            }
        } catch (Exception e) {
        }
        return null;
    }

    /**
     * Method to load a resource list from the Database
     *
     * @param objName (String): Object API Name to load
     * @param fields (List<String>): Projection fields to load
     * @param fieldKey (String): Field to search using resourceId value
     * @param resourceId (String): Resource Id value
     * @param recordsLimit (Integer): Max records to load
     * @return SObject: Return the found SObject
     */
    @TestVisible
    protected List<SObject> loadResources(String objName, List<String> fields, String fieldKey, String resourceId, Integer recordsLimit) {
        String query = 'Select ' + String.join(fields, ',') + ' from ' + objName;
        if (fieldKey != null)
            query += ' where ' + fieldKey + ' = :resourceId';
        if (recordsLimit > 0)
            query += ' limit :recordsLimit';
        return Database.query(query);
    }

    /**
     * Method to load a resource list from the Database
     *
     * @param objName (String): Object API Name to load
     * @param fields (List<String>): Projection fields to load
     * @param recordsLimit (Integer): Max records to load
     * @return SObject: Return the found SObject
     */
    @TestVisible
    protected List<SObject> loadResources(String objName, List<String> fields, Integer recordsLimit) {
        return loadResources(objName, fields, null, null, recordsLimit);
    }

    /**
     * Method to load a resource list with all fields from the Database
     *
     * @param objName (String): Object API Name to load
     * @param recordsLimit (Integer): Max records to load
     * @return SObject: Return the found SObject
     */
    @TestVisible
    protected List<SObject> loadResources(String objName, Integer recordsLimit) {
        SObjectType objType = Schema.getGlobalDescribe().get(objName);
        if (objType != null) {
            Map<String, Schema.SObjectField> fieldsMap = objType.getDescribe().fields.getMap();
            return loadResources(objName, new List<String>(fieldsMap.keySet()), null, null, recordsLimit);
        }
        return new List<SObject>();
    }

    /**
     * Method to load a resource list with all fields from the Database
     *
     * @param objName (String): Object API Name to load
     * @return SObject: Return the found SObject
     */
    @TestVisible
    protected List<SObject> loadResources(String objName) {
        SObjectType objType = Schema.getGlobalDescribe().get(objName);
        if (objType != null) {
            Map<String, Schema.SObjectField> fieldsMap = objType.getDescribe().fields.getMap();
            return loadResources(objName, new List<String>(fieldsMap.keySet()), null, null, 0);
        }
        return new List<SObject>();
    }

    /**
     * Method to load a resource list with all fields from the Database with the Resource Obj Type (resource Id need to be a Salesforce Id)
     *
     * @return SObject: Return the found SObject
     */
    @TestVisible
    protected List<SObject> loadResources() {
        try {
            if (!String.isEmpty(this.resourceId)) {
                Id idVal = Id.valueOf(this.resourceId);
                SObjectType objType = idVal.getSobjectType();
                if (objType != null) {
                    Map<String, Schema.SObjectField> fieldsMap = objType.getDescribe().fields.getMap();
                    return loadResources(objType.getDescribe().getName(), new List<String>(fieldsMap.keySet()), null, null, 0);
                }
            }
        } catch (Exception e) {
        }
        return new List<SObject>();
    }

    /**
     * Method to load a single resource from Database related to parent record
     *
     * @param objName (String): Object API Name to load
     * @param fields (List<String>): Projection fields to load
     * @param relationshipField (String): Relationship field to load resources
     * @param relatedId (String): Related Id to load
     * @param fieldKey (String): Field to search using resourceId value
     * @param resourceId (String): Resource Id value
     * @return SObject: Return the found SObject
     */
    @TestVisible
    protected SObject loadRelatedResource(String objName, List<String> fields, String relationshipField, String relatedId, String fieldKey, String resourceId) {
        if (resourceId != null && !String.isEmpty(resourceId)) {
            SObjectType objType = Schema.getGlobalDescribe().get(objName);
            if (objType != null) {
                String query = 'Select ' + String.join(fields, ',') + ' from ' + objName + ' where ' + relationshipField + ' = :relatedId and ' + fieldKey + ' = :resourceId limit 1';
                List<SObject> result = Database.query(query);
                return (result.size() == 1) ? result[0] : null;
            }
        }
        return null;
    }

    /**
     * Method to load a single resource from Database related to parent record
     *
     * @param objName (String): Object API Name to load
     * @param relationshipField (String): Relationship field to load resources
     * @param relatedId (String): Related Id to load
     * @param fieldKey (String): Field to search using resourceId value
     * @param resourceId (String): Resource Id value
     * @return SObject: Return the found SObject
     */
    @TestVisible
    protected SObject loadRelatedResource(String objName, String relationshipField, String relatedId, String fieldKey, String resourceId) {
        if (resourceId != null && !String.isEmpty(resourceId)) {
            SObjectType objType = Schema.getGlobalDescribe().get(objName);
            if (objType != null) {
                Map<String, Schema.SObjectField> fieldsMap = objType.getDescribe().fields.getMap();
                return loadRelatedResource(objName, new List<String>(fieldsMap.keySet()), relationshipField, relatedId, fieldKey, resourceId);
            }
        }
        return null;
    }

    /**
     * Method to load a single resource from Database related to parent record
     *
     * @param fields (List<String>): Projection fields to load
     * @param relationshipField (String): Relationship field to load resources
     * @param relatedId (String): Related Id to load
     * @param resourceId (String): Resource Id value
     * @return SObject: Return the found SObject
     */
    @TestVisible
    protected SObject loadRelatedResource(List<String> fields, String relationshipField, String relatedId) {
        if (this.resourceId != null && !String.isEmpty(this.resourceId)) {
            try {
                Id idVal = Id.valueOf(this.resourceId);
                SObjectType objType = idVal.getSobjectType();
                if (objType != null) {
                    return loadRelatedResource(objType.getDescribe().getName(), fields, relationshipField, relatedId, 'Id', this.resourceId);
                }
            } catch (Exception e) {
            }
        }
        return null;
    }

    /**
     * Method to load a single resource from Database related to parent record
     *
     * @param fields (List<String>): Projection fields to load
     * @param relationshipField (String): Relationship field to load resources
     * @param relatedId (String): Related Id to load
     * @param resourceId (String): Resource Id value
     * @return SObject: Return the found SObject
     */
    @TestVisible
    protected SObject loadRelatedResource(String relationshipField, String relatedId) {
        if (this.resourceId != null && !String.isEmpty(this.resourceId)) {
            try {
                Id idVal = Id.valueOf(this.resourceId);
                SObjectType objType = idVal.getSobjectType();
                if (objType != null) {
                    Map<String, Schema.SObjectField> fieldsMap = objType.getDescribe().fields.getMap();
                    return loadRelatedResource(objType.getDescribe().getName(), new List<String>(fieldsMap.keySet()), relationshipField, relatedId, 'Id', this.resourceId);
                }
            } catch (Exception e) {
            }
        }
        return null;
    }

    /**
     * Method to load any related resource list
     *
     * @param objName (String): Related Object API Name to load
     * @param fields (List<String>): Projection fields to load
     * @param relationshipField (String): Relationship field to load resources
     * @param relatedId (String): Related Id to load
     * @param recordsLimit (Integer): Max records to load
     * @return List<SObject>: Write the return description
     */
    @TestVisible
    protected List<SObject> loadRelatedResources(String objName, List<String> fields, String relationshipField, String relatedId, Integer recordsLimit) {
        if (relatedId != null && !String.isEmpty(relatedId)) {
            String query = 'Select ' + String.join(fields, ',') + ' from ' + objName + ' where ' + relationshipField + ' = :relatedId';
            if (recordsLimit > 0)
                query += ' limit :recordsLimit';
            return Database.query(query);
        }
        return new List<SObject>();
    }

    /**
     * Method to load any related resource list
     *
     * @param objName (String): Related Object API Name to load
     * @param fields (List<String>): Projection fields to load
     * @param relationshipField (String): Relationship field to load resources
     * @param relatedId (String): Related Id to load
     * @return List<SObject>: Write the return description
     */
    @TestVisible
    protected List<SObject> loadRelatedResources(String objName, List<String> fields, String relationshipField, String relatedId) {
        if (relatedId != null && !String.isEmpty(relatedId)) {
            return loadRelatedResources(objName, fields, relationshipField, relatedId, 0);
        }
        return new List<SObject>();
    }

    /**
     * Method to load any related resource list
     *
     * @param objName (String): Related Object API Name to load
     * @param relationshipField (String): Relationship field to load resources
     * @param relatedId (String): Related Id to load
     * @return List<SObject>: Write the return description
     */
    @TestVisible
    protected List<SObject> loadRelatedResources(String objName, String relationshipField, String relatedId) {
        if (relatedId != null && !String.isEmpty(relatedId)) {
            SObjectType objType = Schema.getGlobalDescribe().get(objName);
            if (objType != null) {
                Map<String, Schema.SObjectField> fieldsMap = objType.getDescribe().fields.getMap();
                return loadRelatedResources(objName, new List<String>(fieldsMap.keySet()), relationshipField, relatedId);
            }
        }
        return new List<SObject>();
    }

    /**
     * Method to check if has next paths to process on relative paths
     *
     * @return Boolean: True if has next path on relative paths, false in otherwise
     */
    protected Boolean hasNextPath() {
        return routePaths.size() > 0;
    }

    /**
     * Method to peark the first value on relative paths (and remove from paths collection)
     *
     * @return String: Return the removed path
     */
    protected String peakNextPath() {
        return routePaths.remove(0);
    }

    /**
     * Method to get the next path on relative paths (do not remove from paths collection)
     *
     * @return String: Return the first value on relative paths
     */
    protected String getNextPath() {
        return routePaths[0];
    }

    /**
     * Method to check if need to expand the response
     *
     * @return Boolean: True if expan response, false in otherwise
     */
    protected Boolean expandResponse() {
        return getQueryParameter('expand') == 'true';
    }

    /**
     * Method to execute routes
     *
     * @return Object: Return the route response
     */
    protected Object executeRoute() {
        loadResourceId();
        if (!hasNextPath())
            return respond();
        RestServiceRoute nextRoute = this.nextRoute();
        if (nextRoute != null)
            return nextRoute.executeRoute();
        throw new RestService.RouteNotFoundException(request);
    }

    /**
     * Method to execute do... methods and get the response object
     *
     * @return Object: Return the response object from http executed operation
     */
    protected Object respond() {
        System.debug(request.httpMethod);
        switch on request.httpMethod {
            when 'GET' {
                return this.doGet();
            }
            when 'POST' {
                return this.doPost();
            }
            when 'DELETE' {
                return this.doDelete();
            }
            when 'PUT' {
                return this.doPut();
            }
            when else {
                throw new RestService.MethodNotSupportedException(request);
            }
        }
    }

    /**
     * Method to exapand the response with the all data
     *
     * @param result (Object): Result from the first route
     * @return Map<String, Object>: Return the expanded response
     */
    protected Map<String, Object> expand(Object result) {
        Map<String, Object> expandedResult = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(result));
        setupRoutes();
        if (routesMap != null) {
            for (String key : routesMap.keySet()) {
                expandedResult.put(key, routesMap.get(key).respond());
            }
        }
        return expandedResult;
    }

    /**
     * Method to add routes to the parent route to execute
     *
     * @param name (String): Route name (must have the same name than the resource route identifier)
     * @param route (RestServiceRoute): Rest Service route instace to execute
     */
    protected void addRoute(String name, RestServiceRoute route) {
        if (routesMap == null)
            routesMap = new Map<String, RestServiceRoute>();
        routesMap.put(name, route);
    }

    /**
     * Method to parse relative paths to get the execution order and resource ids from path
     *
     */
    private void processRoutePaths() {
        this.routePaths = getRelativePaths(getBasePath());
        if (routePaths.size() > 0 && String.isEmpty(routePaths.get(0))) {
            peakNextPath();
        }
    }
}