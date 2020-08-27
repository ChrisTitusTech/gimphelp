; 210_photo_web-photo-edit.scm
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
; Web Photo Editor Script-fu plugin for The Gimp
; Copyright (C) 2007 Justin Watt http://justinsomnia.org/
;==============================================================

(define (210-web-photo-editor 
		image 
		drawable
		newwidth
		shadows
		midtones
		highlights
		contrast
		saturation
		sharpen
	)
	(gimp-image-undo-group-start image)
	(if (not (= RGB (car (gimp-image-base-type image))))
			 (gimp-image-convert-rgb image))
	(let* ((drawable  (car (gimp-image-get-active-drawable image)))
		 (oldwidth  (car (gimp-image-width image)))
		 (oldheight (car (gimp-image-height image)))
		 (newheight (* newwidth (/ oldheight oldwidth)))
		)
	(if (> oldwidth newwidth)(gimp-image-scale image newwidth newheight))
	(gimp-selection-none image)
	(gimp-color-balance drawable 0 0 shadows shadows shadows)
	(gimp-color-balance drawable 1 0 midtones midtones midtones)
	(gimp-color-balance drawable 2 0 highlights highlights highlights)
	(gimp-brightness-contrast drawable 0 contrast)
	(gimp-hue-saturation drawable 0 0 0 saturation)
	(if (= sharpen TRUE)(plug-in-unsharp-mask 1 image drawable 0.4 0.2 0))
	(gimp-image-undo-group-end image)
	)
)
(script-fu-register "210-web-photo-editor"
	"Web Photo Editor"
	"Brings together some common operations to edit a photo for the web, including resizing, contrast, color balancing, saturation, and sharpening. For more information, see:\nhttp://justinsomnia.org/2007/09/web-photo-editor-extension-for-the-gimp/"
	"Justin Watt http://justinsomnia.org/"
	"Copyright 2007 by Justin Watt; GNU GPL"
	"2007-11-07"
	"*"
	SF-IMAGE       "Image"           0
	SF-DRAWABLE    "Drawable"        0
	SF-VALUE       "Width"           "450"                   ; defaults to 450
	SF-ADJUSTMENT  "Shadows"         '(5  -100 100 5 10 0 0) ; defaults to 5
	SF-ADJUSTMENT  "Midtones"        '(10 -100 100 5 10 0 0) ; defaults to 10
	SF-ADJUSTMENT  "Highlights"      '(5  -100 100 5 10 0 0) ; defaults to 5
	SF-ADJUSTMENT  "Contrast"        '(10 -127 127 5 10 0 0) ; defaults to 10
	SF-ADJUSTMENT  "Saturation"      '(15 -100 100 5 10 0 0) ; defaults to 15
	SF-TOGGLE      "Sharpen"         TRUE
)
(script-fu-menu-register "210-web-photo-editor" "<Image>/Script-Fu/Photo")
