@RestResource(urlMapping='/code/exchangeCodeToAccessToken')
global class CodeExchangeAPI {
   @HttpGet
   global static ExchangeResponse doGet() {
       RestRequest req = RestContext.request;
       RestResponse res = RestContext.response;
       try {
           res.statusCode = 200;
           String accessToken = doCodeExchange(req.params.get('code'), req.params.get('sfdc_community_url'));
           if (accessToken != null) {
                return new ExchangeResponse(accessToken, req.params.get('state'));
           } else {
               return new ExchangeResponse('Could not parse auth code redirect URI');
           }
       } catch (Exception e) {
           res.statusCode = 500;
           return new ExchangeResponse('Could not parse auth code redirect URI');
       }
   }
   global static String doCodeExchange(String code, String communityURL) {
       String clientId = '<Connected App Client Id>';
       String redirectURL = '<Your Experience Site Base URL>/services/apexrest/code/exchangeCodeToAccessToken';
       String clientSecret = '<Connected App Client Secret>';
      
       Http h = new Http();
       HttpRequest req = new HttpRequest();
       req.setMethod('POST');
      
       String url = communityURL + '/services/oauth2/token';
       req.setEndpoint(url);
      
       String body = 'grant_type=authorization_code';
       body = body + '&client_id=' + clientId;
       body = body + '&code=' + code;
       if (clientSecret != null) {
          body = body + '&client_secret=' + clientSecret;
       }
       body = body + '&redirect_uri=' + redirectURL;
      
       String encodedBody = EncodingUtil.urlEncode(body, 'UTF-8');
      
       req.setBody(body);
      
       req.setHeader('Content-Type','application/x-www-form-urlencoded');
      
       HttpResponse res = h.send(req);
       if (res.getStatusCode() == 200) {
           Map<String,Object> tokenResponseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
           return (String)tokenResponseMap.get('access_token');
       } else {
           return null;
       }
   }
   global class ExchangeResponse {
       String access_token;
       String refresh_token;
       String state;
       String errMsg;
       Boolean success; 
      public ExchangeResponse(String access_token, String state) {
           this.access_token = access_token;
           this.state = state;
           this.success = true;
       }
        public ExchangeResponse(String errMsg) {
           this.success = false;
           this.errMsg = this.errMsg;
       }       
   }
}