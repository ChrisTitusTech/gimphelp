; 210_shapes_cd-mask.scm
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
; tweaked for GIMP-2.4.x by Paul Sherman 10/24/2007
; Oct 1,2008 removed deprecated foreground function
; 09/27/2010 - added adjustable inner diameter (by %)
;
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
; Make a CD label shape.
; Copyright (C) 2002 by Akkana Peck, akkana@shallowsky.com.
;==============================================================

; Utility to calculate the inner radius
(define (inner-diam diameter mini adj)
	(let* (
	    (j (/ adj 100))
	)
	 (if (= mini TRUE) (* (/ diameter 2.2) j)  (* (/ diameter 3.1) j))
	 ))
	
	
;; Select the CD shape.  Then you can cut, or whatever.
(define (CD-select img diameter mini adj)
    (gimp-image-select-ellipse img CHANNEL-OP-REPLACE 0 0 diameter diameter)
    (let* (
	   (inner (inner-diam diameter mini adj))
	   (offset (/ (- diameter inner) 2))
	   )
      (gimp-image-select-ellipse img CHANNEL-OP-SUBTRACT offset offset inner inner)
      ))

;; Actually make a CD shape, in a solid color.
(define (210-CD-label diameter color mini adj)
  (let* ((old-fg-color (car (gimp-context-get-foreground)))
	 (img (car (gimp-image-new diameter diameter RGB)))
	 (cdlayer (car (gimp-layer-new img diameter diameter
				       RGBA-IMAGE "CD" 100 LAYER-MODE-NORMAL-LEGACY))))
    (gimp-image-undo-disable img)
    (gimp-image-insert-layer img cdlayer 0 -1)
    (gimp-selection-all img)
    (gimp-edit-clear cdlayer)

    (gimp-context-set-foreground color)
    (CD-select img diameter mini adj)
    (gimp-edit-bucket-fill cdlayer FG-BUCKET-FILL LAYER-MODE-NORMAL-LEGACY 100 0 FALSE 0 0)

    ;; Clean up
    (gimp-selection-none img)
    (gimp-image-set-active-layer img cdlayer)
    (gimp-context-set-foreground old-fg-color)
    (gimp-image-undo-enable img)
    (gimp-display-new img)))




;; Cut out a CD shape from the current image.
(define (210-CD-mask img drawable mini adj)
  (gimp-image-undo-group-start img)
  (CD-select img
	     (min (car (gimp-image-width img)) (car (gimp-image-height img)))
	     mini adj)
  (gimp-selection-invert img)
  (gimp-edit-clear drawable)
  (gimp-image-undo-group-end img)
  (gimp-displays-flush)
  )

(script-fu-register "210-CD-label"
		"CD label"
		"CD label shape"
		"Akkana Peck"
		"Akkana Peck"
		"December 2002"
		""
		SF-ADJUSTMENT _"Diameter"      '(800 1 2000 10 50 0 1)
		SF-COLOR      _"Color"         '(174 201 255)
		SF-TOGGLE     _"Mini CD"       FALSE
		SF-ADJUSTMENT _"Adjust Size of Center (%) " '(100 10 300 1 10 0 0)
)
(script-fu-menu-register "210-CD-label" "<Image>/Script-Fu/Create New")

(script-fu-register "210-CD-mask"
	"CD mask"
	"Select a CD label shape out of the current layer"
	"Akkana Peck"
	"Akkana Peck"
	"December 2002"
	"RGB* GRAY* INDEXED*"
	SF-IMAGE      "Image"        0
	SF-DRAWABLE "Drawable" 0
	SF-TOGGLE     _"Mini CD"     FALSE
	SF-ADJUSTMENT _"Adjust Size of Center (%) " '(100 10 300 1 10 0 0)
)
(script-fu-menu-register "210-CD-mask" "<Image>/Script-Fu/Shapes")
