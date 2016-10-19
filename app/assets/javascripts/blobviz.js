function opacityForItem(item) {
  if(item.size_int) {
    return 1;
  } else {
    return 0.3;
  }
}

function strokeWidthForItem(item) {
  return 0;
  if(item.size_int && (item.size_int < 5)) {
    return 1;
  } else if(item.size_int && (item.size_int < 1000)) {
    return 1;
  } else if(item.size_int) {
    return 3;
  } else {
    return 2;
  }
}

function radiusInsideSquare(radius) {
  return Math.sqrt((radius*radius)/2);
}

function xyForItemInCount(itemIndex,totalCount,item) {
  var itemNo = itemIndex+1;

  // gives you row index
  var rowIndex = Math.ceil(itemNo / window.colCount) - 1;

  var colIndex = (itemNo - (rowIndex * window.colCount)) - 1;

  var xPos = (colIndex*window.gridSpacing) + window.margin;
  var yPos = (rowIndex*window.gridSpacing) + window.margin;

  return [xPos, yPos];
}

function radiusForItem(item) {
  if(item.size_int) {
    var minimum = 5;
    scaled = Math.sqrt(item.size_int) / 10;
    if(scaled > minimum) {
      return scaled;
    } else {
      return minimum;
    }
  } else {
    return 15;
  }
}

function setup() {
  var svgContainer = d3.select("#blobviz").append("svg")
  .attr("id", "svg")
  .attr("width", 1400)
  .attr("height", 930)
  .on("mousemove", function(d,i) {
    handleGridMouseMove(d,i);
  })
  .on("mouseout", function() {
    //hideHud();
  });


  d3.json('/collections/json', function(collections) {
    window.collectionSize = collections.length;

    window.colCount = 26;
    window.rowCount = Math.floor(window.collectionSize / window.colCount) + 1;
    window.gridSpacing = 50;
    window.defaultRadius = 20;
    window.hudWidth = 250;
    window.defaultRadius = 20;
    window.leftOffset = 250;
    window.margin = 100;

    window.collections = collections.sort;

    var groups = svgContainer.selectAll('g')
                             .data(collections)
                             .enter()
                             .append('g')
                             .attr("opacity", function(d,i) {
                               return opacityForItem(d);
                             });

     groups.append('circle')
            .attr("cx", function(d,i) {
              return xyForItemInCount(i,window.collectionSize, d)[0];
            })
            .attr("cy", function(d,i) {
              return xyForItemInCount(i,window.collectionSize, d)[1];
            })
            .attr("r", function(d,i) {
              if(d.size_int) {
                return window.defaultRadius;
              } else {
                return 0;
              }
            })
            .attr("style", function(d,i) {
              if(d.size_int == d.digitized_metadata_size_int) {
                return "opacity: 1";
              }
            })
            .attr("stroke-width", function(d,i) {
              return strokeWidthForItem(d);
            })
            .attr("stroke", function(d,i) {
              return '#063642';
            })
            .attr('class', function(d) {
              return d.institution_id;
            })
            .attr('data-radius-scale', function(d,i) {
              return radiusForItem(d) / window.defaultRadius;
            });

     groups.append('rect')
            .attr("x", function(d,i) {
              return xyForItemInCount(i,window.collectionSize, d)[0] - radiusInsideSquare(window.defaultRadius);
            })
            .attr("y", function(d,i) {
              return xyForItemInCount(i,window.collectionSize, d)[1] - radiusInsideSquare(window.defaultRadius);
            })
            .attr("width", function(d,i) {
              if(!d.size_int) {
                return 2 * radiusInsideSquare(window.defaultRadius);
              } else {
                return 0;
              }
            })
            .attr("height", function(d,i) {
              if(!d.size_int) {
                return 2 * radiusInsideSquare(window.defaultRadius);
              } else {
                return 0;
              }
            })
            .attr('class', function(d) {
              return d.institution_id;
            })


    groups.append('path')
          .attr('d', function(d,i) {
            return piePathStringForItem(d,i);
          })
          .attr('transform', function(d,i) {
            var xy = xyForItemInCount(i,window.collectionSize, d);
            return 'rotate(-90,'+xy[0]+','+xy[1]+')';
          })
          .attr('class', function(d) {
            return d.institution_id;
          })

          window.svgElementOffset = $("#blobviz svg").offset(); 

    tidyGroups();
  });

}

function updateOptionsForKey(key) {
  $.get("/collections/json", function(d) {
    var keys = _.map(d, function(col) {
      return col[key];
    });

    keys = _.flatten(keys);
    keys = _.uniq(keys).sort(function(a,b) {
      var x =  a.toLowerCase();
      var y = b.toLowerCase();
      return x > y ? 1 : (x < y ? -1 : 0);
    });

    $("#value option").remove();

    $('#value').append($('<option>', {
      value: "",
      text: " - ",
    }));

    var valueSelector = $('#value');

    _.each(keys, function(typ) {
      valueSelector.append($('<option>', {
        value: typ,
        text: typ,
      }));
    });
  });
}

function tidyGroups(sortDir) {
  var sortDir = (typeof sortDir !== 'undefined') ?  sortDir : 'desc';
  
  d3.selectAll('g').sort(function(a,b) {
    if(sortDir == 'desc') {
      return d3.descending(a.size_int, b.size_int);
    } else {
      return d3.ascending(a.size_int, b.size_int);
    }
  });
}


function describeSlice(x, y, radius, startAngle, endAngle){
  if(endAngle > 360) {
    endAngle = 360;
  }
  var end = polarToCartesian(x, y, radius, endAngle);

  var largeArcFlag = endAngle - startAngle <= 180 ? "0" : "1";

  var d = [
    "M", x,y ,
    "L", x+radius,y ,
    "A", radius, radius, 0, largeArcFlag, 1, end.x, end.y, "z"
  ].join(" ");

  return d;       
}

function polarToCartesian(centerX, centerY, radius, angleInDegrees) {
  var angleInRadians = (angleInDegrees) * Math.PI / 180.0;

  return {
    x: centerX + (radius * Math.cos(angleInRadians)),
    y: centerY + (radius * Math.sin(angleInRadians))
  };
}

function piePathStringForItem(d,i) {
  if(!(d.size_int && d.digitized_metadata_size_int)) {
    return;
  }

  var radius =  window.defaultRadius - strokeWidthForItem(d);
  var originX =  xyForItemInCount(i,window.collectionSize, d)[0];
  var originY =  xyForItemInCount(i,window.collectionSize, d)[1];
  var ratio = d.digitized_metadata_size_int / d.size_int;

  var theta = ratio * 360;

  return describeSlice(originX, originY, radius, 0, theta);
}

function sweepFlagForAngle(radians) {
  if (radians < Math.PI) {
    return "0 1";
  } else {
    return "1 1";
  }
}

function mouseEventInsideCircle(event,el) {
  el = $(el);

  relPageX = event.pageX - window.svgElementOffset.left;
  relPageY = event.pageY - window.svgElementOffset.top;

  if(relPageX < (el.attr('cx') - el.attr('r'))) {
    return false;
  } else if(relPageY < (el.attr('cy') - el.attr('r'))) {
    return false;
  } else if(relPageX > (el.attr('cx') + el.attr('r'))) {
    return false;
  } else if(relPageY > (el.attr('cy') + el.attr('r'))) {
    return false;
  } else {
    return true;
  }
}

function between(x, min, max) {
  return x >= min && x <= max;
}

function calculateBBFor(x,y) {
  //console.log("caculating BB for ",x,y);
  var x1 = (Math.floor((x+(window.gridSpacing/2))/window.gridSpacing) * window.gridSpacing) - (window.gridSpacing/2); 
  var x2 = (Math.ceil((x+(window.gridSpacing/2))/window.gridSpacing) * window.gridSpacing) - (window.gridSpacing/2);
  var y1 = (Math.floor((y+(window.gridSpacing/2))/window.gridSpacing) * window.gridSpacing) - (window.gridSpacing/2);
  var y2 = (Math.ceil((y+(window.gridSpacing/2))/window.gridSpacing) * window.gridSpacing) - (window.gridSpacing/2);
  if(x1 < 0) return null;
  if(y1 < 0) return null;
  if(x1 > ((window.colCount+1)*gridSpacing)) return null;
  if(y1 > ((window.rowCount+1)*gridSpacing)) return null;

  //$("#bb").remove();
  //d3.select('svg').append('rect').attr('id', 'bb').attr('x', x1)
                                   //.attr('y', y1)
                                   //.attr('width', x2-x1)
                                   //.attr('height', y2-y1)
                                   //.attr('fill', 'red')
                                   //.attr('opacity', 0.5);
  return [x1,y1,x2,y2];
}

function drawMouseBlob() {
  $("#cursor").remove();
  d3.select('svg').append('circle').attr('id', 'cursor').attr('cx', relPageX)
                                   .attr('cy', relPageY)
                                   .attr('r', 10)
                                   .attr('fill', 'red')
                                   .attr('opacity', 0.5);
}

function handleGridMouseMove(d,event) {
  relPageX = d3.event.pageX - $("svg").offset().left;
  relPageY = d3.event.pageY - $("svg").offset().top;
  var bb = calculateBBFor(relPageX, relPageY);

  //drawMouseBlob();
  //console.log(indexOver);

  if(bb != window.currentBB) {
    //console.log("Bounding box has changed to", bb);
    window.currentBB = bb;

    var grps = $("g");
    var noGroups = true;
    for(var i = 0; i < grps.length; i++) {
      var grp = grps[i];
      // get the circle inside it
      var c = $(grp).children("circle")[0];
      var $c = $(c);
      var cx = parseInt($c.attr('cx'));
      var cy = parseInt($c.attr('cy'));

      var xBetween = between(cx, bb[0], bb[2])
      var yBetween = between(cy, bb[1], bb[3])

      // if cursors is inside it
      if(xBetween && yBetween) {
        pointerCursor();


        noGroups = false;
        window.currentXY= [cx,cy];

        window.underCursor = d3.select(grp).data();

        if(!window.isFiltered) {
          growElement(c);
          d3.select(grp).raise();
        }
        var d= d3.select(grp).data()[0];

        var grpOffset = $(grp).offset();
        var hudX = cx - window.leftOffset - (window.hudWidth/2);
        // handle hud falling off screen
        //console.log(d3.event);
        if(d3.event.pageX < (window.hudWidth/2) ) {
          // set the left edge of HUD flush to the left of the gridsquare
          hudX = cx - window.leftOffset - (window.gridSpacing/2);
        } else if(d3.event.pageX+(window.hudWidth/2) > $(window).width()) {
          // set the right edge of HUD flush to the left of the gridsquare
          hudX = cx - window.hudWidth - window.leftOffset + (window.gridSpacing/2);
        }
        var hudY = $("svg").offset().top + cy;

        updateHudForItem(d,hudX,hudY);
      } else {
        if(!window.isFiltered) {
          if(c.getBoundingClientRect().width > (2*window.defaultRadius) || c.getBoundingClientRect().width < (2*window.defaultRadius)) {
            shrinkElement(c);
          } 
        }
      }
    }
    if(noGroups) {
      defaultCursor();
      console.log("No groups under cursor");
      hideHud();
      window.underCursor = null;
    }
  }

  if(!window.currentBB) {
    defaultCursor();
    hideHud();
    window.underCursor = null;
  }

}

function growElement(el) {
  var group = $(el).parents("g")[0];
  var path = $(el).siblings("path")[0];
  var scale = $(el).data().radiusScale;

  var cx = $(el).attr('cx');
  var cy = $(el).attr('cy');
  var saclestr=scale+','+scale;
  var tx=-cx*(scale-1);
  var ty=-cy*(scale-1);                        
  var translatestr=tx+','+ty;

  d3.select(el).transition().attr('transform','translate('+translatestr+') scale('+saclestr+')')
  d3.select(path).transition().attr('transform','rotate(-90,'+cx+','+cy+') translate('+translatestr+') scale('+saclestr+')')
}

function shrinkElement(el) {
  d3.select(el).transition().attr('transform', 'scale(1)');

  var group = $(el).parents("g")[0];
  var path = $(el).siblings("path")[0];
  var cx = $(el).attr('cx');
  var cy = $(el).attr('cy');
  var scale = 1;
  d3.select(group).transition().attr('transform', "scale("+scale+")");
  d3.select(path).transition().attr('transform', 'rotate(-90,'+cx+','+cy+')');

}

function updateHudForItem(d,x,y) {
  var dr_int = d.digitized_metadata_size_int;
  if(!dr_int) {
    // if dr_int is null, set it to 0 - rather than casting null to an integer
    // which I couldn't quite do.
    dr_int = 0;
  }

  var instClass = "inst-"+d.institution_id.toLowerCase()+"-bg";


  $("#blobviz-hud").hide();
  $("#blobviz-hud .collection").attr('class', 'collection '+instClass);
  $("#blobviz-hud").addClass('collection');
  $("#blobviz-hud").addClass(instClass);

  $("#blobviz-hud "+ ".collection").text(humanNameForInstitution(d.institution_id));

  $("#blobviz-hud h1").text(d.name);

  if(d.size_int) {
    $("#blobviz-hud .size").html("<span>" + s.numberFormat(d.size_int) + "</span> things");
  } else {
    $("#blobviz-hud .size").text('Collection size not known');
  }

  if(dr_int > 0) {
    var percentage = Math.round(dr_int / d.size_int * 100);
    $("#blobviz-hud .dig_size").html("<span>" + s.numberFormat(percentage) + "%</span> have digital metadata");
  } else {
    $("#blobviz-hud .dig_size").text('No digital metadata');
  }

  $("#blobviz-hud h2").text(d.department);


  $("#blobviz-hud").show();
  $("#blobviz-hud").css({'left': x, 'top': y-$("#blobviz-hud").height()-35});
}

function hideHud() {
  window.setTimeout(function() {
    $("#blobviz-hud").fadeOut();
  }, 1000);
}

function handleKeyChanges() {
  $("select#key").change(function(e) {
    val = $(this).val();
    updateOptionsForKey(val);
  });
}

function removeFilter() {
  window.isFiltered = false;
  d3.selectAll('g').attr('opacity', function(d,i) {
    return opacityForItem(d);
  });

  removeAllSpotlights();
  tidyGroups();
}

function handleValueChanges() {
    // handle dropdowns changing
  $("select#value").change(function(e) {
    key = $("select#key").val();
    val = $(this).val();
    if(val) {
      tidyGroups('desc');
      window.isFiltered = true;
      d3.selectAll("g").each(function(d, i) {
        var match = false;
        if(d[key]) {
          match = d[key].includes(val);
        }

        if(match) {
          spotlightGroup(this);
        } else {
          unSpotlightGroup(this);
          d3.select(this).lower();
        }
      });
    } else {
      // remove filter
      removeFilter();
      tidyGroups();
    }
  });
}

function spotlightGroup(groupElement) {
  d3.select(groupElement).attr('opacity', 1);
  $(groupElement).addClass('spotlight');
  growElement($(groupElement).children("circle")[0]);
}

function unSpotlightGroup(groupElement) {
  d3.select(groupElement).attr('opacity', 0.2);
  $(groupElement).removeClass('spotlight');
  shrinkElement($(groupElement).children("circle")[0]);
}

function removeAllSpotlights() {
  var grps = $("g");
  for(var i = 0; i < grps.length; i++) {
    var grp = grps[i];
    $(grp).removeClass('spotlight');
    shrinkElement($(grp).children("circle")[0]);
  }
}

function humanNameForInstitution(instId) {
  switch(instId.toLowerCase()) {
    case 'ash':
      return "Ashmolean";
    case 'bod':
      return "Bodleian";
    case 'prm':
      return "Pitt Rivers";
    case 'mhs':
      return "History of Science";
    case 'mnh':
      return "Natural History";
    case 'hrb':
      return "Herbarium";
  }
}

function pointerCursor() {
  $("body").css('cursor', 'pointer');
}


function defaultCursor() {
  $("body").css('cursor', 'auto');
}

$(document).ready(function() {
  setup();

  handleKeyChanges();

  handleValueChanges();

  $("a.clear-link").click(function() {
    $("select#value").val("");
    removeFilter();
    return false;
  });

  $(window).on('click', function(e) {
    // only handle a click inside the visualisation
    var topOfViz = $("svg").offset().top;
    var vizHeight = $("svg").height();
    if((e.pageY > (topOfViz + window.margin - (window.gridSpacing/2))) && 
       e.pageY < (topOfViz + vizHeight)) {
      //console.log("Click inside viz");
      window.location.href = "/collections/" + window.underCursor[0].id;
    }
  });

});

