@isTest
private class CountryInfoRetrieverTest {

    @isTest
    static void testRetrieveCountryInfo() {
        
        // Set the mock
        HttpMock mock = new HttpMock(200, RESPONSE_MOCK);
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        List<Country__c> actualCountries = CountryInfoRetriever.retrieveCountriesInfo();
        Test.stopTest();

        // Assert the result
        System.assert(!actualCountries.isEmpty(), 'We expect some results frm th mock.');
    }

    // todo: check coverage
    @isTest
    static void testRetrieveCountryInfoWithError() {
        
        // Set the mock
        HttpMock mock = new HttpMock(400, '');
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        List<Country__c> countries = CountryInfoRetriever.retrieveCountriesInfo();
        Test.stopTest();
        
        // assert that no countries were retrieved
        System.assertEquals(0, countries.size());
    }


    // mock HTTP response
    static final String RESPONSE_MOCK = '[' 
                                        + '{' 
                                            + '"name": "United States",' 
                                            + '"alpha2Code": "US",' 
                                            + '"alpha3Code": "USA",' 
                                            + '"capital": "Washington, D.C.",' 
                                            + '"region": "Americas",'
                                            + '"subregion": "Northern America",' 
                                            + '"regionalBlocs": ['
                                                + '{'
                                                    + '"acronym": "NAFTA"' 
                                                + '},'
                                                + '{' 
                                                    + '"acronym": "USAN"' 
                                                + '}' 
                                            + ']' 
                                        + '},' 
                                        + '{' 
                                            + '"name": "Canada",'
                                            + '"alpha2Code": "CA",'
                                            + '"alpha3Code": "CAN",'
                                            + '"capital": "Ottawa",'
                                            + '"region": "Americas",'
                                            + '"subregion": "Northern America",'
                                            + '"regionalBlocs": ['
                                                + '{'
                                                    + '"acronym": "NAFTA"'
                                                + '}'
                                            + ']'
                                        + '}'
                                    +']';

    // Inner class to mock HTTP response
    private class HttpMock implements HttpCalloutMock {
        private Integer statusCode;
        private String response;
        
        public HttpMock(Integer statusCode, String response) {
            this.statusCode = statusCode;
            this.response = response;
        }
        
        public HTTPResponse respond(HTTPRequest request) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(statusCode);
            res.setBody(response);

            return res;
        }
    }
}
