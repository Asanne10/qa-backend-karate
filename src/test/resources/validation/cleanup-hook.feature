Feature: Comprobar el resultado de limpieza sin acceder a la API
  Scenario: Validar que la limpieza sin errores permita aprobar el escenario
    * def cleanupFailures = []

  @fail
  Scenario: Validar que un error de limpieza haga fallar el escenario
    * configure afterScenario = function(){ karate.set('cleanupFailures', ['Error simulado de DELETE']); }
