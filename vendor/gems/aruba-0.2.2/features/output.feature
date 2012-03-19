Feature: Output

  In order to specify expected output
  As a developer using Cucumber
  I want to use the "the output should contain" step

  Scenario: Run unknown command
    When I run "neverever gonna work"
    Then the output should contain:
    """
    sh: neverever: command not found
    """

  Scenario: Detect subset of one-line output
    When I run "ruby -e 'puts \"hello world\"'"
    Then the output should contain "hello world"

  Scenario: Detect subset of one-line output
    When I run "echo 'hello world'"
    Then the output should contain "hello world"

  Scenario: Detect absence of one-line output
    When I run "ruby -e 'puts \"hello world\"'"
    Then the output should not contain "good-bye"

  Scenario: Detect subset of multiline output
    When I run "ruby -e 'puts \"hello\\nworld\"'"
    Then the output should contain:
      """
      hello
      """

  Scenario: Detect subset of multiline output
    When I run "ruby -e 'puts \"hello\\nworld\"'"
    Then the output should not contain:
      """
      good-bye
      """

  Scenario: Detect exact one-line output
    When I run "ruby -e 'puts \"hello world\"'"
    Then the output should contain exactly "hello world\n"

  Scenario: Detect exact multiline output
    When I run "ruby -e 'puts \"hello\\nworld\"'"
    Then the output should contain exactly:
      """
      hello
      world

      """

  @announce
  Scenario: Detect subset of one-line output with regex
    When I run "ruby --version"
    Then the output should contain "ruby"
    And the output should match /ruby ([\d]+\.[\d]+\.[\d]+)(p\d+)? \(.*$/

  @announce
  Scenario: Detect subset of multiline output with regex
    When I run "ruby -e 'puts \"hello\\nworld\\nextra line1\\nextra line2\\nimportant line\"'"
    Then the output should match:
      """
      he..o
      wor.d
      .*
      important line
      """

  @announce
  Scenario: Match passing exit status and partial output
    When I run "ruby -e 'puts \"hello\\nworld\"'"
    Then it should pass with:
      """
      hello
      """

  @announce-stdout
  Scenario: Match failing exit status and partial output
    When I run "ruby -e 'puts \"hello\\nworld\";exit 99'"
    Then it should fail with:
      """
      hello
      """

  @announce-cmd
  Scenario: Match output in stdout
    When I run "ruby -e 'puts \"hello\\nworld\"'"
    Then the stdout should contain "hello"
    Then the stderr should not contain "hello"

  @announce-stderr
  Scenario: Match output in stderr
    When I run "ruby -e 'STDERR.puts \"hello\\nworld\";exit 99'"
    Then the stderr should contain "hello"
    Then the stdout should not contain "hello"
