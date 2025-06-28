Feature: Extracting Selected FHIR IDs from the Resource

  Background:
    * url host
    #--------------------Calling this Feature File to generate the Outh 2.0 Token---------------
    * def newToken = call read("classpath:SOF/testModule/outh2.0_token.feature")
    #    * def resourceName = "Observation"
    #    * def dbresourceName = "observation"
    #    * def fhirID = "00ded5ad-c20c-2c91-6a67-9d3273f0f755"
    * def dbresourceName = karate.lowerCase(resourceName)
    #----------------------Reading patient Attribute Paths from the json File-------------
    * def attributes = read("classpath:SOF/testData/MainResources/" + resourceName + "_Attribute_Path.json")


  @whenwithCount
  @ignore
  Scenario: Fetching all the Patient FHIR ID's and store into the Excel Sheet
    Given path resourceName
    And header ApiKey = ApiKeyValue
    And header Authorization = "Bearer " + newToken.accessToken
    And param _count = 100
    Then method get
    When status 200
    * print response
    * def AllfhirIDs = $.entry[*].resource.id
    * print "FHIR ID's from Patient Resource Bundle ",  AllfhirIDs
    #--------------------Select Any Random 5 IDs from the Response List-----------------
    * def getRandomSubset =
      """
      function(array, count) {
        if (!array || array.length === 0) return [];
        if (count >= array.length) return array;

        var result = [];
        var tempArray = array.slice(); // Create a copy to avoid modifying original

        for (var i = 0; i < count; i++) {
          var randomIndex = Math.floor(Math.random() * tempArray.length);
          result.push(tempArray[randomIndex]);
          tempArray.splice(randomIndex, 1); // Remove selected ID to avoid duplicates
        }

        return result;
      }
      """
    * def selectedIds = getRandomSubset(AllfhirIDs, resourceCount)
    * print "Selected resource IDs for validation:", selectedIds
    #---------------Iterate over each FHIR ID and call the scenario------------------------
    # List to store failed FHIR IDs
    * def failedFHIRIDs = []
    * def validateFHIRPatient = function(fhirID) { return karate.call('classpath:SOF/testModule/Validation.feature@validationWithCount', { fhirID: fhirID });}
    * eval
      """
      for (var i = 0; i < selectedIds.length; i++) {
        var fhirID = selectedIds[i];
        validateFHIRPatient(fhirID);
      }
      """

    # Step 3: Print failed FHIR IDs (if any)
    * print "These FHIR ID's aren't present in the DB:- ", failedFHIRIDs
    #--------------------Calling this feature file for validation of commonResources-----------------
    * call read("classpath:SOF/testModule/commonResorces.feature@Count")


  @whenwithFHIRID
  @ignore
  Scenario: Fetching all the Patient FHIR ID's and store into the Excel Sheet
    Given path resourceName, fhirID
    And header ApiKey = ApiKeyValue
    And header Authorization = "Bearer " + newToken.accessToken
    Then method get
    When status 200
    * print response
    * def resourceData = response
    * print resourceData
    * def failedFHIRIDs = []
    * def validateFHIRPatient = function(fhirID) { return karate.call('classpath:SOF/testModule/Validation.feature@validationWithFHIRID', { fhirID: fhirID });}
    * validateFHIRPatient(fhirID)

    # Step 3: Print failed FHIR IDs (if any)
    * print "These FHIR ID's aren't present in the DB:- ", failedFHIRIDs
    #--------------------Calling Validation feature file for validation of commonResources-----------------
    * call read("classpath:SOF/testModule/commonResorces.feature@FHIRID")