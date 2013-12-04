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
    When I run `conjur user:create --as-role $NS:doctor $NS/gregory` interactively
    When I run `conjur user:create --as-role $NS:doctor $NS/james` interactively

    # Create nurses as users
    When I run `conjur user:create --as-role $NS:nurse $NS/brenda` interactively
    When I run `conjur user:create --as-role $NS:nurse $NS/regina` interactively

    # Create patient data
    When I run `conjur variable:create -k medical_history -m application/json`
    And I store the "id" field as $ALICE_MEDICAL_HISTORY_ID
    And I run `conjur variable:values:add $ALICE_MEDICAL_HISTORY_ID` interactively
    And I pipe in:
      """
      [
        {
          "date": "2013-11-01 02:34:56", "type": "emergency_visit",
            "diagnosis": "influenza"
        }
      ]
      """

    When I run `conjur variable:create -k prescription_list -m text/plain`
    And I store the "id" field as $ALICE_PRESCRIPTION_LIST_ID
    And I run `conjur variable:values:add $ALICE_PRESCRIPTION_LIST_ID` interactively
    And I pipe in:
      """
      ["omeprazole", "codeine", "vicodin"]
      """

    When I run `conjur variable:create -k medical_history -m text/plain`
    And I store the "id" field as $BOB_MEDICAL_HISTORY_ID
    And I run `conjur variable:values:add $BOB_MEDICAL_HISTORY_ID` interactively
    And I pipe in:
      """
      [
        {
          "date": "2013-12-01 02:34:56", "type": "routine",
            "diagnosis": "cancer improving"
        },
        {
          "date": "2012-06-07 04:43:01", "type": "routine",
            "diagnosis": "cancer needs more treatment"
        }
      ]
      """

    When I run `conjur variable:create -k prescription_list -m text/plain`
    And I store the "id" field as $BOB_PRESCRIPTION_LIST_ID
    And I run `conjur variable:values:add $BOB_PRESCRIPTION_LIST_ID` interactively
    And I pipe in:
      """
      ["superdrug"]
      """

    # Allow Doctor Gregory to manage Alice's patient data

  Scenario: Doctor James can log in
    When I run `conjur asset:show user:$NS/james`
    Then the json output should have attribute "login" with value "$NS/james"

  Scenario: Nurse Brenda can log in
    When I run `conjur asset:show user:$NS/brenda`
    Then the json output should have attribute "login" with value "$NS/brenda"
