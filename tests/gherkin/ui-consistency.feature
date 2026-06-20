Feature: UI Component Consistency
  Scenario: Symmetrical Tab Switcher
    Given I am on the Dashboard
    Then the "X" and "YouTube" tabs should have identical widths
    And the text in both tabs should be centered
    And the active tab should have a distinct highlight
