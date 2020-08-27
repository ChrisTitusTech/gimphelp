; 210_sketch_Roy-Lichtenstein.scm
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
; 02/15/2014 - accommodate indexed images
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
; $Log: Roy-Lichtenstein.scm,v $
; Revision 1.2  2008-04-07 14:05:16+05:30  Cprogrammer
; combined to if statements into one if-else
;
; Revision 1.1  2008-04-06 15:31:32+05:30  Cprogrammer
; Initial revision
;
; photo-Roy-Lichtenstein.scm
; by $Author: Cprogrammer $
; $Revision: 1.2 $
; Description
;
; A script-fu script that adds the "Roy Lichtenstein" effect to an image
; Adapted from tutorial by Funadium at http://www.flickr.com/photos/funadium/2354849007/
;==============================================================


(define (210-RoyLichtenstein
		theImage
		baseOpacity
		BackGroundColour
		contrast
		edgeMethod
		edgeAmount
		erodeImage
		newsPrint
		pixelSize
		spotFunc
		blackAng
		cyanAng
		magentaAng
		yellowAng
		posterizeLevel
		NewsPrintOpacity
		DeSpeckle
		inFlatten
	)

	; Initiate some variables
	(let*
	 	(
			(base 0)
			(NewsPrintLayer 0)
			(BorderLayer 0)
			(width 0)
			(height 0)
			(bottomlayer 0)
			(drawable 0)
			(old-fg 0)
			(old-bg 0)
		)

		(gimp-image-undo-group-start theImage)
		(if (not (= RGB (car (gimp-image-base-type theImage))))
			 (gimp-image-convert-rgb theImage
			 ))
		(set! drawable (car (gimp-image-get-active-drawable theImage)))
		; Read the image height and width so that we can create a new layer of the same
		; dimensions of the current image
		(set! old-fg (car (gimp-palette-get-foreground)))
		(set! old-bg (car (gimp-palette-get-background)))
		(set! width  (car (gimp-image-width  theImage)))
		(set! height (car (gimp-image-height theImage)))

		; Add a coloured layer to bottom. This I felt gives some punch to the image
		; You can play with different colours to get different effects.
		(set! bottomlayer (car (gimp-layer-new theImage width height RGB-IMAGE "Bottom" 100 LAYER-MODE-NORMAL-LEGACY)))
		(gimp-image-add-layer theImage bottomlayer -1)
		(gimp-palette-set-foreground BackGroundColour)
		(gimp-bucket-fill bottomlayer FG-BUCKET-FILL LAYER-MODE-NORMAL-LEGACY 100 255 0 1 1)
		(gimp-image-lower-layer-to-bottom theImage bottomlayer)

		; Add the NewsPrint layer to the image
		(if (= newsPrint TRUE)
			(begin
		    (define NewsPrintLayer (car (gimp-layer-copy drawable 0)))
		    (gimp-item-set-name NewsPrintLayer "NewsPrint")			
		    (gimp-image-insert-layer theImage NewsPrintLayer 0 0)			

			(if (= DeSpeckle TRUE)
				(begin
				(gimp-posterize NewsPrintLayer posterizeLevel)
				(plug-in-gauss     RUN-NONINTERACTIVE theImage NewsPrintLayer 6 6 0)
				(plug-in-despeckle RUN-NONINTERACTIVE theImage NewsPrintLayer 5 2 2 254)
				)
			)
			(plug-in-newsprint RUN-NONINTERACTIVE theImage NewsPrintLayer pixelSize 
				 1 100 blackAng spotFunc cyanAng spotFunc magentaAng spotFunc yellowAng spotFunc 15)
			; Change the NewsPrint Layer's opacity
			(gimp-layer-set-opacity NewsPrintLayer NewsPrintOpacity)
			)
		)

		; Add Black Edge Border layer to the image
	    (define BorderLayer (car (gimp-layer-copy drawable 0)))
	    (gimp-item-set-name BorderLayer "BorderLayer")			
	    (gimp-image-insert-layer theImage BorderLayer 0 0)
		(plug-in-gauss RUN-NONINTERACTIVE theImage BorderLayer 3 3 0)
		(plug-in-edge  RUN-NONINTERACTIVE theImage BorderLayer edgeAmount edgeMethod 0)
		(gimp-invert BorderLayer)
		(gimp-desaturate-full BorderLayer DESATURATE-LUMINOSITY)
		(gimp-brightness-contrast BorderLayer 0 contrast)

		(if (= erodeImage TRUE)
			(begin
			(plug-in-erode RUN-NONINTERACTIVE theImage BorderLayer 1 0 1 0 0 254)
			(plug-in-gauss RUN-NONINTERACTIVE theImage BorderLayer 3 3 0)
			)
		)
		; This makes only the edge visible and rest of the image becomes transparent
		(plug-in-colortoalpha RUN-NONINTERACTIVE theImage BorderLayer '(255 255 255))

		(gimp-layer-set-opacity drawable baseOpacity)

		(if (= inFlatten TRUE)
			(begin
			(gimp-image-flatten theImage)
			)
		)

		(gimp-image-undo-group-end theImage)
		(gimp-displays-flush)
		(gimp-palette-set-foreground old-fg)
		(gimp-palette-set-background old-bg)
	)
)

(script-fu-register "210-RoyLichtenstein" 
	"Roy Lichtenstein"
	"Add Roy Lichtenstein effect to an image"
	"$Author: Cprogrammer $"
	"$Author: Cprogrammer $"
	"$Date: 2008-04-07 14:05:16+05:30 $"
	"*"
	SF-IMAGE        "Image"                   0
	SF-ADJUSTMENT   "Base Layer Opacity"      '(80 0 100 5 10 1 0)
	SF-COLOR        "Background Colour"       '(255 255 255)
	SF-ADJUSTMENT   "Contrast"                '(55 -127 127 1 5 0 0)
	SF-OPTION       "Edge Detect Algorithm"   '("Sobel" "Prewitt Compass" "Gradient" "Roberts" "Differntial" "Laplace")
	SF-ADJUSTMENT   "Edge Amount"             '(3 1 10 1 5 0 0)
	SF-TOGGLE       "Erode image"             FALSE
	SF-TOGGLE       "News Print Effect"       TRUE
	SF-ADJUSTMENT   "Newsprint Pixel Size"    '(3 1 20 1 10 1 1)
	SF-OPTION       "Spot Function"           '("Round" "Line" "Diamond" "PS Square" "PS Diamond")
	SF-ADJUSTMENT   "Black Angle"             '(45 -90 90 1 10 1 1)
	SF-ADJUSTMENT   "Cyan Angle"              '(15 -90 90 1 10 1 1)
	SF-ADJUSTMENT   "Magenta  Angle"          '(75 -90 90 1 10 1 1)
	SF-ADJUSTMENT   "Yellow Angle"            '(0 -90 90 1 10 1 1)
	SF-ADJUSTMENT   "Posterize Level"         '(7 1 255 1 10 1 1)
	SF-ADJUSTMENT   "Newsprint Layer Opacity" '(50 0 100 5 10 1 1)
	SF-TOGGLE       "Despeckle"               TRUE
	SF-TOGGLE       "Flatten image"           TRUE
)
(script-fu-menu-register "210-RoyLichtenstein" "<Image>/Script-Fu/Sketch")
