@backend
Feature: POST /usuarios - Registrar usuarios
  Background:
    * url baseUrl
    * def cleanupIds = []
    * configure afterScenario = read('classpath:helpers/cleanup.js')
    * def createUserData = read('classpath:helpers/user-data.js')
    * def userSchema = read('classpath:schemas/user.json')
    * def createSchema = read('classpath:schemas/create.json')
    * def messageSchema = read('classpath:schemas/message.json')

  @BE-S02 @smoke
  Scenario Outline: Validar el registro de un usuario válido y la persistencia de sus datos [<caso>]
    * def user = createUserData()
    * set user.administrador = '<admin>'
    Given path 'usuarios'
    And request user
    When method post
    * if (response._id) cleanupIds.push(response._id)
    Then status 201
    And match header Content-Type contains 'application/json'
    And match response == createSchema
    And match response.message == 'Cadastro realizado com sucesso'
    * def id = response._id
    Given path 'usuarios', id
    When method get
    Then status 200
    And match response == userSchema
    And match response == karate.merge(user, { _id: id })

    Examples:
      | caso     | admin |
      | BE-EX-04 | true  |
      | BE-EX-05 | false |

  @BE-S03
  Scenario Outline: Validar el rechazo de un body que incumple el esquema [<caso>]
    * def user = createUserData()
    * if (accion == 'omitir') delete user[campo]
    * if (accion == 'cambiar') user[campo] = valor
    * def expectedError = {}
    * eval expectedError[campo] = mensaje
    Given path 'usuarios'
    And request user
    When method post
    * if (response._id) cleanupIds.push(response._id)
    Then status 400
    And match header Content-Type contains 'application/json'
    And match response == expectedError

    Examples:
      | caso     | accion  | campo         | valor           | mensaje                                     |
      | BE-EX-07 | cambiar | email         | correo-invalido | email deve ser um email válido              |
      | BE-EX-08 | omitir  | nome          | no aplica       | nome é obrigatório                          |
      | BE-EX-09 | omitir  | email         | no aplica       | email é obrigatório                         |
      | BE-EX-10 | omitir  | password      | no aplica       | password é obrigatório                      |
      | BE-EX-11 | cambiar | administrador | talvez          | administrador deve ser 'true' ou 'false'     |

  @BE-S10 @BE-EX-06
  Scenario: Validar el rechazo del registro con email ya utilizado
    * def fixture = call read('classpath:helpers/create-user.feature')
    Given path 'usuarios'
    And request fixture.user
    When method post
    * if (response._id) cleanupIds.push(response._id)
    Then status 400
    And match header Content-Type contains 'application/json'
    And match response == messageSchema
    And match response == { message: 'Este email já está sendo usado' }
    Given path 'usuarios'
    And param email = fixture.user.email
    When method get
    Then status 200
    And match response == read('classpath:schemas/list.json')
    And match response.quantidade == 1
    * def expectedUser = karate.merge(fixture.user, { _id: fixture.id })
    And match response.usuarios == [ '#(expectedUser)' ]
