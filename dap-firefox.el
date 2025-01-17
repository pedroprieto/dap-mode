;;; dap-firefox.el --- Debug Adapter Protocol mode for Firefox      -*- lexical-binding: t; -*-

;; Copyright (C) 2019  Ivan Yonchovski

;; Author: Ivan Yonchovski <yyoncho@gmail.com>
;; Keywords: languages

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;; URL: https://github.com/yyoncho/dap-mode
;; Package-Requires: ((emacs "25.1") (dash "2.14.1") (lsp-mode "4.0"))
;; Version: 0.2

;;; Commentary:
;; Adapter for https://github.com/firefoxide/vscode-firefox

;;; Code:

(require 'dap-mode)
(require 'dap-utils)

(defcustom dap-firefox-debug-path (expand-file-name "vscode/firefox-devtools.vscode-firefox-debug"
                                                    dap-utils-extension-path)
  "The path to firefox vscode extension."
  :group 'dap-firefox
  :type 'string)

(defcustom dap-firefox-debug-program `("node"
                                       ,(f-join dap-firefox-debug-path
                                                "extension/out/firefoxDebugAdapter.js"))
  "The path to the firefox debugger."
  :group 'dap-firefox
  :type '(repeat string))

(dap-utils-vscode-setup-function "dap-firefox" "firefox-devtools" "vscode-firefox-debug"
                                 dap-firefox-debug-path)

(defun dap-firefox--populate-start-file-args (conf)
  "Populate CONF with the required arguments."
  (setq conf (-> conf
                 (plist-put :type "firefox")
                 (plist-put :dap-server-path dap-firefox-debug-program)
                 (dap--put-if-absent :cwd (expand-file-name default-directory))))

  (dap--plist-delete
   (pcase (plist-get conf :mode)
     ("url" (-> conf
                (dap--put-if-absent :url (read-string
                                          "Browse url: "
                                          "http://localhost:5371" t))
                (dap--put-if-absent :webRoot (lsp-workspace-root))))

     ("file" (dap--put-if-absent conf :file
		 (read-file-name "Select the file to open in the browser:" nil (buffer-file-name) t)))
     (_ conf))
   :mode))

(dap-register-debug-provider "firefox" 'dap-firefox--populate-start-file-args)

(dap-register-debug-template "Firefox Browse File"
                             (list :type "firefox"
                                   :mode "file"
                                   :cwd nil
                                   :request "launch"
                                   :file nil
                                   :reAttach t
				   :program nil
                                   :name "Firefox Browse File"))

(dap-register-debug-template "Firefox Browse URL"
                             (list :type "firefox"
                                   :mode "url"
                                   :cwd nil
                                   :request "launch"
                                   :webRoot nil
                                   :url nil
                                   :reAttach t
                                   :program nil
                                   :name "Firefox Browse URL"))


(provide 'dap-firefox)
;;; dap-firefox.el ends here
