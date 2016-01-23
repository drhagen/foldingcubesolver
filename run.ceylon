"Run the module `org.drhagen.snakecubesolver`."
shared void run() {
  // Easy cube
  //value strands = [2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2];
  
  // Original cube
  value strands = [2,1,1,2,1,2,1,1,2,2,1,1,1,2,2,2,2];
  
  // Loop over starting positions and starting directions
  value solutionStream = {
    for (i in 0:3) 
    for (j in 0:3) 
    for (k in 0:3) 
    for (nextDirection in `Direction`.caseValues)
    let (directions = tryNextPiece(Position(i,j,k), nextDirection, strands, [], blankCube(Position(i,j,k))))
    if (exists directions) 
      then Solution(Position(i,j,k), directions) 
      else null
  };
  
  value solution = solutionStream.coalesced.first; // Get first non-null value
  print(solution);
}


// This is a recursive function that accepts the current state of the system and tries to fit the next piece in.
// If the piece fits, it recurses with the updated state to try the next piece. If the piece doesn't fit,
// it returns null, indicating that there is no solution down this path. Once it fits in the last piece, it
// returns the solution up to that point.
[Direction+]? tryNextPiece(
  Position currentPosition, 
  Direction currentDirection, 
  [Integer+] currentRemaining, 
  [Direction*] currentSolution, 
  Taken taken
) {
  value currentLength = currentRemaining.first;
  value newPositions = (1..currentLength).collect((distance) => currentPosition.move(currentDirection, distance));
  
  // Check if current piece goes outside bounds
  value furtherestPosition = newPositions.last;
  if (furtherestPosition.x >= 3 || furtherestPosition.y >= 3 || furtherestPosition.z >= 3 || 
    furtherestPosition.x < 0 || furtherestPosition.y < 0 || furtherestPosition.z < 0) {
    return null;
  }
  
  // Check if current piece intersects other pieces
  for (intermediatePosition in newPositions) {
    value collides = taken.test(intermediatePosition);
    if (collides) {
      return null;
    }
  }
  
  // If it gets to this point, this is a valid place for this piece to go.
  value newSolution = currentSolution.withTrailing(currentDirection);
  value newTaken = taken.withAll(newPositions);
  value newRemaining = currentRemaining.rest;
  
  if  (nonempty newRemaining) {
    // If there are more pieces, recurse in four perpendicular directions
    variable [Direction+]? returnSolution;
    for (newDirection in currentDirection.perpendicularDirections) {
      returnSolution = tryNextPiece(furtherestPosition, newDirection, newRemaining, newSolution, newTaken);
      if (returnSolution exists) {
        break;
      }
    }
    return returnSolution;
  } else {
    // If this is the last piece, return the final solution.
    return newSolution;
  }
}


// Keeps track of all the positions already taken by a piece
// Uses a unidimensional array because multidimensional array support is not good in Ceylon
class Taken([Boolean*] bitmap = false27) {
  Integer positionToIndex(Position position) => position.x + position.y * 3 + position.z *3*3;
  
  shared Boolean test(Position position) {
    value result = bitmap[positionToIndex(position)] else nothing;
    return result;
  }
  
  shared Taken withAll([Position*] newPositions) {
    value indexes = newPositions.collect((x) => positionToIndex(x));
    value updatedTaken = (0:27).collect((Integer index) => indexes.contains(index) then true else (bitmap[index] else nothing));
    
    return Taken(updatedTaken);
  }
}

[Boolean*] false27 = Array.ofSize(27, false).sequence();
Taken blankCube(Position startingPosition) => Taken().withAll([startingPosition]);

// This is basically a wrapper around Integer[3] 
class Position(shared Integer x, shared Integer y, shared Integer z) {
  shared Position move(Direction direction, Integer distance) => Position(this.x + direction.x * distance, this.y + direction.y * distance, this.z + direction.z * distance);
  
  shared actual String string => "Position(``this.x``, ``this.y``, ``this.z``)";
}

// Only unit directions are considered
abstract class Direction(shared Integer x, shared Integer y, shared Integer z) of up|down|front|back|right|left {
  shared formal Direction[4] perpendicularDirections;
}

object up extends Direction(0,1,0) {
  shared actual Direction[4] perpendicularDirections => [right, front, left, back];
  shared actual String string => "up";
}
object down extends Direction(0,-1,0) {
  shared actual Direction[4] perpendicularDirections => [right, front, left, back];
  shared actual String string => "down";
}
object front extends Direction(0,0,1) {
  shared actual Direction[4] perpendicularDirections => [up, left, down, right];
  shared actual String string => "front";
}
object back extends Direction(0,0,-1) {
  shared actual Direction[4] perpendicularDirections => [up, left, down, right];
  shared actual String string => "back";
}
object right extends Direction(1,0,0) {
  shared actual Direction[4] perpendicularDirections => [front, down, back, up];
  shared actual String string => "right";
}
object left extends Direction(-1,0,0) {
  shared actual Direction[4] perpendicularDirections => [front, down, back, up];
  shared actual String string => "left";
}

// A container class for the final solution
class Solution(Position start, [Direction*] directions) {
  shared actual String string => "Solution(``start``,``directions``)";
}
