#############################################################################
#
# (C) 2021 Cadence Design Systems, Inc. All rights reserved worldwide.
#
# This sample script is not supported by Cadence Design Systems, Inc.
# It is provided freely for demonstration purposes only.
# SEE THE WARRANTY DISCLAIMER AT THE BOTTOM OF THIS FILE.
#
#############################################################################

# Create a sphere, hemisphere or quarter-sphere.
#
# NOTE: This script is part of the ShapeWizard Glyph 2 script suite.

global ShapeDict

###
# Register this shape with the wizard
###

dict set ShapeDict Sphere namespace sphere

###
# Implement the shape wizard interface
###

namespace eval sphere {
  # sphere globals
  set Portion Quarter
  set PortionFrame {}
  set p1 {}
  set p2 {}

  proc numDimensions      {} { return 2 }
  proc numSizes           {} { return 1 }
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
  proc sizeLabel          {} { return {Size [R]:} }
  proc originLabel        {} { return "Origin:" }
  proc orientationLabel   {} { return "Portion" }
  proc selectButtonLabel  {} { return "Select Extent Points" }

  proc canApply { shapeArgs } {
    upvar $shapeArgs args

    if { $args(SpecType) == "select" &&
         ($sphere::p1 == "" || $sphere::p2 == "") } {
      return false
    }
    return true
  }

  proc onSurfaceTypeChanged { type } {
    switch -exact $type {
      "Baffle" {
        $sphere::PortionFrame.quarter configure -state active
        $sphere::PortionFrame.half configure -state active
        $sphere::PortionFrame.full configure -state disabled

        if { $sphere::Portion == "Full" } {
          set sphere::Portion Quarter
        }
      }

      "Farfield" {
        $sphere::PortionFrame.quarter configure -state disabled
        $sphere::PortionFrame.half configure -state disabled
        $sphere::PortionFrame.full configure -state active
        if { $sphere::Portion != "Full" } {
          set sphere::Portion "Full"
        }
      }
    }
  }

  proc onGridTypeChanged { type } {
  }

  proc onSpecTypeChanged { type } {
  }

  proc configureOrientationFrame { parent shapeArgs } {
    upvar $shapeArgs args

    if [winfo exists $parent.boxFrame] {
      destroy $parent.boxFrame
    }

    set sphere::PortionFrame [frame $parent.boxFrame -bd 0 -relief flat]
    pack $sphere::PortionFrame -fill x
    pack [label $sphere::PortionFrame.lbl -text "Portion:"] \
      -side left -padx 5
    pack [radiobutton $sphere::PortionFrame.quarter \
              -variable sphere::Portion \
              -value "Quarter" \
              -text "1/4"] -side right -padx 5
    pack [radiobutton $sphere::PortionFrame.half \
              -variable sphere::Portion \
              -value "Half" \
              -text "1/2"] -side right -padx 5
    pack [radiobutton $sphere::PortionFrame.full \
              -variable sphere::Portion \
              -value "Full" \
              -text "Full"] -side right -padx 5

    onSurfaceTypeChanged $args(SurfaceType)
  }

  proc drawCanvas { c } {

    $c delete "all"

    set pi [expr {4 * atan(1.0)}]

    # create the "circle"
    $c create oval 50 50 350 350 -width 2 -outline green

    # create a bisecting line 
    $c create line 200 50 200 350 -arrow none -fill green

    # create a line cutting symetrically across (using theta)
    set r1 150
    set theta [expr {(10.0/180.0) * $pi}] 
    set x1local [expr {$r1 * cos($theta)}]
    set y1local [expr {$r1 * sin($theta)}]
    set x2local [expr {-1.0 * ($r1 * cos($theta))}]
    set y2local [expr {-1.0* ($r1 * sin($theta))}]
    set x1 [expr {200 - $x1local}]
    set y1 [expr {200 - $y1local}]
    set x2 [expr {200 - $x2local}]
    set y2 [expr {200 - $y2local}]

    $c create line 50 200 350 200 -arrow none -fill green -width 2

    # create dimension lines and labels 
    $c create arc 100 50 300 350 -start 90 -extent 180 -width 2 -outline white
    $c create arc 50 125 350 275 -start 0 -extent 180 -width 2 -outline white
    $c create text 280 120 -text "\[ I \]" -anchor e -fill white
    $c create text 100 260 -text "\[ J \]" -anchor e -fill white

    # create a line cutting symmetrically across (normal)
    $c create arc 150 50 250 350 -start 90 -extent 100 -width 2 -outline green 
    $c create arc 150 50 250 350 -start 10 -extent 0 -width 2 -outline green

    # create the plane oval
    $c create arc $x1 $y1 $x2 $y2 -start 0 -extent 180 -width 2 -outline green \
      -dash {6 4}
    $c create arc $x1 $y1 $x2 $y2 -start 180 -extent 180 -width 2 -outline green

    # create vertical arcs on "front" and "back"
    $c create arc 150 50 250 350 -start 90 -extent 180 -width 2 -outline green
    $c create arc 150 50 250 350 -start 270 -extent 180 -width 2 \
      -outline green -dash {6 4}

    # Place origin label and indicator
    $c create text 197 192 -text "Origin" -anchor e -fill white
    $c create oval 198 198 202 202 -fill white

    # create radius definition lines
    $c create arc 190 170 210 230 -start 190 -extent 0 -width 2 -outline white
    $c create arc 190 170 210 230 -start 10 -extent 0 -width 2 -outline white

    $c create line 200 200 275 330 -arrow none -width 2 -fill white 
    $c create line 265 336 285 324 -arrow none -width 2 -fill white
    $c create text 235 275 -text "R" -anchor e -fill white

    # create extent points 
    $c create oval [expr {$x1-3}] [expr {$y1-3}] [expr {$x1+3}] [expr {$y1+3}] \
      -fill red 
    $c create oval [expr {$x2-3}] [expr {$y2-3}] [expr {$x2+3}] [expr {$y2+3}] \
      -fill red 
    $c create text [expr {$x1-5}] $y1 -text "Point1" -anchor e -fill red
    $c create text [expr {$x2+7}] $y2 -text "Point2" -anchor w -fill red 
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
    if { [llength $value] != 1 } {
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
    upvar $shapeArgs args
    wm withdraw .
    if [catch {  
          set sphere::p1 \
            [pw::Display selectPoint -description "Select first point."]
          set sphere::p2 \
            [pw::Display selectPoint -description "Select second point."] 

          set axis [pwu::Vector3 subtract $sphere::p2 $sphere::p1]

          set args(Origin) \
              [pwu::Vector3 add $sphere::p1 [pwu::Vector3 scale $axis 0.5]]

          set args(Size) [expr "[pwu::Vector3 length $axis] / 2.0"]
       } result] {
      return -code error $result
      set sphere::p1 {}
      set sphere::p2 {}
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

    makeSphere $args(SurfaceType) $args(GridType) $args(EntityType) \
             $args(DimensionType) $dims $args(Origin) $args(Size) \
             $sphere::Portion
  }

  proc isSamePt { p1 p2 } {
    set tol [expr "[pw::Database getSamePointTolerance] ** 3"]
    return [expr "[pwu::Vector3 length [pwu::Vector3 subtract $p1 $p2]] < $tol"]
  }

  proc makeSphere { shapeType gridType entType dimType dims origin radius \
                    portion} {

    set ldim [lindex $dims 0]
    set rdim [lindex $dims 1]

    switch -exact $portion {
      "Quarter" {
        set angle 90
      }
      "Half" -
      "Full" {
        set angle 180
      }
    }

    # for now, always create the base curve in the XZ plane
    set p1 [pwu::Vector3 add $origin "$radius 0 0"]
    set p2 [pwu::Vector3 subtract $origin "$radius 0 0"]
    set p3 [pwu::Vector3 add $origin "0 0 $radius"]

    set creator [pw::Application begin Create]

    set crv(gen) [pw::Curve create]
    set seg [pw::SegmentCircle create]
    $seg addPoint $p1
    $seg addPoint $p2
    $seg setShoulderPoint $p3
    $crv(gen) addSegment $seg

    set raxis [pwu::Vector3 normalize [pwu::Vector3 subtract $p2 $p1]]
    set surf(a) [pw::Surface create]
    $surf(a) revolve -angle $angle $crv(gen) $origin $raxis

    if { $portion == "Full" } {
      set surf(b) [pw::Surface create]
      $surf(b) revolve -angle [expr -1.0 * $angle] $crv(gen) $origin $raxis
    }

    $creator end

    if { $entType != "Database" } {
      switch -exact $gridType {
        "Structured" {
          foreach i [array names surf] {
            set creator [pw::Application begin Create]
            set surfcons [pw::Connector createOnDatabase -type Structured \
              $surf($i)]

            set seams [list]
            set poles [list]
            foreach con $surfcons {
              if [[$con getNode Begin] equals [$con getNode End]] {
                lappend poles $con
              } else {
                lappend seams $con
              }
            }
            set poleDim $rdim
            foreach con $seams {
              if { $dimType == "AverageDelS" } {
                $con setDimensionFromSpacing $ldim
                set poleDim [$con getDimension]
              } else {
                $con setDimension $ldim
              }
            }
            foreach con $poles {
              $con setDimension $poleDim
            }

            set dom [pw::DomainStructured createFromConnectors \
              [concat $seams $poles]]

            $creator end

            if { $portion == "Full" } {
              # split the domain to prevent being duped out
              $dom split -I [expr ($poleDim / 2) + 1]
            }
          }
        }

        "Unstructured" {
          set tempMethod [pw::Connector getCalculateDimensionMethod]
          set tempSpacing [pw::Connector getCalculateDimensionSpacing]
          set tempDimension [pw::Connector getDefault Dimension]

          switch -exact $dimType {
            "AverageDelS" {
              pw::Connector setCalculateDimensionMethod Spacing
              pw::Connector setCalculateDimensionSpacing $ldim
            }

            "Dimension" {
              pw::Connector setCalculateDimensionMethod Explicit
              pw::Connector setDefault Dimension $ldim
            }
          }

          foreach i [array names surf] {
            pw::DomainUnstructured createOnDatabase $surf($i)
          }

          pw::Connector setCalculateDimensionMethod $tempMethod
          pw::Connector setCalculateDimensionSpacing $tempSpacing
          pw::Connector setDefault Dimension $tempDimension
        }
      }
    }

    pw::Entity delete $crv(gen)

    if { $entType == "Grid" } {
      foreach i [array names surf] {
        pw::Entity delete $surf($i)
      }
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
