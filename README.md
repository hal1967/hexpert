# hexpert
Lazarus IDE plugin

Our objective is to create some kind o expert, this is a sort of plugin in  Lazarus's IDE similar to "GExperts" (for Delphi).

I particulary use a lot the MessageDialog expert that let me create a preview of the desired dialog and get the right pascal code.

After install we will have an entry in the lazarus tools menu with the name "Message Dialog". In response, this menu will show us a form to configure the window title, message, icon, buttons and some other details. Buttons to output the (ok) command directly to our source code, test what the form would look like, and a button that outputs the code to the clipboard.

The lazarus website via https://wiki.freepascal.org/Extending_the_IDE/ provides information needed for this project.

To integrate our code with Lazarus we will need to create a package (The Lazarus IDE provides this in the menu file, new and then select project). I have called it "hexperts" (lpk). Only one unit "udlgexp" has been included, which contains precisely the form that will be called from the IDE. The IDEIntf packages is required (which gives us access to the IDE elements like the editor, menu and others). LCLBase and FCL are mostly needed by the controls and the form itself.

The form was created as part of a normal executable application just for testing nd development. Later the registration routine (Register) was added in order to notify or link to the IDE that there is an entry in the menu and what is the operation to perform when it is activated.


procedure Register;
begin
  RegisterIDEMenuCommand(itmSecondaryTools,
                         'HExperts',                // name
                         'Message Dialog',          // caption
                         nil,                       // onclic         OnClickMethod TNotifyEvent
                         @ShowMenu            // onclic proc    OnClickProc TNotifyProcedure, procedure(Sender: TObject);
                        );
end;

The first parameter (itmSecondaryTools) points us to the Tools menu and is defined in menuintf (we must include it in the uses section in addition to IDECommands and srceditorintf).

The fifth parameter is the tour that will be executed when the new menu is clicked. This should instantiate the form and shows it to us.


Procedure ShowMenu(Sender : TObject);
begin
  With TfrmMsgDlgExp.Create(Application) do // Create the form
    try
       BtnOk.Enabled := (SourceEditorManagerIntf<>nil) and
                        (SourceEditorManagerIntf.ActiveEditor<>nil); // Editor in use
       ShowModal;
    Finally
       Free;
    end;
end;



Having access to edits would be with the SourceEditorManagerIntf class, if we are integrated to the IDE this class must be defined, otherwise it is likely that we are opening the form from another part (for example a test program). Although the IDE is within our reach, we are not necessarily editing the source code, so we disable the OK button in that case (it is the button that generates the code in pascal), but it is still possible to open the dialog to, for example, test a dialog or bring the code to the clipboard.

At this point, installing the experts involves opening the package use selecting Install (part of "use")

In the code you will find comments regarding the operation, we hope it will be useful.

I must thank the team of people behind GExperts. https://www.gexperts.org/ for the inspiration and the beautiful work done.

Thanks to Michaël Van Canneyt who published in 2005 a precise and clear article "Extending the Lazarus IDE: Menus and the Source
editor."

And of course my thanks to the Lazarus project. https://wiki.freepascal.org/ or https://www.lazarus-ide.org/

