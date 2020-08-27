; 210_photo_BlueSkyClouds.scm
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
; Blue Sky & Clouds, V2.0
; AUTHOR: Darla McKay (Darla@FarcryDesign.com), (C) 2007,2008
; This plugin was tested with GIMP 2.4
;
; DESCRIPTION:
; To fix burned out or white skies by adding a blue sky gradient.
; The script is located in menu "<Image> / Script-Fu / Darla / Blue Sky & Clouds"
;
; USAGE NOTES:
; Two colours are selectable, specifying the upper (darker) and lower 
; (lighter) sky.  The gradient is applied based on a level horizon.
; Threshold masking is applied.  Optionally, a layer with rendered clouds
; can be added.
;     See http://www.FarcryDesign.com/GIMP/ for more information.
;==============================================================


(define (210-BlueSkyClouds 
			InImage 
			InLayer 
			InThreshold 
			InSkyTop 
			InSkyBottom 
			InFeather 
			InClouds 
			InFlatten
		)
	(gimp-image-undo-group-start InImage)
	(if (not (= RGB (car (gimp-image-base-type InImage))))
			 (gimp-image-convert-rgb InImage))
	(let*	(
		(BlueGradientLayer (car (gimp-layer-copy InLayer TRUE)))
		(CloudLayer (car (gimp-layer-copy InLayer TRUE)))
		(ThresholdLayer (car (gimp-layer-copy InLayer TRUE)))
		(CloudMask (car (gimp-layer-create-mask CloudLayer ADD-WHITE-MASK)))
		(BlueGradientMask (car (gimp-layer-create-mask BlueGradientLayer ADD-WHITE-MASK)))
		(TheHeight (car (gimp-image-height InImage)))
		(Old-FG-Color (car (gimp-context-get-foreground)))
		(Old-BG-Color (car (gimp-context-get-background)))
		)

		; add threshold layer
		(gimp-image-insert-layer InImage ThresholdLayer 0 -1)
		(gimp-threshold ThresholdLayer InThreshold 255)
		(plug-in-gauss TRUE InImage ThresholdLayer InFeather InFeather 0)
		(gimp-item-set-name ThresholdLayer "Threshold Layer")
		(gimp-item-set-visible ThresholdLayer FALSE)
		
		; add clouds if applicable, interactive solid noise
		(if (not (= InClouds 0)) 
			(begin
				(gimp-image-insert-layer InImage CloudLayer 0 -1)
				(gimp-selection-all InImage)
				(gimp-edit-clear CloudLayer)
				(plug-in-solid-noise FALSE InImage CloudLayer 0 0 7 2 3.6 7.4)
				(gimp-item-set-name CloudLayer "Cloud Layer")
				(gimp-layer-add-mask CloudLayer CloudMask)
				(gimp-selection-all InImage)
				(gimp-edit-copy ThresholdLayer)
				(gimp-floating-sel-anchor (car (gimp-edit-paste CloudMask FALSE)))
				(gimp-selection-none InImage)
				(gimp-layer-set-mode CloudLayer DARKEN-ONLY-MODE)
				(gimp-layer-set-opacity CloudLayer 15)
			)
		)

		; add blue gradient layer
		(gimp-image-insert-layer InImage BlueGradientLayer 0 -1)
		(gimp-context-set-foreground InSkyTop)
		(gimp-context-set-background InSkyBottom)
		(gimp-edit-blend BlueGradientLayer FG-BG-RGB-MODE LAYER-MODE-NORMAL-LEGACY GRADIENT-LINEAR 100 0 REPEAT-NONE FALSE FALSE 0 0 TRUE 0 0 0 (- TheHeight 1))
		(gimp-item-set-name BlueGradientLayer "Blue Gradient Layer")
		(gimp-layer-add-mask BlueGradientLayer BlueGradientMask)
		(gimp-selection-all InImage)
		(gimp-edit-copy ThresholdLayer)
		(gimp-floating-sel-anchor (car (gimp-edit-paste BlueGradientMask FALSE)))
		(gimp-selection-none InImage)
		(if (not (= InClouds 0)) 
			(begin
				(gimp-layer-set-mode BlueGradientLayer COLOR-MODE)
				(gimp-layer-set-opacity BlueGradientLayer 90)
			)
			(begin
				(gimp-layer-set-mode BlueGradientLayer DARKEN-ONLY-MODE)
				(gimp-layer-set-opacity BlueGradientLayer 70)
			)	
		)

		; return original color palette, flatten image if needed
		(gimp-context-set-foreground Old-FG-Color)
		(gimp-context-set-background Old-BG-Color)
		(if (= InFlatten TRUE) (gimp-image-flatten InImage))
	)

	(gimp-image-undo-group-end InImage)
	(gimp-displays-flush)
)

(script-fu-register 
	"210-BlueSkyClouds"
	"Highlight to Sky and Clouds"
	"Highlights -> Blue Sky & Clouds \n\
To fix burned out or white skies by adding a blue sky \
gradient and clouds (uses a threshold mask). \n\
USE LOWER THRESHOLD to fill a larger white/highlight area. \n\
See http://www.FarcryDesign.com/GIMP for more information."
	"Darla McKay (Darla@FarcryDesign.com)"
	"Darla McKay"
	"2007,2008"
	"*"
	SF-IMAGE		"The Image"					0
	SF-DRAWABLE		"The Layer"					0
	SF-ADJUSTMENT	"Threshold"					'(248 0 254 1 0 0 0)
	SF-COLOR		"Sky Top Color"				'(187 219 255)
	SF-COLOR		"Sky Bottom Color"			'(221 234 255)
	SF-ADJUSTMENT	"Edges: Feather Amount"		'(5.0 1.0 10.0 1.0 0 1 0)
	SF-TOGGLE		"Add Rendered Clouds"		TRUE
	SF-TOGGLE		"Flatten Image"				FALSE
)
(script-fu-menu-register "210-BlueSkyClouds" "<Image>/Script-Fu/Photo")
