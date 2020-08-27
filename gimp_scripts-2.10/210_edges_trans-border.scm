; 210_edges_trans-border.scm
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
; Translucent Border is a script for The GIMP
; Creates a border with reduced brightness and 2 inner colours.
; The script is located in menu "<Image>/Script-Fu/Edges/Translucent Border"
; Last changed: 7 August 2007
;
; Copyright (C) 2007 Harry Phillips <script-fu@tux.com.au>
;==============================================================

(define (210-trans-border
			theImage
			theLayer
			innerColour
			innerSize
			outerColour
			outerSize
			borderType
			borderSize
			borderPercent
			borderBrightness
	)

    (let* 
    (
	;Read the current colours
	(myForeground (car (gimp-context-get-foreground)))
	(myBackground (car (gimp-context-get-background)))

	;Read the image width and height
	(imageWidth (car (gimp-image-width theImage)))
	(imageHeight (car (gimp-image-height theImage)))
	
	(selectWidth)
	(selectHeight)
	(outerLayer)
	(innerLayer)
	(mask)
	(co-ord)
	(sizeBAD FALSE)
	(copyBack)

    )
    
    ;Calculate the selection sizes
    (if (= borderType 0)
    	;Set the co-ord to the pixel size
    	(set! co-ord borderSize)
    	
    	(begin
    		;Set the co-ord to a percentage of the shortest side
    	    (if (> imageWidth imageHeight)
	    	(set! co-ord (/ (* imageHeight borderPercent) 100))
	    	(set! co-ord (/ (* imageWidth borderPercent) 100)))
	)
    )
    
    ;Check the width
    (if (< imageWidth (+ innerSize (+ outerSize (* 2 borderSize))))
    	(set! sizeBAD TRUE)
    	())

    ;Check the height
    (if (< imageHeight (+ innerSize (+ outerSize (* 2 borderSize))))
    	(set! sizeBAD TRUE)
    	())
    
    ;Give an error message if the size is not ok
    (if (= sizeBAD TRUE)
    	(gimp-message "The image is not large enough for that border size")
    	(begin

    ;Start an undo group so the process can be undone with one undo
    (gimp-image-undo-group-start theImage)
    
    ;Copy the layer
    (set! copyBack (car (gimp-layer-copy theLayer 1)))
    
    ;Select none
    (gimp-selection-none theImage)

    ;Set the foreground and background colours
    (gimp-context-set-foreground outerColour)
    (gimp-context-set-background innerColour)

    ;Add the first layer to the image
    (gimp-image-insert-layer theImage copyBack 0 0)

    ;Rename the layer
    (gimp-item-set-name copyBack "Original")

    ;Set the brightness of the background layer
    (gimp-brightness-contrast theLayer borderBrightness 0)
    
    ;Calculate the selection size
    (set! selectWidth (- imageWidth (* co-ord 2)))
    (set! selectHeight (- imageHeight (* co-ord 2)))
    
    ;Select the first part
    (gimp-image-select-rectangle theImage CHANNEL-OP-REPLACE co-ord co-ord selectWidth selectHeight)

    ;Add the outer layer
    (set! outerLayer (car (gimp-layer-new theImage imageWidth imageHeight 1 "Outer" 100 0)))
    (gimp-image-insert-layer theImage outerLayer 0 1)

    ;Fill the layer with FG colour
    (gimp-edit-fill outerLayer 0)


    ;Add a layer mask
    (set! mask (car (gimp-layer-create-mask outerLayer 4)))
    (gimp-layer-add-mask outerLayer mask)

    ;Add the inner layer(car (gimp-context-get-foreground))
    (set! innerLayer (car (gimp-layer-new theImage imageWidth imageHeight 1 "Inner" 100 0)))
    (gimp-image-insert-layer theImage innerLayer 0 1)

    ;Fill the layer with BG colour
    (gimp-edit-fill innerLayer 1)

    ;Reduce the selection by the outer amount
    (gimp-selection-shrink theImage outerSize)

    ;Add a layer mask
    (set! mask (car (gimp-layer-create-mask innerLayer 4)))
    (gimp-layer-add-mask innerLayer mask)

    ;Reduce the selection by the inner amount
    (gimp-selection-shrink theImage innerSize)

    ;Add a layer mask to the original
    (set! mask (car (gimp-layer-create-mask copyBack 4)))
    (gimp-layer-add-mask copyBack mask)

    ;Select none
    (gimp-selection-none theImage)

    ;Set the FG and BG colours back to what they were
    (gimp-context-set-foreground myForeground)
    (gimp-context-set-background myBackground)
    
    ;Finish the undo group for the process
    (gimp-image-undo-group-end theImage)

    ;Ensure the updated image is displayed now
    (gimp-displays-flush)

    ))))


(script-fu-register "210-trans-border"
    "Translucent Border"
    "Gives a transparent border with two inner lines"
    "Harry Phillips"
    "Harry Phillips"
    "Mar. 16 2007"
    "*"
    SF-IMAGE		"Image"					0
    SF-DRAWABLE		"Drawable"				0
    SF-COLOR		"Inner colour"			'(255 255 255)
    SF-ADJUSTMENT	"Inner size"			'(5 0 50 1 1 0 0)
    SF-COLOR		"Outer colour"			'(0 0 0)
	SF-ADJUSTMENT	"Outer size"			'(5 0 50 1 1 0 0)
	SF-OPTION		"Border type"			'("Pixels" "Percentage")
	SF-ADJUSTMENT	"Border pixels"		'(200 0 1000 1 1 0 0)
	SF-ADJUSTMENT	"Border percentage"	'(10 0 100 1 1 0 0)
	SF-ADJUSTMENT	"Border brightness"	'(-80 -127 0 1 1 0 1)
)            
(script-fu-menu-register "210-trans-border" "<Image>/Script-Fu/Edges")
