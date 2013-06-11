Feature: Toggle the containers
  In order to only see the todos relevant on this moment
  As a Tracks user
  I want to toggle the containers so the todos in that container (context or project) are not shown

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And I have logged in as "testuser" with password "secret"

  @javascript
  Scenario: I can toggle a context container
    Given I have the following contexts
      | context  | hide  |
      | @ipad    | false |
      | @home    | false |
      | @boss    | false |
    And I have a project "collapse those contexts" that has the following todos
      | description | context |
      | test 1      | @ipad   |
      | test 2      | @home   |
      | test 3      | @boss   |
    When I go to the home page
    Then I should see "test 1" in the context container for "@ipad"
    And I should see "test 2" in the context container for "@home"
    And I should see "test 3" in the context container for "@boss"
    When I collapse the context container of "@ipad"
    Then I should not see the todo "test 1"
    And I should see "test 2" in the context container for "@home"
    And I should see "test 3" in the context container for "@boss"
    When I collapse the context container of "@home"
    Then I should not see the todo "test 1"
    And I should not see the todo "test 2"
    And I should see "test 3" in the context container for "@boss"
    When I collapse the context container of "@boss"
    Then I should not see the todo "test 1"
    And I should not see the todo "test 2"
    And I should not see the todo "test 3"

  @javascript
  Scenario: I can toggle a project container
    Given I have the following contexts
      | context  | hide  |
      | @ipad    | false |
      | @home    | false |
      | @boss    | false |
    And I have a project "collapse those containers" that has the following todos
      | description | context |
      | test 1      | @ipad   |
      | test 2      | @home   |
      | test 3      | @boss   |
    And I have selected the view for group by project
    When I go to the home page
    Then I should see "test 1" in the project container of "collapse those containers"
    And I should see "test 2" in the project container of "collapse those containers"
    And I should see "test 3" in the project container of "collapse those containers"
    When I collapse the project container of "collapse those containers"
    Then I should not see the todo "test 1"
    And I should not see the todo "test 2"
    And I should not see the todo "test 3"

  @javascript 
  Scenario: I can hide all collapsed context containers
    Given I have the following contexts
      | context | hide  |
      | @ipad   | false |
      | @home   | false |
      | @boss   | false |
    And I have a project "collapse those contexts" that has the following todos
      | description | context |
      | test 1      | @ipad   |
      | test 2      | @home   |
      | test 3      | @boss   |
    When I go to the home page
    Then I should see "test 1" in the context container for "@ipad"
    And I should see "test 2" in the context container for "@home"
    And I should see "test 3" in the context container for "@boss"
    When I collapse the context container of "@home"
    And I collapse the context container of "@boss"
    And I collapse the context container of "@ipad"
    Then I should not see the todo "test 1"
    And I should not see the todo "test 2"
    And I should not see the todo "test 3"
    When I toggle all collapsed context containers
    Then I should not see the context container for "@home"
    And I should not see the context container for "@boss"
    And I should not see the context container for "@ipad"

  @javascript 
  Scenario: I can hide all collapsed project containers
    Given I have the following contexts
      | context | hide  |
      | @ipad   | false |
    And I have a project "collapse those containers" that has the following todos
      | description | context |
      | test 1      | @ipad   |
    And I have a project "collapse those other containers" that has the following todos
      | description | context |
      | test 2      | @ipad   |
    And I have selected the view for group by project
    When I go to the home page
    Then I should see "test 1" in the project container of "collapse those containers"
    And I should see "test 2" in the project container of "collapse those other containers"
    When I collapse the project container of "collapse those containers"
    Then I should not see the todo "test 1"
    And I should see the todo "test 2"
    When I collapse the project container of "collapse those other containers"
    Then I should not see the todo "test 1"
    And I should not see the todo "test 2"
    When I toggle all collapsed context containers
    Then I should not see the project container for "collapse those containers"
    Then I should not see the project container for "collapse those other containers"
