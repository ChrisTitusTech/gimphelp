; 210_contrast_shadow-recovery.scm
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
; Shadow Recovery script for GIMP 2.4
; Original author: Martin Egger (martin.egger@gmx.net)
; (C) 2005, Bern, Switzerland
;
; by Paul Sherman
; august 2007 - fixed for gimp 2.4
; --------------------------------------------------------------------
; by paul Sherman
; Nov 2008 - no fix, just menu item change to fit with 
; gimphelp.org scripts release
; 02/14/2014, edited to convert to RGB if not....
;==============================================================

(define (210-ShadowRecovery 
		InImage 
		InLayer 
		InMethod 
		InOpacity 
		InFlatten
	)

    (gimp-image-undo-group-start InImage)
	(if (not (= RGB (car (gimp-image-base-type InImage))))
			 (gimp-image-convert-rgb InImage))
			 
    (let*    (
        (CopyLayer (car (gimp-layer-copy InLayer TRUE)))
        (ShadowLayer (car (gimp-layer-copy InLayer TRUE)))
        )
;		Create new layer and add it to the image
        (gimp-image-insert-layer InImage CopyLayer 0 -1)
        (gimp-layer-set-mode CopyLayer ADDITION-MODE)
        (gimp-layer-set-opacity CopyLayer InOpacity)
        (gimp-image-insert-layer InImage ShadowLayer 0 -1)
;
        (gimp-desaturate ShadowLayer)
        (gimp-invert ShadowLayer)
        (let*    (
            (CopyMask (car (gimp-layer-create-mask CopyLayer ADD-WHITE-MASK)))
            (ShadowMask (car (gimp-layer-create-mask ShadowLayer ADD-WHITE-MASK)))
            )
            (gimp-layer-add-mask CopyLayer CopyMask)
            (gimp-layer-add-mask ShadowLayer ShadowMask)
            (gimp-selection-all InImage)
            (gimp-edit-copy ShadowLayer)
            (gimp-floating-sel-anchor (car (gimp-edit-paste CopyMask TRUE)))
            (gimp-floating-sel-anchor (car (gimp-edit-paste ShadowMask TRUE)))
        )
        (gimp-layer-set-mode ShadowLayer OVERLAY-MODE)
        (gimp-layer-set-opacity ShadowLayer InOpacity)
        (if (= InMethod 0) (gimp-image-remove-layer InImage CopyLayer))
		; Flatten the image, if we need to
        (cond
            ((= InFlatten TRUE)
                (begin
                    (if (= InMethod 1) (gimp-image-merge-down InImage CopyLayer CLIP-TO-IMAGE))
                    (gimp-image-merge-down InImage ShadowLayer CLIP-TO-IMAGE)
                )
            )
            ((= InFlatten FALSE)
                (begin
                    (if (= InMethod 1) (gimp-item-set-name CopyLayer "Shadowfree strong"))
                    (gimp-item-set-name ShadowLayer "Shadowfree normal")
                )
            )
        )
    )
    (gimp-image-undo-group-end InImage)
    (gimp-displays-flush)
)
(script-fu-register "210-ShadowRecovery"
	"Shadow Recovery"
	"Lighten-up Shadows"
	"Martin Egger (martin.egger@gmx.net)"
	"2005, Martin Egger, Bern, Switzerland"
	"2.06.2005"
	"*"
	SF-IMAGE    	"The Image"    				0
	SF-DRAWABLE    	"The Layer"    				0
	SF-OPTION     	"Shadow Recovery Method" 	'("Normal" "Strong")
	SF-ADJUSTMENT   "Layer Opacity"    			'(60.0 1.0 100.0 1.0 0 2 0)
	SF-TOGGLE    	"Flatten Image"    			FALSE
)
(script-fu-menu-register "210-ShadowRecovery" "<Image>/Script-Fu/Contrast/")
