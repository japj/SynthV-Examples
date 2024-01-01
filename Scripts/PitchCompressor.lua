SCRIPT_TITLE = "Pitch Compressor"
-- based on Scale Pitch Deviation by David Cuny at https://github.com/dcuny/synth-v-scripts


-- Standard header
function getClientInfo()
  return {
    name = SV:T(SCRIPT_TITLE),
    author = "Jeroen Janssen",
    versionNumber = 1,
    minEditorVersion = 65537
  }
end



-- main function
function main()
	-- create a form
	local form = {
		title = SV:T(SCRIPT_TITLE),
		message = "",
		buttons = "OkCancel",
		widgets = {
			{
				-- pitch sliding scale
				name = "pScale",
				type = "Slider",
				label = SV:T("Pitch Compresssion Percent"),
				format = "%3.0f",
				minValue = 25,
				maxValue = 2000,
				interval = 10,
				default = 1000
			},			
		}
	}

	-- render the dialog
	local results = SV:showCustomDialog(form)
  
	-- not cancelled?
	if results.status then
		doScaling(results.answers)
	end

	-- clean up and exit
	SV:finish()
end




-- Return a table of notes containing all the selected notes
function getStartAndEnd(options)

	-- get the selected items from the Editor object
	local selection = SV:getMainEditor():getSelection()
		
	-- get the selected notes from the selected items
	local selectedNotes = selection:getSelectedNotes()
	
	-- exit routine if no notes selected
	if #selectedNotes == 0 then
		return nil
	end

	-- get onset and end of first note
	local theOnset = selectedNotes[1]:getOnset()
	local theEnd = selectedNotes[1]:getEnd()
	
	-- loop through remainder of notes
	for i = 2, #selectedNotes do
		-- get the note
		local theNote = selectedNotes[i]
		
		theOnset = math.min( theOnset, theNote:getOnset() )
		theEnd  = math.max( theEnd, theNote:getEnd() )
	end
	
	-- return the ranges table for each selected note
	return theOnset, theEnd

end

-- Scale the pitch deviation 
function doScaling(options)
	local threshold = 50

	-- get scaling supplied by the user
	local pScale = options.pScale / 100

	-- find the start of the first selected note and the end of the last selected note
	local startBlicks, endBlicks = getStartAndEnd(options)
	
	-- no selected notes?
	if not startBlicks then
			SV:showMessageBox("Warning", "No notes selected.")
		-- exit, doing nothing
		return
	end

	-- get the current group from the main editor {NoteGroupReference}
	local scope = SV:getMainEditor():getCurrentGroup()
	
	-- get the target {NoteGroup}
	local group = scope:getTarget()

	-- get the {Automation} from the group by name
	local amPitchDelta = group:getParameter("pitchDelta")
	
	local controlPoints = amPitchDelta:getPoints(startBlicks, endBlicks)
	
	-- loop through the automation values
	for key, p in ipairs( controlPoints ) do
		-- scale value, but keep in range
		-- local scaled = math.min( p[2] * pScale, 1200 )
        local compressedValue = p[2]

		-- todo: better/correct compression algorithm
		if compressedValue > threshold then
			compressedValue = threshold + (compressedValue - threshold) / pScale
		elseif compressedValue < -threshold then
			compressedValue = -threshold + (compressedValue + threshold) / pScale
		end

		local scaled = math.min(compressedValue, 1200)
		-- replace value with scaled value
		amPitchDelta:add( p[1], scaled )
	end

end