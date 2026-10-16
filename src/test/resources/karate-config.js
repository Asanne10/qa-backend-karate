function fn() {
  karate.configure('report', { showLog: true, showAllSteps: true });
  karate.configure('connectTimeout', 15000);
  karate.configure('readTimeout', 15000);
  // El contrato permite listas vacías; los escenarios validan su cantidad.
  karate.configure('matchEachEmptyAllowed', true);
  var proxy = karate.properties['proxyUri'];
  if (proxy) karate.configure('proxy', proxy);
  return { baseUrl: karate.properties['baseUrl'] || 'https://serverest.dev' };
}
