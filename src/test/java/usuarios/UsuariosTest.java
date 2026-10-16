package usuarios;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import helpers.CleanupHook;
import helpers.ReportesKarate;
import java.io.IOException;
import java.nio.file.Path;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class UsuariosTest {
    @Test
    void ejecutarUsuarios() throws IOException {
        boolean dryRun = Boolean.getBoolean("dryRun");
        Path reportDir = ReportesKarate.crearDirectorio(dryRun);
        Runner.Builder runner = Runner.path("classpath:features/usuarios")
                .hook(new CleanupHook())
                .reportDir(reportDir.toString())
                .backupReportDir(false)
                .outputCucumberJson(true)
                .outputJunitXml(true)
                .dryRun(dryRun);
        String tags = System.getProperty("tags");
        if (tags != null && !tags.isBlank()) runner.tags(tags);
        Results results = runner.parallel(1);
        ReportesKarate.mostrar(reportDir);
        assertTrue(results.getScenariosTotal() > 0,
                "No se encontraron escenarios. Revisar la ruta y el filtro de tags.");
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }
}
