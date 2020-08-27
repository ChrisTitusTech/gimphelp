; 210_photo_pastel-portrait.scm
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
; by Paul Sherman
; based upon iccii-pastel-image.scm
; which was....
; based on pastel-windows100.scm
; --------------------------------------------------------------------
;  Reference Book
;  Windows100% Magazine October, 2001
;  Tamagorou's Photograph touching up class No.29
;  theme 1 -- Create the Pastel image
; --------------------------------------------------------------------
;   - Changelog -
; version 0.1  by Iccii 2001/10/19 <iccii@hotmail.com>
;     - Initial relase
; version 0.2 by Tim Jacobs 2004/04/15
;     - Modified to work for GIMP 2.x
;==============================================================



(define (210-pastel-portrait
            img
            drawable
            detail
            length
            amount
            angle
			flatten
    )

  (gimp-image-undo-group-start img)
  (if (not (= RGB (car (gimp-image-base-type img))))
			 (gimp-image-convert-rgb img))
  (let* (
	 (layer-orig (car (gimp-layer-copy drawable TRUE)))
     (old-selection (car (gimp-selection-save img)))
     (layer-copy0 (car (gimp-layer-copy drawable TRUE)))
         (dummy (gimp-image-add-layer img layer-copy0 -1))
     (dummy (if (< 0 (car (gimp-layer-get-mask layer-copy0)))
                  (gimp-layer-remove-mask layer-copy0 MASK-DISCARD)))
     (layer-copy1 (car (gimp-layer-copy layer-copy0 TRUE)))
     (length (if (= length 1) 0 length))
     (dummy (begin
              (plug-in-mblur TRUE img layer-copy0 0 length angle 0 0 )
              (plug-in-mblur TRUE img layer-copy0 0 length (+ angle 180) 0 0 ) ))
     (layer-copy2 (car (gimp-layer-copy layer-copy0 TRUE)))
     (marged-layer 0)
     (final-layer 0)
	 (new-layer 0)
    )

    (gimp-image-add-layer img layer-copy2 -1)
    (gimp-image-add-layer img layer-copy1 -1)
	(gimp-image-add-layer img layer-orig -1)
	
    (plug-in-gauss-iir TRUE img layer-copy1 (- 16 detail) TRUE TRUE)
    (plug-in-edge TRUE img layer-copy1 10.0 1 0)
    (gimp-layer-set-mode layer-copy1 DIVIDE-MODE)
    (set! marged-layer (car (gimp-image-merge-down img layer-copy1 EXPAND-AS-NECESSARY)))
    (gimp-layer-set-mode marged-layer VALUE-MODE)

    (plug-in-unsharp-mask TRUE img layer-copy0 (+ 1 (/ length 5)) amount 0)
    (set! final-layer (car (gimp-image-merge-down img marged-layer EXPAND-AS-NECESSARY)))
	
	
    (gimp-selection-load old-selection)
    (gimp-edit-copy final-layer)
    (gimp-image-remove-layer img final-layer)
    (gimp-floating-sel-anchor (car (gimp-edit-paste drawable 0)))
    (gimp-selection-load old-selection)
    (gimp-image-remove-channel img old-selection)
	
	(set! new-layer (car(gimp-image-get-active-layer img)))
	(gimp-layer-set-opacity new-layer 30)	
	(gimp-item-set-name new-layer "Pastel Layer")
	
	(gimp-image-lower-layer img layer-orig)
	(gimp-item-set-name layer-orig "Original Image")

    (if (= flatten TRUE)
        (gimp-image-flatten img)
    )

    ;; Clean up
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
  )
)

(script-fu-register
  "210-pastel-portrait"
  "Pastel Portrait"
  "Creates a slightly Painterly version of photo"
  "Paul Sherman <psherman2001@gmail.com>"
  "Paul Sherman"
  "Feb 2014"
  "*"
  SF-IMAGE      "Image"         0
  SF-DRAWABLE   "Drawable"      0
  SF-ADJUSTMENT "Detail Level"  '(12.0 0 15.0 0.1 0.5 1 1)
  SF-ADJUSTMENT "Sketch Length" '(10 0 32 1 1 0 1)
  SF-ADJUSTMENT "Sketch Amount" '(1.0 0 5.0 0.1 0.5 1 1)
  SF-ADJUSTMENT "Angle"         '(45 0 180 1 15 0 0)
  SF-TOGGLE     "Flatten image"  FALSE
 )
(script-fu-menu-register "210-pastel-portrait" "<Image>/Script-Fu/Photo")