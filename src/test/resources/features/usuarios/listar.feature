@backend
Feature: GET /usuarios - Listar usuarios
  Background:
    * url baseUrl
    * def cleanupIds = []
    * configure afterScenario = read('classpath:helpers/cleanup.js')
    * def createUserData = read('classpath:helpers/user-data.js')
    * def userSchema = read('classpath:schemas/user.json')
    * def createSchema = read('classpath:schemas/create.json')
    * def messageSchema = read('classpath:schemas/message.json')

  @BE-S01
  Scenario Outline: Validar la consulta de la lista de usuarios [<caso>]
    * def fixture = {}
    * if (modo == 'propio') fixture = karate.call('classpath:helpers/create-user.feature')
    * def absentEmail = createUserData().email
    * def filters = modo == 'todos' ? {} : { email: modo == 'propio' ? fixture.user.email : absentEmail }
    Given path 'usuarios'
    And params filters
    When method get
    Then status 200
    And match header Content-Type contains 'application/json'
    And match response == read('classpath:schemas/list.json')
    And match response.quantidade == response.usuarios.length
    And assert response.quantidade >= 0 && response.quantidade % 1 == 0
    * def expectedCount = modo == 'todos' ? response.usuarios.length : (modo == 'propio' ? 1 : 0)
    And match response.quantidade == expectedCount
    * def expectedUsers = modo == 'propio' ? [karate.merge(fixture.user, { _id: fixture.id })] : (modo == 'vacio' ? [] : '#array')
    And match response.usuarios == expectedUsers

    Examples:
      | caso     | modo   |
      | BE-EX-01 | todos  |
      | BE-EX-02 | propio |
      | BE-EX-03 | vacio  |
