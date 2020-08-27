; 210_color_bw-from-graphic.scm
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
; Serge Mankovski B/W Film Simulation
;
; Modified by Paul Sherman 12/30/2007
; made to work with GIMP-2.4+
; simplified film type menu
; modified (xtra steps) in High-Contrast for use with graphics
; (to compensate for the "blockiness" when rendering clip art,
; yielding a lighter "sketched" look.)
;
; Copyright Serge Mankovski (sevato@mankovski.com)
; Toronto, Ontario, 2007
;
; Version 1.1  March 30,  2007        
; Converts selected layer into Black and White using channel mixer
; Uses channel presets found on Internet. I am not sure about the origin of these
; settings and I do not know if they really produce result resembling tonal qualities of
; the film, but it produces nice looking B/W and it is a useful way to convert to black and white
; 
; Change Log:
; Version 1.1
;		- added IR film simulation
;		- added color filters applied before b/w conversion
; 		- added saturation option
;		- Gimp 2.3.15+ support
;==============================================================
 
(define (create-new-layer img drawable) 
   (define layer (car (gimp-layer-copy drawable TRUE)))
   (gimp-image-insert-layer img layer 0 -1)
   layer)

      
(define (210-bw-from-graphic  
		img 
		drawable 
		film 
		filter 
		rename 
		new-layer 
		increase-local-contrast 
		auto-levels 
		drop-gamma 
		saturate 
	)
    
	(gimp-image-undo-group-start img)
	(if (not (= RGB (car (gimp-image-base-type img))))
			 (gimp-image-convert-rgb img))	
	
	(let* 
		((bw-layer img)
		 (chan-name ""))
	
    (if (equal? new-layer TRUE) 
        (set! bw-layer (create-new-layer img drawable))
    	(set! bw-layer drawable)
    )
 
   (if (equal? saturate TRUE) 
    	(plug-in-colors-channel-mixer 1 img bw-layer FALSE 1.3 -0.15 -0.15 -0.15 1.3 -0.15 -0.15 -0.15 1.3)
        ())   
   (if (equal? drop-gamma TRUE) (gimp-levels bw-layer 0 0 255 0.9 0 255) ())    

    (cond
		; Yellow Filter	
    	((= filter 1)
            (gimp-hue-saturation bw-layer 0 -5 0 33)    	
    		(set! chan-name (string-append chan-name " Yellow Filter")))	
    	; Orange Filter	
    	((= filter 2)
            (gimp-hue-saturation bw-layer 0 -20 0 25)    	
    		(set! chan-name (string-append chan-name " Orange Filter")))	
		; Red Filter	
    	((= filter 3)
            (gimp-hue-saturation bw-layer 0 -41 0 25)    	
    		(set! chan-name (string-append chan-name " Red Filter")))	
		; Green Filter
    	((= filter 4)
            (gimp-hue-saturation bw-layer 0 90 0 33)    	
    	    (set! chan-name (string-append chan-name " Green Filter")))	
		; Blue Filter
    	((= filter 5)
            (gimp-hue-saturation bw-layer 0 -145 0 25)    	
    	    (set! chan-name (string-append chan-name " Blue Filter")))	
      )
   
   (cond
		; High Contrast
    	((= film 0)  
    	    (set! chan-name (string-append chan-name " High Contrast"))
    		(plug-in-colors-channel-mixer 1 img bw-layer TRUE 0.40 0.34 0.60 0.40 0.34 0.60 0.40 0.34 0.60 )
		(gimp-levels bw-layer HISTOGRAM-VALUE 0 255 1.4 1 255))
		(plug-in-unsharp-mask 1 img bw-layer 5.0 0.30 10)	
		
		; Normal Contrast
    	((= film 1)  
    	    (set! chan-name (string-append chan-name " Normal Contrast"))
    		(plug-in-colors-channel-mixer 1 img bw-layer TRUE 0.43 0.33 0.30 0.43 0.33 0.30 0.43 0.33 0.30 ))
)    
    (if (equal? rename TRUE)  (gimp-item-set-name bw-layer chan-name) () )
    (if (equal? increase-local-contrast TRUE) (plug-in-unsharp-mask 1 img bw-layer 30.0 0.25 9) ())
    (gimp-image-convert-grayscale img)
    (gimp-image-undo-group-end img)
 )
   (gimp-displays-flush)  
)
 
(script-fu-register "210-bw-from-graphic"
	"BW from Graphic" 
	"Black and White From a Color Graphic.  Made for use specifically for rendering clip art in greyscale. High-Contrast setting will yield a sketchy look instead of the blockinesss usually rendered from graphics when converting to grey.\n\nby Paul Sherman\ngimphelp.org"
	"Modified version by Paul Sherman <psherman201@gmail.com> 
	Original by Serge Mankovski (sevato@mankvoski.com)
	Original copyright info below:"
	"2007, Serge Mankovski, Toronto, ON, Canada"
	"05.01.2007"
	"*" 
	SF-IMAGE "Image" 0
	SF-DRAWABLE "Current Layer" 0
	SF-OPTION   "Film" '("High Contrast" "Normal Contrast")
    SF-OPTION   "Filter" 
		'( 		
				"Select"
				"Yellow"
				"Orange" 
				"Red"
				"Green"
				"Blue"
		)						
	SF-TOGGLE "Rename Layer?" TRUE 		
	SF-TOGGLE "New Layer?" FALSE 		
	SF-TOGGLE "Increase Local Contrast" FALSE
	SF-TOGGLE "Auto Levels" FALSE	
	SF-TOGGLE "Drop Gamma 10%" FALSE
	SF-TOGGLE "Saturate" FALSE
)
(script-fu-menu-register "210-bw-from-graphic" "<Image>/Script-Fu/Color")
