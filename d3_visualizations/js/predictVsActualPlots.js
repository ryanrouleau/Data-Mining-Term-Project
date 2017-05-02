var arrestType = "arrest"; // either "arrest" or "noArrest"
var graphingMonth = "March2017"; // either "January2017", "February2017", "March2017"
var colors = ["ignorme", "#ff140a", "#00ff00", "blue"];
var predictTypes = ["ignoreme", "Linear Regression", "LR w/ residuals", "Actual"]

var yDomain = [0,0]
if (arrestType == "arrest") {
    yDomain = [300,2300];
}
else if (arrestType == "noArrest") {
    yDomain = [1700, 6500]
}

var folderName = "./" + arrestType + "PredictionData"
d3.csv(folderName + "/confidence1.csv", csvToPlottablePointsConfidence);
d3.csv(folderName + "/confidence2.csv", csvToPlottablePointsConfidence);
d3.csv(folderName + "/LRPredict.csv", csvToPlottablePoints);
d3.csv(folderName + "/ResidPredict.csv", csvToPlottablePoints);
d3.csv(folderName + "/actualPredict.csv", csvToPlottablePoints);

// each prediction table csv goes in, and outputs a plottable 3d array
// the cols outputted are: predicted/actual count,
var points = [];
var currPredType = 100;
function csvToPlottablePoints(csvData) {
    var currBin = 1;
    for (var i = 0; i < csvData.length; i++) {
        // adding point to points[] in form [bin num, predicton type aka x val, count numbrer akay val]
        points.push([currPredType, parseInt(csvData[i][graphingMonth]), currBin]);
        currBin++;
    }
    currPredType += 100;
    plotVals(points);
}

var numTimesCalled = 0;
function csvToPlottablePointsConfidence(csvData) {
    var confidences = [];
    var currBin = 1;
    for (var k = 0; k < csvData.length; k++) {
        for (var j = 1; j < 4; j++) {
            confidences.push([j*100, parseInt(csvData[k][graphingMonth]), currBin]);
        }
        currBin++;
    }
    plotValsConfidence(confidences);
}

function plotValsConfidence(confidences) {
    /*if (confidences.length != 18) {
        return;
    }*/
    //console.log(confidences);
    var bins = [[],[],[]];
    for (var i = 0; i < confidences.length; i++) {
        if (confidences[i][2] == 1) {

            bins[0].push(confidences[i]);
        }
        else if (confidences[i][2] == 2) {
            bins[1].push(confidences[i]);
        }
        else {
            bins[2].push(confidences[i]);
        }
    }
    //console.log(bins[1]);
    for (var i = 0; i < bins.length; i++) {
        console.log("___");
        console.log(bins[i]);
        main.append("svg:path")
            .data([bins[i]])
            .attr("d", line)
            .style("stroke-width", "3px")
            .style("stroke", function(d, i) {
                return colors[d[i][2]];
            })
            .style("stroke-dasharray", "5")
            .style("opacity", "0.6");
    }
}

function plotVals(points) {
    // checking if all points have loaded yet
    if (points.length != 9) {
        return;
    }

    var bins = [[],[],[]];

    for (var i = 0; i < points.length; i++) {
        if (points[i][2] == 1) {
            console.log(points[i]);
            bins[0].push(points[i]);
        }
        else if (points[i][2] == 2) {
            bins[1].push(points[i]);
        }
        else {
            bins[2].push(points[i]);
        }
    }
    console.log(bins);
    for (var i = 0; i < bins.length; i++) {
        //console.log(bins[i]);
        //bins[i] = x.slice()
        /*for (var j = 0; j < bins[i].length; j++) {
            bins[i][j] = bins[i][j].slice(0,2);
        }*/
        console.log(bins[i]);
        main.append("svg:path")
            .data([bins[i]])
            .attr("d", line)
            .style("stroke-width", "6px")
            .style("stroke", function(d, i) {
                return colors[d[i][2]];
            });

        main.selectAll(".dot")
            .data(bins[i])
            .enter().append("circle")
            .attr("cx", function(d) { return x(d[0]); } )
            .attr("cy", function(d) { return y(d[1]); } )
            .attr("r", 8)
            .style("stroke-width", "4px")
            .style("fill", "#fff")
            .style("stroke", function(d) {
                return colors[d[2]];
            });
            /*.style("stroke-dasharray", function(d) {
                if (d == )
            })*/
    }
}

var margin = {top: 20, right: 15, bottom: 60, left: 60}
var width = 800 - margin.left - margin.right
var height = 800 - margin.top - margin.bottom;

var x = d3.scaleLinear()
          .domain([50, 350])
          .range([ 0, width ]);

var y = d3.scaleLinear()
          .domain(yDomain)
          .range([ height, 0 ]);

var chart = d3.select('.chart');

var main = chart.append('g')
    .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
    .attr('width', width)
    .attr('height', height)
    .attr('class', 'main');

// draw the x axis
var xAxis = d3.axisBottom()
    .scale(x)
    .tickValues([100,200,300])
    .tickFormat(function(d, i) {
        return predictTypes[d%99];
    })
    .tickSize([height-60]);

main.append('g')
    .attr('transform', 'translate(0,' + height + ')')
    .attr('class', 'main axis x')
    .call(xAxis);

// draw the y axis
var yAxis = d3.axisLeft()
    .scale(y);

main.append('g')
    .attr('transform', 'translate(0,0)')
    .attr('class', 'main axis y')
    .call(yAxis);

main.append("text")
    .attr("x", (width/2))
    .attr("y", 30)
    .attr("text-anchor", "middle")
    .attr("font-size", "40px")
    .text(function() {
        // adding space between month and year in graphingMonth
        var month = graphingMonth.split(/[0-9]/)[0];
        return month + " 2017";
    });

var line = d3.line()
    .x(function(d,i) {
        return x(d[0]);
    })
    .y(function(d) {
        return y(d[1]);
    });

//console.log(bins);
