Feature: Creating a role
  As an Conjur user
  I want to create a role
  So that I can group individuals with common permissions

  Background:
    Given I am authorized with Conjur
    When I run `conjur id:create`
    And I save the generated id in $NS

  Scenario: Creating a simple role
    When I run `conjur role:create $NS:simple`
    And I run `conjur role:exists $NS:simple`
    Then the output should contain "true"
