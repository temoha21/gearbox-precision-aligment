-- Copyright (C) 2017 - 2025 SmashHammer Games Inc. - All Rights Reserved.

local partSelection

local prevSelectionStepDistance = 0
local prevSelectionStepAngle = 0
local prevPivotPosition = Vector3.Zero
local prevPivotOrientation = Quaternion.Identity

local win = Windows.CreateWindow()
win.SetAlignment( align_RightEdge, 20, 400 )
win.SetAlignment( align_TopEdge, 80, 380 )
local function onWindowClose()
	UnloadScript.Raise( ScriptName )	-- Window closed, so unload this script.
end
win.OnClose.add( onWindowClose )
win.Title = 'Builder Tool'
win.Show( true )

-- Manipulator orientation:

local manipulatorOrientationLabel = win.CreateLabel()
manipulatorOrientationLabel.SetAlignment( align_LeftEdge, 10, 180 )
manipulatorOrientationLabel.SetAlignment( align_TopEdge, 10, 30 )
manipulatorOrientationLabel.Alignment = textAnc_MiddleLeft
manipulatorOrientationLabel.Text = 'Manipulator Orientation:'

local manipulatorOrientationDropdown = win.CreateDropdown()
manipulatorOrientationDropdown.SetAlignment( align_RightEdge, 10, 200 )
manipulatorOrientationDropdown.SetAlignment( align_TopEdge, 10, 30 )
local options = {}
options[1] = 'Local'
options[2] = 'Global'
manipulatorOrientationDropdown.AddOptions( options )
manipulatorOrientationDropdown.Value = ManipulatorOrientationMode.Value
local function onDropdownChanged()
	ManipulatorOrientationMode.Value = manipulatorOrientationDropdown.Value
end
manipulatorOrientationDropdown.OnChanged.add( onDropdownChanged )

-- Translation step interval:

local translationStepIntervalLabel = win.CreateLabel()
translationStepIntervalLabel.SetAlignment( align_LeftEdge, 10, 180 )
translationStepIntervalLabel.SetAlignment( align_TopEdge, 50, 30 )
translationStepIntervalLabel.Alignment = textAnc_MiddleLeft
translationStepIntervalLabel.Text = 'Position Step Interval:'

local translationStepInputField = win.CreateInputField()
translationStepInputField.SetAlignment( align_RightEdge, 10, 200 )
translationStepInputField.SetAlignment( align_TopEdge, 50, 30 )
translationStepInputField.Value = '0.000'
local function onTranslationStepInputFieldEndEdit()
	SelectionStepDistance.Value = tonumber( translationStepInputField.Value )
end
translationStepInputField.OnEndEdit.add( onTranslationStepInputFieldEndEdit )

-- Rotation step interval:

local rotationStepIntervalLabel = win.CreateLabel()
rotationStepIntervalLabel.SetAlignment( align_LeftEdge, 10, 180 )
rotationStepIntervalLabel.SetAlignment( align_TopEdge, 90, 30 )
rotationStepIntervalLabel.Alignment = textAnc_MiddleLeft
rotationStepIntervalLabel.Text = 'Rotation Step Interval:'

local rotationStepInputField = win.CreateInputField()
rotationStepInputField.SetAlignment( align_RightEdge, 10, 200 )
rotationStepInputField.SetAlignment( align_TopEdge, 90, 30 )
rotationStepInputField.Value = '0.000'
local function onRotationStepInputFieldEndEdit()
	SelectionStepAngle.Value = tonumber( rotationStepInputField.Value )
end
rotationStepInputField.OnEndEdit.add( onRotationStepInputFieldEndEdit )

-- Pivot position:

local pivotPositionLabel = win.CreateLabel()
pivotPositionLabel.SetAlignment( align_HorizEdges, 10, 10 )
pivotPositionLabel.SetAlignment( align_TopEdge, 130, 30 )
pivotPositionLabel.Alignment = textAnc_MiddleLeft
pivotPositionLabel.Text = 'Pivot Position:'

local pivotPositionXInputField = win.CreateInputField()
pivotPositionXInputField.SetAlignment( align_RightEdge, 220, 60 )
pivotPositionXInputField.SetAlignment( align_TopEdge, 130, 30 )
pivotPositionXInputField.Value = '0.000'

local pivotPositionYInputField = win.CreateInputField()
pivotPositionYInputField.SetAlignment( align_RightEdge, 150, 60 )
pivotPositionYInputField.SetAlignment( align_TopEdge, 130, 30 )
pivotPositionYInputField.Value = '0.000'

local pivotPositionZInputField = win.CreateInputField()
pivotPositionZInputField.SetAlignment( align_RightEdge, 80, 60 )
pivotPositionZInputField.SetAlignment( align_TopEdge, 130, 30 )
pivotPositionZInputField.Value = '0.000'

local function onPivotPositionInputFieldEndEdit()
	if partSelection then
		-- Update the pivot position from the input fields.
		partSelection.PivotPosition = Vector3.__new( tonumber( pivotPositionXInputField.Value ), tonumber( pivotPositionYInputField.Value ), tonumber( pivotPositionZInputField.Value ) )
	end
end
pivotPositionXInputField.OnEndEdit.add( onPivotPositionInputFieldEndEdit )
pivotPositionYInputField.OnEndEdit.add( onPivotPositionInputFieldEndEdit )
pivotPositionZInputField.OnEndEdit.add( onPivotPositionInputFieldEndEdit )

local snapPivotPositionButton = win.CreateTextButton()
snapPivotPositionButton.SetAlignment( align_RightEdge, 10, 60 )
snapPivotPositionButton.SetAlignment( align_TopEdge, 130, 30 )
local function onSnapPivotPositionButtonClicked()
	if partSelection then
		-- Snap the pivot position.
		partSelection.PivotPosition = Vector3.round( partSelection.PivotPosition, SelectionStepDistance.Value )
	end
end
snapPivotPositionButton.OnClick.add( onSnapPivotPositionButtonClicked )
snapPivotPositionButton.Text = 'Snap'

-- Pivot orientation:

local pivotOrientationLabel = win.CreateLabel()
pivotOrientationLabel.SetAlignment( align_HorizEdges, 10, 10 )
pivotOrientationLabel.SetAlignment( align_TopEdge, 170, 30 )
pivotOrientationLabel.Alignment = textAnc_MiddleLeft
pivotOrientationLabel.Text = 'Pivot Rotation:'

local pivotOrientationXInputField = win.CreateInputField()
pivotOrientationXInputField.SetAlignment( align_RightEdge, 220, 60 )
pivotOrientationXInputField.SetAlignment( align_TopEdge, 170, 30 )
pivotOrientationXInputField.Value = '0.00'

local pivotOrientationYInputField = win.CreateInputField()
pivotOrientationYInputField.SetAlignment( align_RightEdge, 150, 60 )
pivotOrientationYInputField.SetAlignment( align_TopEdge, 170, 30 )
pivotOrientationYInputField.Value = '0.00'

local pivotOrientationZInputField = win.CreateInputField()
pivotOrientationZInputField.SetAlignment( align_RightEdge, 80, 60 )
pivotOrientationZInputField.SetAlignment( align_TopEdge, 170, 30 )
pivotOrientationZInputField.Value = '0.00'

local function onPivotOrientationInputFieldEndEdit()
	if partSelection then
		-- Update the pivot orientation from the input fields.
		partSelection.PivotOrientation = Quaternion.euler( tonumber( pivotOrientationXInputField.Value ), tonumber( pivotOrientationYInputField.Value ), tonumber( pivotOrientationZInputField.Value ) )
	end
end
pivotOrientationXInputField.OnEndEdit.add( onPivotOrientationInputFieldEndEdit )
pivotOrientationYInputField.OnEndEdit.add( onPivotOrientationInputFieldEndEdit )
pivotOrientationZInputField.OnEndEdit.add( onPivotOrientationInputFieldEndEdit )

local snapPivotOrientationButton = win.CreateTextButton()
snapPivotOrientationButton.SetAlignment( align_RightEdge, 10, 60 )
snapPivotOrientationButton.SetAlignment( align_TopEdge, 170, 30 )
local function onSnapPivotOrientationButtonClicked()
	if partSelection then
		-- Snap the pivot position.
		partSelection.PivotOrientation = Quaternion.snapAngles( partSelection.PivotOrientation, SelectionStepAngle.Value )
	end
end
snapPivotOrientationButton.OnClick.add( onSnapPivotOrientationButtonClicked )
snapPivotOrientationButton.Text = 'Snap'

-- Move selection to ground:

local moveToGroundButton = win.CreateTextButton()
moveToGroundButton.SetAlignment( align_HorizEdges, 10, 10 )
moveToGroundButton.SetAlignment( align_TopEdge, 210, 30 )
local function onMoveToGround()
	if partSelection then
		-- Move the part selection onto the ground.
		partSelection.moveToGround()
	end
end	
moveToGroundButton.OnClick.add( onMoveToGround )
moveToGroundButton.Text = 'Move to ground'

-- Options:

local partPenetrationTestToggle = win.CreateLabelledToggle()
partPenetrationTestToggle.SetAlignment( align_HorizEdges, 10, 10 )
partPenetrationTestToggle.SetAlignment( align_TopEdge, 250, 30 )
partPenetrationTestToggle.Text = 'Prevent interpenetration when attaching parts'
partPenetrationTestToggle.Value = PartPenetrationTestEnabled.Value
local function onPartPenetrationTestToggled()
	PartPenetrationTestEnabled.Value = partPenetrationTestToggle.Value
end
partPenetrationTestToggle.OnChanged.add( onPartPenetrationTestToggled )

local attachmentBridgingToggle = win.CreateLabelledToggle()
attachmentBridgingToggle.SetAlignment( align_HorizEdges, 10, 10 )
attachmentBridgingToggle.SetAlignment( align_TopEdge, 280, 30 )
attachmentBridgingToggle.Text = 'Enable attachment bridging'
attachmentBridgingToggle.Value = AttachmentBridgingEnabled.Value
local function onAttachmentBridgingToggled()
	AttachmentBridgingEnabled.Value = attachmentBridgingToggle.Value
end
attachmentBridgingToggle.OnChanged.add( onAttachmentBridgingToggled )

local showAllAttachmentsToggle = win.CreateLabelledToggle()
showAllAttachmentsToggle.SetAlignment( align_HorizEdges, 10, 10 )
showAllAttachmentsToggle.SetAlignment( align_TopEdge, 310, 30 )
showAllAttachmentsToggle.Text = 'Show all attachments in targeted construction'
showAllAttachmentsToggle.Value = ShowAllAttachments.Value
local function onShowAllAttachmentsToggled()
	ShowAllAttachments.Value = showAllAttachmentsToggle.Value
end
showAllAttachmentsToggle.OnChanged.add( onShowAllAttachmentsToggled )

----- Entry functions -----

function Update()
	local localPlayer = LocalPlayer.Value
	if localPlayer then
		partSelection = localPlayer.Toolbox.PartSelection
	else
		partSelection = nil
	end

	local selectionStepDistance = SelectionStepDistance.Value
	if selectionStepDistance ~= prevSelectionStepDistance then
		translationStepInputField.Value = string.format( '%.3f', selectionStepDistance )
		prevSelectionStepDistance = selectionStepDistance
	end

	local selectionStepAngle = SelectionStepAngle.Value
	if selectionStepAngle ~= prevSelectionStepAngle then
		rotationStepInputField.Value = string.format( '%.3f', selectionStepAngle )
		prevSelectionStepAngle = selectionStepAngle
	end

	if partSelection then
		-- If the pivot position has changed, update the input fields.
		local pivotPosition = partSelection.PivotPosition
		if not prevPivotPosition.equals( pivotPosition ) then
			pivotPositionXInputField.Value = string.format( '%.3f', pivotPosition.X )
			pivotPositionYInputField.Value = string.format( '%.3f', pivotPosition.Y )
			pivotPositionZInputField.Value = string.format( '%.3f', pivotPosition.Z )
			prevPivotPosition = pivotPosition
		end

		-- If the pivot orientation has changed, update the input fields.
		local pivotOrientation = partSelection.PivotOrientation
		if not prevPivotOrientation.equals( pivotOrientation ) then
			pivotOrientationXInputField.Value = string.format( '%.2f', pivotOrientation.EulerAngles.X )
			pivotOrientationYInputField.Value = string.format( '%.2f', pivotOrientation.EulerAngles.Y )
			pivotOrientationZInputField.Value = string.format( '%.2f', pivotOrientation.EulerAngles.Z )
			prevPivotOrientation = pivotOrientation
		end
	end
end

function Cleanup()
	Windows.DestroyWindow( win )
end
