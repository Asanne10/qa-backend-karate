package helpers;

import java.awt.Desktop;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.ZonedDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;

public final class ReportesKarate {
    private ReportesKarate() {}

    public static Path crearDirectorio(boolean dryRun) throws IOException {
        ZonedDateTime inicio = ZonedDateTime.now(ZoneId.of("America/Lima"));
        String nombre = inicio.format(DateTimeFormatter.ofPattern("yyyy-MM-dd_HH-mm-ss-SSS"))
                + (dryRun ? "_dryrun" : "_real");
        Path directorio = Path.of("target", "karate-reports", nombre);
        Files.createDirectories(directorio.getParent());
        Files.createDirectory(directorio);
        String ambiente = "Inicio (America/Lima): " + inicio + System.lineSeparator()
                + "Modo: " + (dryRun ? "dryRun, sin peticiones" : "ejecucion real") + System.lineSeparator()
                + "URL: " + System.getProperty("baseUrl", "https://serverest.dev") + System.lineSeparator()
                + "Tags: " + System.getProperty("tags", "todos") + System.lineSeparator()
                + "Java: " + System.getProperty("java.version") + System.lineSeparator()
                + "Sistema: " + System.getProperty("os.name") + System.lineSeparator()
                + "Comando equivalente: mvn test -DdryRun=" + dryRun
                + " -DbaseUrl=" + System.getProperty("baseUrl", "https://serverest.dev")
                + " -DopenReport=" + System.getProperty("openReport", "true")
                + (System.getProperty("tags") == null ? "" : " -Dtags=" + System.getProperty("tags"))
                + System.lineSeparator();
        Files.writeString(directorio.resolve("ejecucion.txt"), ambiente, StandardCharsets.UTF_8);
        return directorio;
    }

    public static void mostrar(Path directorio) throws IOException {
        Path reporte = directorio.resolve("karate-summary.html").toAbsolutePath();
        if (!Files.isRegularFile(reporte)) return;
        String enlace = directorio.getFileName() + "/karate-summary.html";
        String pagina = "<!doctype html><html lang=\"es\"><meta charset=\"utf-8\">"
                + "<meta http-equiv=\"refresh\" content=\"0;url=" + enlace + "\">"
                + "<title>Ultima ejecucion Karate</title>"
                + "<a href=\"" + enlace + "\">Abrir el ultimo reporte de Karate</a></html>";
        Files.writeString(directorio.getParent().resolve("karate-summary.html"), pagina, StandardCharsets.UTF_8);
        System.out.println("Reporte de esta ejecucion: " + reporte.toUri());
        if (System.getenv("CI") == null
                && Boolean.parseBoolean(System.getProperty("openReport", "true"))
                && Desktop.isDesktopSupported() && Desktop.getDesktop().isSupported(Desktop.Action.BROWSE)) {
            try {
                Desktop.getDesktop().browse(reporte.toUri());
            } catch (IOException | RuntimeException e) {
                System.out.println("Abrir el reporte manualmente: " + reporte.toUri());
            }
        }
    }
}
