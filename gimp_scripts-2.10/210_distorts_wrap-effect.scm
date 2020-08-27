; 210_distorts_wrap-effect.scm
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
; Wrap paint effect Script  for GIMP 1.2
; 
; --------------------------------------------------------------------
;   - Changelog -
; version 0.1  by Iccii 2001/04/15 <iccii@hotmail.com>
;     - Initial relase
; version 0.2  by Iccii 2001/10/01 <iccii@hotmail.com>
;     - Changed menu path because this script attempts to PS's filter
;     - Added some code (if selection exists...)
;==============================================================


(define (210-wrap-effect
		inImage
		inDrawable
		inRadius
		inGamma1
		inGamma2
		inSmooth
	)

	(gimp-image-undo-group-start inImage)
	(if (not (= RGB (car (gimp-image-base-type inImage))))
			 (gimp-image-convert-rgb inImage))
  (let* (
	(theOld-bg (car (gimp-context-get-background)))
	(theNewlayer (car (gimp-layer-copy inDrawable 1)))
	(old-selection (car (gimp-selection-save inImage)))
	(theLayermask (car (gimp-layer-create-mask theNewlayer ADD-MASK-BLACK)))
	)

	(gimp-item-set-name theNewlayer "Wrap effect")
	(gimp-layer-set-mode theNewlayer LAYER-MODE-NORMAL-LEGACY)
	(gimp-image-insert-layer inImage theNewlayer 0 -1)

	(gimp-desaturate theNewlayer)
	(plug-in-gauss-iir2 1 inImage theNewlayer inRadius inRadius)
	(plug-in-edge 1 inImage theNewlayer 6.0 0 4)
	(gimp-invert theNewlayer)


	(if (eqv? inSmooth TRUE)
	    (plug-in-gauss-iir2 0 inImage theNewlayer 5 5))
	(gimp-edit-copy theNewlayer)

	(if (< 0 (car (gimp-layer-get-mask theNewlayer)))
	    (gimp-layer-remove-mask theNewlayer MASK-APPLY))
;	(set! theLayermask (car (gimp-layer-create-mask theNewlayer BLACK-MASK)))
	(gimp-layer-add-mask theNewlayer theLayermask)
	(gimp-floating-sel-anchor (car (gimp-edit-paste theLayermask 0)))

	(gimp-levels theNewlayer 0 0 255 (/ inGamma1 10) 0 255)
	(gimp-levels theNewlayer 0 0 255 (/ inGamma1 10) 0 255)
	(gimp-levels theLayermask 0 0 255 (/ inGamma2 10) 0 255)
	(gimp-levels theLayermask 0 0 255 (/ inGamma2 10) 0 255)

	(gimp-layer-remove-mask theNewlayer MASK-APPLY)
	(gimp-image-select-item inImage CHANNEL-OP-REPLACE old-selection)
	(gimp-edit-copy theNewlayer)
	(gimp-image-remove-layer inImage theNewlayer)
	(gimp-floating-sel-anchor (car (gimp-edit-paste inDrawable 0)))
	(gimp-image-select-item inImage CHANNEL-OP-REPLACE old-selection)
	(gimp-image-remove-channel inImage old-selection)

	(gimp-context-set-background theOld-bg)
	;(gimp-image-set-active-layer inImage inDrawable)
	(gimp-image-undo-group-end inImage)
	(gimp-displays-flush)
   )
)

(script-fu-register
	"210-wrap-effect"
	"Wrap Effect"
	"Draws with wrap effect, which simulates Photoshop's Wrap filter"
	"Iccii <iccii@hotmail.com>"
	"Iccii"
	"Oct, 2001"
	"*"
	SF-IMAGE		"Image"				0
	SF-DRAWABLE		"Drawable"			0
	SF-ADJUSTMENT	"Randomness"		'(10 0 32 1 10 0 0)
	SF-ADJUSTMENT	"Highlight Balance"	'(3.0 1.0 10 0.5 0.1 1 0)
	SF-ADJUSTMENT	"Edge Amount"		'(3.0 1.0 10 0.5 0.1 1 0)
	SF-TOGGLE		"Smooth"			FALSE
)
(script-fu-menu-register "210-wrap-effect" "<Image>/Script-Fu/Distorts")
