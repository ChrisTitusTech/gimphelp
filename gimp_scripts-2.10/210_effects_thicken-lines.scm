; 210_effects_thicken-lines.scm
; last modified/tested by Paul Sherman [gimphelp.org]
; 10/13/2018 on GIMP 2.10.6
;==================================================
;
; Installation:
; This script should be placed in the user or system-wide script folder.
;
;	Windows 7/10
;	C:\Program Files\GIMP 2\share\gimp\2.0\scripts
;	or
;	C:\Users\YOUR-NAME\AppData\Roaming\GIMP\2.10\scripts
;	
;    
;	Linux
;	/home/yourname/.config/GIMP/2.10/scripts  
;	or
;	Linux system-wide
;	/usr/share/gimp/2.0/scripts
;
;==================================================
;
; LICENSE
;
;    This program is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.
;
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with this program.  If not, see <http://www.gnu.org/licenses/>.
;
;==============================================================

(define (210-thicken-lines
		inImage 
		inLayer 
		Strength
		)
	(gimp-image-undo-group-start inImage)
	(if (= Strength 0)(plug-in-vpropagate TRUE inImage inLayer 1 255 0.15 15 0 255))
	(if (= Strength 1)(plug-in-vpropagate TRUE inImage inLayer 1 255 0.25 15 0 255))
	(if (= Strength 2)(plug-in-vpropagate TRUE inImage inLayer 1 255 0.5 15 0 255))
	(plug-in-unsharp-mask 1 inImage inLayer 1.1 0.15 0)
	(gimp-image-undo-group-end inImage)
	(gimp-displays-flush)
)
(script-fu-register "210-thicken-lines"
	"Thicken Lines"
	"Thickens lines/increases contrast in lineart"
	"Paul Sherman <psherman2001@gmail.com>"
	"Paul Sherman"
	"2018, Oct"
	"*"
	SF-IMAGE      "Image"	           0
	SF-DRAWABLE   "Drawable"         0
	SF-OPTION     "Strength"   '("Normal" "Stronger" "Strongest")
)
(script-fu-menu-register "210-thicken-lines" "<Image>/Script-Fu/Effects")
