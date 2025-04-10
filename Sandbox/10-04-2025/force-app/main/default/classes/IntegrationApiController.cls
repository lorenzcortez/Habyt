public virtual without sharing class IntegrationApiController {
    protected RestRequest request;
    protected RestResponse response;
    
    public static final String BASIC_STR = 'Basic';

    public void init(RestRequest request, RestResponse response) {
        this.request = request;
        this.response = response;
        this.response.addHeader('Content-Type', 'application/json');
    }

    protected String handleAuthorization() {
        String authHeader = request.headers.get(request.headers.containsKey('Auth') ? 'Auth' : 'auth');

        if (String.isBlank(authHeader) || !authHeader.startsWith(BASIC_STR)) {
            throw new IntegrationModels.UnauthorizedException().init();
        }

        // Get user and pass from authentication header
        authHeader = EncodingUtil.base64Decode(authHeader.split(' ').get(1)).toString();
        String user = authHeader.split(':').get(0);
        String pass = authHeader.split(':').get(1);

        Paua_Selector selector = Paua_SelectorHandler.getSelector(APIBasicCredentialSelector.APIBasicCredentialByUsernameAndPass.class)
            .setParameter('varUser', user)
            .setParameter('varPass', pass);

        List<APIBasicCredential__mdt> lstCredentials = (List<APIBasicCredential__mdt>) selector.query();
        if (lstCredentials.isEmpty()) {
            throw new IntegrationModels.UnauthorizedException().init();
        }
        
        return lstCredentials.get(0).MasterLabel;
    }

    public void handleGet() {
        Integer statusCode = 200;
        Blob responseBody;

        try {
            handleAuthorization();
            responseBody = doHandleGet(request.params);
        } catch (IntegrationModels.IntegrationException e) {
            IntegrationModels.ErrorPayload errorPayload = e.payload;
            statusCode = errorPayload.statusCode;
            responseBody = Blob.valueOf(JSON.serialize(errorPayload));
        } catch (Exception e) {
            IntegrationModels.ErrorPayload errorPayload = new IntegrationModels.InternalServerErrorException().init(e).payload;
            statusCode = errorPayload.statusCode;
            responseBody = Blob.valueOf(JSON.serialize(errorPayload));
        }

        response.statusCode = statusCode;
        response.responseBody = responseBody;
    }

    protected virtual Blob doHandleGet(Map<String, String> parameters) {
        return null;
    }

    public void handlePost() {
        Integer statusCode = 200;
        Blob responseBody;

        try {
            String userName = handleAuthorization();
            responseBody = doHandlePost(request.requestBody.toString(), userName);
        } catch (IntegrationModels.IntegrationException e) {
            IntegrationModels.ErrorPayload errorPayload = e.payload;
            statusCode = errorPayload.statusCode;
            responseBody = Blob.valueOf(JSON.serialize(errorPayload));
        } catch (Exception e) {
            IntegrationModels.ErrorPayload errorPayload = new IntegrationModels.InternalServerErrorException().init(e).payload;
            statusCode = errorPayload.statusCode;
            responseBody = Blob.valueOf(JSON.serialize(errorPayload));
        }

        response.statusCode = statusCode;
        response.responseBody = responseBody;
    }

    protected virtual Blob doHandlePost(String payload, String userName) {
        return null;
    }
}