package helpers;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class CleanupHookTest {
    @Test
    void comprobarQueLosErroresDeLimpiezaAfectanElResultado() {
        Results results = Runner.path("classpath:validation/cleanup-hook.feature")
                .hook(new CleanupHook())
                .reportDir("target/cleanup-hook-reports")
                .parallel(1);
        assertEquals(2, results.getScenariosTotal());
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }
}
