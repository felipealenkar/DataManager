program DataManager;

uses
  Vcl.Forms,
  Vcl.Themes,
  vcl.Styles,
  Tela.DataManager in 'Tela.DataManager.pas' {FrmDataManager},
  Tela.BackupRestore in 'Tela.BackupRestore.pas' {FrmBackupRestore},
  Vcl.Dialogs,
  Database.GerenciadorBackup in 'Database.GerenciadorBackup.pas';

//Para o Showmessage

{$R *.res}

begin
  Try
    TStyleManager.LoadFromFile('PersonalizadoAzul.vsf');
    TStyleManager.TrySetStyle('PersonalizadoAzul');
  Except
    Showmessage('O arquivo PersonalizadoAzul.vsf não existe, será utilizado o tema padrão do Windows');
  End;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmDataManager, FrmDataManager);
  Application.Run;
end.
