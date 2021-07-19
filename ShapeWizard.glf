#############################################################################
#
# (C) 2021 Cadence Design Systems, Inc. All rights reserved worldwide.
#
# This sample script is not supported by Cadence Design Systems, Inc.
# It is provided freely for demonstration purposes only.
# SEE THE WARRANTY DISCLAIMER AT THE BOTTOM OF THIS FILE.
#
#############################################################################

################################################################################
# Create a variety of 3D shapes for use as Farfields or Baffles
################################################################################

package require PWI_Glyph 2

pw::Script loadTk

set scriptDir [file dirname [info script]]

# Track the available shapes
set ShapeDict [dict create]

# Track the validity of text entry fields
set ValidDict [dict create]

set CurrentShape {}
set CurrentNS {}

###
# Load shape scripts
###

foreach shapeFile [glob -directory $scriptDir -type f "sw_*.{glf,tcl}"] {
  source $shapeFile

  set s [lindex [dict keys $ShapeDict] end]
  set ns [dict get $ShapeDict $s namespace]
  if { [string length $CurrentShape] == 0 } {
    set CurrentShape $s
    set CurrentNS $ns
  }
}

if { [llength [dict keys $ShapeDict]] == 0 } {
  tk_messageBox -icon error -title "Error..." -message \
  "No shape scripts exist in the ShapeWizard directory\n" -type ok
  exit 2
}

###
# Initialize globals
###

set args(SurfaceType)   "Baffle"
set args(GridType)      "Structured"
set args(EntityType)    "Grid"
set args(DimensionType) "Dimension"
set args(Dimension)     {20 20 20}
set args(Dimension1D)   {20}
set args(Dimension2D)   {20 20}
set args(Dimension3D)   {20 20 20}
set args(DeltaS)        0.8
set args(SpecType)      "explicit"
set args(Size)          {10 10 10}
set args(Size1D)        {10}
set args(Size2D)        {10 10}
set args(Size3D)        {10 10 10}
set args(Origin)        {0.0 0.0 0.0}

set color(Invalid) "#FFCCCC"
set color(Valid)   "#FFFFFF"

###
# Event handlers
###

proc onShapeTypeChanged { force } {
  global ShapeDict CurrentShape CurrentNS args W

  # update the global shape namespace
  set newNS [dict get $ShapeDict $CurrentShape namespace]
  if { $newNS == $CurrentNS && ! $force } {
    return
  }

  if { [${CurrentNS}::numDimensions] == 3 } {
    set args(Dimension3D) $args(Dimension)
  } elseif { [${CurrentNS}::numDimensions] == 2 } {
    set args(Dimension2D) $args(Dimension)
  } else {
    set args(Dimension1D) $args(Dimension)
  }

  if { [${CurrentNS}::numSizes] == 3 } {
    set args(Size3D) $args(Size)
  } elseif { [${CurrentNS}::numSizes] == 2 } {
    set args(Size2D) $args(Size)
  } else {
    set args(Size1D) $args(Size)
  }

  set CurrentNS $newNS

  # configure orientation/plane widgets
  $W(FrameOrient) configure -text [${CurrentNS}::orientationLabel]
  ${CurrentNS}::configureOrientationFrame $W(FrameOrient) args

  # configure baffle/farfield widgets
  if [${CurrentNS}::allowsBaffle] {
    $W(RadioBaffle) configure -state active
  } else {
    $W(RadioBaffle) configure -state disabled
    if { $args(SurfaceType) == "Baffle" } {
      set args(SurfaceType) Farfield
      onSurfaceTypeChanged
    }
  }

  if [${CurrentNS}::allowsFarfield] {
    $W(RadioFarField) configure -state active
  } else {
    $W(RadioFarField) configure -state disabled
    if { $args(SurfaceType) == "Farfield" } {
      set args(SurfaceType) Baffle
      onSurfaceTypeChanged
    }
  }

  # configure grid type widgets
  if [${CurrentNS}::allowsGrid] {
    $W(RadioGrid) configure -state active
  } else {
    $W(RadioGrid) configure -state disabled
    if { $args(EntityType) == "Grid" } {
      set args(EntityType) Database
      onEntityTypeChanged
    }
  }

  if [${CurrentNS}::allowsDatabase] {
    $W(RadioDatabase) configure -state active
  } else {
    $W(RadioDatabase) configure -state disabled
    if { $args(EntityType) == "Database" } {
      set args(EntityType) Grid
      onEntityTypeChanged
    }
  }

  if [${CurrentNS}::allowsBothGridDb] {
    $W(RadioBoth) configure -state active
  } else {
    $W(RadioBoth) configure -state disabled
    if { $args(EntityType) == "Both" } {
      if [${CurrentNS}::allowsGrid] {
        set args(EntityType) Grid
      } else {
        set args(EntityType) Database
      }
      onEntityTypeChanged
    }
  }

  if [${CurrentNS}::allowsStructured] {
    $W(RadioStructured) configure -state active
  } else {
    $W(RadioStructured) configure -state disabled
    if { $args(GridType) == "Structured" } {
      set args(GridType) Unstructured
      onGridTypeChanged
    }
  }

  if [${CurrentNS}::allowsUnstructured] {
    $W(RadioUnstructured) configure -state active
  } else {
    $W(RadioUnstructured) configure -state disabled
    if { $args(GridType) == "Unstructured" } {
      set args(GridType) Structured
      onGridTypeChanged
    }
  }

  $W(RadioExplicitDim) configure -text [${CurrentNS}::dimensionLabel]
  $W(RadioDeltaS) configure -text [${CurrentNS}::deltaSLabel]

  if { [${CurrentNS}::numDimensions] == 3 } {
    set args(Dimension) $args(Dimension3D)
  } elseif { [${CurrentNS}::numDimensions] == 2 } {
    set args(Dimension) $args(Dimension2D)
  } else {
    set args(Dimension) $args(Dimension1D)
  }
  onDimensionTypeChanged

  if [${CurrentNS}::allowsSelectSpecs] {
    $W(RadioSelectSpecs) configure -state active
  } else {
    $W(RadioSelectSpecs) configure -state disabled
    if { $args(SpecType) == "select" } {
      set args(SpecType) "explicit"
    }
  }

  $W(LabelSize) configure -text [${CurrentNS}::sizeLabel]
  $W(LabelOrigin) configure -text [${CurrentNS}::originLabel]

  if { [${CurrentNS}::numSizes] == 3 } {
    set args(Size) $args(Size3D)
  } elseif { [${CurrentNS}::numSizes] == 2 } {
    set args(Size) $args(Size2D)
  } else {
    set args(Size) $args(Size1D)
  }
  onSpecTypeChanged

  $W(ButtonSelectSpecs) configure -text [${CurrentNS}::selectButtonLabel]

  ${CurrentNS}::drawCanvas $W(Canvas)
  updateWidgets
}

proc onSurfaceTypeChanged {} {
  global args CurrentNS
  ${CurrentNS}::onSurfaceTypeChanged $args(SurfaceType)
  updateWidgets
}

proc onDimensionTypeChanged {} {
  global CurrentNS args W
  switch -exact $args(DimensionType) {
    "Dimension" {
      $W(EntryDimension) configure -state normal
      $W(EntryDeltaS) configure -state disabled
      validateDimension $args(Dimension)
    }

    "AverageDelS" {
      $W(EntryDimension) configure -state disabled
      $W(EntryDeltaS) configure -state normal
      validateDeltaS $args(DeltaS)
    }
  }
  updateWidgets
}

proc onSpecTypeChanged {} {
  global args W CurrentNS
  switch -exact $args(SpecType) {
    "explicit" {
      $W(EntrySize) configure -state normal
      $W(EntryOrigin) configure -state normal
      $W(ButtonSelectSpecs) configure -state disabled
    }

    "select" {
      $W(EntrySize) configure -state disabled
      $W(EntryOrigin) configure -state disabled
      $W(ButtonSelectSpecs) configure -state active
    }
  }
  validateOrigin $args(Origin)
  validateSize $args(Size)

  ${CurrentNS}::onSpecTypeChanged $args(SpecType)
  updateWidgets
}

proc onEntityTypeChanged {} {
  global args W

  switch -exact $args(EntityType) {
    "Grid" -
    "Both" {
      $W(RadioStructured) configure -state active
      $W(RadioUnstructured) configure -state active
      $W(EntryDimension) configure -state normal
      $W(EntryDeltaS) configure -state normal
      $W(RadioExplicitDim) configure -state active
      $W(RadioDeltaS) configure -state active
    }

    "Database" {
      $W(RadioStructured) configure -state disabled
      $W(RadioUnstructured) configure -state disabled
      $W(EntryDimension) configure -state disabled
      $W(EntryDeltaS) configure -state disabled
      $W(RadioExplicitDim) configure -state disabled
      $W(RadioDeltaS) configure -state disabled
    }
  }
  updateWidgets
}

proc onGridTypeChanged { } {
  global CurrentNS args
  ${CurrentNS}::onGridTypeChanged $args(GridType)
  updateWidgets
}

proc updateWidgets { } {
  global CurrentNS ValidDict color W args

  set canApply [${CurrentNS}::canApply args]

  foreach key [dict keys $ValidDict] {
    if [dict exists $ValidDict $key widget] {
      set w [dict get $ValidDict $key widget]
      if [dict get $ValidDict $key valid] {
        $w configure -bg $color(Valid)
      } else {
        $w configure -bg $color(Invalid)
        set canApply 0
      }
    }
  }

  if { ! $canApply } {
    $W(ButtonOk) configure -state disabled
    $W(ButtonApply) configure -state disabled
  } else {
    $W(ButtonOk) configure -state active
    $W(ButtonApply) configure -state active
  }

  return 1
}

###
# validation procs
###

proc validateDimension { value } {
  global ValidDict CurrentNS
  dict set ValidDict Dimension valid [${CurrentNS}::validateDimension $value]
  dict set ValidDict DeltaS valid 1
  return true
}

proc validateDeltaS { value } {
  global ValidDict CurrentNS
  dict set ValidDict DeltaS valid [${CurrentNS}::validateDeltaS $value]
  dict set ValidDict Dimension valid 1
  return true
}

proc validateSize { value } {
  global ValidDict CurrentNS
  dict set ValidDict Size valid [${CurrentNS}::validateSize $value]
  return true
}

proc validateOrigin { value } {
  global ValidDict CurrentNS
  dict set ValidDict Origin valid [${CurrentNS}::validateOrigin $value]
  return true
}

###
# Shape-specific picking
###

proc doPickEntities { } {
  global ValidDict CurrentNS args
  ${CurrentNS}::pickEntities args
  updateWidgets
}

###
# Create the generic GUI
###

proc buildWidgets { } {
  global ShapeDict ValidDict CurrentShape CurrentNS W

  # widget hierarchy
  set W(LabelTitle)             .title
  set W(FrameWork)              .main
   set W(FrameInput)            $W(FrameWork).input
    set W(FrameAtts)            $W(FrameInput).atts
     set W(ShapeMenu)           $W(FrameAtts).shapemenu
     set W(RadioBaffle)         $W(FrameAtts).rbaffle
     set W(RadioFarField)       $W(FrameAtts).rfarfield
     set W(RadioGrid)           $W(FrameAtts).rgrid
     set W(RadioDatabase)       $W(FrameAtts).rdatabase
     set W(RadioBoth)           $W(FrameAtts).rboth
     set W(RadioStructured)     $W(FrameAtts).rstructured
     set W(RadioUnstructured)   $W(FrameAtts).runstructured
     set W(RadioExplicitDim)    $W(FrameAtts).rdimexplicit
     set W(EntryDimension)      $W(FrameAtts).dimension
     set W(RadioDeltaS)         $W(FrameAtts).ravgds
     set W(EntryDeltaS)         $W(FrameAtts).deltas
    set W(FrameSpecs)           $W(FrameInput).specs
     set W(RadioExplicitSpecs)  $W(FrameSpecs).rspecexplicit
     set W(FrameExplicitSpecs)  $W(FrameSpecs).fspecexplicit
      set W(LabelSize)          $W(FrameExplicitSpecs).lsize
      set W(EntrySize)          $W(FrameExplicitSpecs).size
      set W(LabelOrigin)        $W(FrameExplicitSpecs).lorigin
      set W(EntryOrigin)        $W(FrameExplicitSpecs).origin
     set W(RadioSelectSpecs)    $W(FrameSpecs).rselect
     set W(FrameSelectSpecs)    $W(FrameSpecs).fselect
      set W(ButtonSelectSpecs)  $W(FrameSelectSpecs).bselect
    set W(FrameOrient)          $W(FrameInput).forient
   set W(FrameCanvas)           $W(FrameWork).fcanvas
    set W(Canvas)               $W(FrameCanvas).canvas
  set W(FrameButtons)           .buttons
   set W(ButtonOk)              $W(FrameButtons).ok
   set W(ButtonApply)           $W(FrameButtons).apply
   set W(ButtonCancel)          $W(FrameButtons).cancel
   set W(Logo)                  $W(FrameButtons).logo

  # title
  wm title . "Shape Wizard"
  label $W(LabelTitle) -text "Shape Wizard"
  set font [$W(LabelTitle) cget -font]
  set fontSize [font actual $font -size]
  set wfont [font create -family [font actual $font -family] -weight bold \
    -size [expr {int(1.5 * $fontSize)}]]
  $W(LabelTitle) configure -font $wfont

  pack $W(LabelTitle) -side top

  # spacer
  pack [frame .sp -bd 1 -height 2 -relief sunken] -side top -fill x -padx 15

  # work frame
  pack [frame $W(FrameWork) -width 640 -relief sunken] \
    -side top -fill both -expand 1

  # input frame
  pack [frame $W(FrameInput) -bd 1] -side left -anchor n

  # canvas frame
  pack [frame $W(FrameCanvas) -bd 1 -relief sunken] \
    -side right -padx 10 -pady 10 -fill both -expand 1

  # button frame
  pack [frame $W(FrameButtons) -relief sunken] \
    -fill x -side bottom -padx 2 -pady 4

  button $W(ButtonOk) \
         -text "OK" \
         -command {
           ${CurrentNS}::makeShape args
           exit
         }

  button $W(ButtonApply) \
         -text "Apply" \
         -command {
           ${CurrentNS}::makeShape args
           pw::Display update
         }

  button $W(ButtonCancel) -text "Cancel" -command exit

  pack $W(ButtonCancel) -side right -padx 5
  pack $W(ButtonApply)  -side right -padx 5
  pack $W(ButtonOk)     -side right -padx 5

  # Pointwise logo in button frame
  pack [label $W(Logo) -image [cadenceLogo] -bd 0 -relief flat] -side left

  # Input controls
  labelframe $W(FrameAtts) -text "Attributes" -bd 2 -relief sunken
  grid $W(FrameAtts) -row 0 -column 0 -padx 5 -pady 5 -sticky ew

  grid [label $W(FrameAtts).ml -text "Type: "] -row 0 -column 0 -sticky e

  # build the menu with the available shapes
  set shapeMenu [eval \
    [concat tk_optionMenu $W(ShapeMenu) CurrentShape [dict keys $ShapeDict]]]
  grid $W(ShapeMenu) -row 0 -column 1 -columnspan 2 -sticky w

  grid [label $W(FrameAtts).sl -text "Surface Type: "] \
    -row 1 -column 0 -sticky e

  radiobutton $W(RadioBaffle) \
              -variable args(SurfaceType) \
              -value "Baffle" \
              -text "Baffle" \
              -command { onSurfaceTypeChanged }
  grid $W(RadioBaffle) -row 1 -column 1 -sticky w

  radiobutton $W(RadioFarField) \
              -variable args(SurfaceType) \
              -value "Farfield" \
              -text "Farfield" \
              -command { onSurfaceTypeChanged }
  grid $W(RadioFarField) -row 1 -column 2 -sticky w

  grid [label $W(FrameAtts).el -text "Entity Type: "] -row 2 -column 0 -sticky e

  radiobutton $W(RadioGrid) \
              -variable args(EntityType) \
              -value "Grid" \
              -text "Grid" \
              -command { onEntityTypeChanged }
  grid $W(RadioGrid) -row 2 -column 1 -sticky w -padx 1

  radiobutton $W(RadioDatabase) \
              -variable args(EntityType) \
              -value "Database" \
              -text "Database" \
              -command { onEntityTypeChanged }
  grid $W(RadioDatabase) -row 2 -column 2 -sticky w -padx 1

  radiobutton $W(RadioBoth) \
              -variable args(EntityType) \
              -value "Both" \
              -text "Both" \
              -command { onEntityTypeChanged }
  grid $W(RadioBoth) -row 2 -column 3 -sticky w -padx 1

  grid [label $W(FrameAtts).gl -text "Grid Type: "] -row 3 -column 0 -sticky e

  radiobutton $W(RadioStructured) \
              -variable args(GridType) \
              -value "Structured" \
              -text "Structured" \
              -command { onGridTypeChanged }
  grid $W(RadioStructured) -row 3 -column 1 -sticky w

  radiobutton $W(RadioUnstructured) \
              -variable args(GridType) \
              -value "Unstructured" \
              -text "Unstructured" \
              -command { onGridTypeChanged }
  grid $W(RadioUnstructured) -row 3 -column 2 -sticky w

  # spacer
  grid [frame $W(FrameAtts).sp -height 4 -bd 0] -row 4 -columnspan 4

  radiobutton $W(RadioExplicitDim) \
              -variable args(DimensionType) \
              -value "Dimension" \
              -text {Dimension [ I J K ]} \
              -command { onDimensionTypeChanged; updateWidgets }
  grid $W(RadioExplicitDim) -row 5 -column 0 -sticky w

  entry $W(EntryDimension) \
        -textvariable args(Dimension) \
        -validate key \
        -validatecommand { validateDimension %P; updateWidgets }
  grid $W(EntryDimension) -row 5 -column 1 -sticky w -columnspan 3
  dict set ValidDict Dimension widget $W(EntryDimension)
  dict set ValidDict Dimension valid 1

  radiobutton $W(RadioDeltaS) \
              -variable args(DimensionType) \
              -value "AverageDelS" \
              -text "Average \u394s:" \
              -command { onDimensionTypeChanged; updateWidgets }
  grid $W(RadioDeltaS) -row 6 -column 0 -sticky w

  entry $W(EntryDeltaS) \
        -textvariable args(DeltaS) \
        -validate key \
        -validatecommand { validateDeltaS %P; updateWidgets }
  grid $W(EntryDeltaS) -row 6 -column 1 -sticky w -columnspan 3
  dict set ValidDict DeltaS widget $W(EntryDeltaS)
  dict set ValidDict DeltaS valid 1

  # Specifications frame
  labelframe $W(FrameSpecs) \
             -text "Specifications" \
             -bd 2 \
             -relief sunken
  grid $W(FrameSpecs) -row 1 -column 0 -padx 5 -pady 5 -sticky ew

  radiobutton $W(RadioExplicitSpecs) \
              -variable args(SpecType) \
              -value "explicit" \
              -command { onSpecTypeChanged; updateWidgets }
  grid $W(RadioExplicitSpecs) -row 0 -column 0 -sticky ne

  labelframe $W(FrameExplicitSpecs) \
             -text "Explicit" \
             -bd 1 \
             -relief sunken
  grid $W(FrameExplicitSpecs) -row 0 -column 1 -padx 5 -pady 5 -sticky ew

  # Size
  grid [label $W(LabelSize) -text "Size \[ L W H \] "] \
    -row 0 -column 0 -sticky e -padx 5 -pady 5

  entry $W(EntrySize) \
        -textvariable args(Size) \
        -validate key \
        -validatecommand { validateSize %P; updateWidgets }
  grid $W(EntrySize) -row 0 -column 1 -sticky w -padx 5 -pady 5
  dict set ValidDict Size widget $W(EntrySize)
  dict set ValidDict Size valid 1

  # Origin
  grid [label $W(LabelOrigin) -text "Origin"] \
    -row 1 -column 0 -sticky e -padx 5 -pady 5

  entry $W(EntryOrigin) \
        -textvariable args(Origin) \
        -validate key \
        -validatecommand { validateOrigin %P; updateWidgets }
  grid $W(EntryOrigin) -row 1 -column 1 -sticky w -padx 5 -pady 5
  dict set ValidDict Origin widget $W(EntryOrigin)
  dict set ValidDict Origin valid 1

  # Interactive frame
  radiobutton $W(RadioSelectSpecs) \
              -variable args(SpecType) \
              -value "select" \
              -command { onSpecTypeChanged; updateWidgets }
  grid $W(RadioSelectSpecs) -row 1 -column 0 -sticky ne

  labelframe $W(FrameSelectSpecs) \
             -text "Interactive Mode" \
             -bd 1 \
             -relief sunken
  grid $W(FrameSelectSpecs) -row 1 -column 1 -padx 5 -pady 5 -sticky ew

  button $W(ButtonSelectSpecs) \
         -text "Select entities interactively" -state disabled \
	     -command { doPickEntities }
  grid $W(ButtonSelectSpecs) -row 0 -column 0 -pady 5

  label $W(FrameSelectSpecs).lt \
        -text "Selection uses canvas entities shown in red."
  grid $W(FrameSelectSpecs).lt -row 1 -column 0 -pady 5

  # Orientation frame
  labelframe $W(FrameOrient) \
             -text "Orientation/Portion" \
             -bd 2 \
             -relief sunken
  grid $W(FrameOrient) -row 3 -column 0 -padx 5 -pady 5 -sticky ew

  #### Canvas ####
  pack [canvas $W(Canvas) -bg "#110c3c"] -fill both -expand 1
  ${CurrentNS}::drawCanvas $W(Canvas)

  onShapeTypeChanged true

  #### Bindings ####
  bind $shapeMenu <<MenuSelect>> {
    onShapeTypeChanged false;
    update
  }
}

proc cadenceLogo {} {
  set logoData "
R0lGODlhgAAYAPQfAI6MjDEtLlFOT8jHx7e2tv39/RYSE/Pz8+Tj46qoqHl3d+vq62ZjY/n4+NT
T0+gXJ/BhbN3d3fzk5vrJzR4aG3Fubz88PVxZWp2cnIOBgiIeH769vtjX2MLBwSMfIP///yH5BA
EAAB8AIf8LeG1wIGRhdGF4bXD/P3hwYWNrZXQgYmVnaW49Iu+7vyIgaWQ9Ilc1TTBNcENlaGlIe
nJlU3pOVGN6a2M5ZCI/PiA8eDp4bXBtdGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1w
dGs9IkFkb2JlIFhNUCBDb3JlIDUuMC1jMDYxIDY0LjE0MDk0OSwgMjAxMC8xMi8wNy0xMDo1Nzo
wMSAgICAgICAgIj48cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudy5vcmcvMTk5OS8wMi
8yMi1yZGYtc3ludGF4LW5zIyI+IDxyZGY6RGVzY3JpcHRpb24gcmY6YWJvdXQ9IiIg/3htbG5zO
nhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdFJlZj0iaHR0
cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUcGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh
0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0idX
VpZDoxMEJEMkEwOThFODExMUREQTBBQzhBN0JCMEIxNUM4NyB4bXBNTTpEb2N1bWVudElEPSJ4b
XAuZGlkOkIxQjg3MzdFOEI4MTFFQjhEMv81ODVDQTZCRURDQzZBIiB4bXBNTTpJbnN0YW5jZUlE
PSJ4bXAuaWQ6QjFCODczNkZFOEI4MTFFQjhEMjU4NUNBNkJFRENDNkEiIHhtcDpDcmVhdG9yVG9
vbD0iQWRvYmUgSWxsdXN0cmF0b3IgQ0MgMjMuMSAoTWFjaW50b3NoKSI+IDx4bXBNTTpEZXJpZW
RGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6MGE1NjBhMzgtOTJiMi00MjdmLWE4ZmQtM
jQ0NjMzNmNjMWI0IiBzdFJlZjpkb2N1bWVudElEPSJ4bXAuZGlkOjBhNTYwYTM4LTkyYjItNDL/
N2YtYThkLTI0NDYzMzZjYzFiNCIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g
6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PgH//v38+/r5+Pf29fTz8vHw7+7t7Ovp6Ofm5e
Tj4uHg397d3Nva2djX1tXU09LR0M/OzczLysnIx8bFxMPCwcC/vr28u7q5uLe2tbSzsrGwr66tr
KuqqainpqWko6KhoJ+enZybmpmYl5aVlJOSkZCPjo2Mi4qJiIeGhYSDgoGAf359fHt6eXh3dnV0
c3JxcG9ubWxramloZ2ZlZGNiYWBfXl1cW1pZWFdWVlVUU1JRUE9OTUxLSklIR0ZFRENCQUA/Pj0
8Ozo5ODc2NTQzMjEwLy4tLCsqKSgnJiUkIyIhIB8eHRwbGhkYFxYVFBMSERAPDg0MCwoJCAcGBQ
QDAgEAACwAAAAAgAAYAAAF/uAnjmQpTk+qqpLpvnAsz3RdFgOQHPa5/q1a4UAs9I7IZCmCISQwx
wlkSqUGaRsDxbBQer+zhKPSIYCVWQ33zG4PMINc+5j1rOf4ZCHRwSDyNXV3gIQ0BYcmBQ0NRjBD
CwuMhgcIPB0Gdl0xigcNMoegoT2KkpsNB40yDQkWGhoUES57Fga1FAyajhm1Bk2Ygy4RF1seCjw
vAwYBy8wBxjOzHq8OMA4CWwEAqS4LAVoUWwMul7wUah7HsheYrxQBHpkwWeAGagGeLg717eDE6S
4HaPUzYMYFBi211FzYRuJAAAp2AggwIM5ElgwJElyzowAGAUwQL7iCB4wEgnoU/hRgIJnhxUlpA
SxY8ADRQMsXDSxAdHetYIlkNDMAqJngxS47GESZ6DSiwDUNHvDd0KkhQJcIEOMlGkbhJlAK/0a8
NLDhUDdX914A+AWAkaJEOg0U/ZCgXgCGHxbAS4lXxketJcbO/aCgZi4SC34dK9CKoouxFT8cBNz
Q3K2+I/RVxXfAnIE/JTDUBC1k1S/SJATl+ltSxEcKAlJV2ALFBOTMp8f9ihVjLYUKTa8Z6GBCAF
rMN8Y8zPrZYL2oIy5RHrHr1qlOsw0AePwrsj47HFysrYpcBFcF1w8Mk2ti7wUaDRgg1EISNXVwF
lKpdsEAIj9zNAFnW3e4gecCV7Ft/qKTNP0A2Et7AUIj3ysARLDBaC7MRkF+I+x3wzA08SLiTYER
KMJ3BoR3wzUUvLdJAFBtIWIttZEQIwMzfEXNB2PZJ0J1HIrgIQkFILjBkUgSwFuJdnj3i4pEIlg
eY+Bc0AGSRxLg4zsblkcYODiK0KNzUEk1JAkaCkjDbSc+maE5d20i3HY0zDbdh1vQyWNuJkjXnJ
C/HDbCQeTVwOYHKEJJwmR/wlBYi16KMMBOHTnClZpjmpAYUh0GGoyJMxya6KcBlieIj7IsqB0ji
5iwyyu8ZboigKCd2RRVAUTQyBAugToqXDVhwKpUIxzgyoaacILMc5jQEtkIHLCjwQUMkxhnx5I/
seMBta3cKSk7BghQAQMeqMmkY20amA+zHtDiEwl10dRiBcPoacJr0qjx7Ai+yTjQvk31aws92JZ
Q1070mGsSQsS1uYWiJeDrCkGy+CZvnjFEUME7VaFaQAcXCCDyyBYA3NQGIY8ssgU7vqAxjB4EwA
DEIyxggQAsjxDBzRagKtbGaBXclAMMvNNuBaiGAAA7"

  return [image create photo -format GIF -data $logoData]
}

buildWidgets
::tk::PlaceWindow . widget
tkwait window .

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
