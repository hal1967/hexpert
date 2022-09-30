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

type

  { TfrmMsgDlgExp }

  TfrmMsgDlgExp = class(TForm)
    BtnTest: TButton;
    BtnClipboard: TButton;
    BtnOK: TButton;
    BtnCancel: TButton;
    ChkQuoted: TCheckBox;
    HelpCancel: TButton;
    CheckBox10: TCheckBox;
    CheckBox11: TCheckBox;
    CheckBox12: TCheckBox;
    CheckBox13: TCheckBox;
    CheckBox14: TCheckBox;
    CheckBox15: TCheckBox;
    CheckBox16: TCheckBox;
    CheckBox17: TCheckBox;
    CheckBox18: TCheckBox;
    CheckBox19: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox20: TCheckBox;
    CheckBox21: TCheckBox;
    CheckBox22: TCheckBox;
    CheckBox23: TCheckBox;
    CheckBox24: TCheckBox;
    CheckBox25: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox31: TCheckBox;
    CheckBox32: TCheckBox;
    CheckBox33: TCheckBox;
    CheckBox34: TCheckBox;
    CheckBox35: TCheckBox;
    CheckBox36: TCheckBox;
    CheckBox37: TCheckBox;
    CheckBox38: TCheckBox;
    CheckBox39: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    CheckBox9: TCheckBox;
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
    RBBtnsBoxRBDlgTypeBox1: TRadioGroup;
    RBDlgType: TRadioGroup;
    RBDlgTypeBox: TRadioGroup;
    SeHelpContext: TSpinEdit;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    procedure BtnTestClick(Sender: TObject);
    procedure BtnClipboardClick(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure CmbEmbedChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpCancelClick(Sender: TObject);
  private
    function GenCommand(xpos : longint = 0): String;
    function GenCommandBox(xpos : longint = 0): String;
    procedure ExecCmm;
    procedure ExecCmmBox;
    function CondQuotedStr(const aStr : String): string;
  public

  end;

// frmMsgDlgExp is as part of TAppliction, but now we don't need it
// because ShowMenu instantiate the TfrmMsgDlgExp class
//var
//  frmMsgDlgExp: TfrmMsgDlgExp;

implementation

{$R *.lfm}

uses clipbrd, LCLType;

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
  { #todo : This must be done Checkbox by Checkbox acording buttons selected }
  // There is not sense, por example, set the case por btRetry when isn't an option in the dialog.

  GrpRst.Enabled := CmbEmbed.ItemIndex>0;
  GrpRstBox.Enabled := CmbEmbed.ItemIndex>0;
end;

procedure TfrmMsgDlgExp.FormShow(Sender: TObject);
begin
  CmbEmbedChange(nil);  // GrpRst  on/off (after recover default data)
end;

procedure TfrmMsgDlgExp.HelpCancelClick(Sender: TObject);
begin
  Forms.Application.MessageBox('No implemented', 'Warning', MB_OK);
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

          if CBox.Checked then
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
    flags := flags + ' + '+ msgbtn[RBBtnsBoxRBDlgTypeBox1.ItemIndex]
  else
    flags := msgbtn[RBBtnsBoxRBDlgTypeBox1.ItemIndex];

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

  flags := flags + RBBtnsBoxRBDlgTypeBox1.ItemIndex;

  Forms.Application.MessageBox(PChar(mmMsg.Lines.Text), PChar(EdCaption.Text), flags);
end;

function TfrmMsgDlgExp.CondQuotedStr(const aStr: String): string;
begin
  if ChkQuoted.Checked then
    result := QuotedStr(aStr)
  else
    result := aStr
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



{ #todo : Default Button , probable using XML}

procedure Register;
begin
  RegisterIDEMenuCommand(itmSecondaryTools,
                         'HExperts',                // name
                         'Message Dialog',          // caption
                         nil,                       // onclic         OnClickMethod TNotifyEvent
                         @ShowMenu            // onclic proc    OnClickProc TNotifyProcedure, procedure(Sender: TObject);
                        );
end;

end.

