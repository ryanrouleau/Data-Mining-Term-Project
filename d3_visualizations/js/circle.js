var centers = [
    [-87.6710714285714,41.996,0],
    [-87.9047857142857,41.996,1],
    [-87.7879285714286,41.942,2],
    [-87.6710714285714,41.888,3],
    [-87.7879285714286,41.834,4],
    [-87.6710714285714,41.78,5],
    [-87.5542142857143,41.726,6],
    [-87.6710714285714,41.672,7]
];
var colors = [
    "#FF0000",
    "#FF69B4",
    "#FFA500",
    "#00FF7F",
    "#0000FF",
    "#000080",
    "#EE82EE",
    "#9400D3",
];
var margin = {top: 20, right: 15, bottom: 60, left: 60}
var width = 800 - margin.left - margin.right
var height = 800 - margin.top - margin.bottom;
// width,height 726px
// 0.35 total lat/long in graph
// 1320px per 1 lat/long
// so radius scaled is 1320*0.07956066 = 105px
var x = d3.scaleLinear()
          .domain([-88, -87.45])
          .range([ 0, width ]);

var y = d3.scaleLinear()
          .domain([41.55, 42.1])
          .range([ height, 0 ]);

var chart = d3.select('.chart');

var main = chart.append('g')
    .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
    .attr('width', width)
    .attr('height', height)
    .attr('class', 'main');

// draw the x axis
var xAxis = d3.axisBottom()
    .scale(x);

main.append('g')
    .attr('transform', 'translate(0,' + height + ')')
    .attr('class', 'main axis date')
    .call(xAxis);

// draw the y axis
var yAxis = d3.axisLeft()
    .scale(y);

main.append('g')
    .attr('transform', 'translate(0,0)')
    .attr('class', 'main axis date')
    .call(yAxis);

var g = main.append("svg:g");

g.selectAll("scatter-dots")
    .data(centers)
    .enter().append("svg:circle")
    .attr("cx", function (d,i) { return x(d[0]); })
    .attr("cy", function (d) { return y(d[1]); })
    .attr("r", 5)
    .style("fill", function(d) {
        return colors[d[2]];
    });

g.selectAll("scatter-dots")
    .data(centers)
    .enter().append("svg:circle")
    .attr("cx", function(d,i) { return x(d[0]); })
    .attr("cy", function(d) { return y(d[1]); })
    .attr("r", 105)
    .attr("stroke-width", 2)
    .style("fill", "rgba(0,0,0,0)")
    .style("stroke", function(d) {
        return colors[d[2]];
    });

g.selectAll("scatter-dots")
    .data(centers)
    .enter().append("text")
    .attr("x", function(d) { return x(d[0])-15; })
    .attr("y", function(d) { return y(d[1])-10; })
    .style("fill", function(d) {
        return colors[d[2]];
    })
    .style("font-size", "20px")
    .text(function(d,i) { return i+1; });
