; 210_artist_notepaper.scm
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
; Note paper image script  for GIMP 1.2
; Copyright (C) 2001 Iccii <iccii@hotmail.com>
; 
; version 0.1  by Iccii 2001/07/22
;     - Initial relase
; version 0.1a by Iccii 2001/07/26
;     - Add Background color selector
; version 0.1b by Iccii 2001/09/25
;     - Add Cloud option in Background Texture
; version 0.2  by Iccii 2001/10/01 <iccii@hotmail.com>
;     - Changed menu path because this script attempts to PS's filter
;     - Added some code (if selection exists...)
; version 0.2a by Iccii 2001/10/02 <iccii@hotmail.com>
;     - Fixed bug in keeping transparent area
; version 0.2b by Iccii 2001/10/02 <iccii@hotmail.com>
;     - Fixed bug (get error when drawable doesn't have alpha channel)
;==============================================================

(define (210-notepaper
		img
		drawable
		threshold1
		threshold2
		base-color
		bg-color
		bg-type
		inMerge
	)

    (gimp-image-undo-group-start img)
	(if (not (= RGB (car (gimp-image-base-type img))))
			 (gimp-image-convert-rgb img))
			 
  (let* (
	 (width (car (gimp-drawable-width drawable)))
	 (height (car (gimp-drawable-height drawable)))
	 (old-fg (car (gimp-context-get-foreground)))
	 (old-selection (car (gimp-selection-save img)))
	 (layer-copy1 (car (gimp-layer-copy drawable TRUE)))
	 (layer-copy2 (car (gimp-layer-copy drawable TRUE)))
	 (layer-color1 (car (gimp-layer-new img width height RGBA-IMAGE "Color Upper" 100 MULTIPLY-MODE)))
	 (color-mask1 (car (gimp-layer-create-mask layer-color1 ADD-MASK-WHITE )))
	 (layer-color2 (car (gimp-layer-new img width height RGBA-IMAGE "Color Under" 100 MULTIPLY-MODE)))
	 (color-mask2 (car (gimp-layer-create-mask layer-color2 ADD-MASK-WHITE )))
	 (final-layer (car (gimp-layer-copy drawable TRUE)))
         (tmp 0)
	 (invert? FALSE)
        )

    (gimp-selection-none img)
    (gimp-image-insert-layer img layer-copy1 0 -1)
    (gimp-image-insert-layer img layer-copy2 0 -1)
    (gimp-desaturate layer-copy2)
    (gimp-desaturate layer-copy1)
    (cond
      ((eqv? bg-type 0)
         (gimp-edit-fill layer-copy1 2)
         (gimp-brightness-contrast layer-copy1 0 63))
      ((eqv? bg-type 1)
         (gimp-edit-fill layer-copy1 2)
         (plug-in-noisify 1 img layer-copy1 FALSE 1.0 1.0 1.0 0)
         (gimp-brightness-contrast layer-copy1 0 63))
      ((eqv? bg-type 2)
         (plug-in-solid-noise 1 img layer-copy1 FALSE FALSE (rand 65535) 15 16 16)
         (plug-in-edge 1 img layer-copy1 4 1 4)  ; ev: needed too add the type (new plug-in)
         (gimp-brightness-contrast layer-copy1 0 -63))
      ((eqv? bg-type 3)
         (plug-in-plasma 1 img layer-copy1 (rand 65535) 4.0)
         (gimp-desaturate layer-copy1)
         (plug-in-gauss-iir2 1 img layer-copy1 1 1)
         (gimp-brightness-contrast layer-copy1 0 63))	) ; end of cond
    (if (> threshold1 threshold2)
        (begin				;; always (threshold1 < threshold2)
          (set! tmp threshold2)
          (set! threshold2 threshold1)
          (set! threshold1 tmp)
          (set! invert? TRUE))
        (set! invert? FALSE))
    (if (= threshold1 threshold2)
        (gimp-message "Execution error:\n Threshold1 equals to threshold2!")
        (gimp-threshold layer-copy2 threshold1 threshold2))
    (gimp-edit-copy layer-copy2)
    (plug-in-bump-map 1 img layer-copy1 layer-copy1 135 35 3 0 0 0 0 TRUE FALSE 0)
    (plug-in-bump-map 1 img layer-copy1 layer-copy2 135 35 3 0 0 0 0 FALSE invert? 0)
    (gimp-brightness-contrast layer-copy2 127 0)

    (gimp-image-insert-layer img layer-color1 0 -1)
    (gimp-layer-add-mask layer-color1 color-mask1)
    (gimp-context-set-foreground base-color)
    (gimp-drawable-fill layer-color1 FILL-FOREGROUND)
    (gimp-floating-sel-anchor (car (gimp-edit-paste color-mask1 0)))
    (gimp-image-insert-layer img layer-color2 0 -1)
    (gimp-layer-add-mask layer-color2 color-mask2)
    (gimp-context-set-foreground bg-color)
    (gimp-drawable-fill layer-color2 FILL-FOREGROUND)
    (gimp-floating-sel-anchor (car (gimp-edit-paste color-mask2 0)))
    (gimp-invert color-mask2)

    (gimp-layer-set-mode layer-copy2 LAYER-MODE-SCREEN-LEGACY)
    (gimp-layer-set-opacity layer-copy2 75)
    (gimp-image-merge-down img layer-copy2 EXPAND-AS-NECESSARY)
    (gimp-image-merge-down img layer-color1 EXPAND-AS-NECESSARY)
    (set! final-layer (car (gimp-image-merge-down img layer-color2 EXPAND-AS-NECESSARY)))
    (plug-in-bump-map 1 img final-layer final-layer 135 45 3 0 0 0 0 TRUE FALSE 0) ; added ev
    (if (eqv? (car (gimp-drawable-has-alpha drawable)) TRUE)
        (gimp-image-select-item img CHANNEL-OP-REPLACE drawable))
		
	(if (= inMerge TRUE)(gimp-image-merge-visible-layers img EXPAND-AS-NECESSARY))
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
  )
)

(script-fu-register "210-notepaper"
	"Note Paper"
	"Makes image look like a drawing on note paper"
	"Iccii <iccii@hotmail.com>"
	"Iccii"
	"2001, Oct"
	"*"
	SF-IMAGE      "Image"	           0
	SF-DRAWABLE   "Drawable"         0
	SF-ADJUSTMENT "Threshold (Bigger 1<-->255 Smaller)" '(127 0 255 1 10 0 0)
	SF-ADJUSTMENT "Threshold (Bigger 1<-->255 Smaller)" '(255 0 255 1 10 0 0)
	SF-COLOR      "Base Color"       					'(255 255 255)
	SF-COLOR      "Background Color" 					'(223 223 223)
	SF-OPTION     "Background Texture" 					'("Plane" "Sand" "Paper" "Cloud")
	SF-TOGGLE     "Merge layers when complete?" 		FALSE
)
(script-fu-menu-register "210-notepaper" "<Image>/Script-Fu/Artist")
