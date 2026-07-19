program DataManager;

uses
  Vcl.Forms,
  Vcl.Themes,
  vcl.Styles,
  Vcl.Dialogs,
  Repository.GerenciadorBackup in 'src\Repository.GerenciadorBackup.pas',
  View.BackupRestore in 'View.BackupRestore.pas' {FrmBackupRestore},
  View.DataManager in 'View.DataManager.pas' {FrmDataManager};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Smokey Quartz Kamri');
  Application.CreateForm(TFrmDataManager, FrmDataManager);
  Application.Run;
end.
