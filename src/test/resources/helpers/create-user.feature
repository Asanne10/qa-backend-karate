@ignore
Feature: Preparar un usuario propio
  Scenario: Validar la creación de un usuario propio para la preparación
    * configure afterScenario = null
    * def user = createUserData()
    Given url baseUrl
    And path 'usuarios'
    And request user
    When method post
    * if (response._id) cleanupIds.push(response._id)
    Then status 201
    And match response == createSchema
    And match response.message == 'Cadastro realizado com sucesso'
    * def id = response._id
