Feature: file system commands

  In order to specify commands that load files
  As a developer using Cucumber
  I want to create temporary files
  
  Scenario: create a dir
    Given a directory named "foo/bar"
    When I run "ruby -e \"puts test ?d, 'foo'\""
    Then the stdout should contain "true"
  
  Scenario: create a file
    Given a file named "foo/bar/example.rb" with:
      """
      puts "hello world"
      """
    When I run "ruby foo/bar/example.rb"
    Then the output should contain "hello world"

  Scenario: append to a file
    Given a file named "foo/bar/example.rb" with:
      """
      puts "hello world"
      """
    When I append to "foo/bar/example.rb" with:
      """
      puts "this was appended"
      """
    When I run "ruby foo/bar/example.rb"
    Then the output should contain "hello world"
    And the output should contain "this was appended"

  Scenario: clean up files generated in previous scenario
    When I run "ruby foo/bar/example.rb"
    Then the exit status should be 1
    And the output should contain "No such file or directory -- foo/bar/example.rb"
  
  Scenario: change to a subdir
    Given a file named "foo/bar/example.rb" with:
      """
      puts "hello world"
      """
    When I cd to "foo/bar"
    And I run "ruby example.rb"
    Then the output should contain "hello world"

  Scenario: Reset current directory from previous scenario
    When I run "ruby example.rb"
    Then the exit status should be 1

  Scenario: Holler if cd to bad dir
    Given a file named "foo/bar/example.rb" with:
      """
      puts "hello world"
      """
    When I do aruba I cd to "foo/nonexistant"
    Then aruba should fail with "tmp/aruba/foo/nonexistant is not a directory"

  Scenario: Check for presence of a subset of files
    Given an empty file named "lorem/ipsum/dolor"
    Given an empty file named "lorem/ipsum/sit"
    Given an empty file named "lorem/ipsum/amet"
    Then the following files should exist:
      | lorem/ipsum/dolor |
      | lorem/ipsum/amet  |

  Scenario: Check for absence of files
    Then the following files should not exist:
      | lorem/ipsum/dolor |
      
  Scenario: Check for presence of a subset of directories
    Given a directory named "foo/bar"
    Given a directory named "foo/bla"
    Then the following directories should exist:
      | foo/bar |
      | foo/bla |

  Scenario: Check file contents
    Given a file named "foo" with:
      """
      hello world
      """
    Then the file "foo" should contain "hello world"
    And the file "foo" should not contain "HELLO WORLD"
