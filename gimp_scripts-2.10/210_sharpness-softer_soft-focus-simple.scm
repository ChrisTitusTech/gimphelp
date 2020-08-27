; 210_sharpness-softer_soft-focus-simple.scm
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
; Soft focus script  for GIMP 1.2
; Copyright (C) 2001 Iccii <iccii@hotmail.com>
; --------------------------------------------------------------------
; version 0.1  by Iccii 2001/07/22
;     - Initial relase
;==============================================================


(define (210-soft-focus-simple
		img
		drawable
		blur
		inMerge
	)
	
	(gimp-image-undo-group-start img)
	(define indexed (car (gimp-drawable-is-indexed drawable)))
	(if (= indexed TRUE)(gimp-image-convert-rgb img))

  (let* (
		(layer-copy (car (gimp-layer-copy drawable TRUE)))
		(layer-mask (car (gimp-layer-create-mask layer-copy ADD-MASK-WHITE )))
		)
		
		(gimp-image-insert-layer img layer-copy 0 -1)
		(gimp-layer-add-mask layer-copy layer-mask)
		(gimp-edit-copy layer-copy)
		(gimp-floating-sel-anchor (car (gimp-edit-paste layer-mask 0)))
		(gimp-layer-remove-mask layer-copy MASK-APPLY)
		(plug-in-gauss-iir2 1 img layer-copy blur blur)
		(gimp-layer-set-opacity layer-copy 80)
		(gimp-layer-set-mode layer-copy LAYER-MODE-SCREEN-LEGACY)
		(if (= inMerge TRUE)(gimp-image-merge-visible-layers img EXPAND-AS-NECESSARY))
		(gimp-image-undo-group-end img)
		(gimp-displays-flush)
	)
)

(script-fu-register
	"210-soft-focus-simple"
	"Soft Focus Simple"
	"Soft focus effect"
	"Iccii <iccii@hotmail.com>"
	"Iccii"
	"2001, Jul"
	"*"
	SF-IMAGE      "Image"							0
	SF-DRAWABLE   "Drawable"						0
	SF-ADJUSTMENT "Blur Amount"  					'(10 1 100 1 10 0 0)
	SF-TOGGLE     "Merge layers when complete?" 	FALSE
)
(script-fu-menu-register "210-soft-focus-simple" "<Image>/Script-Fu/Sharpness/Softer")
