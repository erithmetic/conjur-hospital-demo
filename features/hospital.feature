Feature: Setting up roles for a hospital
  As an hospital software developer
  I want to create several roles and users for doctors, patients, and nurses
  So that I can protect patient data

  Scenario: Setting up permissions model
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

    # Create doctors as users
    When I run `conjur user:create --as-role $NS:doctor $NS/gregory`
    When I run `conjur user:create --as-role $NS:doctor $NS/james`

    # Create nurses as users
    When I run `conjur user:create --as-role $NS:nurse $NS/brenda`
    When I run `conjur user:create --as-role $NS:nurse $NS/regina`

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

    # Allow Doctor Gregory to view all of Alice's patient data
    When I run `conjur resource:permit variable:$ALICE_PRESCRIPTION_LIST_ID user:$NS/gregory execute`
    And  I run `conjur resource:permit variable:$ALICE_MEDICAL_HISTORY_ID user:$NS/gregory execute`

    # Allow Doctor James to view all of Bob's patient data
    When I run `conjur resource:permit variable:$BOB_PRESCRIPTION_LIST_ID user:$NS/james execute`
    And  I run `conjur resource:permit variable:$BOB_MEDICAL_HISTORY_ID user:$NS/james execute`

    # Allow all nurses to view every patient's prescription data
    When I run `conjur resource:permit variable:$ALICE_PRESCRIPTION_LIST_ID $NS:nurse execute`
    And I run `conjur resource:permit variable:$BOB_PRESCRIPTION_LIST_ID $NS:nurse execute`

  Scenario: Doctor James can log in
    When I run `conjur asset:show user:$NS/james`
    Then the json output should have attribute "login" with value "$NS/james"

  Scenario: Nurse Brenda can log in
    When I run `conjur asset:show user:$NS/brenda`
    Then the json output should have attribute "login" with value "$NS/brenda"

  Scenario: Doctor Gregory can view Alice's medical history and prescriptions
    When I run `conjur resource:check -r user:$NS/gregory variable:$ALICE_PRESCRIPTION_LIST_ID execute`
    Then the output should be "true"

    When I run `conjur resource:check -r user:$NS/gregory variable:$ALICE_MEDICAL_HISTORY_ID execute`
    Then the output should be "true"

  Scenario: Doctor James can view Bob's medical history and prescriptions
    When I run `conjur resource:check -r user:$NS/james variable:$BOB_PRESCRIPTION_LIST_ID execute`
    Then the output should be "true"

    When I run `conjur resource:check -r user:$NS/james variable:$BOB_MEDICAL_HISTORY_ID execute`
    Then the output should be "true"

  Scenario: Doctor Gregory cannot view Bob's medical history and prescriptions
    When I run `conjur resource:check -r user:$NS/gregory variable:$BOB_PRESCRIPTION_LIST_ID execute`
    Then the output should be "false"

    When I run `conjur resource:check -r user:$NS/gregory variable:$BOB_MEDICAL_HISTORY_ID execute`
    Then the output should be "false"

  Scenario: Doctor James cannot view Alice's medical history and prescriptions
    When I run `conjur resource:check -r user:$NS/james variable:$ALICE_PRESCRIPTION_LIST_ID execute`
    Then the output should be "false"

    When I run `conjur resource:check -r user:$NS/james variable:$ALICE_MEDICAL_HISTORY_ID execute`
    Then the output should be "false"

  Scenario: Nurses can view Alice and Bob's prescriptions
    When I run `conjur resource:check -r $NS:nurse variable:$ALICE_PRESCRIPTION_LIST_ID execute`
    Then the output should be "true"
    When I run `conjur resource:check -r $NS:nurse variable:$ALICE_PRESCRIPTION_LIST_ID execute`
    Then the output should be "true"

    When I run `conjur resource:check -r $NS:nurse variable:$BOB_PRESCRIPTION_LIST_ID execute`
    Then the output should be "true"
    When I run `conjur resource:check -r $NS:nurse variable:$BOB_PRESCRIPTION_LIST_ID execute`
    Then the output should be "true"

  Scenario: Nurses cannot view Alice and Bob's medical history
    When I run `conjur resource:check -r $NS:nurse variable:$ALICE_MEDICAL_HISTORY_ID execute`
    Then the output should be "false"
    When I run `conjur resource:check -r $NS:nurse variable:$ALICE_MEDICAL_HISTORY_ID execute`
    Then the output should be "false"

    When I run `conjur resource:check -r $NS:nurse variable:$BOB_MEDICAL_HISTORY_ID execute`
    Then the output should be "false"
    When I run `conjur resource:check -r $NS:nurse variable:$BOB_MEDICAL_HISTORY_ID execute`
    Then the output should be "false"
