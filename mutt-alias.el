;; Copyright (C) 2014 by Paul Roberts <pmr@stelo.org.uk>
;;
;;
;; This file is not part of GNU Emacs.
;;
;; This is free software; you can redistribute it and/or modify it under
;; the terms of the GNU General Public License as published by the Free
;; Software Foundation; either version 2, or (at your option) any later
;; version.
;;
;; This is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
;; FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
;; for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
;; MA 02111-1307, USA.

(defvar mutt-alias-regexp "^alias\\s-+\\(\\sw+\\)\\s-+\\(.*\\)$"
  "Regex that matches a mutt alias")

(defvar mutt-alias-alist nil
  "Alist of the aliases that have been read from a mutt alias file")

(defvar mutt-alias-default-file
  (expand-file-name "~/.mutt/alias.rc"))

(defun mutt-alias-from-string (str)
  (if (string-match mutt-alias-regexp str)
	  (mutt-alias-from-match str)))

(defun mutt-alias-from-match (&optional str)
  (cons (match-string 1 str) (match-string 2 str)))

(defun mutt-alias-next ()
  "Searches for the next alias in the current buffer from point, leaving point at the end of that match. Returns a cons element which matches the alias, or nil if not found"
  (interactive)
  (if (search-forward-regexp mutt-alias-regexp nil t)
	  (mutt-alias-from-match)))

(defun mutt-alias-read-buffer-to-alist ()
  "Starting from point, keep search for alias in the current buffer until there are no more. Return an alist representing the aliases found"
  (let (ret alias)
	(while (setq alias (mutt-alias-next))
	  (setq ret (cons alias ret)))
	ret))

(defun mutt-alias-load-file (path)
  (interactive "fAlias file: ")
  (with-temp-buffer
	(insert-file-contents path)
	(setq mutt-alias-alist (mutt-alias-read-buffer-to-alist))
	(message "Read %d aliases" (length mutt-alias-alist))))

(defun mutt-alias-get-alist ()
  "Returns the mutt alias alist if it is exists, otherwise, tries
to load it from the default file"
  (unless mutt-alias-alist
	(mutt-alias-load-file mutt-alias-default-file))
  mutt-alias-alist)

(defun mutt-alias-get-keys ()
  (let (ret
		(alist (mutt-alias-get-alist)))
	(while (car alist)
	  (setq ret (cons (car (car alist)) ret))
	  (setq alist (cdr alist)))
	ret))

(defun mutt-alias-lookup (key)
  (cdr (assoc key (mutt-alias-get-alist))))

(defun mutt-alias-insert (key)
  (interactive 
   (list (completing-read "Alias to insert: " (mutt-alias-get-keys))))
  (insert (mutt-alias-lookup key)))
