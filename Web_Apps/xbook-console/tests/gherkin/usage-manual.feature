Feature: Usage Manual Accessibility
  Scenario: Navigation to Manual
    Given I am using the application
    When I click the "Manual" link in the sidebar
    Then I should be redirected to the usage manual page
    And I should see sections for "Importing", "Enrichment", and "Search"

  Scenario: Manual Content Clarity
    Given I am on the usage manual page
    Then the content should explain how to connect X and YouTube OAuth
    And it should describe how to use Semantic Search
