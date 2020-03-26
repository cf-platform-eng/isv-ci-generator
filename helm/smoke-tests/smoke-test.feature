Feature: Helm

  Scenario: Missing helm chart
    Given I have generated my test
    And an environment is configured
    And no helm chart is given

    When I run the test

    Then the test fails
    And I see that the helm chart is missing

  Scenario: Smoke test
    Given I have generated my test
    And an environment is configured
    And a helm chart is given

    When I run the test

    Then the test passes
    And I see that the helm chart is installed and uninstalled
