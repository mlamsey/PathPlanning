# UTK ARC Laboratory: Path Planning Project
Path Planning Software written in MATLAB by the UTK ARC Laboratory Research Team

## Purpose + Summary
This project aims to create an integrated software system that will convert previously generated contours (continuous sets of points in 3-space) into robot trajectories. Currently, the contours are generated using the metrology software GOM Inspect, and the target environment for the robot trajectories is Octopuz (via .path files).

This software uses a five-tier heirarchy to organize builds. An entire plan is encapsulated in a Part, which is composed of a series of Segments. Each segment is composed of a series of contours, which are defined as continuous sets of points in 3-space which must be deposited in the order specified by their arrangement within the segment. Contours consist of Moves, which contain a start and stop Waypoint. This facilitates integration with systems such as KUKA's KRL-based controllers, which interpolates process parameters between points on the part.

## Table of Contents
**Code Organization, Formatting + Syntax**
  - Code organization
  - Formatting + Syntax overview

**Functions List**
  - Part Algorithms
  - Segment Algorithms
  - Contour Algorithms
  - Move Algorithms
  - Waypoint Algorithms
  - Utils

## Code Organization, Formatting + Syntax
This section details the overall organization of the project, as well as the code format used.

### Code Organization
The code in this project is organized into several broad categories:
1. **Hierarchical Data Structures**, which contain geometric information and process parameters for the build (Instance Classes). These classes inherit from MATLAB's handle class, so they are _not_ value classes.
1. **Hierarchical Algorithms**, which apply to their corresponding data structures (Static Classes). Because the data structures are handle classes, these algorithms operate on the data structures by reference. Also included in this category is the Standard Processing class, which contains standard sets of operations performed on parts.
1. **Analysis Tools** for plotting, debugging, etc.
1. **GUI Applications** for manipulating parts.

### Formatting + Syntax
Several conventions are used throughout this project in order to facilitate easy use and extension of the code base.
1. Classes use PascalCase
1. Methods use PascalCase
1. All variables use snake_case
1. Constant Properties in Static Classes which include physical units begin with that unit, i.e. mm_move_length
1. All MATLAB end statements are terminated with a comment describing what that end closes, i.e. `end%if`, `end%for i`, or `end%func MethodName`

Further, several practices are encouraged to facilitate code compatibility and maintainability.
1. Enforcing strict-ish typing is encouraged, especially for functions which accept custom data structures as inputs. The first lines of a function that uses custom data structures should look something like:
`if(~isa(input_variable_name,'correct_type'))
  fpritnf('ClassName::MethodName: Input 1 is not a correct_type');
  return;
end%if
`
1. When printing debug statements, each line should take the following format: "ClassName::MethodName: _error description_"

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

### Utils
- IsOneByThreeVector
- AreAll
- NormalizeQuaternion
- GetDirectionVectorFromQuaternion
- GetABCFromQuaternion
- GetQuaternionFromNormalVectorAndTravelVector
- VectorProjection
- PointDistance3D
- GetNormalizedSlopes
- GetCommaSeparatedString
