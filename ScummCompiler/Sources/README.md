# Reverse Engineering

## String Slots

The syntax is something like this:

`*pause-string = "Game Paused.  Press SPACEBAR to Continue."`
`*4 = "Game Paused.  Press SPACE to Continue."`

### MI1 Lookup Table

```
slot_lookup = {
    1: "disk-insert-prompt",                # "Insert Disk %c and Press Button to Continue."
    2: "disk-not-found-error",               # "Unable to Find %s, (%c%d) Press Button."
    3: "disk-read-error",                    # "Error reading disk %c, (%c%d) Press Button."
    4: "pause-message",                      # "Game Paused.  Press SPACE to Continue."
    5: "confirm-restart-prompt",             # "Are you sure you want to restart?  (Y/N)Y"
    6: "confirm-quit-prompt",                # "Are you sure you want to quit?  (Y/N)Y"
    7: "menu-save",                          # "Save"
    8: "menu-load",                          # "Load"
    9: "menu-play",                          # "Play"
    10: "menu-cancel",                       # "Cancel"
    11: "menu-quit",                         # "Quit"
    12: "menu-ok",                           # "OK"
    13: "disk-insert-save-load-prompt",      # "Insert save/load game disk"
    14: "name-required-prompt",              # "You must enter a name"
    15: "save-failed-message",               # "The game was NOT saved"
    16: "load-failed-message",               # "The game was NOT loaded"
    17: "saving-progress-message",           # "Saving '%s'"
    18: "loading-progress-message",          # "Loading '%s'"
    19: "prompt-save-game-name",             # "Name your SAVE game"
    20: "prompt-load-game-select",           # "Select a game to LOAD"
    21: "iq-points-display",                 # "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    22: "iq-points-short-display",           # "@@@@@@@@@@@@"
    23: "menu-restart",                      # "Restart"
    24: "current-passcode-label",            # "Current Passcode"
    25: "enter-passcode-prompt",             # "Enter Passcode"
    26: "invalid-passcode-message",          # "Invalid Passcode"
    27: "generic-confirmation",              # "Are you sure?"
    29: "debug-file-name",                   # "monkyeng._x_"
    30: "long-dotted-line-1",                # "...................................................................................................."
    31: "long-dotted-line-2",                # "...................................................................................................."
    32: "sword-fight-insult-lines",          # Contains sword fighting insult lines, such as:
                                            # "This is the END for you, you gutter-crawling cur!"
                                            # "You make me want to puke."
                                            # "Nobody's ever drawn blood from me and nobody ever will!"
    33: "sword-fight-comeback-lines",        # Contains sword fighting comeback lines, such as:
                                            # "How appropriate. You fight like a cow."
                                            # "I'm shaking, I'm shaking."
                                            # "Oh yeah?"
    38: "player-name",                       # "Threepwood"
    39: "location-antigua",                  # "Antigua"
    40: "location-barbados",                 # "Barbados"
    41: "location-jamaica",                  # "Jamaica"
    42: "location-montserrat",               # "Montserrat"
    43: "location-nebraska",                 # "Nebraska"
    44: "location-st-kitts",                 # "St.\xFAKitts"
    45: "location-tortuga",                  # "Tortuga"
    46: "passcode-feedback",                 # "Somehow that doesn't seem right.", "Yikes! Not quite right."
                                            # "That's not the answer I get, sorry."
    47: "input-answer-prompt",               # "Type in your answer: XXXX"
    48: "history-quiz-prompt",               # "When was this pirate hanged in " + getString(VAR_SENTENCE_SCRIPT) + "?"
    49: "generic-empty-string"               # " "
}
```


var a = "global a";
var b = "global b";
var c = "global c";
{
  var a = "outer a";
  var b = "outer b";
  {
    var a = "inner a";
    print a;
    print b;
    print c;
  }
  print a;
  print b;
  print c;
}
print a;
print b;
print c;
