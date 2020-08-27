; 210_create-new_glossy-orb.scm
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
;Author: Mike Pippin
;Version: 1.0
;Homepage: Split-visionz.net
;==============================================================


(define (210_glossyorb 
		myradius 
		bgcolor
		flatten
	)

	(let* (
		(buffer (+ (* myradius 0.04) 5))
		(image (car (gimp-image-new (+ buffer myradius) (+ buffer myradius) RGB)))
		(shadow-layer (car (gimp-layer-new image myradius myradius RGBA-IMAGE "shadowLayer" 100 LAYER-MODE-NORMAL-LEGACY)))
		(grad-layer (car (gimp-layer-new image myradius myradius RGBA-IMAGE "gradLayer" 100 LAYER-MODE-NORMAL-LEGACY)))
		(dark-layer (car (gimp-layer-new image myradius myradius RGBA-IMAGE "darkLayer" 100 LAYER-MODE-NORMAL-LEGACY)))	
		(hl-layer (car (gimp-layer-new image myradius myradius RGBA-IMAGE "hlLayer" 100 LAYER-MODE-NORMAL-LEGACY)))
		(shrink-size (* myradius 0.01))
		(hl-width (* myradius 0.7))
		(hl-height (* myradius 0.6))
		(offset (- myradius hl-width))
		(hl-x (/ offset 2));(/ (- myradius hl-width 2)))
		(hl-y 0)
		(quarterheight (/ myradius 4))
		(blur-radius (* myradius 0.1))
	);end variable defines

	;//////////////////////////////////////
	;create layers we'll need
	(gimp-image-add-layer image shadow-layer 0)
	(gimp-edit-clear shadow-layer)

	(gimp-image-add-layer image grad-layer 0)
	(gimp-edit-clear grad-layer)

	(gimp-image-add-layer image dark-layer 0)
	(gimp-edit-clear dark-layer)

	(gimp-image-add-layer image hl-layer 0)
	(gimp-edit-clear hl-layer)

	;//////////////////////////////////////
	;offset layers to sync with later offset of drawn ellipse
	(gimp-layer-set-offsets hl-layer 3 3)
	(gimp-layer-set-offsets dark-layer 3 3)
	(gimp-layer-set-offsets grad-layer 3 3)
	(gimp-layer-set-offsets shadow-layer 3 3)

	;//////////////////////////////////////
	;shadow layer
	(gimp-ellipse-select image 3 3 myradius myradius 0 TRUE FALSE 0)
	(gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(0 0 0))
	(gimp-edit-bucket-fill shadow-layer 0 0 100 0 FALSE 0 0)

	;//////////////////////////////////////
	;gradient layer
	(gimp-context-set-background bgcolor)
	;(gimp-context-set-background '(255 255 255))
	(gimp-image-set-active-layer image grad-layer)
	(gimp-edit-blend grad-layer 0  0 0 100 0 0 FALSE FALSE 0 0 TRUE 0 (- 1(/ myradius 2)) 0 myradius)

	;//////////////////////////////////////
	; highlight layer
	(gimp-image-set-active-layer image hl-layer)
	(gimp-context-set-foreground '(255 255 255))
	(gimp-edit-blend hl-layer 2  0 0 100 0 0 FALSE FALSE 0 0 TRUE 0 0 0 myradius )

	;//////////////////////////////
	;dark layer
	(gimp-image-set-active-layer image dark-layer)
	(gimp-context-set-foreground '(255 255 255))
	(gimp-context-set-background '(255 255 255))
	(gimp-edit-bucket-fill dark-layer 0 0 100 0 FALSE 0 0)
	(gimp-selection-grow image shrink-size )
	(gimp-selection-feather image (/ myradius 4))
	(gimp-edit-cut dark-layer)

	;Shrink highlight layer and move to proper position
	(gimp-image-set-active-layer image hl-layer)
	(gimp-layer-scale hl-layer hl-width hl-height FALSE)
	(gimp-layer-translate hl-layer hl-x hl-y)
	(gimp-layer-set-opacity hl-layer 75)
	(gimp-layer-resize-to-image-size hl-layer)

	;Move and blur shadow layer
	(gimp-image-set-active-layer image shadow-layer)
	(gimp-layer-translate shadow-layer (/ hl-x 7) (/ hl-x 5))
	(gimp-layer-resize-to-image-size shadow-layer)
	(plug-in-gauss-rle 1 image shadow-layer blur-radius 2 2)
	(gimp-layer-set-opacity shadow-layer 70)

	(gimp-display-new image)
	(gimp-displays-flush)
	(gimp-image-clean-all image)
	(gimp-selection-none image)
	(gimp-image-merge-visible-layers image 0)

    (if (= flatten TRUE)
        (gimp-image-flatten image)
    )

	); end LET scope
); end function DEFINE


(script-fu-register "210_glossyorb"
	"Glossy Orb"
	"Creates a Web2.0 style gloss orb"
	"Mike Pippin"
	"copyright 2007-8, Mike Pippin"
	"Dec 2007"
	""
	SF-ADJUSTMENT 	"Orb Radius" 						'(100 32 2000 1 10 0 1)
	SF-COLOR      	"Background Color" 					'(38 57 200)	
	SF-TOGGLE     	"Flatten image when complete?"    	FALSE	
)
(script-fu-menu-register "210_glossyorb" "<Image>/Script-Fu/Create New")
