; 210_artist_pastel.scm
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
; Pastel image script  for GIMP 1.2
; Copyright (C) 2001 Iccii <iccii@hotmail.com>
; 
; This script is based on pastel-windows100.scm
; version 0.1  by Iccii 2001/10/19 <iccii@hotmail.com>
;     - Initial relase
; 
; Reference Book: Windows100% Magazine October, 2001
; Tamagorou's Photograph touching up class No.29
; theme 1 -- Create the Pastel image
;==============================================================

(define (210-artist-pastel
	img		
	drawable	
	Dbord           
	detail		
	length		
	amount		
	angle		
	canvas?	
	inMerge
	)

    (gimp-image-undo-group-start img)
	(if (not (= RGB (car (gimp-image-base-type img))))
			 (gimp-image-convert-rgb img))
			 
  (let* (
	 (Dbordx  (cond ((= Dbord 0) 4) ((= Dbord 1) 0) ((= Dbord 2) 1) ((= Dbord 3) 2) ((= Dbord 4) 3) ((= Dbord 5) 5)  ))
	 (old-selection (car (gimp-selection-save img)))
	 (layer-copy0 (car (gimp-layer-copy drawable TRUE)))
	 (dummy (if (< 0 (car (gimp-layer-get-mask layer-copy0)))
                  (gimp-layer-remove-mask layer-copy0 DISCARD)))
	 (layer-copy1 (car (gimp-layer-copy layer-copy0 TRUE)))
	 (length (if (= length 1) 0 length))
	 (layer-copy2 (car (gimp-layer-copy layer-copy0 TRUE)))
	 (merged-layer (car (gimp-layer-copy drawable TRUE)))
	 (final-layer  (car (gimp-layer-copy drawable TRUE)))
	)

    (gimp-image-insert-layer img layer-copy0 0 -1)
    (gimp-image-insert-layer img layer-copy2 0 -1)
    (gimp-image-insert-layer img layer-copy1 0 -1)

    (plug-in-mblur TRUE img layer-copy0 0 length angle TRUE TRUE);
    (plug-in-mblur TRUE img layer-copy0 0 length (+ angle 180) TRUE TRUE)

    (plug-in-gauss-iir TRUE img layer-copy1 (- 16 detail) TRUE TRUE)
    (plug-in-edge TRUE img layer-copy1 6.0 0 Dbord)  
    (gimp-layer-set-mode layer-copy1 DIVIDE-MODE)
    (set! merged-layer (car (gimp-image-merge-down img layer-copy1 EXPAND-AS-NECESSARY)))
    (gimp-layer-set-mode merged-layer VALUE-MODE)
	
    (if (equal? canvas? TRUE)
        (plug-in-apply-canvas TRUE img merged-layer 0 5))
    (plug-in-unsharp-mask TRUE img layer-copy0 (+ 1 (/ length 5)) amount 0)
    (set! final-layer (car (gimp-image-merge-down img merged-layer EXPAND-AS-NECESSARY)))

    (gimp-image-select-item img CHANNEL-OP-REPLACE old-selection)
    (gimp-edit-copy final-layer)
	(gimp-item-set-name final-layer "Pastel Layer")

    (gimp-image-select-item img CHANNEL-OP-REPLACE old-selection)
    (gimp-image-remove-channel img old-selection)

	(if (= inMerge TRUE)(gimp-image-merge-visible-layers img EXPAND-AS-NECESSARY))
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
  )
)

(script-fu-register "210-artist-pastel"
	"Pastel"
	"Create the Pastel image"
	"Iccii <iccii@hotmail.com>"
	"Iccii"
	"2001, Oct"
	"*"
	SF-IMAGE      "Image"	         					0
	SF-DRAWABLE   "Drawable"       						0
	SF-OPTION     "Edge detection" 						'("Differential" "Sobel" "Prewitt" "Gradient" "Roberts" "Laplace")
	SF-ADJUSTMENT "Detail Level"   						'(12.0 0 15.0 0.1 0.5 1 1)
	SF-ADJUSTMENT "Sketch Length" 						'(5 0 32 1 1 0 1)
	SF-ADJUSTMENT "Sketch Amount" 						'(2.0 0 5.0 0.1 0.5 1 1)
	SF-ADJUSTMENT "Angle"          						'(45 0 180 1 15 0 0)
	SF-TOGGLE     "Add a canvas texture" 				FALSE
	SF-TOGGLE     "Merge layers when complete?" 		FALSE
 )
(script-fu-menu-register "210-artist-pastel" "<Image>/Script-Fu/Artist")
