#############################################################################
#
# (C) 2021 Cadence Design Systems, Inc. All rights reserved worldwide.
#
# This sample script is not supported by Cadence Design Systems, Inc.
# It is provided freely for demonstration purposes only.
# SEE THE WARRANTY DISCLAIMER AT THE BOTTOM OF THIS FILE.
#
#############################################################################

# Create a cone/cylinder.
#
# NOTE: This script is part of the ShapeWizard Glyph 2 script suite.

global ShapeDict

###
# Register this shape with the wizard
###

dict set ShapeDict Cone namespace cone

###
# Implement the shape wizard interface
###

namespace eval cone {
  set Orientation Z
  set OrientFrame {}
  set p1 {}
  set p2 {}
  set axis {}

  proc numDimensions      {} { return 2 }
  proc numSizes           {} { return 3 }
  proc allowsBaffle       {} { return 1 }
  proc allowsFarfield     {} { return 1 }
  proc allowsGrid         {} { return 1 }
  proc allowsDatabase     {} { return 1 }
  proc allowsBothGridDb   {} { return 1 }
  proc allowsStructured   {} { return 1 }
  proc allowsUnstructured {} { return 1 }
  proc allowsSelectSpecs  {} { return 1 }

  proc dimensionLabel     {} { return {Dimension [I J]:} }
  proc deltaSLabel        {} { return "Average \u394s:" }
  proc sizeLabel          {} { return {Size [H R1 R2]:} }
  proc originLabel        {} { return "Origin:" }
  proc orientationLabel   {} { return "Orientation" }
  proc selectButtonLabel  {} { return "Select Seam Points and Axis" }

  proc canApply { shapeArgs } {
    upvar $shapeArgs args

    if { $args(SpecType) == "select" &&
         ($cone::p1 == "" || $cone::p2 == "" || $cone::axis == "") } {
      return false
    }
    return true
  }

  proc onSurfaceTypeChanged { type } {
  }

  proc onGridTypeChanged { type } {
  }

  proc onSpecTypeChanged { type } {
    switch -exact $type {
      explicit {
        $cone::OrientFrame.rx configure -state active
        $cone::OrientFrame.ry configure -state active
        $cone::OrientFrame.rz configure -state active
      }

      select {
        $cone::OrientFrame.rx configure -state disabled
        $cone::OrientFrame.ry configure -state disabled
        $cone::OrientFrame.rz configure -state disabled
      }
    }
  }

  proc configureOrientationFrame { parent shapeArgs } {
    if [winfo exists $parent.boxFrame] {
      destroy $parent.boxFrame
    }

    set cone::OrientFrame [frame $parent.boxFrame -bd 0 -relief flat]
    pack $cone::OrientFrame -fill x
    pack [label $cone::OrientFrame.lbl -text "Axis (H) oriented:"] \
      -side left -padx 5
    pack [radiobutton $cone::OrientFrame.rz \
              -variable cone::Orientation \
              -value "Z" \
              -text "Along Z"] -side right -padx 5
    pack [radiobutton $cone::OrientFrame.ry \
              -variable cone::Orientation \
              -value "Y" \
              -text "Along Y"] -side right -padx 5
    pack [radiobutton $cone::OrientFrame.rx \
              -variable cone::Orientation \
              -value "X" \
              -text "Along X"] -side right -padx 5
  }

  proc drawCanvas { c } {

    $c delete "all"

    set x1 50
    set y1 150
    set x2 300
    set y2 100
    set y3 250
    set y4 300 

    $c create line $x1 $y1 $x2 $y2 -arrow none -fill green -width 2
    $c create line $x1 $y3 $x2 $y4 -arrow none -fill green -width 2

    # create dimension line and label
    $c create arc 5 125 95 275 -start 310 -extent 100 -style arc \
        -outline white -width 2
    $c create text 100 225 -text " \[ J \] " -anchor w -fill white

    # create top arcs 
    set xtop1 25
    set xbot1 75
    $c create arc $xtop1 $y1 $xbot1 $y3 -start 90 -extent 180 -outline green \
      -width 2 
    $c create arc $xtop1 $y1 $xbot1 $y3 -start 270 -extent 180 -outline green \
      -width 2

    # create bottom arcs
    set xtop2 250
    set xbot2 350 
    $c create arc $xtop2 $y2 $xbot2 $y4 -start 90 -extent 180 -outline green \
      -width 2 -dash {6 2}
    $c create arc $xtop2 $y2 $xbot2 $y4 -start 270 -extent 180 -outline green \
      -width 2 

    # create origin label and point
    $c create oval [expr {$x2 - 5}] 195 [expr {$x2 + 5}] 205 -fill white 
    $c create text [expr {$xbot2 + 10}] 200 -text "Origin /" -anchor e \
      -fill white

    # create H dimension lines
    set yh1 [expr {$y1 + 30}]
    set yh2 [expr {$yh1 + 10}]
    set yh3 [expr {($yh2 - $yh1)/2} + $yh1]
    $c create line $x1 $yh1 $x1 $yh2 -arrow none -fill white -width 3 
    $c create line $x1 $yh3 $x2 $yh3 -arrow none -fill white -width 2
    $c create line $x2 $yh1 $x2 $yh2 -arrow none -fill white -width 3

    # create axis line
    $c create line $x1 200 $x2 200 -arrow none -fill red -width 2 -dash {6 2}

    # create H label
    set xh [expr {($x2 - $x1)/2 + $x1}]
    $c create text $xh 175 -text "H \[ I \]" -anchor e -fill white

    # create points & labels
    $c create oval [expr {$x1-3}] [expr {$y1-3}] [expr {$x1+3}] [expr {$y1+3}] \
      -fill red
    $c create text $x1 [expr {$y1 - 15}] -text "Point1" -fill red 
    $c create oval [expr {$x2-3}] [expr {$y2-3}] [expr {$x2+3}] [expr {$y2+3}] \
      -fill red
    $c create text $x2 [expr {$y2 - 15}] -text "Point2" -fill red
    $c create text [expr {$xbot2 + 10}] 200 -text "Axis" -anchor w -fill red 

    # create radii dimension lines
    set x1r1 [expr {$x1 - 10}]
    set x2r1 [expr {($x1 - $x1r1)/2 + $x1r1}]
    $c create line $x1r1 200 $x1 200 -arrow none -fill white -width 3
    $c create line $x2r1 200 $x2r1 $y3 -arrow none -fill white -width 2
    $c create line $x1r1 $y3 $x1 $y3 -arrow none -fill white -width 3

    set x1r2 [expr {$x2 -10}]
    set x2r2 [expr {($x2 - $x1r2)/2 + $x1r2}]
    $c create line $x1r2 200 $x2 200 -arrow none -fill white -width 3
    $c create line $x2r2 200 $x2r2 $y4 -arrow none -fill white -width 2
    $c create line $x1r2 $y4 $x2 $y4 -arrow none -fill white -width 3

    # create radii labels
    set xr1l [expr {$x1r1+12}]
    set yr1l [expr {($y3-200)/2 + 200}]
    $c create text $xr1l $yr1l -text "R2" -anchor w -fill white
   
    set xr2l [expr {$x1r2+12}]
    set yr2l [expr {($y4-200)/2 + 200}]
    $c create text $xr2l $yr2l -text "R1" -anchor w -fill white
  }

  proc validateDimension { value } {
    if { [llength $value] != 2 } {
      return false
    } else {
      foreach dim $value {
        if { ! [string is integer -strict $dim] || $dim <= 0 } {
          return false
        }
      }
    }
    return true
  }

  proc validateDeltaS { value } {
    return [expr { [string is double -strict $value] && $value > 0.0 } ]
  }

  proc validateSize { value } {
    if { [llength $value] != 3 } {
      return false
    } else {
      foreach dim $value {
        if { ! [string is double -strict $dim] } {
          return false
        }
      }
    }
    return true
  }

  proc validateOrigin { value } {
    if { [llength $value] != 3 } {
      return false
    } else {
      foreach dim $value {
        if { ! [string is double -strict $dim] } {
          return false
        }
      }
    }
    return true
  }

  proc pickEntities { shapeArgs } {
    wm withdraw .
    if [catch {  
          set cone::p1 \
            [pw::Display selectPoint -description "Select first point."]
          set cone::p2 \
            [pw::Display selectPoint -description "Select second point."] 
          set conMask [pw::Display createSelectionMask -requireConnector {} \
            -requireDatabase {Curves}]
          pw::Display selectEntities -selectionmask $conMask \
                      -description "Select curve/connector for axis." \
                      -single pick
          if [llength $pick(Connectors)] {
            set cone::axis $pick(Connectors)
          } elseif [llength $pick(Databases)] {
            set cone::axis $pick(Databases)
          } else {
            set cone::axis {}
          }
       } result] {
      return -code error $result
      set cone::p1 {}
      set cone::p2 {}
      set cone::axis {}
    }
    wm deiconify .
  }

  proc makeShape { shapeArgs } {
    upvar args $shapeArgs

    switch -exact $args(DimensionType) {
      AverageDelS {
        set dims [list $args(DeltaS) $args(DeltaS)]
      }
      Dimension {
        set dims $args(Dimension)
      }
      default {
        return -code error "Invalid dimension mode: $args(DimensionType)"
      }
    }

    switch -exact $args(SpecType) {
      select {
        if { $cone::axis == "" } {
          return -code error "No connector picked for axis"
        }
        set o1 [$cone::axis getXYZ -parameter 0.0]
        set o2 [$cone::axis getXYZ -parameter 1.0]
        set p1 $cone::p1
        set p2 $cone::p2
        set axis [pwu::Vector3 normalize [pwu::Vector3 subtract $o2 $o1]]
      }

      explicit {
        set h  [lindex $args(Size) 0]
        set r1 [lindex $args(Size) 1]
        set r2 [lindex $args(Size) 2]

        switch -exact $cone::Orientation {
          "X" {
            set axis "1 0 0"
            set v1 "0 $r1 0"
            set v2 "0 $r2 0"
          }
          "Y" {
            set axis "0 1 0"
            set v1 "0 0 $r1"
            set v2 "0 0 $r2"
          }
          "Z" {
            set axis "0 0 1"
            set v1 "$r1 0 0"
            set v2 "$r2 0 0"
          }
        }

        set o1 $args(Origin)
        set o2 [pwu::Vector3 add $o1 [pwu::Vector3 scale $axis $h]]
        set p1 [pwu::Vector3 add $o1 $v1]
        set p2 [pwu::Vector3 add $o2 $v2]
      }
    }

    makeCone $args(SurfaceType) $args(GridType) $args(EntityType) \
             $args(DimensionType) $dims $o1 $o2 $p1 $p2 $axis
  }

  proc isSamePt { p1 p2 } {
    set tol [expr "[pw::Database getSamePointTolerance] ** 3"]
    return [expr "[pwu::Vector3 length [pwu::Vector3 subtract $p1 $p2]] < $tol"]
  }

  proc makeCone { shapeType gridType entType dimType dims o1 o2 p1 p2 axis } {

    set ldim [lindex $dims 0]
    set rdim [lindex $dims 1]

    set r1v [pwu::Vector3 subtract $o1 $p1]
    set r2v [pwu::Vector3 subtract $o2 $p2]

    set p1a [pwu::Vector3 add $o1 $r1v]
    set p2a [pwu::Vector3 add $o2 $r2v]

    set s1  [pwu::Vector3 add $o1 [pwu::Vector3 cross $axis $r1v]]
    set s2  [pwu::Vector3 add $o2 [pwu::Vector3 cross $axis $r2v]]
    set s1a [pwu::Vector3 add $o1 [pwu::Vector3 cross $r1v $axis]]
    set s2a [pwu::Vector3 add $o2 [pwu::Vector3 cross $r2v $axis]]

    set creator [pw::Application begin Create]

    set crv(a1) [pw::Curve create]
    set seg [pw::SegmentCircle create]
    $seg addPoint $p1
    $seg addPoint $p1a
    $seg setShoulderPoint $s1
    $crv(a1) addSegment $seg

    set crv(b1) [pw::Curve create]
    set seg [pw::SegmentCircle create]
    $seg addPoint $p1
    $seg addPoint $p1a
    $seg setShoulderPoint $s1a
    $crv(b1) addSegment $seg

    set crv(a2) [pw::Curve create]
    set seg [pw::SegmentCircle create]
    $seg addPoint $p2
    $seg addPoint $p2a
    $seg setShoulderPoint $s2
    $crv(a2) addSegment $seg

    set crv(b2) [pw::Curve create]
    set seg [pw::SegmentCircle create]
    $seg addPoint $p2
    $seg addPoint $p2a
    $seg setShoulderPoint $s2a
    $crv(b2) addSegment $seg

    set sides(front) [pw::Surface create]
    $sides(front) interpolate $crv(a1) $crv(a2)

    set sides(back) [pw::Surface create]
    $sides(back) interpolate $crv(b1) $crv(b2)

    if { $shapeType == "Farfield" } {
      set cap(head) [pw::Surface createFromCurves [list $crv(a1) $crv(b1)]]
      set cap(tail) [pw::Surface createFromCurves [list $crv(a2) $crv(b2)]]
    }

    if { $entType != "Database" } {
      set domType pw::Domain$gridType

      if { $gridType == "Structured" && $shapeType != "Baffle" } {
        # require odd number of points to split the ends
        if { [expr ($rdim / 2) * 2] == $rdim } { incr rdim }
      }

      set cons(head) [pw::Collection create]
      set cons(tail) [pw::Collection create]

      foreach i [array names sides] {
        set surfcons [pw::Connector createOnDatabase $sides($i)]
        foreach con $surfcons {
          set n1 [[$con getNode Begin] getXYZ]
          set n2 [[$con getNode End] getXYZ]

          if { (([isSamePt $p1 $n1] || [isSamePt $p1 $n2]) &&
               ([isSamePt $p2 $n1] || [isSamePt $p2 $n2])) ||
               (([isSamePt $p1a $n1] || [isSamePt $p1a $n2]) &&
               ([isSamePt $p2a $n1] || [isSamePt $p2a $n2])) } {
            if { $dimType == "AverageDelS" } {
              $con setDimensionFromSpacing $ldim
            } else {
              $con setDimension $ldim
            }
          } else {
            if { $dimType == "AverageDelS" } {
              $con setDimensionFromSpacing $rdim
            } else {
              $con setDimension $rdim
            }
            if { [isSamePt $p1 $n1] || [isSamePt $p1a $n1] ||
                 [isSamePt $p1 $n2] || [isSamePt $p1a $n2] } {
              $cons(head) add $con
            } else {
              $cons(tail) add $con
            }
          }
        }
        $domType createFromConnectors -solid $surfcons
      }

      $creator end

      if { $entType == "Grid" } {
        foreach i [array names sides] {
          pw::Entity delete $sides($i)
        }
        foreach i [array names cap] {
          pw::Entity delete $cap($i)
        }
      }

      if { $shapeType != "Baffle" } {
        foreach i [array names cons] {
          if { $gridType == "Structured" } {
            foreach con [$cons($i) list] {
              $con split [$con getParameter -closest [$con getXYZ -arc 0.5]]
            }
          }
          set dom [$domType createFromConnectors -solid [$cons($i) list]]
          if { $gridType == "Structured" } {
            set solver [pw::Application begin EllipticSolver $dom]
            if { $entType == "Both" } {
              $dom setEllipticSolverAttribute ShapeConstraint $cap($i)
            }
            $solver run 50
            $solver end
          } else {
            if { $entType == "Both" } {
              $dom setUnstructuredSolverAttribute ShapeConstraint $cap($i)
              $dom initialize
            }
          }
        }
      }
    } else {
      $creator end
    }

    foreach i [array names crv] {
      pw::Entity delete $crv($i)
    }

    return
  }
}

#############################################################################
#
# This file is licensed under the Cadence Public License Version 1.0 (the
# "License"), a copy of which is found in the included file named "LICENSE",
# and is distributed "AS IS." TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE
# LAW, CADENCE DISCLAIMS ALL WARRANTIES AND IN NO EVENT SHALL BE LIABLE TO
# ANY PARTY FOR ANY DAMAGES ARISING OUT OF OR RELATING TO USE OF THIS FILE.
# Please see the License for the full text of applicable terms.
#
#############################################################################
