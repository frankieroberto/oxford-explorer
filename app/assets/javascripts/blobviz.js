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
    hideHud();
  });


  d3.json('/collections/json', function(collections) {
    window.collectionSize = collections.length;

    window.colCount = 26;
    window.rowCount = Math.floor(window.collectionSize / window.colCount) + 1;
    window.gridSpacing = 50;
    window.defaultRadius = 20;
    //window.margin = window.defaultRadius;
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
            })

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

function updateOptionsForItemType() {
  $.get("/latest.json", function(d) {

    var itemTypes = _.map(d, function(col) {
      var retVal = [];
      var t = col.type_of_things;
      _.each(t.split(";"), function(typ) {
        retVal.push(typ.trim());
      });
      if(retVal.length > 0) {
        return retVal;
      }
    });

    itemTypes = _.flatten(itemTypes);
    itemTypes = _.uniq(itemTypes).sort(function(a,b) {
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

    _.each(itemTypes, function(typ) {
      valueSelector.append($('<option>', {
        value: typ,
        text: typ,
      }));
    });
  });
}

function updateOptionsForSubject() {
  $.get("/latest.json", function(d) {
    var subjects = _.map(d, function(col) {
      var retVal = [];
      var t = col.subjects;
      if(!t) {
        return;
      }

      t = t.replace(/\,/g, ";");
      _.each(t.split(";"), function(typ) {
        typ = typ.trim();
        if(typ != "") {
          retVal.push(typ.trim());
        }
      });
      if(retVal.length > 0) {
        return retVal;
      }
    });

    subjects = _.flatten(subjects);
    subjects = _.uniq(subjects).sort(function(a,b) {
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

    _.each(subjects, function(typ) {
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
  var x1 = Math.floor(x/window.gridSpacing) * gridSpacing;
  var x2 = Math.ceil(x/window.gridSpacing) * gridSpacing;
  var y1 = Math.floor(y/window.gridSpacing) * gridSpacing;
  var y2 = Math.ceil(y/window.gridSpacing) * gridSpacing;

  if(x1 < 0) return null;
  if(y1 < 0) return null;
  if(x1 > (window.colCount*gridSpacing)) return null;
  if(y1 > (window.rowCount*gridSpacing)) return null;
  return [x1,y1,x2,y2];
}

function handleGridMouseMove(d,event) {
  relPageX = d3.event.pageX - window.svgElementOffset.left;
  relPageY = d3.event.pageY - window.svgElementOffset.top;
  var bb = calculateBBFor(relPageX, relPageY);

  //console.log(indexOver);

  if(bb != window.currentBB) {
    window.currentBB = bb;

    var grps = $("g");
    for(var i = 0; i < grps.length; i++) {
      var grp = grps[i];
      // get the circle inside it
      var c = $(grp).children("circle")[0];
      var $c = $(c);
      var cx = parseInt($c.attr('cx'));
      var cy = parseInt($c.attr('cy'));

      var xBetween = between(relPageX, cx-window.defaultRadius, cx+window.defaultRadius);
      var yBetween = between(relPageY, cy-window.defaultRadius, cy+window.defaultRadius);
      // if cursors is inside it
      if(xBetween && yBetween) {
        window.currentXY= [cx,cy];

        if(!window.isFiltered) {
          growElement(c);
          d3.select(grp).raise();
        }
        var d= d3.select(grp).data()[0];
        //updateHudForItem(d,cx-window.svgElementOffset.left,cy-window.svgElementOffset.top);
        updateHudForItem(d,d3.event.pageX-225,d3.event.pageY);
      } else {
        if(!window.isFiltered) {
          if(c.getBoundingClientRect().width > (2*window.defaultRadius) || c.getBoundingClientRect().width < (2*window.defaultRadius)) {
            shrinkElement(c);
          } 
        }
      }
    }
  }

  if(!window.currentBB) {
    hideHud();
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
  $("#blobviz-hud h1").text(d.name + " (" + d.size_int + " things, of which "+dr_int+" have digital records)");
  $("#blobviz-hud h2").text(d.institution_id + ": " + d.department);

  $("#blobviz-hud").css({'left': x, 'top': y});

  $("#blobviz-hud").fadeIn();
}

function hideHud() {
  window.slideTimeout = window.setTimeout(function() {
    $("#blobiz-hud").fadeOut(function() {
      $("#blobiz-hud h1").text("");
      $("#blobiz-hud h2").text("");
    });
  }, 1000);
}

function handleKeyChanges() {
  $("select#key").change(function(e) {
    val = $(this).val();
    switch(val) {
      case "item-type":
        updateOptionsForItemType();
        break;
      case "subjects":
        updateOptionsForSubject();
        break;
    }
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
        if(key == 'subjects') {
          if(d.subjects) {
            match = d.subjects.match(val);
          }
            
        }
        if(key == 'item-type') {
          if(d.type_of_things) {
            match = d.type_of_things.match(val);
          }
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

$(document).ready(function() {
  setup();

  updateOptionsForItemType();

  handleKeyChanges();

  handleValueChanges();

  $("a.clear-link").click(function() {
    $("select#value").val("");
    removeFilter();
    return false;
  });

});

