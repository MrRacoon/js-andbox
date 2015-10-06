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
            width:  width + padding*2,
            height: height + padding*2

Create the container for the gradient declarations

    defs = target.append 'defs'


Shapes
------

    randomWithin = (max) -> Math.random() * max

    class Circle
        constructor: (@cx = center.x, @cy = center.y, @r = padding) ->

    getR = R.prop 'r'
    getX = R.prop 'cx'
    getY = R.prop 'cy'

    makeRandomCircle = ->
        x = randomWithin width
        y = randomWithin height
        r = randomWithin padding
        new Circle x, y, r

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
    topFillScaleCirc = R.compose topFillScale, getR
    botFillScaleCirc = R.compose botFillScale, getR

Data Generation
---------------

    makeData = (count = Math.round (Math.random() * 30)) ->
        console.log "Hell0! #{count}"
        f = R.compose (R.sortBy getR), (R.map makeRandomCircle), (R.range 0)
        a = f count
        console.log "Hell0! #{a}"
        a


Binding
-------

    circs = target.selectAll 'circle'
        .data []

    grads = target.append 'defs'
        .selectAll 'radialGradient'
        .data []

Procedure
---------

    go = () ->

        del = (d) -> d.r * 100
        dur = (d) -> d.r * 200 + 1000

        d = if R.isEmpty circs.data() then makeData 30 else makeData 0

        circs = circs.data d
        grads = grads.data d

        circs.enter()
            .append 'circle'
            .attr
                'cy': center.y
                'cx': center.x
                'r' : 0
                'id': (d, i) -> i

        circs.transition()
            .duration dur
            .delay    del
            .ease     'elastic'
            .attr
                'cy'   : yScaleCirc
                'cx'   : xScaleCirc
                'r'    : getR
                'fill' : (d, i) -> "url(#grad#{i})"

        circs.exit()
            .transition()
            .duration dur
            .delay    del
            .ease     'cubic'
            .attr
                'cy' : center.y
                'cx' : center.x
                'r'  : 0
            .remove()

        grads.enter()
            .append 'radialGradient'
            .attr
                'gradientUnits': 'objectBoundingBox'
                'cx' : 0
                'cy' : 0
                'r'  : '100%'
                'id' : (d, i) -> 'grad' + i

        grads.append('stop')
            .transition()
            .duration dur
            .delay    del
            .ease     'elastic'
            .attr
                'class': 'x'
                'offset': '0%'
            .style
                'stop-color': topFillScaleCirc

        grads.append('stop')
            .transition()
            .duration dur
            .delay del
            .attr
                'class': 'y'
                'offset': '100%'
            .style
                'stop-color': botFillScaleCirc

        setTimeout go, 2000


Perform
-------

    go()
