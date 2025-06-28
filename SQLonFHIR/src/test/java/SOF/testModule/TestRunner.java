package SOF.testModule;

import com.intuit.karate.junit5.Karate;


class TestRunner {

    @Karate.Test
    Karate SQLonFHIR_Count() {

        return Karate.run("classpath:SOF/testModule/fetchResourceDetails.feature@withCount");

    }

    @Karate.Test
    Karate SQLonFHIR_FHIRId() {

        return Karate.run("classpath:SOF/testModule/fetchResourceDetails.feature@withFHIRID");

    }

    @Karate.Test
    Karate Validation() {

        return Karate.run("classpath:SOF/testModule/Validation.feature@validationWithCount");

    }
}
