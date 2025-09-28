# Timer
A timer made with Godot.

<img width="723" alt="Pasted image 20241111141959" src="https://github.com/user-attachments/assets/49ad3fa1-4f66-466a-a78c-21734ce1486e">

Warning:
- Super WIP!!!
- Breaking change at ANY time!!!!!
  - You need to manually delete the _config files_ (your records are safe) and let it regenerate them if you've used a version released before 2025-09-29

# Features
- One-hot timer
- Preserves all history
- Visualize the history (WIP)
- Self-hosted sync

# Usage
Now it works out of the box. But still, if you want...

## How to change the names and colors of the timers:

1. Launch the app once to let it generate the config files, then close it
2. Pay attention to the command line outputs to find out where those config files are
3. Edit the `server_config.json` file on the __server side__ to change the names and colors of the timers

## Command line arguments:
- `--server`: run the program in server mode and skip the server selection screen
- `--headless`: don't spawn the window

# Credits
- This program was made with Godot.
