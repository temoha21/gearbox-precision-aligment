-- Copyright (C) 2017 - 2025 SmashHammer Games Inc. - All Rights Reserved.

local currentTargetedPart

local win = Windows.CreateWindow()
win.SetAlignment( align_RightEdge, 20, 300 )
win.SetAlignment( align_TopEdge, 80, 120 )
local function onWindowClose()
	UnloadScript.Raise( ScriptName )	-- Window closed, so unload this script.
end
win.OnClose.add( onWindowClose )
win.Title = 'Is Part Collidable: N/A'
win.Show( true )

local togglePartButton = win.CreateTextButton()
togglePartButton.SetAlignment( align_HorizEdges, 10, 10 )
togglePartButton.SetAlignment( align_TopEdge, 10, 30 )
local function onTogglePartClicked()
	if currentTargetedPart then
		ConstructionOps.SetPartCollidable( currentTargetedPart.ID, not currentTargetedPart.IsCollidable )
		currentTargetedPart = nil	-- Force "is collidable" label to be updated.
	end
end
togglePartButton.OnClick.add( onTogglePartClicked )
togglePartButton.Text = 'Toggle Targeted Part <i>(Tab)</i>'

local resetConstructionButton = win.CreateTextButton()
resetConstructionButton.SetAlignment( align_HorizEdges, 10, 10 )
resetConstructionButton.SetAlignment( align_TopEdge, 50, 30 )
local function onResetConstructionClicked()
	if currentTargetedPart then
		ConstructionOps.SetConstructionCollidable( currentTargetedPart.ParentConstruction.ID, true )
		currentTargetedPart = nil	-- Force "is collidable" label to be updated.
	end
end
resetConstructionButton.OnClick.add( onResetConstructionClicked )
resetConstructionButton.Text = 'Reset All Parts in Construction'

----- Entry functions -----

function Update()
	local localPlayer = LocalPlayer.Value
	local targetedPart
	if localPlayer and localPlayer.Targeter then
		targetedPart = localPlayer.Targeter.TargetedPart
	end

	-- Update the "is collidable" label.
	if targetedPart ~= currentTargetedPart then
		if targetedPart then
			local colour = targetedPart.IsCollidable and '#88ff88' or '#ff8888'
			win.Title = string.format( 'Is Part Collidable: <color=%s>%s</color>', colour, tostring( targetedPart.IsCollidable ) )
		else
			win.Title = 'Is Part Collidable: N/A'
		end
		currentTargetedPart = targetedPart
	end

	-- Check for keyboard shortcuts.
	if Input.GetKeyDown( 'tab' ) then
		onTogglePartClicked()
	end
end

function Cleanup()
	Windows.DestroyWindow( win )
end
