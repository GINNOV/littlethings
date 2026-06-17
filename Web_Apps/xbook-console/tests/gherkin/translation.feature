Feature: Bookmark Translation
  As a researcher
  I want to translate bookmark text into my preferred language
  So that I can understand content in foreign languages.

  Scenario: Default translation language is English
    Given the settings are at their default values
    When I view the LLM settings
    Then the target language should be "English"

  Scenario: Update default translation language
    Given I am on the settings page
    When I change the target language to "Spanish"
    And I save the settings
    Then the default translation language should be updated to "Spanish"

  Scenario: Translate a bookmark
    Given I have a bookmark with non-English text
    And my target language is set to "English"
    When I click the "Translate" button on the bookmark panel
    Then the system should call the LLM to translate the text
    And I should see the translated text in the UI
