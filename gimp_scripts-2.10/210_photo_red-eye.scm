; 210_photo_red-eye.scm
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
; 10/01/2008 
; - Modified to remove deprecated procedures by Paul Sherman
; 12/15/2008 - menu placement and info comment for Selection script
; 10/15/2010 - Restricted input to RGB image to eliminate errors
;
; Original information ---------------------------------------------
; The GIMP -- an image manipulation program
; Copyright (C) 1995 Spencer Kimball and Peter Mattis
; 
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.  
; 
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
; 
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
;
; red-eye.scm   version 0.95   2002/10/06
;
; CHANGE-LOG:
; 0.95 - initial release
; Copyright (C) 2002 Martin Guldahl <mguldahl@xmission.com>
; Removes red eye
;
; End original information ------------------------------------------

(define (210-red-eye image
			   drawable
			   radius
			   threshold
			   red
			   green
			   blue)


  (let* ((select-bounds (gimp-drawable-mask-bounds drawable))
	 (x1 (cadr select-bounds))
         (y1 (caddr select-bounds))
         (x2 (cadr (cddr select-bounds)))
         (y2 (caddr (cddr select-bounds)))
	 (red-component 0)
	 (green-component 1)
	 (blue-component 2)
	 )

  (gimp-image-undo-group-start image)

  ; Select and view the green channel only as it has the best contrast
  ; between the iris and pupil.
  ; - Deselect the Red and Blue channels

  (gimp-image-set-component-active image red-component FALSE)
  (gimp-image-set-component-active image blue-component FALSE)

  ; Use the fuzzy select tool (select contiguous regions) to select the pupils
  (gimp-image-select-contiguous-color image CHANNEL-OP-REPLACE drawable x1 y1)

  ; Reselect Red and Blue channels
  (gimp-image-set-component-active image red-component TRUE)
  (gimp-image-set-component-active image blue-component TRUE)

  ; Use the channel mixer to make selected area monochrome
  (plug-in-colors-channel-mixer
   ;;run_mode
   1
   image
   drawable
   ;;monochrome
   1
   (/ red 100) (/ green 100) (/ blue 100) 0 0 0  0 0 0
   )
  
  (gimp-selection-none image)
  (gimp-image-undo-group-end image)
  (gimp-displays-flush)
  )
  )

(define (210-red-eye-no-cm image
			   drawable
			   radius
			   threshold
			   )


  (let* ((select-bounds (gimp-drawable-mask-bounds drawable))
	 (x1 (cadr select-bounds))
         (y1 (caddr select-bounds))
         (x2 (cadr (cddr select-bounds)))
         (y2 (caddr (cddr select-bounds)))
	 (red-component 0)
	 (green-component 1)
	 (blue-component 2)
	 )

  (gimp-image-undo-group-start image)

  ; Select and view the green channel only as it has the best contrast
  ; between the iris and pupil.
  ; - Deselect the Red and Blue channels

  (gimp-image-set-component-active image red-component FALSE)
  (gimp-image-set-component-active image blue-component FALSE)

  ; Use the fuzzy select tool (select contiguous regions) to select the pupils
  (gimp-image-select-contiguous-color image CHANNEL-OP-REPLACE drawable x1 y1)

  ; Reselect Red and Blue channels
  (gimp-image-set-component-active image red-component TRUE)
  (gimp-image-set-component-active image blue-component TRUE)

  ; Now desaturate the Red channel
  (gimp-image-set-component-active image red-component TRUE)
  (gimp-image-set-component-active image green-component FALSE)
  (gimp-image-set-component-active image blue-component FALSE)
  (gimp-desaturate drawable)
  (gimp-image-set-component-active image red-component TRUE)
  (gimp-image-set-component-active image green-component TRUE)
  (gimp-image-set-component-active image blue-component TRUE)

  (gimp-selection-none image)
  (gimp-image-undo-group-end image)
  (gimp-displays-flush)
  )
  )

(script-fu-register "210-red-eye"
	"Red Eye by Selected Area"
	"Removes red eye; given selection is used, whole image if nothing selected.\n\nNeeds the channel-mixer plug-in."
	"Martin Guldahl <mguldahl@xmission.com>"
	"Martin Guldahl"
	"2002/10/05"
	"RGB*"
	SF-IMAGE "Image" 0
	SF-DRAWABLE "Drawable" 0
	SF-ADJUSTMENT _"Radius" '(8 0 100 .2 1 1 1)
	SF-ADJUSTMENT _"Threshold" '(40 0 255 1 1 1 1)
	SF-ADJUSTMENT _"Red" '(10 0 100 1 1 1 1)
	SF-ADJUSTMENT _"Green" '(60 0 100 1 1 1 1)
	SF-ADJUSTMENT _"Blue" '(30 0 100 1 1 1 1)
)
(script-fu-menu-register "210-red-eye" "<Image>/Script-Fu/Photo")

(script-fu-register "210-red-eye-no-cm"
	"Red Eye Desaturate"
	"Removes red eye; given selection is seed."
	"Martin Guldahl <mguldahl@xmission.com>"
	"Martin Guldahl"
	"2002/10/05"
	"RGB*"
	SF-IMAGE "Image" 0
	SF-DRAWABLE "Drawable" 0
	SF-ADJUSTMENT _"Radius" '(8 0 100 .2 1 1 1)
	SF-ADJUSTMENT _"Threshold" '(40 0 255 1 1 1 1)
)
(script-fu-menu-register "210-red-eye-no-cm" "<Image>/Script-Fu/Photo")
