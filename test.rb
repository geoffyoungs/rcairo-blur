require 'rubygems'
require 'cairo'
require 'pango'
$: << 'x86_64-linux'
require 'rcairoblur'

def grad_vl(y1,y2,col1=nil,col2=nil,&block)
	pattern= Cairo::LinearPattern.new(0, y1, 0, y2)
	{0=>col1,1=>col2}.each do |offset, col|
		next unless col
		case col.size
		when 3
			pattern.add_color_stop_rgb(offset, *col)
		when 4
			pattern.add_color_stop_rgba(offset, *col)
		end
	end
	yield(pattern) if block_given?
	pattern
end

width, height = 500, 200

surface = Cairo::ImageSurface.new(:argb32, width, height)
cr = Cairo::Context.new(surface)

cr.save do 
	cr.set_operator(Cairo::OPERATOR_CLEAR)
	cr.set_source_rgba(1.0, 1.0, 1.0, 0)
	cr.paint(1.0)
end

cr.translate(50,50)

text = "Birthday"
font = Pango::FontDescription.new("Droid Sans Bold 56")


layout = cr.create_pango_layout
layout.font_description = font
layout.set_text(text)


ink, log = layout.get_pixel_extents

cr.set_source(grad_vl(ink.y, ink.height, [0.2,0.6,1.0], [0,0.2,0.5]))
cr.show_pango_layout(layout)

Cairo.blur_image_surface(surface, 4)

cr.translate(-2,-2)
cr.set_source_rgb(1,1,1)
cr.show_pango_layout(layout)

surface.write_to_png('test-out.png')

