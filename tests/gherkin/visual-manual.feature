Feature: Visual Usage Manual
  Scenario: Visual Guides in Manual
    Given the usage manual is rendered
    Then it should contain images for the Dashboard and Library
    And the images should be accessible from the public directory
    And each image should have an appropriate "alt" text for accessibility
