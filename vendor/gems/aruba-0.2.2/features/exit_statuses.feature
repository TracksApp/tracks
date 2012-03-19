Feature: exit statuses

  In order to specify expected exit statuses
  As a developer using Cucumber
  I want to use the "the exit status should be" step

  Scenario: exit status of 0
    When I run "ruby -h"
    Then the exit status should be 0
    
  Scenario: non-zero exit status
    When I run "ruby -e 'exit 56'"
    Then the exit status should be 56
    And the exit status should not be 0

  Scenario: Successfully run something
    When I successfully run "ruby -e 'exit 0'"

  Scenario: Unsuccessfully run something
    When I do aruba I successfully run "ruby -e 'exit 10'"
    Then aruba should fail with "Exit status was 10"
