Feature: Usage Docs Accessibility
  Scenario: Navigation to Docs
    Given I am using the application
    When I click the "Docs" link in the sidebar
    Then I should be redirected to the docs page
    And I should see sections for "Scenarios", "Sync", and "Search"

  Scenario: Docs Content Clarity
    Given I am on the docs page
    Then the content should explain how to connect X and YouTube OAuth
    And it should describe how to use Semantic Search
    And it should present two winning Scenarios for recall and create
