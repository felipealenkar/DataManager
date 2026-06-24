program DataManager;

uses
  Vcl.Forms,
  Vcl.Themes,
  vcl.Styles,
  Vcl.Dialogs,
  Repository.GerenciadorBackup in 'src\Repository.GerenciadorBackup.pas',
  View.BackupRestore in 'src\View.BackupRestore.pas' {FrmBackupRestore},
  View.DataManager in 'src\View.DataManager.pas' {FrmDataManager},
  Utils.Funcoes in 'src\Utils.Funcoes.pas';

//Para o Showmessage

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
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
