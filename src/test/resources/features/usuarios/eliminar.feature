@backend
Feature: DELETE /usuarios/{id} - Eliminar usuarios
  Background:
    * url baseUrl
    * def cleanupIds = []
    * configure afterScenario = read('classpath:helpers/cleanup.js')
    * def createUserData = read('classpath:helpers/user-data.js')
    * def userSchema = read('classpath:schemas/user.json')
    * def createSchema = read('classpath:schemas/create.json')
    * def messageSchema = read('classpath:schemas/message.json')

  @BE-S07 @BE-EX-18 @smoke
  Scenario: Validar la eliminación de un usuario existente y su ausencia posterior
    * def fixture = call read('classpath:helpers/create-user.feature')
    Given path 'usuarios', fixture.id
    When method delete
    Then status 200
    And match header Content-Type contains 'application/json'
    And match response == messageSchema
    And match response == { message: 'Registro excluído com sucesso' }
    Given path 'usuarios', fixture.id
    When method get
    Then status 400
    And match response == { message: 'Usuário não encontrado' }
    * eval cleanupIds.splice(cleanupIds.indexOf(fixture.id), 1)
    Given path 'usuarios'
    And param email = fixture.user.email
    When method get
    Then status 200
    And match response == { quantidade: 0, usuarios: [] }

  @BE-S09 @BE-EX-19
  Scenario: Validar la eliminación de un ID inexistente sin afectar usuarios
    * def absentId = Java.type('java.util.UUID').randomUUID().toString().replace(/-/g, '').substring(0, 16)
    Given path 'usuarios', absentId
    When method get
    Then status 400
    And match response == { message: 'Usuário não encontrado' }
    Given path 'usuarios', absentId
    When method delete
    Then status 200
    And match header Content-Type contains 'application/json'
    And match response == messageSchema
    And match response == { message: 'Nenhum registro excluído' }
    Given path 'usuarios', absentId
    When method get
    Then status 400
    And match response == { message: 'Usuário não encontrado' }
