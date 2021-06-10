#############################################################################
#
# (C) 2021 Cadence Design Systems, Inc. All rights reserved worldwide.
#
# This sample script is not supported by Cadence Design Systems, Inc.
# It is provided freely for demonstration purposes only.
# SEE THE WARRANTY DISCLAIMER AT THE BOTTOM OF THIS FILE.
#
#############################################################################

# Create a swept baffle surface.
#
# NOTE: This script is part of the ShapeWizard Glyph 2 script suite.

global ShapeDict

###
# Register this shape with the wizard
###

dict set ShapeDict Sweep namespace sweep

###
# Implement the shape wizard interface
###

namespace eval sweep {
  set Orientation XY
  set OrientFrame {}
  set generatrixCurves [list]
  set railCurve ""

  proc numDimensions      {} { return 2 }
  proc numSizes           {} { return 2 }
  proc allowsBaffle       {} { return 1 }
  proc allowsFarfield     {} { return 0 }
  proc allowsGrid         {} { return 1 }
  proc allowsDatabase     {} { return 1 }
  proc allowsBothGridDb   {} { return 1 }
  proc allowsStructured   {} { return 1 }
  proc allowsUnstructured {} { return 1 }
  proc allowsSelectSpecs  {} { return 1 }

  proc dimensionLabel     {} { return {Dimension [I J]:} }
  proc deltaSLabel        {} { return "Average \u394s:" }
  proc sizeLabel          {} { return {Size [L W]:} }
  proc originLabel        {} { return "Origin:" }
  proc selectButtonLabel  {} { return "Select Curves" }
  proc orientationLabel   {} { return "Sweep Plane" }

  proc canApply { shapeArgs } {
    upvar $shapeArgs args

    if { $args(SpecType) == "select" &&
         ([llength $sweep::generatrixCurves] == 0 ||
          $sweep::railCurve == "") } {
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
        $sweep::OrientFrame.rxz configure -state active
        $sweep::OrientFrame.ryz configure -state active
        $sweep::OrientFrame.rxy configure -state active
      }

      select {
        $sweep::OrientFrame.rxz configure -state disabled
        $sweep::OrientFrame.ryz configure -state disabled
        $sweep::OrientFrame.rxy configure -state disabled
      }
    }
  }

  proc configureOrientationFrame { parent shapeArgs } {
    if [winfo exists $parent.boxFrame] {
      destroy $parent.boxFrame
    }

    set sweep::OrientFrame [frame $parent.boxFrame -bd 0 -relief flat]
    pack $sweep::OrientFrame -fill x
    pack [label $sweep::OrientFrame.lbl -text "Plane:"] \
      -side left -padx 5
    pack [radiobutton $sweep::OrientFrame.rxz \
              -variable sweep::Orientation \
              -value "XZ" \
              -text "XZ"] -side right -padx 5
    pack [radiobutton $sweep::OrientFrame.ryz \
              -variable sweep::Orientation \
              -value "YZ" \
              -text "YZ"] -side right -padx 5
    pack [radiobutton $sweep::OrientFrame.rxy \
              -variable sweep::Orientation \
              -value "XY" \
              -text "XY"] -side right -padx 5
  }

  proc drawCanvas { c } {
    $c delete "all"

    # create initial line
    set x1 100
    set y1 325
    set x2 200
    set y2 250
    set x3 300
    set y3 275
    set x4 350
    set y4 200
    $c create line [list $x1 $y1 $x2 $y2 $x3 $y3 $x4 $y4] \
      -arrow none -joinstyle round -smooth true -fill green -width 2

    # create parallel line
    set xf -50 
    set yf -125
    set x5 [expr {$x1 +$xf}]
    set y5 [expr {$y1 +$yf}]
    set x6 [expr {$x2 +$xf}]
    set y6 [expr {$y2 +$yf}]  
    set x7 [expr {$x3 +$xf}]
    set y7 [expr {$y3 +$yf}]
    set x8 [expr {$x4 +$xf}]
    set y8 [expr {$y4 +$yf}]

    $c create line [list $x5 $y5 $x6 $y6 $x7 $y7 $x8 $y8] \
      -arrow none -joinstyle round -smooth true -fill red -width 2

    # create connecting lines
    $c create line $x1 $y1 $x5 $y5 -arrow none -fill red -width 2
    $c create line $x4 $y4 $x8 $y8 -arrow none -fill green -width 2

    # create width dimension lines
    set xw1 [expr {$x1-6}]
    set yw1 [expr {$y1+3}] 
    set xw2 [expr {$xw1-12}]
    set yw2 [expr {$yw1+6}]
    set xw3 [expr {($xw1 - $xw2)/2 + $xw2}]
    set yw3 [expr {($yw2-$yw1)/2 + $yw1}]
    set xw4 [expr {$x5-6}]
    set yw4 [expr {$y5+3}]
    set xw5 [expr {$xw4-12}]
    set yw5 [expr {$yw4+6}]
    set xw6 [expr {($xw4 - $xw5)/2 + $xw5}]
    set yw6 [expr {($yw5-$yw4)/2 + $yw4}]

    $c create line $xw1 $yw1 $xw2 $yw2 -arrow none -fill white -width 3
    $c create line $xw3 $yw3 $xw6 $yw6 -arrow none -fill white -width 2
    $c create line $xw4 $yw4 $xw5 $yw5 -arrow none -fill white -width 3

    # create length dimension lines
    set xl1 [expr {$x5-4}]
    set yl1 [expr {$y5-10}]
    set xl2 [expr {$xl1-6}]
    set yl2 [expr {$yl1-15}]
    set xl3 [expr {($xl1 - $xl2)/2 + $xl2}]
    set yl3 [expr {($yl1-$yl2)/2 + $yl2}]
    set xl4 [expr {$x8-4}]
    set yl4 [expr {$y8-10}]
    set xl5 [expr {$xl4-6}]
    set yl5 [expr {$yl4-15}]
    set xl6 [expr {($xl4 - $xl5)/2 + $xl5}]
    set yl6 [expr {($yl4-$yl5)/2 + $yl5}]

    $c create line $xl1 $yl1 $xl2 $yl2 -arrow none -fill white -width 3
    $c create line $xl3 $yl3 $xl6 $yl6 -arrow none -fill white -width 2
    $c create line $xl4 $yl4 $xl5 $yl5 -arrow none -fill white -width 3

    # create labels
    $c create text [expr {($xl6-$xl3)/2+$xl3}] [expr {($yl3-$yl6)/2 + $yl6}] \
      -text "L ( I )" -anchor se -fill white
    $c create text [expr {($xw3-$xw6)/2+$xw6}] [expr {($yw3-$yw6)/2 + $yw6}] \
      -text "W ( J )" -anchor ne -fill white

    # create bisecting dashed line
    set xo1 [expr {$x2 + 35}]
    set yo1 [expr {$y2 + 11}] 
    $c create line $xo1 $yo1 [expr {$x6+35}] [expr {$y6+11}] -arrow none \
      -fill white -width 2 -dash {6 2}

    # create lengthwise bisecting dashed line
    set xf2 -25
    set yf2 -62
    set xb1 [expr {$x1 +$xf2}]
    set yb1 [expr {$y1 +$yf2}]
    set xb2 [expr {$x2 +$xf2}]
    set yb2 [expr {$y2 +$yf2}]  
    set xb3 [expr {$x3 +$xf2}]
    set yb3 [expr {$y3 +$yf2}]
    set xb4 [expr {$x4 +$xf2}]
    set yb4 [expr {$y4 +$yf2}]

    $c create line [list $xb1 $yb1 $xb2 $yb2 $xb3 $yb3 $xb4 $yb4] \
      -arrow none -joinstyle round -smooth true -fill white -width 2 -dash {6 2}

    # create origin point and label
    $c create oval [expr {$xo1-4}] \
                   [expr {$yo1-4}] \
                   [expr {$xo1+4}] \
                   [expr {$yo1+4}] -fill white

    # create extrude point
    $c create oval [expr {$x5-3}] [expr {$y5-3}] [expr {$x5+3}] [expr {$y5+3}] \
      -fill red
    $c create text [expr {$x5+15}] [expr {$y5-1}] -text "Origin" -anchor w \
      -fill red

    return $c
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
    if { [llength $value] != 2 } {
      return false
    } else {
      foreach dim $value {
        if { ! [string is double -strict $dim] || $dim <= 0.0 } {
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

    set sweep::generatrixCurves [list]
    set sweep::railCurve ""
  
    if [catch {
        set mask [pw::Display createSelectionMask \
          -requireConnector {Dimensioned} -blockConnector {Pole} \
          -requireDatabase {Curves}]

        pw::Display selectEntities -selectionmask $mask \
          -description "Select curve(s)/connector(s) to sweep." picked

        if [llength $picked(Connectors)] {
          eval [concat lappend sweep::generatrixCurves $picked(Connectors)]
        }
        if [llength $picked(Databases)] {
          eval [concat lappend sweep::generatrixCurves $picked(Databases)]
        }

        if [llength $sweep::generatrixCurves] {
          set mask [pw::Display createSelectionMask \
            -requireConnector {} -blockConnector {Pole} \
            -requireDatabase {Curves}]

          pw::Display selectEntities -selectionmask $mask \
            -description "Select curve/connector for sweep path." -single picked

          if [llength $picked(Connectors)] {
            set sweep::railCurve $picked(Connectors)
          } else {
            set sweep::railCurve $picked(Databases)
          }
        }
      } msg] {
      puts $msg
      set sweep::generatrixCurves [list]
      set sweep::railCurve ""
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

    switch -exact $sweep::Orientation {
      "XY" {
        set railDir "1 0 0"
        set generatrixDir "0 1 0"
      }

      "YZ" {
        set railDir "0 1 0"
        set generatrixDir "0 0 1"
      }

      "XZ" {
        set railDir "1 0 0"
        set generatrixDir "0 0 1"
      }
    }

    if { $args(SpecType) == "explicit" } {
      set rail ""
      set generatrix ""
    } else {
      set rail $sweep::railCurve
      set generatrix $sweep::generatrixCurves
    }

    makeSweep $args(GridType) $args(EntityType) \
              $args(DimensionType) $dims $args(Size) $args(Origin) \
              $railDir $generatrixDir $rail $generatrix

  }

  proc isSamePt { p1 p2 } {
    set tol [expr "[pw::Database getSamePointTolerance] ** 3"]
    return [expr "[pwu::Vector3 length [pwu::Vector3 subtract $p1 $p2]] < $tol"]
  }

  proc makeSweep { gridType entType dimType dims size origin \
                   railDir generatrixDir railCurve generatrixCurves } {

    set pathCon {}
    set surf {}
    set curvesToDelete [list]

    set creator [pw::Application begin Create]

    set genCurves [list]
    set genCons {}

    # make a generatrix if needed
    if { [llength $generatrixCurves] == 0 } {
      # make a two point curve from origin in plane
      set genCurves [pw::Curve create]
      set seg [pw::SegmentSpline create]
      $seg addPoint $origin
      $seg addPoint [pwu::Vector3 add $origin \
        [pwu::Vector3 scale $generatrixDir [lindex $size 0]]]
      $genCurves addSegment $seg
      lappend curvesToDelete $genCurves
    } else {
      foreach gen $generatrixCurves {
        if { [$gen isOfType pw::Connector] } {
          # build a db curve from the grid points
          set crv [pw::Curve create]
          set seg [pw::SegmentSpline create]
          for { set i 1 } { $i <= [$gen getDimension] } { incr i } {
            $seg addPoint [$gen getXYZ -grid $i]
          }
          $crv addSegment $seg
          lappend genCurves $crv
          lappend genCons $gen
          lappend curvesToDelete $crv
        } else {
          lappend genCurves $gen
          lappend genCons {}
        }
      }
    }

    if { $railCurve != "" } {
      if [$railCurve isOfType pw::Curve] {
        set p1 [$railCurve getXYZ -parameter 0.0]
        set p2 [$railCurve getXYZ -parameter 1.0]
      } else {
        set pathCon $railCurve
        set p1 [[$railCurve getNode Begin] getXYZ]
        set p2 [[$railCurve getNode End] getXYZ]
      }
      set sweepVec [pwu::Vector3 subtract $p2 $p1]
    } else {
      set sweepVec [pwu::Vector3 scale $railDir [lindex $size 1]]
    }

    foreach genCurve $genCurves genCon $genCons {
      set surf [pw::Surface create]
      $surf sweep $genCurve $sweepVec

      set cons [pw::Connector createOnDatabase $surf]
      foreach con $cons {
        set pos [$con getPosition -parameter 0.5]
        if [isSamePt "[lindex $pos 0] 0 0" "0.5 0 0"] {
          # U boundary
          if { $genCon != "" } {
            set dimCon $genCon
          } else {
            set dim [lindex $dims 0]
          }
        } else {
          # V boundary
          if { $pathCon != "" } {
            set dimCon $pathCon
          } else {
            set dim [lindex $dims 1]
          }
        }

        if { ! [info exists dimCon] } {
          if { $dimType == "Dimension" } {
            $con setDimension $dim
          } else {
            $con setDimensionFromSpacing $dim
          }
        } else {
          # copy the dimension and distribution from the source connector
          set subcons [list]
          for { set i 1 } { $i <= [$dimCon getSubConnectorCount] } { incr i } {
            lappend subcons [list $dimCon $i]
          }

          $con setDimensionFromSubConnectors $subcons
        
          for { set i 1 } { $i < [$dimCon getSubConnectorCount] } { incr i } {
            $con addBreakPoint [$dimCon getBreakPoint $i]
          }
          for { set i 1 } { $i <= [$dimCon getSubConnectorCount] } { incr i } {
            $con setDistribution $i [$dimCon getDistribution -copy $i]
          }
          unset dimCon
        }
      }

      pw::Domain$gridType createFromConnectors $cons

      if { $entType == "Grid" } {
        pw::Entity delete $surf
      }
    }

    # clean up database curves
    if [llength $curvesToDelete] {
      pw::Entity delete $curvesToDelete
    }

    $creator end
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
