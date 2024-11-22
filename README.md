A timer written in Godot.

<img width="723" alt="Pasted image 20241111141959" src="https://github.com/user-attachments/assets/49ad3fa1-4f66-466a-a78c-21734ce1486e">

Warning:
- Super WIP!!!
- Breaking change at ANY time!!!!!

# Features
- One-hot timer
- Preserves all history
- Visualize the history (WIP)
- Self-hosted sync

# Usage
## Brief guide before I write a proper one:
1. Change the name of the timers in `Scripts\timer_type_list.gd`
2. Change the `SERVER_IP` (and optionally `PORT`) in `Scripts\main.gd` to your actual one (or leave it unchanged if you don't plan to use it on multiple devices)
3. Export your executables

## Command line arguments:
- `--server`: run the program in server mode. (the default is client mode)
- `--headless`: don't create the timer window

# Credits
- This program was made with Godot.
