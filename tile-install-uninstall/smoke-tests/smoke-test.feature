Feature: Tile install uninstall
   Scenario: Smoke test
     Given I have generated my test
     And an environment is configured
     And I have an app-only tile
     And I have a working config file for my app-only tile

     When I run the test

     Then I see that the tile installed and uninstalled
