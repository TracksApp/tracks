Feature: Tagging todos
  In order to organise my todos in various lists
  As a Tracks user
  I want to to be able to add or edit one or more tags to todos

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And I have logged in as "testuser" with password "secret"
    And I have a context called "@pc"
    And I have a project called "hacking tracks"

  Scenario: If there are no todos with a tag, the tag page should show an empty message
    When I go to the tag page for "starred"
    Then I should see "Currently there are no incomplete actions with the tag 'starred'"

  @javascript
  Scenario: I can remove a tag from a todo from the tag view and the todo will be removed
    Given I have a todo "fix tests" in context "@pc" with tags "now"
    When I go to the tag page for "now"
    Then I should see the todo "fix tests"
    When I edit the tags of "fix tests" to "later"
    Then I should not see the todo "fix tests"

  @javascript
  Scenario: I can add a new todo from tag view with that tag and it will be added to the page
    When I go to the tag page for "tracks"
    And I submit a new action with description "prepare release" and the tags "tracks, release" in the context "@pc"
    Then I should see "prepare release" in the context container for "@pc"

  @javascript
  Scenario: I can add a new todo from tag view with a different tag and it will not be added to the page
    When I go to the tag page for "tracks"
    And I submit a new action with description "prepare release" and the tags "release, next" in the context "@pc"
    Then I should not see the todo "prepare release"

  @javascript
  Scenario: I can move a tagged todo in tag view to a hidden project and it will move the todo on the page to the hidden container
    Given I have a hidden project called "secret"
    When I go to the tag page for "tracks"
    And I submit a new action with description "prepare release" to project "hacking tracks" with tags "release, tracks" in the context "@pc"
    Then I should see "prepare release" in the context container for "@pc"
    When I edit the project of "prepare release" to "secret"
    Then I should not see "prepare release" in the context container for "@pc"
    And I should see "prepare release" in the hidden container

  @javascript
  Scenario: I can move a tagged todo in tag view to a hidden context and it will move the todo on the page to the hidden container
    Given I have a hidden context called "@secret"
    When I go to the tag page for "tracks"
    And I submit a new action with description "prepare release" and the tags "release, tracks" in the context "@pc"
    Then I should see "prepare release" in the context container for "@pc"
    When I edit the context of "prepare release" to "@secret"
    Then I should not see "prepare release" in the context container for "@pc"
    Then I should see "prepare release" in the hidden container

  @javascript
  Scenario: Completing the last todo from the tag view will show the empty message
    Given I have a todo "migrate old scripts" in context "@pc" with tags "starred"
    When I go to the tag page for "starred"
    Then I should see "migrate old scripts" in the context container for "@pc"
    When I mark "migrate old scripts" as complete
    Then I should not see the context container for "@pc"
    And I should see "Currently there are no incomplete actions with the tag 'starred'"

  @javascript
  Scenario: Setting default tags for a project will prefill new todo form for that project
    When I go to the "hacking tracks" project
    Then the tag field in the new todo form should be empty
    And I edit the default tags to "tests"
    Then the tag field in the new todo form should be "tests"
    # also the tag field should be prefilled after reload
    When I go to the "hacking tracks" project
    Then the tag field in the new todo form should be "tests"
    # and the tag field should be prefilled after submitting a new todo
    When I submit a new action with description "are my tags prefilled"
    Then the tags of "are my tags prefilled" should be "tests"
    
  @javascript
  Scenario: Selecting a project with default tags when editing a todo will prefill the tags field
    Given I have a todo "tag me" in the context "@pc"
    And the default tags for "hacking tracks" are "TagA, TagB"
    When I go to the "@pc" context
    And I edit the project of "tag me" to "hacking tracks"
    Then the tags of "tag me" should be "taga, tagb"
    
  @javascript
  Scenario: If there are todos for a tag, when viewing the tag's page, the Tags field for new todos should be defaulted to that tag
    Given I have a todo "migrate old scripts" in context "@pc" with tags "starred"
    When I go to the tag page for "starred"
    Then the tag field in the new todo form should be "starred"
