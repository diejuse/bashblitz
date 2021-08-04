# bashblitz
A game for Linux made with Bash: BashBlitz.
Video showing the game of my Youtube channel: https://www.youtube.com/watch?v=Y0df-MQmdrI

To increase my BASH level, I decided to make a game based on the classic Fritz game. I have seen few games written in pure Bash searching the web and I think many more could be made. The advantage of BASH games is that most Linux distros have BASH pre-installed and you don't need to have a graphical user environment (GUI) installed to play.
In this game, you are the pilot of a fighter plane and earn points when you bombard buildings in enemy cities. When you have bombed all the buildings in the city, you land, increase your level and go to another city.
The higher the level, the more difficult it is because the faster the plane flies. Up to what level are you capable of reaching, pilot?

How to play?

1.     Download bashblitz.sh
2.     Open a terminal (tty or pty) and go to the path where you downloaded the file.
3.     sh bashblitz.sh

Features:
- It displays correctly on TTY and PTY.
- It detects if the size of the terminal is adequate to view the game correctly.
- It exits the game if you try to resize the terminal.
- It saves the maximum score and the maximum level reached.
- It sounds when the bomb explodes. (beeps). It uses speaker-test if it is installed, otherwise it generates a beep with ANSI sequences.
