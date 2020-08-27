; 210_texture_stained-glass.scm
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
; Stained glass script  for GIMP 1.2
; Copyright (C) 2001 Iccii <iccii@hotmail.com>
; 
; You'll find that this script isn't "real" staind glass effect
; Plese tell me how to create if you know more realistic effect
; This script is only applying the mosac plugin ;-(
; --> Eddy Verlinden : tile spacing bigger and light-direction set to 270 + added copy-layer3 in screenmode
; --------------------------------------------------------------------
; version 0.1  by Iccii 2001/07/21
;     - Initial relase
; this version 9 april 2006
;==============================================================


(define (210-stained-glass
		img
		drawable
		tile-size
	)
  (gimp-image-undo-group-start img)
  (if (not (= RGB (car (gimp-image-base-type img))))(gimp-image-convert-rgb img))  
  (plug-in-mosaic 1 img drawable tile-size 1 2.5 0.65 0 270.0 0.25 TRUE TRUE 1 0 0)
  (let* (
		(copy-layer1 (car (gimp-layer-copy drawable 1)))
		(copy-layer2 (car (gimp-layer-copy drawable 1)))
		(copy-layer3 (car (gimp-layer-copy drawable 1)))
		)
		(gimp-image-insert-layer img copy-layer1 0 -1)
		(gimp-image-insert-layer img copy-layer2 0 -1)
		(gimp-layer-set-mode copy-layer1 OVERLAY-MODE)
		(gimp-layer-set-mode copy-layer2 OVERLAY-MODE)
		(gimp-layer-set-opacity copy-layer1 100)
		(gimp-layer-set-opacity copy-layer2 100)
		(gimp-image-merge-down img (car (gimp-image-merge-down img copy-layer2 EXPAND-AS-NECESSARY)) EXPAND-AS-NECESSARY)
		(gimp-image-insert-layer img copy-layer3 0 -1)
		(gimp-layer-set-mode copy-layer3 SCREEN-MODE)
		(gimp-layer-set-opacity copy-layer3 100)
		(gimp-image-merge-down img copy-layer3 EXPAND-AS-NECESSARY)
    )
  (gimp-image-undo-group-end img)
  (gimp-displays-flush)
)
(script-fu-register "210-stained-glass"
	"Stained Glass"
	"Create stained glass image"
	"Iccii <iccii@hotmail.com>"
	"Iccii"
	"2001, Jul"
	"*"
	SF-IMAGE      "Image"					0
	SF-DRAWABLE   "Drawable"				0
	SF-ADJUSTMENT "Cell Size (pixels)"   	'(18 5 100 1 10 0 1)
)
(script-fu-menu-register "210-stained-glass" "<Image>/Script-Fu/Texture")
