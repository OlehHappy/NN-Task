public class CountryInfoRetriever {
    // I didn't used Named Credentioal because HTTP for free account, 
    // and Named Credentials requires HTTPS
    private static final String API_ENDPOINT = 'http://api.countrylayer.com/v2/all';
    private static final String API_ACCESS_KEY = '7973e014e72e9e9ea74a35607295ca11';

    public static List<Country__c> retrieveCountriesInfo() {
        List<Country__c> countries = new List<Country__c>();

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(API_ENDPOINT + '?access_key=' + API_ACCESS_KEY);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');

        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            List<Object> jsonResponse = (List<Object>) JSON.deserializeUntyped(response.getBody());

            for (Object obj : jsonResponse) {

                Map<String, Object> countryMap = (Map<String, Object>) obj;

                Country__c country = new Country__c();
                country.Name = (String) countryMap.get('name');
                country.ISO_Code_2__c = (String) countryMap.get('alpha2Code');
                country.ISO_Code_3__c = (String) countryMap.get('alpha3Code');
                country.CapitalCity__c = (String) countryMap.get('capital');
                country.Region__c = (String) countryMap.get('region');
                country.Subregion__c = (String) countryMap.get('subregion');

                List<Object> regionalBlocsList = (List<Object>) countryMap.get('regionalBlocs');

                if (regionalBlocsList != null && !regionalBlocsList.isEmpty()) {
                
                    List<String> regionalBlocs = new List<String>();
                
                    for (Object regionalBlocObj : regionalBlocsList) {
                        Map<String, Object> regionalBlocMap = (Map<String, Object>) regionalBlocObj;
                        regionalBlocs.add((String) regionalBlocMap.get('acronym'));
                    }

                    // used this approach apart from miltiselect picklist, 
                    // coz in case they will use another acronym values this solution will works
                    country.RegionalBlocs__c = String.join(regionalBlocs, ', ');
                }

                countries.add(country);
            }
        } else {
            //todo: the best way for error handling in Apex
            System.debug('Error response: ' + response.getBody());
        }

        return countries;
    }
}
