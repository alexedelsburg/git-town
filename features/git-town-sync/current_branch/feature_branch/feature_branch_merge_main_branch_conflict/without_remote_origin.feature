Feature: git town-sync: resolving conflicts between the current feature branch and the main branch (without remote repo)

  Background:
    Given my repo does not have a remote origin
    And I have a local feature branch named "feature"
    And the following commits exist in my repository
      | BRANCH  | LOCATION | MESSAGE                    | FILE NAME        | FILE CONTENT    |
      | main    | local    | conflicting main commit    | conflicting_file | main content    |
      | feature | local    | conflicting feature commit | conflicting_file | feature content |
    And I am on the "feature" branch
    And I have an uncommitted file
    When I run `git town-sync`


  Scenario: result
    Then it runs the commands
      | BRANCH  | COMMAND                  |
      | feature | git stash -u             |
      |         | git merge --no-edit main |
    And I get the error
      """
      To abort, run "git town-sync --abort".
      To continue after you have resolved the conflicts, run "git town-sync --continue".
      To skip the sync of the 'feature' branch, run "git town-sync --skip".
      """
    And I am still on the "feature" branch
    And my uncommitted file is stashed
    And my repo has a merge in progress


  Scenario: aborting
    When I run `git town-sync --abort`
    Then it runs the commands
      | BRANCH  | COMMAND           |
      | feature | git merge --abort |
      |         | git stash pop     |
    And I am still on the "feature" branch
    And I again have my uncommitted file
    And there is no merge in progress
    And I am left with my original commits


  Scenario: continuing without resolving the conflicts
    When I run `git town-sync --continue`
    Then it runs no commands
    And I get the error "You must resolve the conflicts before continuing the git town-sync"
    And I am still on the "feature" branch
    And my uncommitted file is stashed
    And my repo still has a merge in progress


  Scenario: continuing after resolving the conflicts
    Given I resolve the conflict in "conflicting_file"
    When I run `git town-sync --continue`
    Then it runs the commands
      | BRANCH  | COMMAND              |
      | feature | git commit --no-edit |
      |         | git stash pop        |
    And I am still on the "feature" branch
    And I again have my uncommitted file
    And I still have the following commits
      | BRANCH  | LOCATION | MESSAGE                          | FILE NAME        |
      | main    | local    | conflicting main commit          | conflicting_file |
      | feature | local    | conflicting feature commit       | conflicting_file |
      |         |          | conflicting main commit          | conflicting_file |
      |         |          | Merge branch 'main' into feature |                  |
    And I still have the following committed files
      | BRANCH  | NAME             | CONTENT          |
      | main    | conflicting_file | main content     |
      | feature | conflicting_file | resolved content |


  Scenario: continuing after resolving the conflicts and comitting
    Given I resolve the conflict in "conflicting_file"
    When I run `git commit --no-edit; git town-sync --continue`
    Then it runs the commands
      | BRANCH  | COMMAND       |
      | feature | git stash pop |
    And I am still on the "feature" branch
    And I again have my uncommitted file
    And I still have the following commits
      | BRANCH  | LOCATION | MESSAGE                          | FILE NAME        |
      | main    | local    | conflicting main commit          | conflicting_file |
      | feature | local    | conflicting feature commit       | conflicting_file |
      |         |          | conflicting main commit          | conflicting_file |
      |         |          | Merge branch 'main' into feature |                  |
    And I still have the following committed files
      | BRANCH  | NAME             | CONTENT          |
      | main    | conflicting_file | main content     |
      | feature | conflicting_file | resolved content |
