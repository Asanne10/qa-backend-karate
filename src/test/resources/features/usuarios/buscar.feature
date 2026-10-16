@backend
Feature: GET /usuarios/{id} - Consultar usuarios
  Background:
    * url baseUrl
    * def cleanupIds = []
    * configure afterScenario = read('classpath:helpers/cleanup.js')
    * def createUserData = read('classpath:helpers/user-data.js')
    * def userSchema = read('classpath:schemas/user.json')
    * def createSchema = read('classpath:schemas/create.json')
    * def messageSchema = read('classpath:schemas/message.json')

  @BE-S04 @BE-EX-12
  Scenario: Validar la consulta de un usuario propio existente
    * def fixture = call read('classpath:helpers/create-user.feature')
    Given path 'usuarios', fixture.id
    When method get
    Then status 200
    And match header Content-Type contains 'application/json'
    And match response == userSchema
    And match response == karate.merge(fixture.user, { _id: fixture.id })

  @BE-S08 @BE-EX-13
  Scenario: Validar la consulta de un ID inexistente
    * def absentId = Java.type('java.util.UUID').randomUUID().toString().replace(/-/g, '').substring(0, 16)
    Given path 'usuarios', absentId
    When method get
    Then status 400
    And match header Content-Type contains 'application/json'
    And match response == messageSchema
    And match response == { message: 'Usuário não encontrado' }
