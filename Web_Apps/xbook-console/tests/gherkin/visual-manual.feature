Feature: Visual Usage Docs
  Scenario: Visual Guides in Docs
    Given the docs page is rendered
    Then it should contain images for the Dashboard and Library
    And the images should be accessible from the public directory
    And each image should have an appropriate "alt" text for accessibility
