;
; This file is part of ArtPRO.
; Copyright (C) 1996-2018 Frank Pagels
;
; ArtPRO is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; ArtPRO is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with ArtPRO.  If not, see <http://www.gnu.org/licenses/>.
;


	xdef	_main
	xref	_jpeg_CreateCompress

	section	text

_main:
	
	jsr	_jpeg_CreateCompress


	END

