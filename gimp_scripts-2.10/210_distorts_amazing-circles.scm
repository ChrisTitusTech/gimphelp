; 210_distorts_amazing-circles.scm
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
; Amazing Circles is a script for The GIMP
;
; Turn an image into an Amazing Circle.
; The script is located in menu "<Image> / Filters / Distorts / Circle Maker"
; Last changed: 7 August 2007
; Copyright (C) 2007 Harry Phillips <script-fu@tux.com.au>
;
; Made to not error out by attempting to use on indexed image
; and changed menu location by Paul Sherman on 11/30/2007
; distributed by gimphelp.org
; 02/14/2014 - convert to RGB if needed
; --------------------------------------------------------------------
;  
; Changelog
;
;  Version 1.5 (7th August 2007)
;    - Added the option to choose the background colour:
;
;  Version 1.4 (7th August 2007)
;    - Cleaned up the code
;    - Created a mini funtion "square-crop"
;    - Added the cropping multi option
;
;  Version 1.3 (5th August 2007)
;    - Added GPL3 licence 
;    - Menu location at the top of the script
;    - Removed the "script-fu-menu-register" section
;
;  Version 1.2
;    - Made the script compatible with GIMP 2.3
;
;  Version 1.1
;    - Added a check to see if the image is already square
;==============================================================

(define (square-crop image)
    
    (let* (
	(width (car (gimp-image-width image)))
	(height (car (gimp-image-height image)))
	)
	
	(if (= width height)
		()
		(begin
	;Check which is longer
	(if 	(> width height)
		(gimp-image-crop image height height (/ (- width height) 2) 0)
		(gimp-image-crop image width width 0 (/ (- height width) 2))
	))
)))


(define (210-amazing-circles	theImage
		theLayer
		circlePercent
		backGround
		cropType
	)

    (gimp-image-undo-group-start theImage)
	(if (not (= RGB (car (gimp-image-base-type theImage))))
			 (gimp-image-convert-rgb theImage))

    ;Initiate some variables
    (let* (
	;Read the current colour
	(myBackground (car (gimp-context-get-background)))
    )

    ;Set the background colour
    (gimp-context-set-background backGround)
	
    ;Select none
    (gimp-selection-none theImage)

    ;Select none
    (gimp-selection-none theImage)

    (if (= cropType 1)
    	(square-crop theImage)
    	()
    )

    ;First polar co-ord with "To Polar = off"
    (plug-in-polar-coords 1 theImage theLayer circlePercent 0 1 0 0)

    ;Flip vertically
    (gimp-image-flip theImage 1)

    ;Second polar co-ord with "To Polar = on"
    (plug-in-polar-coords 1 theImage theLayer circlePercent 0 1 0 1)

    (if (= cropType 0)
    	(square-crop theImage)
    	()
    )
    ;Reset the background colour
    (gimp-context-set-background myBackground)
    (gimp-image-undo-group-end theImage)
    (gimp-displays-flush)
))

(script-fu-register "210-amazing-circles"
	"Circle Maker"
	"Does the amazing circles on a square image"
	"Harry Phillips"
	"Harry Phillips"
	"Mar. 23 2007"
	"*"
	SF-IMAGE		"Image"     		0
	SF-DRAWABLE		"Drawable"  		0
	SF-ADJUSTMENT	"Circle depth"      '(100 0 100 1 10 1 0)
	SF-COLOR		"Surround colour"   '(255 255 255)
	SF-OPTION		"Crop image?"		'("Crop after" "Crop before" "Don't crop")
)
(script-fu-menu-register "210-amazing-circles" "<Image>/Script-Fu/Distorts")

