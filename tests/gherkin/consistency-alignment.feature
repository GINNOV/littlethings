Feature: Source Consistency Alignment
  Scenario: Unified Action Labels
    Given I am on the Dashboard
    When I switch between "X" and "YouTube" tabs
    Then the primary action buttons should follow the pattern "Sync [Source]" and "Enrich [Source]"
    And the enrichment button should show the batch size for both sources

  Scenario: Unified Stats Layout
    Given I view the stats cards
    Then the headers should be symmetrical (e.g., "X Account" vs "YouTube Account")
    And the usage descriptions should follow a similar sentence structure
