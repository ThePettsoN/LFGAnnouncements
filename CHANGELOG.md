# LFG Announcements

## [1.4.0](https://github.com/NilssonPontusOrg/LFGAnnouncements/tree/1.4.0) (2022-04-17)
[Full Changelog](https://github.com/NilssonPontusOrg/LFGAnnouncements/compare/1.3.0...1.4.0) [Previous Releases](https://github.com/NilssonPontusOrg/LFGAnnouncements/releases)

- Bump to 1.4.0  
- Add option to resize toaster window  
    - Option to change width and height of toaster  
    - Toaster content text will now properly wrap and/or truncate depending  
      on the size of the window  
    - Fix error when changing font size while main UI is not visible  
- Fix containers overlaping on specific font sizes  
- General code cleanup  
    - Move commands to its own file  
    - Define local variables for globals to improve performance  
    - Rename some stuff  
    - Remove some old code and comments  
- Split commands into its own module  
- It's now possible to change font style and size through the settings menu  
- More symbols to split the message with to better improve matching messages to the right stuff  
- [#10] Entries are now removed when filter settings are changed  
- Add option to flash game client icon on new requests  
