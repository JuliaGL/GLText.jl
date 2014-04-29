import GLUtil.render

function render(text::String, cursor::TextCursor, font::GLFont, displayableAray::Shape)
	for char in text
        if char == '\t'
        	cursor.x += font.properties.advance * 3
        elseif char == '\r' || char == '\n'
        	cursor.y -= font.properties.lineHeight
         	cursor.x = cursor.intend
        else
            if inside(displayableAray, cursor.x, cursor.y)
                render("charOffset", [cursor.x, cursor.y], font.gl.program.id)
                #in the GLBuffer for the text triangle data, there are six verts per char
    			glDrawArrays(GL_TRIANGLES, int(char) * 6, 6)
            end
            cursor.x += font.properties.advance
        end
    end
end

global selectionStyle = Dict{ASCIIString, Any}(["textColor" => Float32[0,0,0,0], "backgroundColor" => Float32[0.02,0.8,0.01,0.2]])

function render(t::TextField, font::GLFont, displayableAray::Shape = Rectangle(0, 0, 9999999,9999999))
	render(font.gl)

	startLine, line = findline(t.newLineIndexes, first(t.selection))

	xPosition = first(t.selection) - first(line)
	cursorX = t.x + (xPosition * font.properties.advance)
	cursorY = t.y - ((startLine-1) * font.properties.lineHeight)
	selectionStart =  TextCursor(cursorX, cursorY, 0)
	render(selectionStyle, font.gl.program.id)
	if length(t.selection) < 1
		render("|", TextCursor(cursorX + (font.properties.advance / 2f0), cursorY, 0), font, displayableAray)
	else
		#first approach, just render selection as a blank string with backgroundcolor
		selectionString = map(x -> (x == '\r' || x == '\n') ? x : ' ', t.text[chr2ind(t.text, t.selection.start):chr2ind(t.text, last(t.selection))])
		render(selectionString, TextCursor(cursorX, cursorY, 0), font, displayableAray)
	end
	startCursor = TextCursor(t.x, t.y, t.x)

	for elem in t.styles
		# assert range is in text range
		segment = intersect(elem.segment, 1:length(t.text))
		@assert segment.start <= last(segment)
		
		render(elem.style, font.gl.program.id)

		render(t.text[chr2ind(t.text, segment.start):chr2ind(t.text, last(segment))], startCursor, font, displayableAray)
	end
end



