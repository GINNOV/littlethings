Feature: Maintenance and Search UX
  Scenario: Global Embedding Sync
    Given I have 500 legacy bookmarks without embeddings
    When I click "Sync All Embeddings" in Settings
    Then the system should process them in batches
    And every bookmark should eventually have an embedding

  Scenario: Semantic Search Feedback
    Given I perform a semantic search for "AI agents"
    When the results are displayed
    Then each result should show a similarity percentage
    And results should be sorted by that percentage

  Scenario: Home Page Decomposition
    Given I view the Dashboard
    Then the page should be composed of smaller, focused components
    And the overall Cyclomatic Complexity of the Home component should be <= 20
