function fn() {
  var uuid = Java.type('java.util.UUID').randomUUID().toString().replace(/-/g, '');
  var user = karate.read('classpath:requests/usuarios/create.json');
  user.email = 'qa.' + uuid + '@example.com';
  return user;
}
