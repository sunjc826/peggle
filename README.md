# CS3217 Problem Set 4

**Name:** Sun Jia Cheng

**Matric No:** A0214263N

## Tips
1. CS3217's docs is at https://cs3217.github.io/cs3217-docs. Do visit the docs often, as
   it contains all things relevant to CS3217.
2. A Swiftlint configuration file is provided for you. It is recommended for you
   to use Swiftlint and follow this configuration. We opted in all rules and
   then slowly removed some rules we found unwieldy; as such, if you discover
   any rule that you think should be added/removed, do notify the teaching staff
   and we will consider changing it!

   In addition, keep in mind that, ultimately, this tool is only a guideline;
   some exceptions may be made as long as code quality is not compromised.
3. Do not burn out. Have fun!
## Dev Guide
### Overview
This application uses a mix of MVVM and MVC, as well as the Coordinator pattern. For the most part, MVVM is used, other than relatively simple components that don't require a view model. 
<img src="./images/overview.png" />

**General utilities**
- Provide generic storage and logging services for the other components.

**Coordinators**
- Manage view transitions. Instantiate controllers and inject them with view models.
  
**Controllers**
- Depend on view models for domain logic and state.
- Manipulate views.

**Views**
- Depend on view models for state.

**View models**
- Manipulate models.

**Models**
- Contain all the core domain logic.

### General utilities
Next, we go one step deeper. Let's explore the general utilities which don't depend on other parts of the application first.
<img src="./images/utils.png"/>

General utilities consist of 2 main classes, `LoggerWrapper` and `Storage`. There is also `JSONStorage` that is a specialization of `Storage`.

#### Storage
- `Storage` handles reading and writing of files to local storage.
- `JSONStorage` specializes in handling JSON data, and is also equipped with encoding and decoding facilities. Of course, `JSONStorage` can only encode objects conforming to the `Encodable` protocol and decode objects conforming to the `Decodable` protocol.
- `Storage` is used by view models when loading and saving game levels created by the level designer.
#### LoggerWrapper
- `LoggerWrapper` is a friendly wrapper around the `Logger` class in the `os` module and provides conditional logging depending on the currently set `logLevel`. 
- `LoggerWrapper` is used by any class that requires logging.

With the general utilities covered, we can move on to the core business logic of PeggleClone.


### Coordinator

<img src="./images/coordinator.png" />

The diagrams shows the flow of views. The root view is a `NavigationViewController` and transitions to views take the form of pushing them onto the navigation stack by `AppCoordinator`. When views are dismissed, they are popped from the stack.

The root view of the `NavigationalViewController` is the menu, where the player can choose between selecting a level to play, or going straight into the level designer.

### Models
We cover the revised shape hierarchy. The `XXXShape` and `XXXPolygon` protocol chain appears to be parallel, while in some environments it may be deemed as an anti-pattern, it does not cause any issues in this application, and in fact makes things more explicit.

<img src="./images/model_shapes.png"/>

- A `Shape` can be considered as any connected 2D object.
- A `CenteredShape` is a shape with a defined center. For the purposes of this application, we can reasonably assume that this center refers to the center of mass. (Although this assumption might cause limitations if we want to rotate a shape about an arbitrary pivot.)
- A `TransformableShape` is a centered shape that can accept the affine transformations of rotation and scaling. Translation can be simulated by moving the center of a shape; the rest of the shape moves along with the center. 
- A `Polygon` is a shape with a finite number of edges, in particular, it must have at least 3 edges (a triangle). `CenteredPolygon` and `TransformablePolygon` are similar to `CenteredShape` and `TransformableShape`, with the addition of the polygonal nature of the shape.
- A `RegularPolygon` is a convenient subtype of a `TransformablePolygon`. This is because we only to know the "radius" of a regular shape to know where its vertices are.
By convention, the default position of the $i$-th vertex of a regular shape with $n$ sides is at
$$
(r\cdot \cos \frac{2\pi i}{n},r\cdot \sin \frac{2\pi i}{n}),\quad i = 0,1,\dots,n-1
$$
in Cartesian coordinates.
This is easily generalizable to $(r\cdot \cos(\frac{2\pi i}{n} + \theta),r\cdot \sin(\frac{2\pi i}{n} + \theta))$ for some $\theta$ by doing a rotation on the shape.

`XXXObject` are class-implementations of the various protocols. For the game engine objects, only `CircleObject` and `TransformablePolygonObject` are used, since these cover all the shapes we need for Peggle. Of course, this excludes shapes like non-circular ellipses, but we will not cover those.

##### The coordinate system
The coordinate system is a mixture of cartesian coordinates and polar coordinates.
The position of a shape is given by its center, which uses cartesian coordinates.
The vertices of a shape are relative to the shape's center, these use polar coordinates, with the origin being the center of the peg.

Next, we examine the actual game objects. Note that the shape hierarchy provides the geometrical properties associated with each game object.

<img src="./images/model_entities.png"/>

- `GameEntity` is the high level protocol that all game objects conform to.
- `EditableGameEntity` are game entities that can be edited in the level designer. For example, the ball is not editable since it is not part of the level design.
- `Ball` is the ball that is shot from the cannon.
- `Peg`s are any destructible objects (by the ball).
- `Obstacle`s are indestructible objects. Obstacles can still be potentially forcibly removed if the ball gets stuck.

The game level is split into 2 major models. The first is the `DesignerGameLevel`, which represents the state of the level being designed on the level designer. The second is `GameLevel`, which represents the state of the level when the game is actually being played.

#### DesignerGameLevel

<img src="./images/model_designer_game_level.png"/>

`DesignerGameLevel` has a number of dependencies. The main dependencies are:

##### CoordinateMapper
There are 3 types of coordinates in this application. They are:
- Logical coordinates: The coordinates that the core logic works with.
- Screen coordinates: The displayed pixel coordinates.
- Physical coordinates: "Real world" coordinates. This is only relevant for the game, and is only really used by the physics engine. In fact, the physics engine takes in a `PhysicsCoordinateMapper` object, which is a subclass of `CoordinateMapper` to transform any physical coordinates (such as acceleration due to gravity $g$) into logical coordinates before performing computations.

The base `CoordinateMapper` class only handles conversion between logical and screen coordinates.
Logical coordinates are of the following form. Upon creation of a level, $\text{aspect ratio} = \frac{\text{screen width}}{\text{screen height}}$. After this computation, the logical coordinate space is then described by
$$
[0, \text{aspect ratio}] \times [0, 1]
$$
In other words, the y-component of the logical coordinate space is always in $[0, 1]$.
The actual display dimensions are then a scaled-up version of the logical coordinate space. The application scales this as large as possible without exceeding either screen width or screen height.

##### PlayArea
The play area represents the big rectangular box that the game takes place in. Everything (pegs and obstacles) must be wholly contained within the play area.

##### Container
The container manages the collection of entities in the level. Ideally, the container would provide fast membership testing.

##### CollisionDetector
The collision detector detects collisions between entities.
##### NeighborFinder
The neighbor finder participates in the broad-sweep portion of collision detection, where a number of candidates are found to be potentially colliding. Each candidate is then checked specifically using an accurate collision detection algorithm (provided by the collision resolver).

##### Dependency injection
For testability, many of these dependencies are stated as protocols to be conformed to by some implementing class, and these dependencies are then passed to `DesignerGameLevel`'s constructor explicitly, allowing for *dependency injection*.
The `AnyXXX` classes such as `AnyNeighborFinder` and `AnyContainer` are used for type erasure. This is due to the limitations Swift places on protocols.
Protocols cannot conform to another protocol. In other words, if I widen an object `a` of say, type `A: ProtocolA` to `ProtocolA`, then I cannot use `a` as a parameter in any function expecting `ProtocolA`.
These restrictions are even more troublesome when it comes to protocols with associated types like `Container`. It is not possible to even have a class member with a protocol type `Container<Element>`. It must be a concrete type(such as `AnyContainer<Element>`).

In practice, the default implementations of each protocol is as follows:
- `Container`: `SetObject`, which is wrapper around `Set`. Note that this is necessary due to difficulties in getting `Set` (which is a value-type) to be added to the type-erased `AnyContainer`.
- `CollisionDetector`: `Collision`, which has both collision detection and collision resolution abilities.
- `NeighborFinder`: `QuadTree`, which is a data structure that splits 2D space into quarters.

**Remark** When examining the `Collision` class, it may seem that the collision detection methods are similar to the collision resolution methods. Indeed, collision detection is essentially a lower-powered version of collision resolution. For performance reasons, I chose to split them apart. 
#### GameLevel

<img src="./images/model_game_level.png"/>

Somewhat unlike `DesignerGameLevel`, `GameLevel` only one main dependency, the `PhysicsEngine`. This is because all logic concerning geometry, collisions etc. are delegated to the physics engine.

The enumeration `GamePhase` models the state of the game is in. Read the in-code documentation for a summary of the game states.

The `PhysicsEngine` has these dependencies:
- `RigidBodyObject`, which is a concrete implementation of the `RigidBody` protocol. The `RigidBodyObject` contains an assortment of properties that are used to perform physics calculations.
- The `RigidBodyObject` has a convenience reference back to the `GameEntity` it is associated with, allowing the physics engine to communicate with the game level, which can be interpreted as the game engine.  
- `Boundary` represents the physical world of the game. It is rectangular, and each rigid object can have customized behavior when it collides with an edge of the boundary.

The `WallBehavior` enumeration (See `Boundary.swift`)  dictates how a rigid body ought to behave upon colliding with an edge of the boundary.
1. `fallThrough`: The body "passes through" the edge without any interaction, and when the body is completely outside the boundary, it is marked for deletion.
2. `collide`: Just as what you would expect, the body will bounce off the wall.
3. `wrapAround`: The body "wraps around" to the opposite side of the boundary. For example, if the body moves completely outside the left wall, and its left wall behavior is marked as wrapAround, then the body will be teleported to the right wall, keeping its previous velocity.


#### Persistence
Before moving on to more details about the game level, we first discuss the persistence models, since we have already covered the `DesignerGameLevel` and `GameLevel`.

<img src="./images/model_persistence.png"/>

Only 3 models are Codable, and persisted, `PersistablePlayArea`, `PersistableDesignerGameLevel` and `PersistablePeg`. They are stripped down versions of the `PlayArea`, `DesignerGameLevel` and `Peg`.

The most notable part is that both `DesignerGameLevel` and `GameLevel` are hydrated by the `PersistableDesignerGameLevel`. In other words,
- When a designed game level is saved, it is converted to `PersistableDesignerGameLevel`
- When transitioning into the designer view, the information available in `PersistableDesignerGameLevel` is injected into the `DesignerGameLevel`, and the view is then updated accordingly.
- When transitioning into the game view, similarly the game view gets its information from `PersistableDesignerGameLevel`.

**Remark** Due to the nature of the hydration, which takes place after a controller's `viewDidAppear` lifecycle phase, the loading process can be quite obvious, especially on iOS simulators. i.e. You can see the pegs popping into view. There may be better ways to do this, like add in a loading spinner, but I think I may not do that due to time reasons.

#### Game Loop
Before going into the main game loop, we take a loop at a sequence diagram of the initialization process of the game level and associated controllers and view models. 
<img src="./images/seq_game_setup.png" />

The `appCoordinator`, in its `showGame` method, instantiates a `GameViewController` and later pushes it into the navigational stack of the `navigationViewController`.
But before that, the `appCoordinator` has to prepare data for the `gameViewController`. And to do this, the associated view model, an instance of `GameViewModel` is created and injected into `gameViewController` as a property.

On `viewDidLoad`, one of the most important things done by the `gameViewController` is to create the display link, and instructs its view model to start a new game of Peggle.

<img src="./images/seq_game_loop.png" />

This is a relatively high level overview of the game loop. To avoid seeing the forest for the trees, some details are left out, such as
- Game phase: We assume that the game is currently in the `.ongoing` phase. The code itself has more documentation about the various game phases and what they mean. See `GamePhase.swift`.
- Physics engine: Details about what the physics engine does are left out. Collision resolution is done in `calculateWithoutApplyingResults` and rigid body updates are done in `applyResults`

Now, the call sequence of `applyResults` is actually quite detailed. The reason for this is to see the series of callbacks that result. In particular, `GameLevel` attaches game logic callbacks onto `PhysicsEngine`, and `GameViewController` attaches view logic callbacks onto `GameLevel`.

The `XXX` can be replaced by `Ball` or `Peg`.

#### Physics Engine
We examine a high level activity diagram of what the physics engine does.
<img src="./images/activity_physics.png" />

For each physics update, the physics engine first calculates the physical properties (like position, velocity) for all objects based on the most recent state without applying these updates. This is so that the order of updates will not matter.

When doing calculations, 2 things need to be resolved.
1. The first is to resolve the case where an object collides with the game's boundaries, for example the left wall. Based on how the object is defined to behave at the wall, the physics engine calculates the next position/velocity accordingly.
2. The second is to resolve the collisions between rigid bodies.

In the next step, objects outside the game boundaries are removed. For example, a ball that falls below the game screen.

Finally, the physics calculations are applied to each object. Here, a single physics update is considered done.



#### RigidBodyObject
We examine the various properties on a `RigidBodyObject` and how they affect it. Not listed here are also some computed properties on `RigidBodyObject` that essentially come from the underlying `backingShape`.
- `backingShape: TransformableShape`: The underlying geometrical shape of the rigidbody. Notice that the rigidbody does not care about what the game object is, be it a `Peg`, `Ball` etc. Only the shape can possibly affect its physical properties.
- `associatedEntity: GameEntity?`: Used to communicate with the game engine. When passing a rigidbody back to the game engine, this field allows the game engine to find out which game entity is associated with the rigid body, and apply the corresponding game logic.
- `sides: Int`: The number of sides of the underlying shape. 0 if the shape is a circle.
- `nextTeleportLocation: CGPoint?`: Allows the physics engine to teleport a rigidbody in an update.
- `isAffectedByGlobalForces: Bool`: Whether the body is affected by global forces like gravity.
- `canTranslate: Bool`: This property overrides mass. Determines whether an object can actually translate, regardless of its mass.
- `canRotate: Bool`: This property overrides moment of inertia. Determines whether an object can actually rotate, regardless of its moment of inertia.
- `uniformDensity: Double`: The density uniform across a rigidbody. Clearly, simulating varying density is far beyond a simple physics engine.
- `mass: Double`: Physics concept. Defaults to the area of the underlying shape scaled by the uniform density.
- `inverseMass: Double`: The reciprocal of mass. Used as a performance optimization.
- `momentOfInertia: Double`: Physics concept. The rotational equivalent of mass. Defaults to the moment of area (see wikipedia) of the underlying shape scaled by the uniform density.
  - **Remark**: In the implementation, this quantity is multipled by `Settings.easeOfRotation.rawValue` in order to possibly make pegs more easy to rotate. This is because the moment of inertia is dependent on shape area, and without this artificial scaling factor, the ball is too small to apply sufficient force on a large peg to make it spin. 
- `inverseMomentOfInertia: Double`: The reciprocal of moment of inertia. Used as a performance optimization.
- `linearVelocity: CGVector`: Physics concept.
- `angularVelocity: Double`: Physics concept. The rotational equivalent of linear veloicty.
- `force: CGVector`: Physics concept.
- `impulseIgnoringForce: CGVector`: Physics concept. Impulse is the change in momentum, and is the result of force applied over time. This particular quantity, however, acts as "instanteneous impulse", and ignores force. See "impulse-based physics engines" for more details.
- `torque: Double`: Physics concept. The rotational equivalent of force.
- `angularImpulseIgnoringTorque: Double`: Physics concept.
- `elasticity: Double`: Determines how much energy is lost by a rigidbody upon collision.
- `leftWallBehavior, rightWallBehavior, topWallBehavior, bottomWallBehavior: WallBehavior`: This has been explained above.
- `hasCollidedMostRecently: Bool`: Whether in the most recent physics update, the rigidbody has collided with something.
- `consecutiveCollisionCount: Int`: The number of consecutive physics engine updates for which a collision is detected. Used by the game engine to detect if objects are stuck.

### View Models, Controllers, Views
Since the view models, controllers and views are closely related, we will discuss them together.

#### Level Designer
<img src="./images/view_designer.png" />

The `MainViewController` is the root of the level designer view. It contains 3 child view controllers.

The `PaletteViewController` controls the palette. The palette offers a selection of template pegs, that when selected, will be placed down into the game level when tapping on the designer. The palette also has a delete button, that when selected, deletes any pegs that is tapped on.

**Remarks**
- The currently selected peg (if any) will have full opacity.
- Unselected pegs will be translucent.
- The delete button's background color turns blue when it is selected.

The `StorageViewController` handles the bottom bar of the level designer and it has the following functions.
- Reset level by clearing all placed objects.
- Load level by transitioning to the level select view.
- Save the level currently being designed.
- Play the level by transitioning to the game view.

**Remarks**
- The game does not allow saving of inconsistent levels, and will check that the level is consistent (i.e. no "ghost" pegs) before saving.

The `DesignerViewController` controls the bulk of the level designer. The concerns it handles include
- Letterboxing
- Choosing the level editor mode ("Concrete" vs "Ghost")
- Adding, updating (moving), removing pegs
- Removing inconsistent ("ghost") pegs


**Remarks**
- When a placed peg is selected in the level designer, a rectangular box will be drawn around it.
- The letterboxing implementation is incomplete, as the game view itself does not have letterboxing logic. The designer view's implementation is also incomplete. For now, the letterboxing only works when creating a new level, or loading a level of the same size as the screen. The letterboxing comes in the form of translucent blue boxes.

#### Game

<img src="./images/view_game.png" />

The `GameViewModel` relies on the `GameLevel` for information on game objects, and renders them accordingly onto the view.

Like `DesignerViewController`, the `GameViewController` maps pegs to views, and adds view relevant callbacks to the `GameLevel`. Indeed, one may question whether this coupling between controller and view is acceptable in MVVM. This is addressed in the section on *Design Tradeoffs*.

The `GameView` is responsible for rendering the cannon (in future) and the guiding line of fire.

#### Level Select

<img src="./images/view_select.png" />

The level select view is rather simple and serves to display the collection of stored levels along with their associated preview images.

Upon loading a level, it transitions back to the level designer.

## Rules of the Game
Please write the rules of your game here. This section should include the
following sub-sections. You can keep the heading format here, and you can add
more headings to explain the rules of your game in a structured manner.
Alternatively, you can rewrite this section in your own style. You may also
write this section in a new file entirely, if you wish.

### Cannon Direction
Please explain how the player moves the cannon.

### Win and Lose Conditions
Please explain how the player wins/loses the game.

## Level Designer Additional Features

### Peg Rotation
Please explain how the player rotates the triangular pegs.

### Peg Resizing
Please explain how the player resizes the pegs.

## Bells and Whistles
Please write all of the additional features that you have implemented so that
your grader can award you credit.

## Tests
### Unit tests
Many of the basic model classes have been unit tested.

`DesignerGameLevel.swift` A limited number of tests have also been written in code as well.
As this class has been refactored to allow for dependency injection, it is possible to inject stubs. For example, injecting a referenced type container can make it easier to test if elements in container match expectations.

- `hydrate`
  - given level with different `playArea`, expect error to be thrown
  - given level with equally sized `playArea`, expect success. Furthermore, check that `self` has exactly the same pegs as `incomingPeg` by comparing their respective containers.

- `addPeg`
  - Try adding the exact same peg (identical) twice. Check that callbacks are called the first time. Check that no callbacks are called the second time. (To do this, we can register a callback that updates a counter.)
  - Set `isAcceptingOverlappingPegs` to true. Try adding two equivalent, but not identical pegs. Expect both pegs to be added, so that add callbacks are triggered.

- `removePeg`
  - Deleting a peg that doesn't exist would cause an assertion failure.
  - Checking for successful deletion is similar as in `addPeg`, register a callback that updates a counter, and check the the parameter received by the callback is indeed the deleted peg.

- `updatePeg`
  - Again, checking for successful update amounts to adding a suitable callback.
  - Passing two identical pegs would cause assertion error.

- `isConsistent`
  - To an empty game level, add two pegs to the same spot. Check that output is false.
  - Update one of the peg and move it far away. Check that output is true.

- `removeInconsistencies`
  - Do similar things as above until `isConsistent()` returns false.
  - Call `removeInconsistencies`. Check that `isConsistent()` returns true.

`GameLevel.swift` The integration tests for game state are described in the later section.
- `hydrate` (Same as `DesignerGameLevel`)
  - given level with different `playArea`, expect error to be thrown
  - given level with equally sized `playArea`, expect success. Furthermore, check that `self` has exactly the same pegs as `incomingPeg` by comparing their respective containers.
Hook into the lifecycle of `GameLevel` by registering callbacks. These callbacks can be used to check if adding, updating or removing is successful.
- `update`
  - This is very hard to unit test. An integration test is preferred.

`PhysicsEngine.swift` The idea of testing a physics engine is to inject in a certain pre-calculated initial state, where the initial state can be one of the following general cases.
1. Bodies not capable of translating or rotating. Essentially the physics engine is expected to make no changes to their positions or velocities.
2. Stationary bodies that neither collide with each other nor with the wall. If a body is unaffected by gravity, it stays still. If a body is affected by gravity, check that in a single update, its velocity increases by `dt * gravitationalAcceleration` where the gravitational acceleration is scaled due to the conversion between physical coordinates and logical coordinates.
3. Stationary bodies that collide with each other. If the bodies partially overlap, they will be expected to be completely disjoint in the next update due to the teleportation mechanism of collision resolution. However, since the bodies are stationary, ignoring gravity, they should remain stationary. To ignore gravity, we can just set their property `isAffectedByGlobalForces` to false.
4. Stationary bodies colliding with wall, where their wall behavior is set to `WallBehavior.collide`. Unlike point 3, the bodies do not teleport.
5. Moving bodies colliding with each other. The bodies should reflect against each other based on the Newtonian kinematics equations.
6. Moving bodies colliding with wall. The body should bounce off the wall. More accurately, the component of the body's velocity  normal to the wall is reflected and the component parallel to the wall remains the same. There should also be energy loss based on the body's elasticity, which can be seen by a decrease in speed.
Other things like rotation are probably impossible to test since the rotation dynamics implementation is very much an approximation, and not even a physically accurate one at that. 


With the MVVM pattern, the view models make testing much easier. However, due to time limitations, I will use integration tests to test view models alongside controllers.

The initialization of controllers is unit tested, as seen in `StoryboardableTests.swift`.

### Integration tests
#### Test menu
- On tap Designer
  - Transition to designer view with a blank canvas
  - The title of the blank designer level should be "Default level name"
- On tap Level Select
  - Transition to level select view 
#### Test palette
- On tap first peg, the tapped peg becomes opaque. All other pegs should be translucent.
- On tap second peg, the second peg becomes opaque. First peg returns to original state, i.e. translucent.
- The same applies for any other peg.
- On tap delete button, delete button background color turns from white to blue. All pegs become translucent.
- On tap any peg after tapping delete button, delete button background should be white. And as before, the tapped peg becomes opaque while all other pegs become translucent.
- Tapping an opaque (i.e. selected) peg does not change anything. That is, the tapped peg remains opaque, all other pegs remain translucent, and the delete button background remains white.

#### Test designer
- The designer is letterboxed. The aspect ratio of the design area should match the aspect ratio of the iOS device. (As of now, letterboxing for game levels of arbitrary aspect ratios has not been implemented, though the core coordinate mapping logic is there.)
- On tap edit mode button, the following state transitions should occur.
  - If edit mode is previously "concrete", the label above the edit mode button should say "ghost" and a remove inconsistencies button should appear on the right of the screen.
  - If edit mode is previously "ghost", the label above edit button should say "concrete" and the remove inconsistencies button should disappear. Furthermore, any ghost pegs should be removed.

*Edit mode concrete, palette peg selected*
- On tap anywhere in the designer that is not a button, the following cases occur: $(1)$
  - A new shape is created centered at the tapped spot if it does not cause any overlaps.
  - No new shape is created if it causes overlaps.
- On dragging a shape
  - The shape's position is such that its center is at the current dragging location if it does not cause any overlaps
  - The shape does not move if it moving to the current dragging position causes overlaps. Overlaps include attempting to drag the shape out of bounds (outside the blue background). The top area (space reserved for the cannon) and palette also count as being out of bounds.
- On long pressing a shape
  - The shape is deleted
- On double tapping a shape when there is no transform menu
  - Transform menu appears
    - If the shape is a circle, the transform menu should only have scale label and slider
    - If the shape is a polygon, the transform menu should have scale label and slider, as well as rotation label and slider.
  - A rectangular box is drawn around the shape. No other shape has a rectangular box around it.
- On double tapping a shape when there is a transform menu
  - If the shape is the same shape the transform menu is associated with, the menu should disappear. Additionally, the rectangular box around the shape should disappear. There should be no rectangular box around any shape in the designer.
  - Otherwise, the menu remains, and the slider values change to reflect the scale and/or rotation of the newly tapped shape. Furthermore, a rectangular box forms around the newly selected shape. The rectangular box around the previously selected shape disappears.
- On tap anywhere in the designer with transform menu open
  - The aforementioned behavior in $(1)$ still holds
  - The transform menu closes

*Edit mode concrete, nothing selected*
- Essentially the same behavior as above, with the exception that no peg is created when tapping a blank spot.

*Edit mode concrete, delete peg selected*
- On tap on a shape
  - Shape is removed. Furthermore if transform menu is open, the menu is closed.
- On tap on blank spot
  - No shape is created. Furthermore if transform menu is opened, it is closed.

 *Edit mode ghost, palette peg selected*
- On tap anywhere in designer that isn't a button
  - A shape is created. If it overlaps with a concrete peg, the shape becomes a ghost.
- On dragging a shape
  - If the shape is a ghost, and it moves to a location where it doesn't overlap with a concrete peg, it becomes concrete.
  - If the shape is concrete, and it moves to a location where it overlaps a concrete peg, it becomes a ghost.
  - If the shape is a concrete, and move away such that there are other ghost pegs that no longer overlap with concrete pegs. Then those other pegs become concrete.

#### Test shape transform
- On scale slider change, the peg's scale changes. e.g. if scale slider moves right, the peg grows in size.
- On slider change
  - If edit mode concrete: the peg's transformation will only changes correspondingly if no overlaps are caused.
  - If edit mode ghost: the peg's transformation always changes, and the peg updates its concrete status correctly based on its current transformation.

#### Test bottom menu bar
- On tap reset button
  - All pegs are removed. However, these changes are not automatically persisted unless saved.
- On tap load button
  - Transitions to level select.
  - The level is not saved and any unsaved changes are lost.
- On tap save button
  - If the level name is blank, that is, the level name only contains spaces and newlines, then a notification pops up warning the user. Level does not save. The user can then close the notification, after which no changes occur in the level.
  - If level name is not blank, and there are no ghost pegs, save the current level with the name in the text label (overwrite if the level already exists), and transitions to level select. The level select view should show the newly created level with a correct preview image and title. Furthermore, only pegs should be in the preview, no extraneous buttons, labels, sliders etc.
  - If the level name is not blank and there are ghost pegs, a notification modals appears stating that saving is not possible due to inconsistent pegs. There will be 2 buttons, one to close the modal without changes, and one to remove inconsistent pegs. When either button is tapped, the modal closes.
    - If the remove inconsistent pegs is pressed, all ghost pegs will be removed.
    - If close is pressed, all pegs remain unchanged, including the ghost pegs.
  - The level name should be saved correctly and appear in the level select collection view.
- On tap level name button
  - A modal pops up, with a text field.
  - The user can type in a name into the text field.
  - On press the "confirm level name" button
    - The level name is updated, and the text on the level name changes to reflect the new name.
    - However, this change is not persisted unless saved.
    - The modal closes.
  - On press the "cancel" button
    - No changes are made to the level name.
    - The model closes.
- On tap start button
  - Saves the level, automatically removing any inconsistent pegs.
  - Transitions to game view.

**Test Load level**
- On tap Back
  - If we came from menu, transitions to menu.
  - If we came from level designer, transitions to level designer
- On tap Load for a particular cell
  - Transitions to level designer
  - The level should be loaded, assuming that the play area matches.
  - The pegs in the design view should match the preview image in the collection view cell.
  - The level name in the bottom text field should match the level name displayed in the collection view cell.
  - Otherwise, if play area does not match, nothing is loaded, and a blank canvas is seen.
- On tap wastepaper basket button (delete button) for a particular cell
  - The level is deleted from local storage
  - The collection view refreshes and the cell corresponding to the deleted level disappears
- On tap Start for a particular cell
  - Transitions to game view
  - The level should be loaded, assuming that the play area matches.
  - The pegs in the game view should match the preview image in the collection view cell.

#### Test Game
When the view appears, there should be a black dashed line (guiding line of cannon) starting from the top portion (horizontal center) of the screen.
- On transition from level designer
  - From level designer
    - The game view shows the most recently edited version of the level, which may be different from the persisted version of the level.
  - From level select
    - The pegs in the game view should match the preview image in the collection view cell.
- On tap Back 
  - Assuming the level designer view comes prior to the game view
    - Transitions to designer view.
    - The saved level reloads.
  - Assuming the level select view comes prior to the game view
    - Transitions to level select view.

**Test game phase**
The bulk of the game will be tested based on the current phase of the game.

`beginning` phase
A black line should be drawn
- On long press on the gameplay area
  - The starting angle of the black dashed line moves toward the pressed position.
  - The black line reacts to any objects it "collides" upon, and appears to predict a realistic physics path.
- On tap on the gameplay area
  - Transition to `shootBallWhenReady` phase.

`shootBallWhenReady` phase
- A black line should be drawn.
- No reponse to user input in the gameplay area. The same applies for the below phases, and will not be mentioned in the tests below.
- A ball should be shot in the direction of the cannon, indicated by the guiding black dashed line. 
  - Transition to `ongoing` phase.

`ongoing` phase
- No black line should be drawn. The same applies for the below phases, and will not be mentioned in the tests below.
- The ball appears to move in a physically accurate manner, with:
  - Gravity from the bottom of the screen
  - Collides with pegs and bounces off realistically
  - Energy loss: The ball should appear to lose some speed after collision. Another way to test this is to drop the ball (starting with 0 velocity) on a surface and check that the maximum height reached is strictly smaller than before, though this is harder to test if the ball starts off with a non-zero initial velocity.
- Upon collision with peg
  - The peg lights up, if not already lit up.
  - Depending on settings, peg may move or rotate in response to the collision.
- If ball is stuck, i.e. the ball keeps collides with the same object for a certain (relatively short) period of time. 
  - Transition to stuck phase
- Upon collision with wall
  - If left, right or top wall, the ball should bounce off realistically.
  - If bottom wall, the ball falls through.
- Upon fallthrough, i.e. ball completely disappears from bottom of screen
  - Transition to `cleanup` phase.

**Note** When pegs are set to rotate-only, i.e. `canRotate == true` and `canTranslate == false`, and when rotating pegs collide with each other, they do not move and even their rotational velocities are unchanged. This is not a bug, and is a limitation of the physics engine. This is because the physics engine only takes translational velocities into account when calculating collisions. So the physics engine actually detects the rotating pegs as colliding, but since none of them are moving, they are viewed as colliding with zero velocity, so no impulse is applied on them.

`stuck` phase
- Objects the ball is in collision with will fade out and disappear.
- When the ball can continue moving without collisions, transition to `ongoing` phase.

`cleanup` phase
- All lit pegs fade out and disappear.
- After around 2 seconds, transition to `beginning` phase.

## Written Answers

### Reflecting on your Design
> Now that you have integrated the previous parts, comment on your architecture
> in problem sets 2 and 3. Here are some guiding questions:
> - do you think you have designed your code in the previous problem sets well
>   enough?
> - is there any technical debt that you need to clean in this problem set?
> - if you were to redo the entire application, is there anything you would
>   have done differently?

Your answer here
