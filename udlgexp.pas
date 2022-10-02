unit uDlgExp;
{
   Sep 27, 2022

   This is my first try for a lazarus plugin.
   So I find very interesting GExperts so I created my own version of
   MessageDialog

   In order to create lazarus extentions

   https://wiki.freepascal.org/Extending_the_IDE#Overview

   Aditional material (very clear specific)

   "Extending the Lazarus IDE: Menus and the Source"
    Michaël Van Canneyt
    October 1, 2005


    Version 1.0.2

       Embed is a csDropDownList

       Controls in result enabled/disabled according embed selection o dialog button

       Save/Load Config ("Save as default")

       Shortcut Alt-Ctrl-M



}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Spin,
  IDECommands, // Access IDE
  menuintf,  // Access IDE's menu
  srceditorintf, // Access Source Editor
  ComCtrls, ExtCtrls;

procedure Register;

const
  Version = 0;

type

  { TfrmMsgDlgExp }

  TfrmMsgDlgExp = class(TForm)
    BtnTest: TButton;
    BtnClipboard: TButton;
    BtnOK: TButton;
    BtnCancel: TButton;
    ChkQuoted: TCheckBox;
    HelpCancel: TButton;
    cbmbAll: TCheckBox;
    cbmbNoToAll: TCheckBox;
    cbmbYesToAll: TCheckBox;
    cbmbHelp: TCheckBox;
    cbmrYes: TCheckBox;
    cbmrNo: TCheckBox;
    cbmrOK: TCheckBox;
    cbmrCancel: TCheckBox;
    cbmrAbort: TCheckBox;
    cbmrRetry: TCheckBox;
    ChkAutoSave: TCheckBox;
    cbmrIgnore: TCheckBox;
    cbmrAll: TCheckBox;
    cbmrNoToAll: TCheckBox;
    cbmrYesToAll: TCheckBox;
    cbmrNone: TCheckBox;
    cbmbClose: TCheckBox;
    cbmbYes: TCheckBox;
    cbIDOK: TCheckBox;
    cbIDCANCEL: TCheckBox;
    cbIDABORT: TCheckBox;
    cbIDRETRY: TCheckBox;
    cbIDIGNORE: TCheckBox;
    cbIDYES: TCheckBox;
    cbIDNO: TCheckBox;
    cbIDCLOSE: TCheckBox;
    cbIDHELP: TCheckBox;
    cbmbNo: TCheckBox;
    cbmbOK: TCheckBox;
    cbmbCancel: TCheckBox;
    cbmbAbort: TCheckBox;
    cbmbRetry: TCheckBox;
    cbmbIgnore: TCheckBox;
    CmbEmbed: TComboBox;
    EdCaption: TEdit;
    GrpRstBox: TGroupBox;
    GrpBtns: TGroupBox;
    GrpRst: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    mmMsg: TMemo;
    PageControl1: TPageControl;
    RBBtnsBoxRBDlgTypeBox: TRadioGroup;
    RBDlgType: TRadioGroup;
    RBDlgTypeBox: TRadioGroup;
    SeHelpContext: TSpinEdit;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    procedure BtnTestClick(Sender: TObject);
    procedure BtnClipboardClick(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure CmbEmbedChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpCancelClick(Sender: TObject);
    procedure RBBtnsBoxRBDlgTypeBoxClick(Sender: TObject);
  private
    DataDir : string;
    FileVersion: integer;
    function GenCommand(xpos : longint = 0): String;
    function GenCommandBox(xpos : longint = 0): String;
    procedure ExecCmm;
    procedure ExecCmmBox;
    function CondQuotedStr(const aStr : String): string;
    procedure SaveConfig;
    procedure LoadConfig;
    procedure SetFunctionRst;
    procedure SetFunctionRstFromCtrl(Sender: TObject);
    procedure SetFunctionRstBox;
  public

  end;

// frmMsgDlgExp is as part of TAppliction, but now we don't need it
// because ShowMenu instantiate the TfrmMsgDlgExp class
//var
//  frmMsgDlgExp: TfrmMsgDlgExp;

implementation

{$R *.lfm}

uses clipbrd, LCLType, LCLProc, BaseIDEIntf,LazConfigStorage, LazIDEIntf;

{ TfrmMsgDlgExp }

procedure TfrmMsgDlgExp.BtnClipboardClick(Sender: TObject);
begin
  if PageControl1.ActivePageIndex = 0 then
     clipboard.AsText:= GenCommand               // MessageDlg
  else
     clipboard.AsText:= GenCommandBox            // MessageBox
end;

procedure TfrmMsgDlgExp.BtnOKClick(Sender: TObject);
Var
  Editor : TSourceEditorInterface;
begin
  // Code Generated to editor

  // SourceEditorManagerIntf part of lazarus IDE to access the code under Editor
  if SourceEditorManagerIntf=nil then exit;  // No code in edition

  Editor:= SourceEditorManagerIntf.ActiveEditor; // Current editor

  If (Editor=Nil) then  // or (Not Editor.SelectionAvailable) then
     Exit; // Nothing to do

  if Editor.ReadOnly then exit; // Nothing can be write down

  Editor.SelEnd:= Editor.SelStart;   // No selecion, not overwrite preselected code

  if PageControl1.ActivePageIndex = 0 then
     Editor.Selection:= GenCommand(Editor.CursorTextXY.X)  // MessageDialog
  else
     Editor.Selection:= GenCommandBox(Editor.CursorTextXY.X) // MessageBox
end;

procedure TfrmMsgDlgExp.CmbEmbedChange(Sender: TObject);
begin
  SetFunctionRst;
  SetFunctionRstBox;
end;

procedure TfrmMsgDlgExp.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  SaveConfig;
end;

procedure TfrmMsgDlgExp.FormCreate(Sender: TObject);
begin
  if assigned(LazarusIDE) then
    DataDir := SysUtils.IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath)    // Place for config
  else
    DataDir := ExtractFilePath(paramstr(0));

  LoadConfig;
end;

procedure TfrmMsgDlgExp.FormShow(Sender: TObject);
var
   i : integer;
begin
  CmbEmbedChange(nil);  // GrpRst  on/off (after recover default data);

  // Every Button selected could enabled a result
  for i := 0 to  Pred(GrpBtns.ControlCount) do
    TCheckBox(GrpBtns.Controls[i]).OnClick := @SetFunctionRstFromCtrl
end;

procedure TfrmMsgDlgExp.HelpCancelClick(Sender: TObject);
begin
  Forms.Application.MessageBox('No implemented', 'Warning', MB_OK);
end;

procedure TfrmMsgDlgExp.RBBtnsBoxRBDlgTypeBoxClick(Sender: TObject);
begin
  SetFunctionRstBox
end;

// Show the dialog as preview
procedure TfrmMsgDlgExp.BtnTestClick(Sender: TObject);
begin
  if PageControl1.ActivePageIndex=0 then
     ExecCmm
  else
     ExecCmmBox
end;

{
   Each Dlg type has a constant (DlgTypStr )value 0, $10, $20, $30....
         (0, 16, 32, 48 ...)

   So index * 16 bring us de right value.

   RBDlgTypeBox.ItemIndex * 16;


   Each CheckBox contenined in GrpBtns has a tag value according position in
      DlgMsgBtnStr and order of MsgButtons.
}

function TfrmMsgDlgExp.GenCommand(xpos : longint = 0): String;
var
  msg, btn : string;
  i : integer;
  // for embebed code incluse if, then case ....
  pre, post, margin : string;
  CBox : TCheckBox;

const
  DlgTypStr : array of string =  ('mtWarning' , 'mtError', 'mtInformation', 'mtConfirmation', 'mtCustom');

  DlgMsgBtnStr : array of string = ('mbYes' , 'mbNo', 'mbOK', 'mbCancel',
                                    'mbAbort', 'mbRetry', 'mbIgnore',
                                    'mbAll', 'mbNoToAll', 'mbYesToAll',
                                    'mbHelp', 'mbClose');

  function GetRstString: string;
  var
       i : integer;
    CBox : TCheckBox;
     tmp : string;
  begin
    tmp := '';
    for i:= 0 to pred(GrpRst.ControlCount) do
      if GrpRst.Controls[i] is TCheckBox then
        begin
          CBox := TCheckBox(GrpRst.Controls[i]);

          if CBox.Enabled and CBox.Checked then
            tmp := tmp + CBox.Caption + ', ';
        end;
    result := Copy(tmp,1,tmp.length-2); // we don't need last comma
  end;

begin
  btn := '[';  // Begin of set

  for i:= 0 to pred(GrpBtns.ControlCount) do
    if GrpBtns.Controls[i] is TCheckBox then
      begin
        CBox := TCheckBox(GrpBtns.Controls[i]);

        if CBox.Checked then
          btn := btn + DlgMsgBtnStr[CBox.Tag] + ', ';
      end;

  // [ mbAbort, mbRetry, mbIgnore,
  // Delete the last comma (and space)

  if btn.length>2 then
       delete(btn, btn.length-1,2);

  btn := btn + ']'; // End of set    // [ mbAbort, mbRetry, mbIgnore]

  // Margin to keep aligment, to use spaces is not the best option.
  margin := StringOfChar(' ' , xpos);


  if CmbEmbed.ItemIndex=1 then // if ... then
    begin
      pre := 'if ';
      post :=  ' in ['+GetRstString+'] then ';
    end
  else if CmbEmbed.ItemIndex=2 then // if not ... then
    begin
      pre := 'if not (';
      post :=  ' in ['+GetRstString+']) then ';
    end
  else if CmbEmbed.ItemIndex=3 then // case
    begin
      pre := 'case ';
      post :=  ' of '#13+margin;
      post := post + StringReplace(GetRstString, ', ', ': ;'#13+margin,
               [rfReplaceAll, rfIgnoreCase]) + ': ;'#13 +margin+'end';
    end
  else
    begin
      pre := '';
      post :=  '';
    end;

  margin := margin + '       ';
  msg := pre + 'MessageDlg( ' +
         QuotedStr(EdCaption.Text) + ', '#13;



  for i:= 0 to mmMsg.Lines.Count-2 do  // Except last line
    msg := msg +  margin + CondQuotedStr(mmMsg.Lines[i]) + '#13 +' +  #13;

  if mmMsg.Lines.Count>0 then  // Last Line, except empty message
    msg := msg +  margin + CondQuotedStr(mmMsg.Lines[mmMsg.Lines.Count-1]) + #13
  else
    msg := msg +  margin + ''''''+#13; // Empty message

  result := msg +
         margin + ', ' +
         DlgTypStr[RBDlgType.Itemindex] + ', ' +
         btn + ', ' + SeHelpContext.Text + ')' + post;
end;

function TfrmMsgDlgExp.GenCommandBox(xpos : longint = 0): String;
var
  flags, post, pre : string;
  margin, msg : string;
  i : integer;
const
  msgbtn : array of string =
  ('MB_OK',
  'MB_OKCANCEL',
  'MB_ABORTRETRYIGNORE',
  'MB_YESNOCANCEL',
  'MB_YESNO',
  'MB_RETRYCANCEL');


  function GetRstString: string;
  var
       i : integer;
    CBox : TCheckBox;
     tmp : string;
  begin
    tmp := '';
    for i:= 0 to pred(GrpRstBox.ControlCount) do
      if GrpRstBox.Controls[i] is TCheckBox then
        begin
          CBox := TCheckBox(GrpRstBox.Controls[i]);

          if CBox.Checked then
            tmp := tmp + CBox.Caption + ', ';
        end;
    result := Copy(tmp,1,tmp.length-2);
  end;

begin
  Case RBDlgTypeBox.ItemIndex of
  1: flags :=  'MB_ICONHAND';
  2: flags :=  'MB_ICONQUESTION';
  3: flags :=  'MB_ICONEXCLAMATION';
  4: flags :=  'MB_ICONASTERISK';
  end;

  if flags>'' then
    flags := flags + ' + '+ msgbtn[RBBtnsBoxRBDlgTypeBox.ItemIndex]
  else
    flags := msgbtn[RBBtnsBoxRBDlgTypeBox.ItemIndex];

  // Margin to keep aligment
  margin := StringOfChar(' ' , xpos);

  if CmbEmbed.ItemIndex=1 then // if ... then
    begin
      pre := 'if ';
      post :=  ' in ['+GetRstString+'] then ';
    end
  else if CmbEmbed.ItemIndex=2 then // if not ... then
    begin
      pre := 'if not (';
      post :=  ' in ['+GetRstString+']) then ';
    end
  else if CmbEmbed.ItemIndex=3 then // case
    begin
      pre := 'case ';
      post :=  ' of '#13+margin;
      post := post + StringReplace(GetRstString, ', ', ': ;'#13+margin,
                     [rfReplaceAll, rfIgnoreCase]) + ': ;'#13 + margin + 'end';
    end
  else
    begin
      pre := '';
      post :=  '';
    end;

  margin := margin + '       ';

  msg := pre + 'Forms.Application.MessageBox('#13;

  for i:= 0 to mmMsg.Lines.Count-2 do
    msg := msg + margin + CondQuotedStr(mmMsg.Lines[i] ) + '#13 +' + #13;

  if mmMsg.Lines.Count>0 then
    msg := msg + margin + CondQuotedStr(mmMsg.Lines[mmMsg.Lines.Count-1] ) + ', '#13;


  result := msg + margin +
        QuotedStr(EdCaption.Text) + ', ' + flags+ ')' + post;

end;

procedure TfrmMsgDlgExp.ExecCmm;
var
  btn : TMsgDlgButtons;
  i : integer;

  CBox : TCheckBox;
{
const
  DlgTypStr : array of string =  ('mtWarning' , 'mtError', 'mtInformation', 'mtConfirmation', 'mtCustom');

  DlgMsgBtnStr : array of string = ('mbYes' , 'mbNo', 'mbOK', 'mbCancel',
                                    'mbAbort', 'mbRetry', 'mbIgnore',
                                    'mbAll', 'mbNoToAll', 'mbYesToAll',
                                    'mbHelp', 'mbClose');
}

begin
  btn := [];

  for i:= 0 to pred(GrpBtns.ControlCount) do
    if GrpBtns.Controls[i] is TCheckBox then
      begin
        CBox := TCheckBox(GrpBtns.Controls[i]);

        if CBox.Checked then
          Include( btn, TMsgDlgBtn(CBox.Tag));
      end;

  MessageDlg( EdCaption.Text,
             mmMsg.Lines.Text ,
             TMsgDlgType(RBDlgType.Itemindex) ,
             btn ,
             SeHelpContext.Value);


end;

//  This called from Test button and is related to MessageBox rutine.
procedure TfrmMsgDlgExp.ExecCmmBox;
var
  flags : integer;
begin
  flags := Succ(RBDlgTypeBox.ItemIndex) * 16;

  flags := flags + RBBtnsBoxRBDlgTypeBox.ItemIndex;

  Forms.Application.MessageBox(PChar(mmMsg.Lines.Text), PChar(EdCaption.Text), flags);
end;

function TfrmMsgDlgExp.CondQuotedStr(const aStr: String): string;
begin
  if ChkQuoted.Checked then
    result := QuotedStr(aStr)
  else
    result := aStr
end;

// Sample:  https://wiki.freepascal.org/Extending_the_IDE/es#Cargar.2FSalvar_configuraciones
procedure TfrmMsgDlgExp.SaveConfig;
var
  Config: TConfigStorage;
  flag, i : integer;
  cb : TCheckbox;
begin
  if GetIDEConfigStorage = nil then exit;
  try
    Config:=GetIDEConfigStorage(DataDir+ 'hexperts.xml',false);
    try
     Config.SetDeleteValue('MessageDialog/Version',Version,0);
     Config.SetDeleteValue('MessageDialog/AutoSave',ChkAutoSave.Checked,false);

     if ChkAutoSave.Checked then
       begin
        Config.SetDeleteValue('MessageDialog/Page',PageControl1.ActivePageIndex , 0);
        Config.SetDeleteValue('MessageDialog/Embed',CmbEmbed.Itemindex , 0);
        Config.SetDeleteValue('MessageDialog/Caption', EdCaption.Text, 'Message');
        Config.SetDeleteValue('MessageDialog/msgf', mmMsg.Text, '');
        Config.SetDeleteValue('MessageDialog/hcontext', SeHelpContext.Value, 0);

        Config.SetDeleteValue('MessageDialog/Quoted',ChkQuoted.Checked, true);
        Config.SetDeleteValue('MessageDialog/MsgDlg/DlgType',RBDlgType.ItemIndex, 2);

        // MessageDialog Buttons
        // Each Checkbox has a tag 1,2,3....
        // So we set a bit 1 oer 0 according the position indexed by the tag

        flag := 0;
        for i:= 0 to Pred(GrpBtns.ControlCount) do
          if TCheckBox(GrpBtns.Controls[i]).Checked then
             flag := flag or (1 shl TCheckBox(GrpBtns.Controls[i]).Tag);

        Config.SetDeleteValue('MessageDialog/MsgDlg/Btn', flag, 0);

        for i:= 0 to Pred(GrpRst.ControlCount) do
          begin
            cb := TCheckBox(GrpRst.Controls[i]);
            Config.SetDeleteValue('MessageDialog/MsgDlg/'+cb.Caption,cb.Checked, false );
          end;

        Config.SetDeleteValue('MessageDialog/MsgBox/DlgType', RBDlgTypeBox.ItemIndex, 0);
        Config.SetDeleteValue('MessageDialog/MsgBox/Btn', RBBtnsBoxRBDlgTypeBox.ItemIndex, 0);

        // MessageBox result
        // Each Checkbox has a tag 1,2,3....
        // So we set a bit 1 oer 0 according the position indexed by the tag

        flag := 0;
        for i:= 0 to Pred(GrpRstBox.ControlCount) do
          if TCheckBox(GrpRstBox.Controls[i]).Checked then
             flag := flag or (1 shl TCheckBox(GrpRstBox.Controls[i]).Tag);

        Config.SetDeleteValue('MessageDialog/MsgBox/Rst', flag, 0);


       end;


    finally
      Config.Free;
    end;
  except
    on E: Exception do begin
      DebugLn(['Saving hexperts.xml failed: ',E.Message]);
    end;
  end;
end;

procedure TfrmMsgDlgExp.LoadConfig;
var
  Config: TConfigStorage;
  flag, i : integer;
  cb : TCheckBox;
begin
  if GetIDEConfigStorage = nil then exit;
  try
    Config:=GetIDEConfigStorage( DataDir+ 'hexperts.xml',true);
    try
      // read the version of the config
      FileVersion:= Config.GetValue('MessageDialog/Version',0);
      ChkAutoSave.Checked:=Config.GetValue('MessageDialog/AutoSave',false);

     if ChkAutoSave.Checked then
       begin
         // Select MessageDiaolgo or MessageBox
         PageControl1.ActivePageIndex := Config.GetValue('MessageDialog/Page', 0);


         CmbEmbed.Itemindex := Config.GetValue('MessageDialog/Embed', 0);
         EdCaption.Text:=  Config.GetValue('MessageDialog/Caption', 'Message');
         mmMsg.Text:= Config.GetValue('MessageDialog/msgf', '');
         SeHelpContext.Value :=  Config.GetValue('MessageDialog/hcontext', 0);
         ChkQuoted.Checked:= Config.GetValue('MessageDialog/Quoted',true);

         RBDlgType.ItemIndex:= Config.GetValue('MessageDialog/MsgDlg/DlgType', 2);

         // MessageDialog Buttons
         // Each Checkbox has a tag 1,2,3....
         // So we set a bit 1 oer 0 according the position indexed by the tag

         flag := Config.GetValue('MessageDialog/MsgDlg/Btn', 0);
         for i:= 0 to Pred(GrpBtns.ControlCount) do
           TCheckBox(GrpBtns.Controls[i]).Checked := ((1 shl TCheckBox(GrpBtns.Controls[i]).Tag) and flag)<>0;


         // The results are stored/assembled by the caption
         for i:= 0 to Pred(GrpRst.ControlCount) do
           begin
             cb := TCheckBox(GrpRst.Controls[i]);
             cb.Checked :=  Config.GetValue('MessageDialog/MsgDlg/'+cb.caption, false );
           end;

         RBDlgTypeBox.ItemIndex:= Config.GetValue('MessageDialog/MsgBox/DlgType', 0);
         RBBtnsBoxRBDlgTypeBox.ItemIndex:= Config.GetValue('MessageDialog/MsgBox/Btn', 0);


         // MessageBox result
         // Each Checkbox has a tag 1,2,3....
         // So we set a bit 1 oer 0 according the position indexed by the tag

         flag := Config.GetValue('MessageDialog/MsgBox/Rst', 0);
         for i:= 0 to Pred(GrpRstBox.ControlCount) do
           TCheckBox(GrpRstBox.Controls[i]).Checked := ((1 shl TCheckBox(GrpRstBox.Controls[i]).Tag) and flag)<>0


       end;

    finally
      Config.Free;
    end;
  except
    on E: Exception do begin
      DebugLn(['Loading hexperts.xml failed: ',E.Message]);
    end;
  end
end;
// Each button  y related with a function result
procedure TfrmMsgDlgExp.SetFunctionRst;
var
  i : integer;
  mrname, mbname : string;
  mrcb, mbcb : TCheckBox;
begin
  if CmbEmbed.ItemIndex=0 then
    for i:= 0 to pred(GrpRst.ControlCount) do
      TCheckBox(GrpRst.Controls[i]).Enabled:= false
  else
   begin
     cbmrNone.Enabled:= true;
     for i:= 0 to pred(GrpRst.ControlCount) do
       begin
          mrcb := TCheckBox(GrpRst.Controls[i]);
          mrname := mrcb.name;
          if mrname <> 'cbmrNone' then
            begin
               mbname := 'cbmb' + mrname.Substring(4);
               mbcb := TCheckBox(GrpBtns.FindChildControl(mbname));
               if (mbcb<>nil) then
                 mrcb.Enabled := mbcb.Checked;
            end;
       end;

   end
end;

procedure TfrmMsgDlgExp.SetFunctionRstFromCtrl(Sender: TObject);
begin
  SetFunctionRst
end;

procedure TfrmMsgDlgExp.SetFunctionRstBox;
var
  i : integer;
begin
  if CmbEmbed.ItemIndex=0 then     // All disabled
    for i:= 0 to pred(GrpRstBox.ControlCount) do
      TCheckBox(GrpRstBox.Controls[i]).Enabled:= false
  else
   begin
     cbIDHELP.Enabled:= true;
     cbIDCLOSE.Enabled:= true;

     cbIDNO.Enabled:= RBBtnsBoxRBDlgTypeBox.ItemIndex in [ MB_YESNO, MB_YESNOCANCEL];
     cbIDYes.Enabled:= RBBtnsBoxRBDlgTypeBox.ItemIndex in [ MB_YESNO, MB_YESNOCANCEL];

     cbIDIGNORE.Enabled:= RBBtnsBoxRBDlgTypeBox.ItemIndex = MB_ABORTRETRYIGNORE;
     cbIDRETRY.Enabled:= RBBtnsBoxRBDlgTypeBox.ItemIndex in [MB_ABORTRETRYIGNORE, MB_RETRYCANCEL];
     cbIDABORT.Enabled:= RBBtnsBoxRBDlgTypeBox.ItemIndex = MB_ABORTRETRYIGNORE;

     cbIDCANCEL.Enabled:= RBBtnsBoxRBDlgTypeBox.ItemIndex in [ MB_OKCANCEL, MB_YESNOCANCEL, MB_RETRYCANCEL];
     cbIDOK.Enabled:= RBBtnsBoxRBDlgTypeBox.ItemIndex in [ MB_OKCANCEL, MB_OK, MB_RETRYCANCEL];
   end
end;

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




// For the code related to Shortcut
//   Michaël Van Canneyt "Extending the Lazarus IDE: Menus and the Source editor."
procedure Register;
Var
  Key : TIDEShortCut;
  Cat : TIDECommandCategory;

  Command: TIDECommand;
begin
  Cat:=IDECommandList.CreateCategory(Nil,
      'hExpert',
      'Expert to use MessageDialog or MessageBox',
      IDECmdScopeSrcEdit);

  Key:=IDEShortCut(VK_M,[SSctrl,ssAlt],VK_UNKNOWN,[]);

  Command:=RegisterIDECommand(Cat,
      'Message Dialog',
      'Expert to use MessageDialog or MessageBox',
      Key);


  RegisterIDEMenuCommand(itmSecondaryTools,
                         'HExperts',                // name
                         'Message Dialog',          // caption
                         nil,                       // onclic         OnClickMethod TNotifyEvent
                         @ShowMenu,             // onclic proc    OnClickProc TNotifyProcedure, procedure(Sender: TObject);
                         Command
                        );



end;

end.

