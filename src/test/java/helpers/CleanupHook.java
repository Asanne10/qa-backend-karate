package helpers;

import com.intuit.karate.RuntimeHook;
import com.intuit.karate.core.ScenarioRuntime;
import java.util.List;

public class CleanupHook implements RuntimeHook {
    @Override
    public void afterScenario(ScenarioRuntime scenario) {
        if (scenario.caller.depth > 0) return;
        Object failures = scenario.engine.getVariable("cleanupFailures");
        if (failures instanceof List<?> errors && !errors.isEmpty()) {
            scenario.result.addFakeStepResult("Verificar limpieza de usuarios propios",
                    new AssertionError("Limpieza incompleta: " + errors));
        }
    }
}
