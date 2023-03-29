public with sharing class CountriesController {

    public void updateCountriesFromAPI() {

        List<Country__c> countryApiList = CountryInfoRetriever.retrieveCountriesInfo();

        // didn't impement logic for very large amonunt of records 
        // coz we don't have such a lot of countries yet
        List<Country__c> countries = [SELECT Id, Name, 
                                            CapitalCity__c, 
                                            ISO_Code_2__c, 
                                            ISO_Code_3__c, 
                                            Region__c, 
                                            RegionalBlocs__c, 
                                            Subregion__c 
                                    FROM Country__c];

        List<Country__c> countriesToUpsert = new List<Country__c>();
    
        if (!countryApiList.isEmpty() && !countries.isEmpty()) {

            for (Country__c apiCountry : countryApiList) {

                Boolean countryExists = false;
                for (Country__c country : countries) {
                    
                    if (country.Name == apiCountry.Name) {
                        countryExists = true;

                        country.CapitalCity__c = apiCountry.CapitalCity__c;
                        country.ISO_Code_2__c = apiCountry.ISO_Code_2__c;
                        country.ISO_Code_3__c = apiCountry.ISO_Code_3__c;
                        country.Region__c = apiCountry.Region__c;
                        country.RegionalBlocs__c = apiCountry.RegionalBlocs__c;
                        country.Subregion__c = apiCountry.Subregion__c;

                        countriesToUpsert.add(country);
                    }
                }

                // if country doesn't exist in DB, we need to add then
                if (!countryExists) {
                    countriesToUpsert.add(apiCountry);
                }
            }
        }

        // when we don't have countries at all
        if (!countryApiList.isEmpty() && countries.isEmpty()) {
            countriesToUpsert.addAll(countryApiList);
        }

        if (!countriesToUpsert.isEmpty()) {

            try {
                upsert countriesToUpsert;
            } catch (Exception ex) {
                //todo: the best way for error handling in Apex
                System.debug('Error while database operation: ' + ex.getMessage());
            }
        }
    }
}
