# UTK ARC Laboratory: Path Planning Project
Path Planning Software written in MATLAB by the UTK ARC Laboratory Research Team

## Purpose + Summary
This project aims to create an integrated software system that will convert previously generated contours (continuous sets of points in 3-space) into robot trajectories. Currently, the contours are generated using the metrology software GOM Inspect, and the target environment for the robot trajectories is Octopuz (via .path files).

## Functions List
This section outlines the available functions in this project, organized by the tier at which they operate within the software's object heirarchy. Standard processing operations are written in the StandardProcessing Object.

### Part Algorithms
**Operations**
- UpdateTorchQuaternionsUsingInterContourVectors
- DecimateContoursByMoveLength
- CombineCollinearMoves
- StaggerPartStartPoints
- AlternateContourDirections
- RepairContourEndContinuity

### Segment Algorithms
**Operations**
- UpdateTorchQuaternionsUsingInterContourVectors
- DecimateContoursByMoveLength
- CombineCollinearMoves
- StaggerSegmentStartPoints
- AlternateContourDirections
- RepairContourEndContinuity

### Contour Algorithms
**Operations**
- UpdateTorchQuaternionsUsingInterContourVectors
- DecimateContoursByMoveLength
- CombineCollinearMoves
- StaggerStartByMoves
- Bisect Move
- ReverseContourPointOrder
- RepairContourEndContinuity
- AddMoveAtBeginningOfContour

**Tools**
- GetNormalVectorFromClosestMoveOnPreviousContour
- FindClosestContour2MoveToContour1Move
- FindClosestContour2MoveToContour1MoveWithInitialGuess

### Move Algorithms
**Operations**
- UpdateTorchOrientation
- ReverseMove
- BisectMove
- BisectMoveAtPercent
- CombineMoves

**Tools**
- GetMoveDirectionVector
- GetMoveDistance
- GetMoveMidpoint
- IsCollinear
- IsContinuous
- IsParallel

### Waypoint Algorithms
**Tools**
- GetVectorBetweenPoints
- GetDistanceBetweenPoints
- GetMidpoint
- GetPointBetween
