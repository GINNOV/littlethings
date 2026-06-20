Feature: Batch Size UI Consistency
  Scenario: Button reflects actual batch size
    Given the database settings have enrichBatchSize set to 50
    When I view the Dashboard
    Then the enrichment button label should contain "(50)"
    And it should not show the old value "(25)"
