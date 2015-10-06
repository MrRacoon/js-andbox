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

Scales
------

    xScale = d3.scale.linear()
        .domain [0, width]
        .range  [padding, width - (padding*2)]

    yScale = d3.scale.linear()
        .domain [0, height]
        .range  [padding, height - (padding*2)]

    yScaleCirc    = R.compose yScale, R.prop 'cy'
    xScaleCirc    = R.compose xScale, R.prop 'cx'

    padScale = d3.scale.linear()
        .domain [0, padding]

    fillScale     = padScale.range ['white','black']
    topFillScale  = padScale.range ['white','black']
    botFillScale  = padScale.range ['black','white']

    getRadius = R.prop 'r'

    fillScaleCirc    = R.compose fillScale,    getRadius
    topFillScaleCirc = R.compose topFillScale, getRadius
    botFillScaleCirc = R.compose botFillScale, getRadius

    makeCirc = ->
        cx: Math.random() * width,
        cy: Math.random() * height,
        r:  Math.random() * padding

    makeData = (count) ->
        count = if R.isNil count then Math.round (Math.random() * 30)  else count
        make  = R.compose (R.sortBy getRadius), (R.map makeCirc), (R.range 0)
        make count

    circs = target.selectAll 'circle'
        .data []

    grads = target.append 'defs'
        .selectAll 'radialGradient'
        .data []


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
                'r'    : getRadius
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


    go()


