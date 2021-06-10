#############################################################################
#
# (C) 2021 Cadence Design Systems, Inc. All rights reserved worldwide.
#
# This sample script is not supported by Cadence Design Systems, Inc.
# It is provided freely for demonstration purposes only.
# SEE THE WARRANTY DISCLAIMER AT THE BOTTOM OF THIS FILE.
#
#############################################################################

# Create a cartesian-aligned box.
#
# NOTE: This script is part of the ShapeWizard Glyph 2 script suite.

global ShapeDict

###
# Register this shape with the wizard
###

dict set ShapeDict Box namespace box

###
# Implement the shape wizard interface
###

namespace eval box {
  set Orientation Z
  set OrientFrame {}
  set p1 {}
  set p2 {}

  proc numDimensions      {} { return 3 }
  proc numSizes           {} { return 3 }
  proc allowsBaffle       {} { return 1 }
  proc allowsFarfield     {} { return 1 }
  proc allowsGrid         {} { return 1 }
  proc allowsDatabase     {} { return 1 }
  proc allowsBothGridDb   {} { return 1 }
  proc allowsStructured   {} { return 1 }
  proc allowsUnstructured {} { return 1 }
  proc allowsSelectSpecs  {} { return 1 }

  proc dimensionLabel     {} { return {Dimension [I J K]:} }
  proc deltaSLabel        {} { return "Average \u394s:" }
  proc sizeLabel          {} { return {Size [L W H]:} }
  proc originLabel        {} { return "Origin:" }
  proc selectButtonLabel  {} { return "Select Corner Points" }
  proc orientationLabel   {} { return "Orientation" }

  proc canApply { shapeArgs } {
    upvar $shapeArgs args

    if { $args(SpecType) == "select" &&
         ($box::p1 == "" || $box::p2 == "") } {
      return false
    }
    return true
  }

  proc onSurfaceTypeChanged { type } {
    switch -exact $type {
      Baffle {
        $box::OrientFrame.rx configure -state active
        $box::OrientFrame.ry configure -state active
        $box::OrientFrame.rz configure -state active
      }

      Farfield {
        $box::OrientFrame.rx configure -state disabled
        $box::OrientFrame.ry configure -state disabled
        $box::OrientFrame.rz configure -state disabled
      }
    }
  }

  proc onGridTypeChanged { type } {
  }

  proc onSpecTypeChanged { type } {
  }

  proc configureOrientationFrame { parent shapeArgs } {
    if [winfo exists $parent.boxFrame] {
      destroy $parent.boxFrame
    }

    set box::OrientFrame [frame $parent.boxFrame -bd 0 -relief flat]
    pack $box::OrientFrame -fill x
    pack [label $box::OrientFrame.lbl -text "Open through axis:"] \
      -side left -padx 5
    pack [radiobutton $box::OrientFrame.rz \
              -variable box::Orientation \
              -value "Z" \
              -text "Z"] -side right -padx 5
    pack [radiobutton $box::OrientFrame.ry \
              -variable box::Orientation \
              -value "Y" \
              -text "Y"] -side right -padx 5
    pack [radiobutton $box::OrientFrame.rx \
              -variable box::Orientation \
              -value "X" \
              -text "X"] -side right -padx 5
  }

  proc drawCanvas { c } {
    $c delete "all"

    # create lines of the rectangular prism
    set x1 125
    set y1 175
    set x2 325
    set y2 275 
    set x3 75
    set y3 125
    set x4 275
    set y4 225 

    $c create line [list $x1 $y1 $x1 $y2] -arrow none -fill green -width 2
    $c create line [list $x1 $y2 $x2 $y2] -arrow none -fill green -width 2
    $c create line [list $x2 $y2 $x2 $y1] -arrow none -fill green -width 2
    $c create line [list $x2 $y1 $x1 $y1] -arrow none -fill green -width 2

    $c create line [list $x3 $y3 $x3 $y4] -arrow none -fill green -width 2
    $c create line [list $x3 $y4 $x4 $y4] -arrow none -fill green -dash {6 2} \
      -width 2
    $c create line [list $x4 $y4 $x4 $y3] -arrow none -fill green -dash {6 2} \
      -width 2
    $c create line [list $x4 $y3 $x3 $y3] -arrow none -fill green -width 2

    $c create line [list $x1 $y1 $x3 $y3] -arrow none -fill green -width 2
    $c create line [list $x1 $y2 $x3 $y4] -arrow none -fill green -width 2
    $c create line [list $x2 $y2 $x4 $y4] -arrow none -fill green -dash {6 2} \
      -width 2
    $c create line [list $x2 $y1 $x4 $y3] -arrow none -fill green -width 2

    # create label dots
    $c create oval 122 172 128 178 -fill red 
    $c create oval 272 222 278 228 -fill red
    $c create text 125 160 -text "Point 1" -anchor w -fill red
    $c create text 278 215 -text "Point 2" -anchor w -fill red

    # create origin
    $c create oval 197 197 203 203 -fill white
    $c create text 196 196 -text "Origin" -anchor e -fill white

    # create measurement lines and labels
    set xy1 60; set xy2 70; set xy3 65
    $c create line [list $xy1 $y3 $xy2 $y3] -arrow none -fill white -width 2
    $c create line [list $xy1 $y4 $xy2 $y4] -arrow none -fill white -width 2
    $c create line [list $xy3 $y3 $xy3 $y4] -arrow none -fill white -width 2

    set xz3 65 ; set xz4 115;  set xz1 110 ; set xz2 120  
    $c create line [list $xz3 $y4 $xz4 $y2] -arrow none -fill white -width 2
    $c create line [list $xz1 $y2 $xz2 $y2] -arrow none -fill white -width 2

    set xx1 128; set yx1 278; set xx2 135; set yx2 285
    set xx3 131; set yx3 281; set xx4 331; set xx5 328; set xx6 335
    $c create line [list $xx1 $yx1 $xx2 $yx2] -arrow none -fill white -width 2
    $c create line [list $xx3 $yx3 $xx4 $yx3] -arrow none -fill white -width 2
    $c create line [list $xx5 $yx1 $xx6 $yx2] -arrow none -fill white -width 2

    $c create text [expr {$xy3 - 5}] \
        [expr {($y4 - $y3)/2} + $y3] -text "H (J)" -anchor e -fill white
    $c create text [expr {$xy2 - 20}] \
        [expr {($y2 - $y4)/2} + $y4] -text "W (K)" -anchor w -fill white
    $c create text [expr {($x2 - $x1)/2 + $x1}] \
        $yx2 -text "L (I)" -anchor n -fill white

    # create note
    $c create text 200 380 -text "Origin is centered in prism" \
      -anchor c -fill white
    return $c
  }

  proc validateDimension { value } {
    if { [llength $value] != 3 } {
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
    upvar args $shapeArgs
    wm withdraw .
    if [catch {  
          set box::p1 \
            [pw::Display selectPoint -description "Select first point."]
          set box::p2 \
            [pw::Display selectPoint -description "Select second point."] 

          set diagonal [pwu::Vector3 subtract $box::p2 $box::p1]
          set args(Size) [list [expr abs([pwu::Vector3 x $diagonal])] \
                               [expr abs([pwu::Vector3 y $diagonal])] \
                               [expr abs([pwu::Vector3 z $diagonal])]]
          set args(Origin) \
            [pwu::Vector3 add [pwu::Vector3 scale $diagonal .5] $box::p1]
        } result] {
      set box::p1 ""
      set box::p2 ""
    }
    wm deiconify .
  }

  proc makeShape { shapeArgs } {
    upvar args $shapeArgs

    switch -exact $args(DimensionType) {
      AverageDelS {
        set dims [list $args(DeltaS) $args(DeltaS) $args(DeltaS)]
      }
      Dimension {
        set dims $args(Dimension)
      }
      default {
        return -code error "Invalid dimension mode: $args(DimensionType)"
      }
    }

    switch -exact $args(SurfaceType) {
      Baffle {
        set axis $box::Orientation
      }
      Farfield {
        set axis {}
      }
      default {
        return -code error "Invalid shape type: $args(SurfaceType)"
      }
    }

    makeBox $args(SurfaceType) $args(GridType) $args(EntityType) \
            $args(DimensionType) $dims $args(Size) $args(Origin) $axis

  }

  proc makeBox { shapeType gridType entType dimType dims size origin axis } {
    set x_dim [lindex $dims 0]
    set y_dim [lindex $dims 1]
    set z_dim [lindex $dims 2]

    set x_width  [lindex $size 0]
    set y_height [lindex $size 1]
    set z_depth  [lindex $size 2]

    switch -exact $entType {
      Grid {
        set edgeType "pw::Connector"
      }
      Database -
      Both {
        set edgeType "pw::Curve"
      }
      default {
        return -code error "Invalid entity type $entType"
      }
    }

    # Six Cartesian planes
    set xmin [expr [lindex $origin 0] - ($x_width/2)]
    set xmax [expr [lindex $origin 0] + ($x_width/2)]
    set ymin [expr [lindex $origin 1] - ($y_height/2)]
    set ymax [expr [lindex $origin 1] + ($y_height/2)]
    set zmin [expr [lindex $origin 2] - ($z_depth/2)]
    set zmax [expr [lindex $origin 2] + ($z_depth/2)]

    # Eight corners of a Cartesian-aligned box
    set nodes [list \
      "$xmin $ymin $zmin" \
      "$xmin $ymin $zmax" \
      "$xmin $ymax $zmin" \
      "$xmin $ymax $zmax" \
      "$xmax $ymin $zmin" \
      "$xmax $ymin $zmax" \
      "$xmax $ymax $zmin" \
      "$xmax $ymax $zmax"]

    # Twelve edges
    set edgeNodes [list \
      {0 1} {1 3} {3 2} {2 0} \
      {4 5} {5 7} {7 6} {6 4} \
      {0 4} {1 5} {3 7} {2 6}]

    # Dimension for each edge
    set edgeDims [list \
      $z_dim $y_dim $z_dim $y_dim \
      $z_dim $y_dim $z_dim $y_dim \
      $x_dim $x_dim $x_dim $x_dim]

    # Edges define each face
    set face(xmin) { 0  1  2  3 }
    set face(xmax) { 4  5  6  7 }
    set face(ymin) { 0  8  4  9 }
    set face(ymax) { 2 11  6 10 }
    set face(zmin) { 8  7 11  3 }
    set face(zmax) { 9  5 10  1 }

    # Create entities in a mode
    set creator [pw::Application begin Create]

    # create the edges
    foreach pair $edgeNodes dim $edgeDims {
      set edge [$edgeType create]
      set seg [pw::SegmentSpline create]
      $seg addPoint [lindex $nodes [lindex $pair 0]]
      $seg addPoint [lindex $nodes [lindex $pair 1]]
      $edge addSegment $seg

      # dimension connectors
      if [$edge isOfType pw::Connector] {
        if { $dimType == "AverageDelS" } {
          $edge setDimensionFromSpacing $dim
        } else {
          $edge setDimension $dim
        }
      }

      lappend edges $edge
    }

    # Determine which faces to build
    if { $shapeType == "Baffle" } {
      switch -exact $axis {
        X { set faces [list $face(ymin) $face(ymax) $face(zmin) $face(zmax)] }
        Y { set faces [list $face(xmin) $face(xmax) $face(zmin) $face(zmax)] }
        Z { set faces [list $face(xmin) $face(xmax) $face(ymin) $face(ymax)] }
      }
    } else {
        set faces [list $face(xmin) $face(xmax) \
                        $face(ymin) $face(ymax) \
                        $face(zmin) $face(zmax)]
    }

    # Build faces
    foreach bface $faces {
      set bedges [list]
      foreach edgenum $bface {
        lappend bedges [lindex $edges $edgenum]
      }

      if { $edgeType == "pw::Connector" } {
        # create domain
        lappend doms [pw::Domain$gridType createFromConnectors $bedges]
      } else {
        # create surfaces
        set surf [pw::Surface create]
        eval [concat $surf interpolate -orient Best $bedges]
        lappend surfs $surf

        if { $entType == "Both" } {
          # create connectors on surface boundaries
          set cons [pw::Connector createOnDatabase -merge 0 $surf]
          # dimension the new connectors
          set tol [pw::Database getSamePointTolerance]
          foreach con $cons {
            # determine dimension to apply
            set dir [pwu::Vector3 subtract \
                [[$con getNode Begin] getXYZ] [[$con getNode End] getXYZ]]
            if { abs([pwu::Vector3 x $dir]) > $tol } {
              set dim $x_dim
            } elseif { abs([pwu::Vector3 y $dir]) > $tol } {
              set dim $y_dim
            } else {
              set dim $z_dim
            }

            # apply the dimension
            if { $dimType == "AverageDelS" } {
              $con setDimensionFromSpacing $dim
            } else {
              $con setDimension $dim
            }
          }
    
          lappend doms [pw::Domain$gridType createFromConnectors $cons]
        }
      }
    }

    $creator end

    # delete database curves, leave only surfaces
    if { $edgeType != "pw::Connector" } {
      pw::Entity delete $edges
    }
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
