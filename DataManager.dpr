program DataManager;

uses
  Vcl.Forms,
  Vcl.Themes,
  vcl.Styles,
  UnitDataManager in 'UnitDataManager.pas' {FormDataManager},
  UnitBackupRestore in 'UnitBackupRestore.pas' {FormBackupRestore},
  Vcl.Dialogs; //Para o Showmessage

{$R *.res}

begin
  Try
    TStyleManager.LoadFromFile('PersonalizadoAzul.vsf');
    TStyleManager.TrySetStyle('PersonalizadoAzul');
  Except
    Showmessage('O arquivo PersonalizadoAzul.vsf n�o existe, ser� utilizado o tema padr�o do Windows');
  End;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormDataManager, FormDataManager);
  Application.Run;
end.
