; 210_texture_patchwork.scm
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
; Patchwork effect script  for GIMP 1.2
; Copyright (C) 2001 Iccii <iccii@hotmail.com>
;==============================================================


(define (210-patchwork
		img
		drawable
		type
		size
		depth
		angle
		level
	)

  (gimp-image-undo-group-start img)
  (if (not (= RGB (car (gimp-image-base-type img))))
			 (gimp-image-convert-rgb img))
			 
  (let* (
		 (width (car (gimp-drawable-width drawable)))
		 (height (car (gimp-drawable-height drawable)))
		 (old-fg (car (gimp-context-get-foreground)))
		 (old-selection (car (gimp-selection-save img)))
		 (tmp-layer1 (car (gimp-layer-copy drawable TRUE)))
		 (tmp-layer2 (car (gimp-layer-copy drawable TRUE)))
		 (final-layer (car (gimp-layer-copy drawable TRUE)))
		 (depth-color (list depth depth depth))
		 (radius (- (/ size 2) 1))
		 (blur   (cond ((= type 0) 1) ((= type 1) 0) ((= type 2) 0) ((= type 3) 0)))
		 (hwidth (cond ((= type 0) 1) ((= type 1) 0) ((= type 2) 2) ((= type 3) 1)))
		 (vwidth (cond ((= type 0) 1) ((= type 1) 2) ((= type 2) 0) ((= type 3) 1)))
		) ; end variable definition

		(gimp-image-insert-layer img tmp-layer1 0 -1)
		(gimp-image-insert-layer img tmp-layer2 0 -1)
		(gimp-desaturate tmp-layer2)
		(if (eqv? (car (gimp-selection-is-empty img)) FALSE)
			(begin
			  (gimp-selection-invert img)
			  (gimp-edit-clear tmp-layer2)
			  (gimp-selection-invert img)))

		(plug-in-noisify 1 img tmp-layer2 FALSE 1.0 1.0 1.0 0)
		(plug-in-pixelize 1 img tmp-layer1 size)
		(plug-in-pixelize 1 img tmp-layer2 size)
		(gimp-levels tmp-layer2 HISTOGRAM-LUMINANCE (+ 32 (* level 2)) (- 223 (* level 2)) 1.0 0 255)
		(plug-in-grid 1 img tmp-layer2 hwidth size 0 depth-color 255
								   vwidth size 0 depth-color 255
									   0      0    0 '(0 0 0)    255)
									   
		(if (= type 3)
			(let* ((selection-channel (car (gimp-selection-save img))))
			  (gimp-context-set-foreground depth-color)
			  (gimp-by-color-select tmp-layer2 depth-color 0 REPLACE FALSE 0 0 FALSE)
			  (gimp-selection-grow img radius)
			  (gimp-selection-shrink img radius)
			  (gimp-edit-fill tmp-layer2 FG-IMAGE-FILL)
			  (gimp-image-select-item img CHANNEL-OP-REPLACE selection-channel)
			  (gimp-image-remove-channel img selection-channel)
			  (gimp-image-set-active-layer img tmp-layer2)	;; why do I need this line?
			  (gimp-context-set-foreground old-fg)))
		(plug-in-gauss-iir2 1 img tmp-layer2 (+ blur hwidth) (+ blur vwidth))
		(plug-in-bump-map 1 img tmp-layer2 tmp-layer2 angle
						  30 (+ 4 level) 0 0 0 0 TRUE FALSE 0)

		(gimp-layer-set-mode tmp-layer2 OVERLAY-MODE)
		(gimp-layer-set-opacity tmp-layer2 (+ level 84))
		(set! final-layer (car (gimp-image-merge-down img tmp-layer2 EXPAND-AS-NECESSARY)))
		(if (eqv? (car (gimp-drawable-has-alpha drawable)) TRUE)
			(gimp-image-select-item img CHANNEL-OP-REPLACE drawable))
		;    (if (eqv? (car (gimp-selection-is-empty img)) FALSE)
		;        (begin
		;          (gimp-selection-invert img)
		;          (gimp-edit-clear final-layer)))
		(gimp-image-select-item img CHANNEL-OP-REPLACE old-selection)
		(gimp-edit-copy final-layer)
		(gimp-image-remove-layer img final-layer)
		(gimp-floating-sel-anchor (car (gimp-edit-paste drawable 0)))
		(gimp-image-select-item img CHANNEL-OP-REPLACE old-selection)
		(gimp-image-remove-channel img old-selection)
		(gimp-context-set-foreground old-fg)

    ) ; end of let*
	(gimp-image-undo-group-end img)
    (gimp-displays-flush)
)

(script-fu-register "210-patchwork"
	"Patchwork"
	"Creates patchwork image, which simulates Photoshop's Patchwork filter"
	"Iccii <iccii@hotmail.com>"
	"Iccii"
	"2001, Oct"
	"*"
	SF-IMAGE       "Image"			0
	SF-DRAWABLE    "Drawable"		0
	SF-OPTION      "Tile Type"    	'("Normal" "Horizontal" "Vertical" "Round")
	SF-ADJUSTMENT  "Block Size"		'(10 2 127 1 10 0 1)
	SF-ADJUSTMENT  "Depth"			'(127 0 255 1 10 0 1)
	SF-ADJUSTMENT  "Angle"			'(135 0 360 1 10 0 0)
	SF-ADJUSTMENT  "Level"			'(8 0 16 1 2 0 0)
)
(script-fu-menu-register "210-patchwork" "<Image>/Script-Fu/Texture")
