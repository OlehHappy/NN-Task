global class CountriesInfoUpdaterScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        // Call the updateCountriesFromAPI method
        CountriesInfoUpdater.updateCountriesFromAPI();
    }
}