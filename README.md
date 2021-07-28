AScrollLayer
------------
This is an attempt to create an open source alternative to UIScrollView by implementing it as a cocos2d layer.
The idea is to make it fully featured (e.g. rubber band, smooth scrolling).

[![Showcase](https://i.ytimg.com/vi/WKrOY4Y4LRg/hqdefault.jpg)](https://www.youtube.com/watch?v=WKrOY4Y4LRg)

How to use
----------
- Add AScrollLayer as a child to the scene
- Disable one of the axis (temporary solution)
- Add CCNodes to AScrollLayer's 'contentLayer'-property
- Define the contentSize of AScrollLayer


Current Features
----------------
- Scrolling either vertically or horizontally (buggy when enabled at the same time)
- Deceleration
- Bounce when hitting edge
- Rubber band effect when dragging beyond bounds


TODO
----
 - Make scrolling more natural by defining deceleration using physics -- it's linear right now
 - Subtle bounce back when hitting edge whilst dragging
 - Remove stuttering of content when pulling content beyond bounds (rubber band)
 - Counter-force when pulling content beyond bounds (i.e. content translates less and less due to rubber band)
 - Let bounds of content restrict scrolling instead of verticalScrollDisabled/horizontalScrollDisabled booleans(lazy)


Bugs
----


Contributing
------------
You know you want to =)
