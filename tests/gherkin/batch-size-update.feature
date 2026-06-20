Feature: Increased Batch Processing
  Scenario: New default batch size
    Given I have not customized my batch size
    When I trigger "Enrich All"
    Then the system should request a batch of 50 items by default
    And the settings page should show 50 as the default value
