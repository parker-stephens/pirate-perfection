local M_dialog = managers.dialog

plugins:new_plugin("shutdown_dialogs")

VERSION = "1.0"

DESCRIPTION = "No more dialogs"

function MAIN()
	M_dialog.old_dialog_list = M_dialog._dialog_list
	M_dialog._dialog_list = {}
end

function UNLOAD()
	M_dialog._dialog_list = M_dialog.old_dialog_list or M_dialog._dialog_list
end

FINALIZE()