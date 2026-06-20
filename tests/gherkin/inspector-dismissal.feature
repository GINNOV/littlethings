Feature: Bookmark Inspector Dismissal
  As a researcher
  I want to dismiss the entry details panel
  So that I can see the bookmark table in full width again.

  Scenario: Dismissing the inspector
    Given a bookmark is selected and the inspector is visible
    When I click the "Close" button on the inspector panel
    Then the inspector panel should disappear
    And the bookmark table should expand to full width
    And the selection highlight on the table should be removed
