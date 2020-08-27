; 210_color-xpro.scm
; last modified/tested by Paul Sherman [gimphelp.org]
; 05/12/2019 on GIMP-2.10.10
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
; ALSO NEED TO PUT:
; pointer-click-effect.png
; pointer-drag-and-drop-move.png
; pointer-drag-and-drop.png
; pointer-editor.png
; pointer-link-select.png
; pointer-normal-select.png
;
;	Windows 7/10
;	C:\Program Files\GIMP 2\share\gimp\2.0\scripts\images
;	or
;	C:\Users\YOUR-NAME\AppData\Roaming\GIMP\2.10\scripts\images
;	
;    
;	Linux
;	/home/yourname/.config/GIMP/2.10/scripts/images
;	or
;	Linux system-wide
;	/usr/share/gimp/2.0/scripts/images

;==============================================================
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

;==============================================================
; Original information 
; 
; Copyright (c) 2011 Cardinal Peak
;;;
;;; Permission is hereby granted, free of charge, to any person obtaining a copy
;;; of this software and associated documentation files (the "Software"), to deal
;;; in the Software without restriction, including without limitation the rights
;;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;;; copies of the Software, and to permit persons to whom the Software is
;;; furnished to do so, subject to the following conditions:
;;;
;;; The above copyright notice and this permission notice shall be included in
;;; all copies or substantial portions of the Software.
;;;
;;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
;;; THE SOFTWARE.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Cross-processing script for the gimp
;
; Description of cross processing:
; http://en.wikipedia.org/wiki/Cross_processing
;
; This script automates the tutorial found at:
; http://www.jesusda.com/blog/index.php?id=375
;==============================================================

(define (210-xpro inImage inLayer)

  ; start an undoable group of operations

  (gimp-image-undo-group-start inImage)
  (if (not (= RGB (car (gimp-image-base-type inImage))))(gimp-image-convert-rgb inImage))
  ; remap curves for red/green/blue components

  (gimp-curves-spline inLayer HISTOGRAM-RED 10 #(0 0  88 47  170 188  221 249  255 255))
  (gimp-curves-spline inLayer HISTOGRAM-GREEN 8 #(0 0  65 57  184 208  255 255))
  (gimp-curves-spline inLayer HISTOGRAM-BLUE 4 #(0 29  255 226))

  ; duplicate image layer, mark it as 50% opacity, and overlay it

  (let* ((newLayer (car (gimp-layer-copy inLayer FALSE))))
    (gimp-image-add-layer inImage newLayer -1)
    (gimp-layer-set-opacity newLayer 50)
    (gimp-layer-set-mode newLayer OVERLAY-MODE))

  ; create a new greenish-yellow layer at 10% opacity and overlay it

  (let* ((newLayer (car (gimp-layer-new inImage (car (gimp-image-width inImage))
					(car (gimp-image-height inImage)) RGB-IMAGE 
					"GreenishYellow" 10 OVERLAY-MODE))))
    (gimp-context-set-foreground '(0 255 186))
    (gimp-drawable-fill newLayer FOREGROUND-FILL)
    (gimp-image-add-layer inImage newLayer -1))

  ; display cross processed image, and end the undoable group of operations

  (gimp-displays-flush)
  (gimp-image-undo-group-end inImage))

(script-fu-register 
 "210-xpro"
 "Xpro"
 "Cross-Process - color/contrast shifts as if film processed as another type."
 "Cross-process an image."
 "Ben Mesander"
 "(C) Cardinal Peak, 2011"
 "*"
 SF-IMAGE "The Image" 0
 SF-DRAWABLE "The Layer" 0
)
(script-fu-menu-register "210-xpro" "<Image>/Script-Fu/Color")
