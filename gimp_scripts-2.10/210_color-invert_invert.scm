; 210_color-invert_invert.scm
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
; Lasm's color invert effect  script  for GIMP 2.4
; Original author: lasm <lasm@rocketmail.com>
;
; Author statement:
;
;;; Welcome to the Grandmother's Light Invert
;;; Dedication - to my mother (1917-2002) in loving memory
;;; Grandmother's Color Invert::
;;; This effect is fully reversible.
;;; Another quality script brought to you by  the Grandmother Coffee House production.
;;; Created in the Special Palindrome Day of the century 20022002
;==============================================================

(define (210-color-invert 
		invert-type 
		img 
		inLayer
	)

	(gimp-image-undo-group-start img)
	(if (not (= RGB (car (gimp-image-base-type img))))
			 (gimp-image-convert-rgb img))

(define (copylayer layer layername)
  (let* ((new (car(gimp-layer-copy layer 1)))) ; Add an alpha channel
  (gimp-item-set-name new layername)
  new
  )
)

(let*
	((invert-layer (copylayer inLayer "Invert Layer")))
	(gimp-image-insert-layer img invert-layer 0 -1)
	(if (= invert-type 0)
	(gimp-invert inLayer)
	(gimp-invert invert-layer))
	(gimp-layer-set-mode invert-layer
	(cond
		((= invert-type 0) HUE-MODE)
		((= invert-type 1) HUE-MODE)
		((= invert-type 2) LAYER-MODE-NORMAL-LEGACY)
		((= invert-type 3) DARKEN-ONLY-MODE)
		((= invert-type 4) VALUE-MODE)))

	(gimp-item-set-name (car (gimp-image-merge-down img invert-layer EXPAND-AS-NECESSARY))
	(cond
		((= invert-type 0) "GM Light Invert")
		((= invert-type 1) "GM Color Only Invert")
		((= invert-type 2) "GM Simple Color Invert")
		((= invert-type 3) "GM Solarize")
		((= invert-type 4) "GM Vivid V-Invert")))

  (gimp-image-undo-group-end img)
  (gimp-displays-flush)

  )
)

(script-fu-register "210-color-invert 0"
	"Light Invert"
	"Version 2.0a\nLasm's color invert effect. This turns the photo into a photo negative without changing the colors and the effect is reversible.\n\nCycle through all 3 effects in random order and you will arrive back to the original image"
	"lasm"
	"Copyright 2002-2005, lasm"
	"February 20, 2002"
	"*"
	SF-IMAGE "The Image"      0
	SF-DRAWABLE "The Layer" 0
)
(script-fu-menu-register "210-color-invert 0" "<Image>/Script-Fu/Color/Invert")

(script-fu-register "210-color-invert 1"
 	"Color Only Invert"
	"Version 2.0a\nLasm's color invert effect. This inverts color only, leaving brightness alone on any RGB image and the effect is reversible.\n\nCycle through all 3 effects in random order and you will arrive back to the original image"
	"lasm"
	"Copyright 2002-2005, lasm"
	"February 20, 2002"
	"*"
	SF-IMAGE "The Image"      0
	SF-DRAWABLE "The Layer" 0
)
(script-fu-menu-register "210-color-invert 1" "<Image>/Script-Fu/Color/Invert")

(script-fu-register "210-color-invert 2"
	"Simple Color Invert"
	"Version 2.0a\nLasm's color invert effect. This is vanilla color invert and the effect is reversible. \n\nCycle through all 3 effects in random order and you will arrive back to the original image"
	"lasm"
	"Copyright 2002-2005, lasm"
	"February 20, 2002"
	"*"
	SF-IMAGE "The Image"      0
	SF-DRAWABLE "The Layer" 0
)
(script-fu-menu-register "210-color-invert 2" "<Image>/Script-Fu/Color/Invert")

(script-fu-register "210-color-invert 3"
	"Solarize Simple"
	"Version 2.0a\nThe solarize effect is irreversible.\n...Although you can Undo :)"
	"lasm"
	"Copyright 2002-2005, lasm"
	"November 19, 2005"
	"*"
	SF-IMAGE "The Image"      0
	SF-DRAWABLE "The Layer" 0
)
(script-fu-menu-register "210-color-invert 3" "<Image>/Script-Fu/Color/Invert")

(script-fu-register "210-color-invert 4"
	"Vivid V-Invert"
	"Version 2.0a\nProduces a highly saturated version of v-invert. Toggle it twice and it will stay in the V-invert mode, but the effect is not reversible to the original image.\n...Although you can Undo :)"
	"lasm"
	"Copyright 2002-2005, lasm"
	"November 21, 2005"
	"*"
	SF-IMAGE "The Image"      0
	SF-DRAWABLE "The Layer" 0
)
(script-fu-menu-register "210-color-invert 4" "<Image>/Script-Fu/Color/Invert")
