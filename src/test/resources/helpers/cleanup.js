function fn() {
  var ids = karate.get('cleanupIds', []);
  var failures = [];
  for (var i = 0; i < ids.length; i++) {
    try {
      karate.call('classpath:helpers/delete-user.feature', { id: ids[i] });
    } catch (e) {
      failures.push(ids[i] + ': ' + e);
    }
  }
  // El runner comprueba este resultado: Karate solo registra warnings del hook JS.
  karate.set('cleanupFailures', failures);
}
