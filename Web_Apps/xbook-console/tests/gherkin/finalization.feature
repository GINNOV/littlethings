Feature: Finalization and Data Integrity
  Scenario: Bookmarks Hook Logic
    Given a list of initial bookmarks
    When I toggle the read state
    Then the items should be updated in the hook state
    And the server should be notified via API

  Scenario: Library Service Extraction
    Given I need to search or filter bookmarks
    When the BookmarksPage renders
    Then it should delegate data fetching to the Bookmarks Service
    And the page component should be focused purely on layout

  Scenario: Global Embedding Coverage
    Given bookmarks exist without embeddings
    When the sync maintenance script is executed
    Then all bookmarks with summaries should have a corresponding vector embedding
