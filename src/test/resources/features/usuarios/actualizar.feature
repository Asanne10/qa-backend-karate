@backend
Feature: PUT /usuarios/{id} - Actualizar usuarios
  Background:
    * url baseUrl
    * def cleanupIds = []
    * configure afterScenario = read('classpath:helpers/cleanup.js')
    * def createUserData = read('classpath:helpers/user-data.js')
    * def userSchema = read('classpath:schemas/user.json')
    * def createSchema = read('classpath:schemas/create.json')
    * def messageSchema = read('classpath:schemas/message.json')

  @BE-S05 @BE-EX-14 @smoke
  Scenario: Validar la actualización de un usuario y la persistencia de todos los cambios
    * def fixture = call read('classpath:helpers/create-user.feature')
    * def updated = createUserData()
    * set updated.nome = 'Usuario actualizado'
    * set updated.password = 'Nueva123!'
    * set updated.administrador = 'false'
    Given path 'usuarios', fixture.id
    And request updated
    When method put
    Then status 200
    And match header Content-Type contains 'application/json'
    And match response == messageSchema
    And match response == { message: 'Registro alterado com sucesso' }
    Given path 'usuarios', fixture.id
    When method get
    Then status 200
    And match response == userSchema
    And match response == karate.merge(updated, { _id: fixture.id })
    Given path 'usuarios'
    And param email = fixture.user.email
    When method get
    Then status 200
    And match response == { quantidade: 0, usuarios: [] }

  @BE-S06
  Scenario Outline: Validar el rechazo de una actualización inválida sin modificar el registro [<caso>]
    * def fixture = call read('classpath:helpers/create-user.feature')
    * copy updated = fixture.user
    * if (accion == 'omitir') delete updated[campo]
    * if (accion == 'cambiar') updated[campo] = valor
    * def expectedError = {}
    * eval expectedError[campo] = mensaje
    Given path 'usuarios', fixture.id
    And request updated
    When method put
    Then status 400
    And match header Content-Type contains 'application/json'
    And match response == expectedError
    Given path 'usuarios', fixture.id
    When method get
    Then status 200
    And match response == userSchema
    And match response == karate.merge(fixture.user, { _id: fixture.id })

    Examples:
      | caso     | accion  | campo | valor           | mensaje                        |
      | BE-EX-16 | cambiar | email | correo-invalido | email deve ser um email válido |
      | BE-EX-17 | omitir  | nome  | no aplica       | nome é obrigatório             |

  @BE-S11 @BE-EX-15
  Scenario: Validar el rechazo del email de otro usuario y la conservación de ambos registros
    * def first = call read('classpath:helpers/create-user.feature')
    * def second = call read('classpath:helpers/create-user.feature')
    * copy updated = first.user
    * set updated.email = second.user.email
    Given path 'usuarios', first.id
    And request updated
    When method put
    Then status 400
    And match header Content-Type contains 'application/json'
    And match response == messageSchema
    And match response == { message: 'Este email já está sendo usado' }
    Given path 'usuarios', first.id
    When method get
    Then status 200
    And match response == userSchema
    And match response == karate.merge(first.user, { _id: first.id })
    Given path 'usuarios', second.id
    When method get
    Then status 200
    And match response == userSchema
    And match response == karate.merge(second.user, { _id: second.id })
