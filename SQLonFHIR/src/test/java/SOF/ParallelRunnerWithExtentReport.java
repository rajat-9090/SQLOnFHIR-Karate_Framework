package SOF;

import SOF.utilities.CustomExtentReport;
import org.junit.jupiter.api.Test;

import com.intuit.karate.Results;
import com.intuit.karate.Runner.Builder;

public class ParallelRunnerWithExtentReport {
    @Test
    public void executeKarateTest() {
        Builder aRunner = new Builder();
        aRunner.path("classpath:SOF/testModule/patient.feature");
        Results result = aRunner.parallel(3);
        // Extent Report
        CustomExtentReport extentReport = new CustomExtentReport()
                .withKarateResult(result)
                .withReportDir(result.getReportDir())
                .withReportTitle("Karate Test Execution Report For SQLonFHIR");
        extentReport.generateExtentReport();

    }
}
