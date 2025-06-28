Feature: Validating Data for Common Resources


  @Count
  @ignore
  Scenario: Validation for Codeableconcept
    #----------------------Reading codeableconcept Attribute Paths from the json File-------------
    * def attributes = read("classpath:SOF/testData/CommonResources/Codeableconcept_Attribute_Path.json")
    * def dbresourceName = "codeableconcept"
    * print selectedIds
    * print resourceName
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

  @FHIRID
  @ignore
  Scenario: Validation for Codeableconcept
    #----------------------Reading codeableconcept Attribute Paths from the json File-------------
    * def attributes = read("classpath:SOF/testData/CommonResources/Codeableconcept_Attribute_Path.json")
    * def dbresourceName = "codeableconcept"
    * print resourceName
    * print resourceData
    * def failedFHIRIDs = []
    * def validateFHIRPatient = function(fhirID) { return karate.call('classpath:SOF/testModule/Validation.feature@validationWithFHIRID', { fhirID: fhirID });}
    * validateFHIRPatient(fhirID)

    # Step 3: Print failed FHIR IDs (if any)
    * print "These FHIR ID's aren't present in the DB:- ", failedFHIRIDs


  @Count
  @ignore
  Scenario: Validation for Identifier
    #----------------------Reading identifier Attribute Paths from the json File-------------
    * def attributes = read("classpath:SOF/testData/CommonResources/Identifier_Attribute_Path.json")
    * def dbresourceName = "identifier"
    * print selectedIds
    * print resourceName
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



  @FHIRID
  @ignore
  Scenario: Validation for Identifier
    #----------------------Reading identifier Attribute Paths from the json File-------------
    * def attributes = read("classpath:SOF/testData/CommonResources/Identifier_Attribute_Path.json")
    * def dbresourceName = "identifier"
    * print resourceName
    * def failedFHIRIDs = []
    * def validateFHIRPatient = function(fhirID) { return karate.call('classpath:SOF/testModule/Validation.feature@validationWithFHIRID', { fhirID: fhirID });}
    * validateFHIRPatient(fhirID)

    # Step 3: Print failed FHIR IDs (if any)
    * print "These FHIR ID's aren't present in the DB:- ", failedFHIRIDs


  @Count
  @ignore
  Scenario: Validation for Reference
    #----------------------Reading reference Attribute Paths from the json File-------------
    * def attributes = read("classpath:SOF/testData/CommonResources/Reference_Attribute_Path.json")
    * def dbresourceName = "reference"
    * print selectedIds
    * print resourceName
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


  @FHIRID
  @ignore
  Scenario: Validation for Reference
    #----------------------Reading reference Attribute Paths from the json File-------------
    * def attributes = read("classpath:SOF/testData/CommonResources/Reference_Attribute_Path.json")
    * def dbresourceName = "reference"
    * print resourceName
    * def failedFHIRIDs = []
    * def validateFHIRPatient = function(fhirID) { return karate.call('classpath:SOF/testModule/Validation.feature@validationWithFHIRID', { fhirID: fhirID });}
    * validateFHIRPatient(fhirID)

    # Step 3: Print failed FHIR IDs (if any)
    * print "These FHIR ID's aren't present in the DB:- ", failedFHIRIDs