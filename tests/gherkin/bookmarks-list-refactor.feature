Feature: Bookmarks List Refactoring
  As a developer
  I want to decompose the BookmarksList component
  So that it is maintainable and testable.

  Scenario: Row Selection
    Given a list of bookmarks
    When I click a bookmark row
    Then that bookmark should be selected
    And the inspector panel should update with its details

  Scenario: Translation and Reprocessing
    Given a selected bookmark
    When I trigger "Translate" or "Reprocess"
    Then the component should manage busy states correctly
    And the updated data should be reflected in the UI

  Scenario: Keyboard Navigation
    Given a bookmark row has focus
    When I press "Enter" or "Space"
    Then the bookmark should be selected
