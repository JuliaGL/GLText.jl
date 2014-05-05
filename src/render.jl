import GLUtil.render

function render(text::String, cursor::TextCursor, font::GLFont, displayableAray::Shape)
	for char in text
        if char == '\t'
        	cursor.x += font.properties.advance * 3
        elseif char == '\r' || char == '\n'
        	cursor.y -= font.properties.lineHeight
         	cursor.x = cursor.intend
        else
            if cursor.x <= displayableAray.x + displayableAray.w
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

	#render selection
	startLine, line = findline(t.newLineIndexes, first(t.selection))
	xPosition = first(t.selection) - first(line)
	cursorX = t.x + (xPosition * font.properties.advance)
	cursorY = t.y - ((startLine-1) * font.properties.lineHeight)
	selectionStart =  TextCursor(cursorX, cursorY, cursorX)
	render(selectionStyle, font.gl.program.id)
	if length(t.selection) < 1
		render("|", TextCursor(cursorX + (font.properties.advance / 2f0), cursorY, t.x), font, displayableAray)
	else
		#naive approach, just render selection as a blank string with backgroundcolor
		a = chr2ind(t.text, max(first(t.selection), 1))
		b = chr2ind(t.text, min(last(t.selection), length(t.text)))
		selectionString = map(x -> (x == '\r' || x == '\n') ? x : ' ', t.text[a:b])
		render(selectionString, TextCursor(cursorX, cursorY, t.x), font, displayableAray)
	end

	#render text	
	startCursor = TextCursor(t.x, t.y, t.x)
	if !isempty(t.text)
		for elem in t.styles
			if startCursor.y  <= displayableAray.y + displayableAray.h
				# assert range is in text range
				segment = intersect(elem.segment, 1:(length(t.text) + 1))
				if first(segment) > last(segment)
					error("segment not in textrange! segment: ", segment, " length(text): ", length(t.text), " stylesegment: ", elem.segment)
				end

				render(elem.style, font.gl.program.id)
				a = chr2ind(t.text, first(segment))
				b = chr2ind(t.text, last(segment))
				render(t.text[a:b], startCursor, font, displayableAray)
			end
		end
	end
end



