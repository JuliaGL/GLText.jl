export select, update, delete, addchar, newline

function delete(s::UTF8String, r::Range{Int})
	i = chr2ind(s, first(r))
	j = chr2ind(s, last(r))
	s[1:prevind(s, i)] * s[nextind(s, j):end]
end

function delete(s::UTF8String, i::Int)
	if i == 0
		return s
	elseif i == length(s)
		return s[1:end-1]
	end
	I = chr2ind(s, i)
	return s[1:prevind(s, I)] * s[nextind(s, I):end]
end

function delete(event::UnicodeInput, t::TextField)
	i = first(t.selection)
	if length(t.selection) > 0
		t.text = delete(t.text, t.selection)
	else
		t.text = delete(t.text, i)
	end
	t.selection = max(i-1, 0) : i-2
	update(t)
end

function newline(event::UnicodeInput, t::TextField)
	addchar(event, t)
end

addchar(s::UTF8String, char::Char, i::Int) = addchar(s, utf8(string(char)), i)

function addchar(s::UTF8String, char::UTF8String, i::Int)
	if i == 0
		return char * s
	elseif i == length(s)
		return s * char
	end
	I 		= chr2ind(s, i)
	startI 	= nextind(s, I)
	return s[1:I] *char* s[startI:end]
end

function addchar(event::UnicodeInput, t::TextField)
	char = utf8(string(event.char))
	i = first(t.selection)
	if length(t.selection) > 0
		t.text = delete(t.text, t.selection)
		i -= 1
	end
	t.text = addchar(t.text, char, i)
	i = min(i, length(t.text)-1)
	t.selection = i+1:i
	update(t)
end


function update(t::TextField)
	t.newLineIndexes 	= build_line_indexes(t.text)
	defaultStyle 		= Dict{ASCIIString, Any}(["textColor" => Float32[0,0,0,1], "backgroundColor" => Float32[0,0,0,0]])
	t.styles 			= [StyledTextSegment(1:length(t.text), defaultStyle)]
end

function select(event::MouseClicked, t::TextField, f::FontProperties)
	changed, newSelection = select(event.x, event.y, t, f)
	if changed
		t.selection = newSelection
	end
end

function select(event::MouseDragged, t::TextField, f::FontProperties)
	changed, startSelection = select(event.start.x, event.start.y, t, f)
	changed, endSelection 	= select(event.x, event.y, t, f)
	if changed
		t.selection = min(first(startSelection),first(endSelection)):max(first(startSelection),first(endSelection))
	end
end
function select(x::Real, y::Real, t::TextField, f::FontProperties)
	# is x, y inside the textfield?
	if y <= t.y + f.lineHeight && y >= t.y - f.lineHeight * length(t.newLineIndexes)
		#convert into Glyph coordinates
		lineIndex		= max(min(div(t.y + f.lineHeight - y, f.lineHeight) + 1, length(t.newLineIndexes)), 1)
		line 			= t.newLineIndexes[lineIndex]
		xPosCursor::Int	= max(min(div(x - t.x, f.advance) + first(line), last(line)), 0)
		return (true, xPosCursor:xPosCursor-1)
	end
	return (false, 1:0)
end



function select(direction::ASCIIString, t::TextField, f::FontProperties)
	if !isempty(t.text)
		cursor = first(t.selection)
		currentLineIndex, currentLine = findline(t.newLineIndexes, cursor)
		currentLine = first(currentLine)-1:last(currentLine)
		newLine 	= currentLineIndex
		newIndex    = cursor - first(currentLine)
		if direction == "left"
			if newIndex > 0
				newIndex -= 1
			else
				if newLine > 1
					newLine -= 1
					newIndex = length(t.newLineIndexes[newLine])
				end
			end
		elseif direction == "right"
			
			if newIndex < length(currentLine) - 1
				newIndex += 1
			else
				if newLine < length(t.newLineIndexes)
					newLine += 1
					newIndex = 0
				end
			end
		elseif direction == "up"
			if newLine > 1
				newLine -= 1
				newIndex = min(newIndex, length(t.newLineIndexes[newLine]))
			end
		elseif direction == "down"
			if newLine < length(t.newLineIndexes)
				newLine += 1
				newIndex = min(newIndex, length(t.newLineIndexes[newLine]))
			end
		end
		currentLine = t.newLineIndexes[newLine]
		newIndex 	= first(currentLine) - 1 + newIndex
		return newIndex:newIndex-1
	end
	t.selection
end


