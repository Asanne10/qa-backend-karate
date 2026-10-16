@ignore
Feature: Limpiar un usuario propio sin carrito
  Scenario: Validar la limpieza de un usuario propio y su ausencia posterior
    * configure afterScenario = null
    Given url baseUrl
    And path 'usuarios', id
    When method delete
    Then status 200
    And match response == { message: '#string' }
    And match response.message == '#? _ == "Registro excluído com sucesso" || _ == "Nenhum registro excluído"'
    Given path 'usuarios', id
    When method get
    Then status 400
    And match response == { message: 'Usuário não encontrado' }
