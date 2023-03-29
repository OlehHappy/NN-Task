// I made it in one class coz its more easy for unit tests
public class CountriesInfoUpdater {

    private static final String COUNTRY_LAYER_OPTION_NAME = 'CoutryLayer';

    // I didn't used Named Credentioal because HTTP for free account, 
    // and Named Credentials requires HTTPS
    private static CalloutSetting__mdt countryLayerSettingMdt {
        get {
            if (countryLayerSettingMdt == null) {
                countryLayerSettingMdt = [SELECT EndpointURL__c, AccessKey__c
                                            FROM CalloutSetting__mdt 
                                            WHERE DeveloperName = :COUNTRY_LAYER_OPTION_NAME];
            }
          
            return countryLayerSettingMdt;
        }
        set;
    }


    public static void updateCountriesFromAPI() {

        List<Country__c> countriesApiList = retrieveCountriesInfo();

        Map<String, Country__c> countriesMap = new Map<String, Country__c>();

        // didn't adjust for large amount of records, 
        // coz we don't have much countries yet
        for (Country__c country : [SELECT Id, Name, 
                                        CapitalCity__c, 
                                        ISO_Code_2__c, 
                                        ISO_Code_3__c, 
                                        Region__c, 
                                        RegionalBlocs__c, 
                                        Subregion__c 
                                    FROM Country__c]) {

            countriesMap.put(country.Name, country);
        }

        List<Country__c> countriesToUpsert = new List<Country__c>();
        for (Country__c apiCountry : countriesApiList) {

            Country__c country = countriesMap.get(apiCountry.Name);

            if (country != null) {
                
                country.CapitalCity__c = apiCountry.CapitalCity__c;
                country.ISO_Code_2__c = apiCountry.ISO_Code_2__c;
                country.ISO_Code_3__c = apiCountry.ISO_Code_3__c;
                country.Region__c = apiCountry.Region__c;
                country.RegionalBlocs__c = apiCountry.RegionalBlocs__c;
                country.Subregion__c = apiCountry.Subregion__c;

                countriesToUpsert.add(country);
            } else {
                countriesToUpsert.add(apiCountry);
            }
        }

        if (!countriesToUpsert.isEmpty()) {

            try {
                upsert countriesToUpsert;
            } catch (DmlException e) {
                // Handle the exception appropriately (e.g. log to custom object, send email notification)
                System.debug('Error in DML: ' + e.getMessage());
            }
        }
    }

    public static List<Country__c> retrieveCountriesInfo() {
        List<Country__c> countriesList = new List<Country__c>();

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(countryLayerSettingMdt.EndpointURL__c + '?access_key=' + countryLayerSettingMdt.AccessKey__c);
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

                countriesList.add(country);
            }
        } else {
            // Handle the exception appropriately (e.g. log to custom object, send email notification)
            System.debug('Error response: ' + response.getBody());
        }

        return countriesList;
    }
}
