Feature: UI Clipping and Selection Fix
  Scenario: Table row full visibility
    Given I am on the library page
    When the viewport is narrow
    Then the table should scroll horizontally
    And the "Actions" column buttons (Read/Edit) should be fully visible within the scrollable area

  Scenario: Conditional Inspector Visibility
    Given no bookmark is selected
    Then the inspector aside panel should not be visible
    And the table should occupy the full width of its container
    When I select a bookmark
    Then the inspector panel should appear on the right
    And the table should resize to accommodate it
