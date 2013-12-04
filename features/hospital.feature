@announce @puts
Feature: Setting up roles for a hospital
  As an hospital software developer
  I want to create several roles and users for doctors, patients, and nurses
  So that I can protect patient data

  Background:
    # A hospital has patients, doctors, and nurses.
    #
    # Doctors and nurses have identities and can log in.
    #
    # Patients are tracked but cannot log in.
    #
    # Each patient has two pieces of confidential data:
    #   * medical_history
    #   * prescription_list
    #
    # Doctors are allowed to view and modify all data related to their patients,
    # but cannot access resources associated with other patients.
    #
    # Nurses are allowed to view the prescription_list of any patient, but no 
    # other perimssions.

    # Log in and set up a new namespace
    Given I am authorized with Conjur
    When I run `conjur id:create`
    And I save the generated id in $NS

    # Create roles
    When I run `conjur role:create $NS:doctor`
    And  I run `conjur role:create $NS:nurse`
    And  I run `conjur role:create $NS:patient`

    # Create doctors as users
    When I run `conjur user:create --as-role $NS:doctor $NS:gregory` interactively
    When I run `conjur user:create --as-role $NS:doctor $NS:james` interactively

    # Create nurses as users
    When I run `conjur user:create --as-role $NS:nurse $NS:brenda` interactively
    When I run `conjur user:create --as-role $NS:nurse $NS:regina` interactively

  Scenario: Doctor James can log in
    When I run `conjur asset:show user:$NS-james`
    Then the json output should have attribute "login" with value "$NS-james"

  Scenario: Nurse Brenda can log in
    When I run `conjur asset:show user:$NS-brenda`
    Then the json output should have attribute "login" with value "$NS-brenda"
