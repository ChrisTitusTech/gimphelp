; 210_sketch_synthetic-edges.scm
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
; 02/15/2014 - accommodate indexed images, 
; added option to merge layers upon completion
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
; version 0.1  by Jeff Trefftzs <trefftzs@tcsn.net>
;     - Initial relase
; version 0.2 Raymond Ostertag <r.ostertag@caramail.com>
;     - ported to Gimp 2.0, changed menu entry
;==============================================================


(define (210-synthetic-edges 
		inImage 
		inLayer
		inWeight 
		inMono
		inMerge
	)
	
	(gimp-image-undo-group-start inImage)
	(define indexed (car (gimp-drawable-is-indexed inLayer)))
	(if (= indexed TRUE)(gimp-image-convert-rgb inImage))
	
  (let*
      (
       (EdgeLayer (car (gimp-layer-copy inLayer TRUE)))
       (tmpLayer (car (gimp-layer-copy inLayer TRUE)))
       )
    (gimp-image-insert-layer inImage EdgeLayer 0 -1)
    (gimp-item-set-name EdgeLayer "Synthetic Edges")

    ; Real work goes in here
    (gimp-image-insert-layer inImage tmpLayer 0 -1)
    (gimp-layer-set-mode tmpLayer DIVIDE-MODE)
    (plug-in-gauss-iir TRUE inImage tmpLayer inWeight TRUE TRUE)
    (set! EdgeLayer 
	  (car (gimp-image-merge-down inImage tmpLayer
				      EXPAND-AS-NECESSARY)))
    (gimp-levels EdgeLayer HISTOGRAM-VALUE
		 (- 255 inWeight) ; low input
		 255		; high input
		 1.0		; gamma
		 0 255)		; output 
		 
    (gimp-layer-set-mode EdgeLayer LAYER-MODE-NORMAL-LEGACY)
    (if (= inMono TRUE)
	(gimp-desaturate EdgeLayer)
	)
	
    (gimp-image-set-active-layer inImage inLayer)
	(if (= inMerge TRUE)(gimp-image-merge-visible-layers inImage EXPAND-AS-NECESSARY))
    (gimp-image-undo-group-end inImage)
    (gimp-displays-flush)
    )
  )

(script-fu-register "210-synthetic-edges"
	"Synthetic Edges"
	"Synthetic edge detection merges a blurred copy in DIVIDE-MODE with a copy of the original image.  The edges are then enhanced with levels (255 - blur radius) becomes the lower limit for input."
	"Jeff Trefftzs"
	"Copyright 2002, Jeff Trefftzs"
	"January 12, 2002"
	"*"
	SF-IMAGE 		"The Image" 								0
	SF-DRAWABLE 	"The Layer" 								0
	SF-ADJUSTMENT 	"Line Weight (Fine) 1 <----> 128 (Thick)" 	'(5 1 128 1 8 0 1)
	SF-TOGGLE 		"Monochrome?" 								FALSE
	SF-TOGGLE     	"Merge layers when complete?" 				TRUE
)
(script-fu-menu-register "210-synthetic-edges" "<Image>/Script-Fu/Sketch")
