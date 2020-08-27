; 210_photo_fix-overblown.scm
; last modified/tested by Paul Sherman [gimphelp.org]
; 05/11/2019 on GIMP 2.10.10
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
; 10/15/2010 - restricted to RGB to eliminate errors on indexed and gray
; 02/12/2014 - added strength option as well as flatten.
; 02/14/2014 - convert to RGB if needed
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
; Original information 
; 
; FixOverblown is a script for Gimp
; This script helps fix overblown areas of an image.
; The script is located in "<Image> / Script-Fu / Photo / Fix Overblown"
; Last changed: 2009 June 18
; Copyright (C) 2009 Jonathan Denning <jon@gfxcoder.us>
;==============================================================


(define (210-FixOverblown 
		inImage 
		inLayer 
		strength 
		flatten
	)

	(gimp-image-undo-group-start inImage)
	(if (not (= RGB (car (gimp-image-base-type inImage))))
			 (gimp-image-convert-rgb inImage))
			 
	(let*
		(
			(overlayLayer (car (gimp-layer-copy inLayer FALSE)))
			(mask 0)
		)
		(gimp-image-insert-layer inImage overlayLayer 0 -1)
		(gimp-layer-set-mode overlayLayer OVERLAY-MODE)
		(gimp-item-set-name overlayLayer "Fix Overblown")
		(set! mask (car (gimp-layer-create-mask overlayLayer ADD-COPY-MASK)))
		(gimp-layer-add-mask overlayLayer mask)
		(plug-in-vinvert RUN-NONINTERACTIVE inImage overlayLayer)
		
		(cond ((= strength 1)
			 (gimp-curves-spline mask 0 6 #(0 0 128 0 255 255))
			)
		((= strength 2)
			  (gimp-curves-spline mask 0 8 #(0 0 55 27 176 197 255 255))
			)
		((= strength 3)
			  (gimp-curves-spline mask 0 16 #(0 0 63 73 95 125 127 31 156 188 191 151 223 227 255 255))
			)
		)		
		
		(if (= flatten TRUE)(gimp-image-flatten inImage))
		(gimp-image-undo-group-end inImage)
		(gimp-displays-flush)
		(list overlayLayer)
	)
)

(script-fu-register "210-FixOverblown"
	"Fix Overblown"
	"Helps fix overblown areas"
	"Jon Denning <jon@gfxcoder.us>"
	"Jon Denning"
	"2009-06-18"
	"*"
	SF-IMAGE	  "Image"	  				0
	SF-DRAWABLE	  "Layer"					0
	SF-ADJUSTMENT "Adjustment Strength" 	'(1 1 3 1 1 0 0)
	SF-TOGGLE     "Flatten image" 			FALSE
)
(script-fu-menu-register "210-FixOverblown" "<Image>/Script-Fu/Photo")
