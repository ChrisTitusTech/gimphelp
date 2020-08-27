; 210_distorts_photocopy.scm
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
; Stamp image script  for GIMP 1.2
; Copyright (C) 2001 Iccii <iccii@hotmail.com>
; 
; --------------------------------------------------------------------
; version 0.1  by Iccii 2001/10/01 <iccii@hotmail.com>
;     - Initial relase
; version 0.1a by Iccii 2001/10/02 <iccii@hotmail.com>
;     - Added Balance option
;     - Fixed bug in keeping transparent area
; version 0.1b by Iccii 2001/10/02 <iccii@hotmail.com>
;     - Fixed bug (get error when drawable doesn't have alpha channel)
;==============================================================


(define (210-photocopy
		img
		drawable
		threshold1
		threshold2
		base-color
		bg-color
		balance
		smooth
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
	 (layer-color1 (car (gimp-layer-new img width height RGBA-IMAGE "Color1" 100 LAYER-MODE-NORMAL-LEGACY)))
	 (layer-color2 (car (gimp-layer-new img width height RGBA-IMAGE "Color2" 100 LAYER-MODE-NORMAL-LEGACY)))
	 (color-mask2 (car (gimp-layer-create-mask layer-color2 ADD-MASK-BLACK)))
	 (channel (car (gimp-channel-new img width height "Color" 50 '(255 0 0))))
	 (tmp 0)
	 (final-layer (car (gimp-layer-new img width height RGBA-IMAGE "Color1" 100 LAYER-MODE-NORMAL-LEGACY)))
        )

    (gimp-image-insert-layer img layer-color1 0 -1)
    (gimp-image-insert-layer img layer-color2 0 -1)
    (gimp-layer-add-mask layer-color2 color-mask2)
    (gimp-image-insert-channel img channel 0 0)

    (gimp-selection-none img)
    (gimp-edit-copy drawable)
    (gimp-floating-sel-anchor (car (gimp-edit-paste channel 0)))
    (if (> threshold1 threshold2)
        (begin				;; always (threshold1 < threshold2)
          (set! tmp threshold2)
          (set! threshold2 threshold1)
          (set! threshold1 tmp)))
    (if (= threshold1 threshold2)
        (gimp-message "Execution error:\n Threshold1 equals to threshold2!")
        (gimp-threshold channel threshold1 threshold2))
    (gimp-edit-copy channel)

    (gimp-context-set-foreground bg-color)
    (gimp-drawable-fill layer-color1 FILL-FOREGROUND)
    (gimp-context-set-foreground base-color)
    (gimp-drawable-fill layer-color2 FILL-FOREGROUND)

	(gimp-image-select-item img CHANNEL-OP-REPLACE channel)
    (if (> balance 0)
      (gimp-selection-grow img balance)
      (begin
        (gimp-selection-invert img)
        (gimp-selection-grow img (abs balance))
        (gimp-selection-invert img)))
    (gimp-selection-feather img smooth)
    (gimp-selection-sharpen img)
    (gimp-edit-fill color-mask2 2)
    (gimp-selection-none img)

    (set! final-layer (car (gimp-image-merge-down img layer-color2 EXPAND-AS-NECESSARY)))
    (if (eqv? (car (gimp-drawable-has-alpha drawable)) TRUE)
        (gimp-image-select-item img CHANNEL-OP-REPLACE drawable))
    (gimp-context-set-foreground old-fg)
	(if (= inMerge TRUE)(gimp-image-merge-visible-layers img EXPAND-AS-NECESSARY))
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
  )
)

(script-fu-register
	"210-photocopy"
	"Photocopy"
	"Creates photocopy image of just 2 colors (BW)"
	"Iccii <iccii@hotmail.com>"
	"Iccii"
	"2001, Oct"
	"*"
	SF-IMAGE      "Image"	           					0
	SF-DRAWABLE   "Drawable"         					0
	SF-ADJUSTMENT "Threshold (Bigger 1<-->255 Smaller)" '(127 0 255 1 10 0 0)
	SF-ADJUSTMENT "Threshold (Bigger 1<-->255 Smaller)" '(255 0 255 1 10 0 0)
	SF-COLOR      "Base Color"       					'(255 255 255)
	SF-COLOR      "Background Color" 					'(  0   0   0)
	SF-ADJUSTMENT "Balance"          					'(0 -100 100 1 10 0 1)
	SF-ADJUSTMENT "Smooth"           					'(5 1 100 1 10 0 1)
	SF-TOGGLE     "Merge layers when complete?" 		FALSE
)
(script-fu-menu-register "210-photocopy" "<Image>/Script-Fu/Distorts")