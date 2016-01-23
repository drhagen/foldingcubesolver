# snakecubesolver
This is a simple Ceylon project to solve snake cube puzzles. [A random description here](https://stackoverflow.com/questions/11622068/snake-cube-puzzle-correctness). The code currently only works on 3x3x3 cubes. The variable `strands` encodes turns of the snake. To encode:

1. select one of the ends as your starting point
2. count the steps it takes to get to the end of the first segment (either 1 or 2) (this is the first number in the list)
3. now the snake turns, count the number of steps it takes to get to the end of that segment (this is the second number in the list)
4. repeat until the end is reached

For reference, the snake in the link above is the snake in the code. I started from the left end.
