Feature: User-Friendly Usage Manual
  As a non-technical user
  I want a clear, step-by-step guide
  So that I can use Xbook without needing to understand APIs or code.

  Scenario: Clear Explanations
    Given I am reading the manual
    Then I should see a "What is Xbook?" section
    And the term "LLM" should be explained in simple terms
    And the benefit of "Semantic Search" should be described using examples

  Scenario: Practical Steps
    Given I want to see my bookmarks
    Then the manual should clearly explain how to "Sync" (Step 1) and "Enrich" (Step 2)
    And it should explain that "Enrichment" is what makes the AI read the content
