Define the dimensions of the svg space.
NOTE: padding will be added to all sides of the `svg`

    height  = 500
    width   = 1200
    padding = 50

The center of the space

    center =
        x: width / 2 + padding,
        y: height / 2 + padding

Create the svg object, this will serve as our container for svg objects

    target = d3.select '#target'
        .append 'svg'
        .attr
            width:  width  + padding * 2,
            height: height + padding * 2

Shapes
------

Given a number, find a random value between that number and zero

    randomWithin = (max) -> Math.random() * max

Implement the general circle class. This thing is bare. Fill it with whatever
you want

    class Circle
        constructor: (@cx = center.x, @cy = center.y, @r = padding) ->

Implement the random circle class. All value will be randomized using internal
bounds

    class RandomCircle extends Circle
        constructor: ->
            x = randomWithin width
            y = randomWithin height
            r = randomWithin padding
            super x, y, r

Return a new `RandomCircle`

    makeRandomCircle = -> new RandomCircle()

And some convenience methods

    getR = R.prop 'r'
    getX = R.prop 'cx'
    getY = R.prop 'cy'

Scales
------

    xScale = d3.scale.linear()
        .domain [0, width]
        .range  [padding, width + padding]

    yScale = d3.scale.linear()
        .domain [0, height]
        .range  [padding, height + padding]

    padScale = d3.scale.linear()
        .domain [0, padding]

    fillScale        = padScale.range ['white','black']
    topFillScale     = padScale.range ['white','black']
    botFillScale     = padScale.range ['black','white']

    xScaleCirc       = R.compose xScale,       getX
    yScaleCirc       = R.compose yScale,       getY
    fillScaleCirc    = R.compose fillScale,    getR

Data Generation
---------------

    makeData = (count = Math.round (Math.random() * 30)) ->
        f = R.compose (R.sortBy getR), (R.map makeRandomCircle), (R.range 0)
        f count

Binding
-------

    dur    = 2000
    del    = (d) -> d.r * 200 + 1000

    circs = target.selectAll 'circle'
        .data []

    setId = (t) ->
        t.attr
            'id' : (d, i) -> i

    initialPosition = (t) ->
        t.attr
            'cy' : center.y
            'cx' : center.x

    initialRadius = (t) ->
        t.attr
            'r'  : 0

    setPosition = (t) ->
        t.attr
            'cy'   : yScaleCirc
            'cx'   : xScaleCirc

    setRadius = (t) ->
        t.attr
            'r'    : getR

    setFill = (t) ->
        t.attr
            'fill' : fillScale

    setSpeed = (trans) ->
        trans
            .duration 2000
            .delay    (d) -> d.r * 200 + 1000
            .ease     'bounce'

    moveIntoPosition = (trans) ->
        trans
            .call(setPosition)
            .call(setRadius)
            .call(setFill)

    initialState = (trans) ->
        trans
            .call(initialPosition)
            .call(initialRadius)
            .call(setId)

Procedure
---------

    go = () ->

Create the data. If there was data previously, then pass the empty list into
data. Otherwise, create 30 circles and pass them to data.

        d = if R.isEmpty circs.data() then makeData 30 else makeData 0

        circs = circs.data d

### Enter
Create the svg `<circle>` and insert it to the initial position.

        circs.enter()
            .append 'circle'
            .call initialState

### Update
On update, move it to the position specified by the circle's data.

        circs
            .transition()
            .call setSpeed
            .call moveIntoPosition

### Exit
On Exit, move it back to the initil position and remove it from the dom.

        circs.exit()
            .transition()
            .call setSpeed
            .call initialState
            .remove()

### Loop
Set a timeout to loop

        setTimeout go, 5000, {r: padding}

Begin Looping
-------------

    go()
