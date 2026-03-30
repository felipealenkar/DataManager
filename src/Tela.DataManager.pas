unit Tela.DataManager;

interface

uses
  //Padrao do VCL Form
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  //Automáticas
  FireDAC.Phys.PG, FireDAC.Phys.PGDef, System.ImageList, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, Data.DB, FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.Comp.Client,
  Vcl.StdCtrls, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, Vcl.Grids, Vcl.DBGrids, Vcl.ImgList,
  Vcl.VirtualImageList, Vcl.BaseImageCollection, Vcl.ImageCollection,  Vcl.ExtCtrls,
  //Adicionadas
   System.IOUtils, ShellAPI, System.UITypes, Utils.Funcoes, Database.GerenciadorBackup,
  //Retirei e não deu erro
  Math, DateUtils, TypInfo, FireDAC.Phys.FBDef, FireDAC.Phys.IBBase, FireDAC.Phys.FB, Vcl.ComCtrls, StrUtils, System.SyncObjs, Vcl.DBCtrls,
  FireDAC.Comp.UI, Vcl.Buttons, FireDAC.Phys.IBWrapper, FireDAC.Phys.IB, System.RegularExpressions;

type
  TFrmDataManager = class(TForm)
    BtnConectarBD: TButton;
    DataSourceBD: TDataSource;
    ImgcolManager: TImageCollection;
    VimglstManager: TVirtualImageList;
    EdtHost: TEdit;
    LblHost: TLabel;
    LblPorta: TLabel;
    EdtPorta: TEdit;
    LblUsuario: TLabel;
    EdtUsuario: TEdit;
    LblSenha: TLabel;
    EdtSenha: TEdit;
    PnlConexao: TPanel;
    BtnDesconectar: TButton;
    BtnNovoDataBase: TButton;
    PnlGerenciar: TPanel;
    BtnAtualizar: TButton;
    BtnRenomearDatabase: TButton;
    BtnExcluirDatabase: TButton;
    BtnFazerBackupDatabase: TButton;
    BtnFazerRestoreDatabase: TButton;
    LbxDatabases: TListBox;
    LblDriverConectado: TLabel;
    LblVersaoPg: TLabel;
    CbxVersao: TComboBox;
    PnlDatabases: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure BtnConectarBDClick(Sender: TObject);
    procedure BtnDesconectarClick(Sender: TObject);
    procedure BtnNovoDataBaseClick(Sender: TObject);
    procedure BtnAtualizarClick(Sender: TObject);
    procedure BtnRenomearDatabaseClick(Sender: TObject);
    procedure BtnExcluirDatabaseClick(Sender: TObject);
    procedure BtnFazerBackupDatabaseClick(Sender: TObject);
    procedure BtnFazerRestoreDatabaseClick(Sender: TObject);
    procedure LbxDatabasesClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    procedure ConectarDatabase;
    procedure DesconectarDatabase;
    procedure AtualizarListaBancos(PStatusConexao: Boolean);
    procedure ExcluirDatabase;
    procedure HabilitarDesabilitarElementos(PStatusConexao, PBancoSelecionado: Boolean);
    procedure NovoDatabase;
    procedure ValidarRenomearDatabase;

    function CapturarNomeDoDatabase(PNomeDoDatabase: string; OUT PDigitou: boolean):string;
    function ValidarSeDatabaseExiste(PNomeDoDatabase: String): boolean;
  public
    GerenciadorBackup: TGerenciadorBackup;
    Const VersaoMinimaPostgre: currency = 17;
end;

var
  FrmDataManager: TFrmDataManager;
  CaminhoDoArquivoDeLog: string;

implementation

uses
  Tela.BackupRestore;

{$R *.dfm}

function TFrmDataManager.CapturarNomeDoDatabase(PNomeDoDatabase: string; OUT PDigitou: boolean): string;
// Colhe o nome do database digitado e o retorna
begin
  repeat
    begin
      PDigitou := InputQuery('Nome do Database', 'Digite o nome do novo banco de dados', PNomeDoDatabase);
      if PDigitou and (PNomeDoDatabase = '') then
      MessageBox(Application.Handle,
                PChar('O nome do banco de dados não pode ser vazio.'),
                PChar('Digitação de nome do database.'),
                MB_OK or MB_ICONWARNING);
    end;
  until (not PDigitou) or (PNomeDoDatabase <> '');
  Result:= PNomeDoDatabase;
  RegistrarLogs('TFormDataManager.CapturarNomeDoDatabase', 'Nome do database "' + PNomeDoDatabase +
                '" capturado - Parâmetro Out foi "' + BoolToStr(PDigitou) + '"');
end;

procedure TFrmDataManager.ConectarDatabase;
//Método que conecta ao banco de dados
var
  VersaoCompleta: String;
begin
  if (CbxVersao.ItemIndex = -1) then
    MessageBox(Application.Handle, PChar('Selecione a versão do PostgreSQL.'), PChar('Versão do PostgrSQL.'), MB_OK or MB_ICONINFORMATION)
  else
  begin
    try
      GerenciadorBackup.DefinirParametros(EdtHost.text, EdtPorta.Text, EdtUsuario.Text, 'postgres', EdtSenha.Text,
                                        StrToCurr(CbxVersao.Text));
      GerenciadorBackup.Conectar;
      GerenciadorBackup.VerificarVersaoPostgres(VersaoCompleta);
      HabilitarDesabilitarElementos(True, False);
      AtualizarListaBancos(True);
      LblDriverConectado.Caption := VersaoCompleta;
      LblDriverConectado.font.Color := ClBlue;
      RegistrarLogs('TFormDataManager.BtnConectarBDClick',
                        'Conexão com o banco de dados "' + GerenciadorBackup.Connection.DriverName + '" feita com sucesso');
    Except
      On E: Exception do
      begin
        RegistrarLogs('TFrmDataManager.BtnConectarBDClick', E.ClassName + ' ' + E.Message);
        MessageBox(Application.Handle,
                  PChar('Não foi possível conectar ao banco de dados.' + sLineBreak + sLineBreak +
                    'Classe: ' + E.ClassName + sLineBreak + sLineBreak +
                    'Detalhes do erro: ' + E.Message),
                  PChar('Conexão com o PostgrSQL.'),
                  MB_OK or MB_ICONERROR);
      end;
    end;
  end;
end;

procedure TFrmDataManager.DesconectarDatabase;
//Método que desconecta ao banco de dados
begin
  GerenciadorBackup.Desconectar;
  HabilitarDesabilitarElementos(False, False);
  AtualizarListaBancos(False);
  LblDriverConectado.Caption := 'Nenhum banco de dados conectado';
  LblDriverConectado.font.Color := ClRed;
  RegistrarLogs('TFormDataManager.BtnDesconectarClick',
                'Conexão com o banco de dados "' + GerenciadorBackup.Connection.DriverName + '" encerrada com sucesso');
end;

procedure TFrmDataManager.ExcluirDatabase;
//Método que faz validação antes da exclusão do databasse.
var
  NomeDoDatabase, POwnerBD, Versao: string;
  ConfircamaoExcluirDatabase: TModalResult;
begin
  try
    RegistrarLogs('TFormDataManager.BtnExcluirDatabaseClick', ' Usuário clicou no botão "' + BtnExcluirDatabase.Name + '".');
    POwnerBD := '';
    HabilitarDesabilitarElementos(True, False);
    NomeDoDatabase := LbxDatabases.Items[LbxDatabases.ItemIndex];
    if not (GerenciadorBackup.VerificarVersaoPostgres(Versao) < GerenciadorBackup.PgVersaoMinima) then
    begin
      if GerenciadorBackup.ValidarOwnerDatabase(NomeDoDatabase, GerenciadorBackup.OwnerPadrao, POwnerBD) then
      begin
        ConfircamaoExcluirDatabase := MessageBox(Application.Handle,
                                                PChar('Tem certeza que deseja excluir o Database "' + NomeDoDatabase + '" ?'),
                                                PChar('Exclusão de database.'),
                                                MB_YESNO or MB_ICONQUESTION);
        if ConfircamaoExcluirDatabase = IDYES then
        begin
          RegistrarLogs('TFormDataManager.BtnExcluirDatabaseClick', 'Usuário confirmou a exclusão do banco de dados "' + NomeDoDatabase + '".');
          GerenciadorBackup.RemoverPermissoesNosRoles(NomeDoDatabase);
          GerenciadorBackup.DroparRoles(NomeDoDatabase);
          GerenciadorBackup.DroparDataBase(NomeDoDatabase);
          MessageBox(Application.Handle,
                    PChar('Database "' + NomeDoDatabase + '" excluído com sucesso.'),
                    PChar('Exclusão de database.'),
                    MB_OK or MB_ICONINFORMATION);
          AtualizarListaBancos(True);
          Exit;
        end
        else
          RegistrarLogs('TFormDataManager.BtnExcluirDatabaseClick', 'Usuário cancelou a exclusão do banco de dados "' + NomeDoDatabase + '".');
        AtualizarListaBancos(True);
        Exit;
      end
      else
      RegistrarLogs('TFormDataManager.BtnExcluirDatabaseClick', 'Função cancelada porquê o usuário tentou excluir um banco de dados de outro proprietário.');
      MessageBox(Application.Handle,
                PChar('O DataManager não pode excluir o banco de dados "' + NomeDoDatabase + '", pois ele pertence ao proprietário "' +
                      POwnerBD + '". Torne-se o proprietário do banco para poder executar esta tarefa ou exclua o banco por outra ferramenta.'),
                PChar('Exclusão de database.'),
                MB_OK or MB_ICONWARNING);
    end
    else
    begin
      RegistrarLogs('TFormDataManager.BtnExcluirDatabaseClick', 'Função encerrada devido a tentativa de ' +
                    'excluir um banco de dados com a versão ' + CurrToStr(GerenciadorBackup.VerificarVersaoPostgres(Versao)) +
                    ' que é inferior a versão ' + CurrToStr(GerenciadorBackup.PgVersaoMinima) + ' .');
      MessageBox(Application.Handle,
                PChar('O DataManager não exclúi banco de dados com versão inferior a versão mínima: PostgreSQL ' +
                      CurrToStr(GerenciadorBackup.PgVersaoMinima) + ' .'),
                PChar('Exclusão de database.'),
                MB_OK or MB_ICONWARNING);
    end;
    AtualizarListaBancos(True);
  except
    on E: Exception do
      begin
        RegistrarLogs('TFormDataManager.BtnExcluirDatabaseClick', E.ClassName + ' - ' + e.Message);
        MessageBox(Application.Handle,
                PChar('Não foi possível Excluir o banco de dados. "' + NomeDoDatabase + sLineBreak + sLineBreak +
                      'Classe: ' + E.ClassName + sLineBreak + sLineBreak +
                      'Detalhes do erro: ' + E.Message),
                PChar('Exclusão de database.'),
                MB_OK or MB_ICONERROR);
      end;
  end;
end;

procedure TFrmDataManager.FormCreate(Sender: TObject);
// Cria a janela e classes da aplicação
begin
  GerenciadorBackup := TGerenciadorBackup.Create;
  DataSourceBD.DataSet := GerenciadorBackup.Query;
  CaminhoDoArquivoDeLog := TPath.Combine(ExtractFilePath(ParamStr(0)), 'Logs.txt');
  RegistrarLogs('TFormDataManager.FormCreate', '-------------------------------------------------------------------------------');
  RegistrarLogs('TFormDataManager.FormCreate', 'Aplicação iniciada.');
  HabilitarDesabilitarElementos(False, False);
end;

procedure TFrmDataManager.FormClose(Sender: TObject; var Action: TCloseAction);
// Fecha a janela da aplicação
begin
  HabilitarDesabilitarElementos(False, False);
  RegistrarLogs('TFormDataManager.FormClose', 'Aplicação Encerrada.');
  RegistrarLogs('TFormDataManager.FormClose', '-------------------------------------------------------------------------------');
end;

procedure TFrmDataManager.FormDestroy(Sender: TObject);
// Destrói a janela e classes da aplicação
begin
  GerenciadorBackup.Free;
  RegistrarLogs('TFormDataManager.FormDestroy', 'Form limpo da memória com sucesso');
end;

procedure TFrmDataManager.BtnConectarBDClick(Sender: TObject);
// Botão Conectar
begin
  ConectarDatabase;
end;

procedure TFrmDataManager.BtnDesconectarClick(Sender: TObject);
// Botão Desconectar
begin
  DesconectarDatabase;
end;

procedure TFrmDataManager.BtnAtualizarClick(Sender: TObject);
// Botão atualizar(Refresh)
begin
  AtualizarListaBancos(True);
  HabilitarDesabilitarElementos(True, False);
end;

procedure TFrmDataManager.BtnNovoDataBaseClick(Sender: TObject);
// Botão novo database
begin
  NovoDatabase;
end;

procedure TFrmDataManager.BtnRenomearDatabaseClick(Sender: TObject);
// Botão renomear database
begin
  ValidarRenomearDatabase;
end;

procedure TFrmDataManager.BtnExcluirDatabaseClick(Sender: TObject);
// Botão excluir database
begin
  ExcluirDatabase;
end;

procedure TFrmDataManager.BtnFazerBackupDatabaseClick(Sender: TObject);
//Boatão fazer Backup
var
  FrmBackupRestore: TFrmBackupRestore; // Declara uma variável para o seu formulário de progresso
  OutputFile, Comando: string;
  LSvDlgBackup: TSaveDialog;
begin
  HabilitarDesabilitarElementos(True, False);
  GerenciadorBackup.Database := LbxDatabases.Items[LbxDatabases.ItemIndex];
  GerenciadorBackup.Conectar;

  LSvDlgBackup := TSaveDialog.Create(Self);
  LSvDlgBackup.FileName := GerenciadorBackup.Database + '_[' + FormatDateTime('dd.mm.yyyy_hh.mm.ss', Now) + '].' + GerenciadorBackup.Extensao;
  LSvDlgBackup.Filter := GerenciadorBackup.TipoArquivoDlg + ' (*.' + GerenciadorBackup.Extensao + ')|*.' + GerenciadorBackup.Extensao + '|Todos os arquivos (*.*)|*.*';
  LSvDlgBackup.DefaultExt := GerenciadorBackup.Extensao;
  LSvDlgBackup.Title := 'Salvar Backup do Banco de Dados';
  LSvDlgBackup.Options := LSvDlgBackup.Options + [ofOverwritePrompt];

  if not LSvDlgBackup.Execute then
  begin
    RegistrarLogs('TFormDataManager.BtnFazerBackupDatabaseClick', 'Usuário cancelou sem decidir salvar o backup".');
    AtualizarListaBancos(True);
    Exit;
  end
  else
    RegistrarLogs('TFormDataManager.BtnFazerBackupDatabaseClick', 'Usuário confirmou salvar o arquivo de backup".');

  OutputFile := LSvDlgBackup.FileName;

  Comando := GerenciadorBackup.CriarComando(CmdBackup, OutputFile, GerenciadorBackup.Dump, GerenciadorBackup.Restore, GerenciadorBackup.Server,
                          GerenciadorBackup.Porta, GerenciadorBackup.Database, GerenciadorBackup.Senha);
  RegistrarLogs('TFormDataManager.BtnFazerBackupDatabaseClick', 'Comando recebido: ' + Comando);

  FrmBackupRestore := TFrmBackupRestore.Create(Self);
  try
    // Configura o formulário de progresso com os parâmetros necessários
    FrmBackupRestore.IniciarOperacao(Comando, OutputFile, GerenciadorBackup.Dump, GerenciadorBackup.Restore, GerenciadorBackup.Server,
                          GerenciadorBackup.Porta, GerenciadorBackup.Database, GerenciadorBackup.Senha, CmdBackup, GerenciadorBackup.Connection); // Passa a conexão

    FrmBackupRestore.ShowModal;
    // Após ShowModal, o código continua aqui (quando o FrmBackupRestore é fechado)
  finally
    LSvDlgBackup.Free;
    FrmBackupRestore.Free; // Libera o formulário de progresso
    RegistrarLogs('TFormDataManager.BtnFazerBackupDatabaseClick', 'Form "' + FrmBackupRestore.Name + '" foi fechado.');
    GerenciadorBackup.Database := 'postgres';
    GerenciadorBackup.Conectar;
  end;
  AtualizarListaBancos(True);
end;

procedure TFrmDataManager.BtnFazerRestoreDatabaseClick(Sender: TObject);
var
  FrmBackupRestore : TFrmBackupRestore;
  NomeDoDatabase, InputFile, Comando, Versao, POwnerBD: string;
  LOpnDlgRestore: TOpenDialog;
  LSvDlgBackup: TSaveDialog;
begin
  HabilitarDesabilitarElementos(True, False);
  NomeDoDatabase := LbxDatabases.Items[LbxDatabases.ItemIndex];

  if GerenciadorBackup.VerificarVersaoPostgres(Versao) < GerenciadorBackup.PgVersaoMinima then
  begin
    RegistrarLogs('TFormDataManager.BtnFazerRestoreDatabaseClick', 'Função encerrada devido a tentativa de ' +
                  'restaurar um backup em um banco de dados com a versão ' + CurrToStr(GerenciadorBackup.VerificarVersaoPostgres(Versao)) +
                  ' que é inferior a versão mínima: ' + CurrToStr(GerenciadorBackup.PgVersaoMinima) + ' .');
    MessageBox(Application.Handle,
                  PChar('O DataManager não faz restauração em banco de dados com versão inferior a versão mínima: PostgreSQL ' +
                        CurrToStr(GerenciadorBackup.PgVersaoMinima) + ' .'),
                  PChar('Conexão com o PostgrSQL.'),
                  MB_OK or MB_ICONWARNING);
  end
  else
  begin
    POwnerBD := '';
    if GerenciadorBackup.ValidarOwnerDatabase(NomeDoDatabase, GerenciadorBackup.OwnerPadrao, POwnerBD) then
    begin
      LSvDlgBackup := TSaveDialog.Create(Self);
      LOpnDlgRestore := TOpenDialog.Create(Self);
      try
        LOpnDlgRestore.Filter := 'PostgreSQL Custom Backup Files (*.' + GerenciadorBackup.Extensao + ')|*.' + GerenciadorBackup.Extensao + '|Todos os arquivos (*.*)|*.*';
        LSvDlgBackup.DefaultExt := GerenciadorBackup.Extensao;
        LOpnDlgRestore.Options := [ofFileMustExist, ofPathMustExist, ofEnableSizing];
        LOpnDlgRestore.Title := 'Selecionar Arquivo de Backup para Restaurar';

        if not LOpnDlgRestore.Execute then
        begin
          RegistrarLogs('TFormDataManager.BtnFazerRestoreDatabaseClick', 'Usuário cancelou sem abrir nenhum arquivo de backup".');
          AtualizarListaBancos(True);
          Exit;
        end
        else
        begin
          RegistrarLogs('TFormDataManager.BtnFazerRestoreDatabaseClick', 'Usuário abriu o arquivo de backup ' + LOpnDlgRestore.FileName + '.');
          InputFile := LOpnDlgRestore.FileName;
        end;

        Comando := GerenciadorBackup.CriarComando(CmdRestore, InputFile, GerenciadorBackup.Dump, GerenciadorBackup.Restore, GerenciadorBackup.Server,
                               GerenciadorBackup.Porta, NomeDoDatabase, GerenciadorBackup.Senha);
        RegistrarLogs('TFormDataManager.BtnFazerRestoreDatabaseClick', 'Comando recebido: ' + Comando);

        GerenciadorBackup.RemoverPermissoesNosRoles(NomeDoDatabase);
        GerenciadorBackup.DroparRoles(NomeDoDatabase);
        GerenciadorBackup.DroparDataBase(NomeDoDatabase);
        RegistrarLogs('TFormDataManager.BtnFazerRestoreDatabaseClick', 'Excluído o banco de dados existente.');
        GerenciadorBackup.CriarDataBase(NomeDoDatabase);
        GerenciadorBackup.CriarRoles(NomeDoDatabase);
        GerenciadorBackup.AdicionarPermissoesNosRoles(NomeDoDatabase);
        RegistrarLogs('TFormDataManager.BtnFazerRestoreDatabaseClick', 'Recriado o banco de dados vazio.');
        FrmBackupRestore := TFrmBackupRestore.Create(Self);
        try
          FrmBackupRestore.IniciarOperacao(Comando, InputFile, GerenciadorBackup.Dump, GerenciadorBackup.Restore, GerenciadorBackup.Server,
                                            GerenciadorBackup.Porta, NomeDoDatabase, GerenciadorBackup.Senha, CmdRestore, GerenciadorBackup.Connection);
          FrmBackupRestore.ShowModal;
        finally
          FrmBackupRestore.Free;
          RegistrarLogs('TFormDataManager.BtnFazerRestoreDatabaseClick', 'Form "' + FrmBackupRestore.Name + '" foi fechado.');
          GerenciadorBackup.Conectar;
        end;
      finally
        LOpnDlgRestore.Free;
        LSvDlgBackup.Free;
      end;
    end
    else
    begin
      RegistrarLogs('TFormDataManager.BtnFazerRestoreDatabaseClick', 'Função cancelada porquê o usuário ' +
                    'tentou fazer o restore em um banco de dados de outro proprietário.');
      MessageBox(Application.Handle,
                PChar('O banco de dados "' + NomeDoDatabase + '" pertence ao proprietário "' +
                      POwnerBD + '". Não será possível a restauração.'),
                PChar('Restauração de backup.'),
                MB_OK or MB_ICONWARNING);
    end;
  end;
  AtualizarListaBancos(True);
end;

procedure TFrmDataManager.LbxDatabasesClick(Sender: TObject);
// evento de clicar na lista de databases
begin
  if LbxDatabases.ItemIndex <> -1 then
  begin
  RegistrarLogs('TFormDataManager.LbxDatabasesClick', 'Usuário selecionou o banco de dados "' + LbxDatabases.Items.Strings[LbxDatabases.ItemIndex] + '".');
  HabilitarDesabilitarElementos(True, True);
  end;
end;

procedure TFrmDataManager.NovoDatabase;
var
  NomeDoDatabase: string;
  NomeExiste: boolean;
  Digitou: boolean;
  Versao: string;
begin
  if not (GerenciadorBackup.VerificarVersaoPostgres(Versao) < GerenciadorBackup.PgVersaoMinima) then
  begin
    HabilitarDesabilitarElementos(True, False);
    NomeDoDatabase := CapturarNomeDoDatabase(NomeDoDatabase, Digitou);
    if not Digitou then
    begin
      RegistrarLogs('TFormDataManager.BtnNovoDataBaseClick', 'Usuário cancelou a operação.');
      AtualizarListaBancos(True);
      exit;
    end
    else
    begin
      repeat
      begin
        NomeExiste := ValidarSeDatabaseExiste(NomeDoDatabase);
        if NomeExiste then
        begin
          RegistrarLogs('TFormDataManager.BtnNovoDataBaseClick', 'Usuário digitou o database "' + NomeDoDatabase + ' que já existe.');
          MessageBox(Application.Handle,
                      PChar('Já existe um database com o nome "' + NomeDoDatabase + '", digite um nome diferente'),
                      PChar('Criação de novo database.'), MB_OK or MB_ICONWARNING);

          NomeDoDatabase := CapturarNomeDoDatabase(NomeDoDatabase, Digitou);
          if not Digitou then
          begin
            RegistrarLogs('TFormDataManager.BtnNovoDataBaseClick', 'Novamente o usuário cancelou sem digitar o nome do banco.');
            AtualizarListaBancos(True);
            exit;
          end;
        end
      end;
      until not NomeExiste;

      if NomeDoDatabase <> '' then
      begin
        RegistrarLogs('TFormDataManager.BtnNovoDataBaseClick', 'Usuário digitou o nome do banco de dados "' + NomeDoDatabase + '".');
        GerenciadorBackup.CriarRoles(NomeDoDatabase);
        GerenciadorBackup.CriarDataBase(NomeDoDatabase);
        GerenciadorBackup.AdicionarPermissoesNosRoles(NomeDoDatabase);
        MessageBox(Application.Handle,
                  PChar('Database "' + NomeDoDatabase + '" criado com sucesso'),
                  PChar('Criação de database'),
                  MB_OK or MB_ICONINFORMATION);
        AtualizarListaBancos(True);
      end
      else
        RegistrarLogs('TFormDataManager.BtnNovoDataBaseClick', 'Usuário não digitou o nome do banco de dados.');
    end;
  end
  else
  begin
    RegistrarLogs('TFormDataManager.BtnNovoDataBaseClick', 'Função encerrada devido a tentativa de ' +
                  'criar um banco de dados com a versão ' + CurrToStr(GerenciadorBackup.VerificarVersaoPostgres(Versao)) +
                  ' que é inferior a versão ' + CurrToStr(GerenciadorBackup.PgVersaoMinima) + ' .');
    MessageBox(Application.Handle,
              PChar('O DataManager não cria banco de dados com versão inferior a versão mínima: PostgreSQL ' +
              CurrToStr(GerenciadorBackup.PgVersaoMinima) + ' .'),
              PChar('Criação de database'),
              MB_OK or MB_ICONWARNING);
  end;
  AtualizarListaBancos(True);
end;

procedure TFrmDataManager.ValidarRenomearDatabase;
//Método que faz a validação antes da renomeacao do database.
var
  NomeDoDatabaseAntigo, NomeDoDatabaseNovo, POwnerBD, Versao: string; NomeExiste: boolean;
  Digitou: boolean;
begin
  HabilitarDesabilitarElementos(True, False);
  NomeDoDatabaseAntigo := LbxDatabases.Items[LbxDatabases.ItemIndex];
  if not (GerenciadorBackup.VerificarVersaoPostgres(Versao) < GerenciadorBackup.PgVersaoMinima) then
  begin
    if GerenciadorBackup.ValidarOwnerDatabase(NomeDoDatabaseAntigo, GerenciadorBackup.OwnerPadrao, POwnerBD) then
    begin
      NomeDoDatabaseNovo := CapturarNomeDoDatabase(NomeDoDatabaseAntigo, Digitou);
      if not Digitou then
      begin
        RegistrarLogs('TFormDataManager.BtnRenomearDatabaseClick', 'Usuário cancelou a operação.');
        AtualizarListaBancos(True);
        exit
      end
      else
      begin
        if NomeDoDatabaseNovo <> NomeDoDatabaseAntigo then
        begin
          repeat
          begin
            NomeExiste := ValidarSeDatabaseExiste(NomeDoDatabaseNovo);
            if NomeExiste then
            begin
              RegistrarLogs('TFormDataManager.BtnRenomearDatabaseClick', 'Usuário digitou o database "' + NomeDoDatabaseNovo + ' que já existe.');
              MessageBox(Application.Handle,
                        PChar('Já existe um database com o nome "' + NomeDoDatabaseNovo + '", digite um nome diferente'),
                        PChar('Renomear database.'),
                        MB_OK or MB_ICONWARNING);

              NomeDoDatabaseNovo := CapturarNomeDoDatabase(NomeDoDatabaseNovo, Digitou);
              if not Digitou then
              begin
                RegistrarLogs('TFormDataManager.BtnRenomearDatabaseClick', 'usuário cancelou a operação.');
                AtualizarListaBancos(True);
                exit;
              end;
            end
          end;
          until not NomeExiste;

          if NomeDoDatabaseNovo <> NomeDoDatabaseAntigo then
          begin
            RegistrarLogs('TFormDataManager.BtnRenomearDatabaseClick', 'Usuário digitou o nome do banco de dados "' + NomeDoDatabaseNovo + '".');
            GerenciadorBackup.RemoverPermissoesNosRoles(NomeDoDatabaseAntigo);
            GerenciadorBackup.DroparRoles(NomeDoDatabaseAntigo);
            GerenciadorBackup.RenomearDatabase(NomeDoDatabaseAntigo, NomeDoDatabaseNovo);
            GerenciadorBackup.CriarRoles(NomeDoDatabaseNovo);
            GerenciadorBackup.AdicionarPermissoesNosRoles(NomeDoDatabaseNovo);
            MessageBox(Application.Handle,
                      PChar('Database "' + NomeDoDatabaseAntigo + '" renomeado com sucesso para "' + NomeDoDatabaseNovo + '.'),
                      PChar('Renomear database.'),
                      MB_OK or MB_ICONINFORMATION);

            AtualizarListaBancos(True);
          end
          else
            RegistrarLogs('TFormDataManager.BtnRenomearDatabaseClick', 'Usuário não digitou o nome do banco de dados.');
          AtualizarListaBancos(True);
          exit;
        end
        else
        begin
          RegistrarLogs('TFormDataManager.BtnRenomearDatabaseClick', 'Usuário digitou o mesmo nome de banco de dados.');
          AtualizarListaBancos(True);
          Exit;
        end;
      end
    end;
    RegistrarLogs('TFormDataManager.BtnRenomearDatabaseClick', 'Função cancelada porquê o usuário tentou renomear um banco de dados de outro proprietário.');
    MessageBox(Application.Handle,
              PChar('O banco de dados "' + NomeDoDatabaseAntigo + '" pertence ao proprietário "' +
                      POwnerBD + '". Não será possível renomear.'),
                      PChar('Renomear database.'),
                      MB_OK or MB_ICONWARNING);
  end
  else
  begin
    RegistrarLogs('TFormDataManager.BtnRenomearDatabaseClick', 'Função encerrada devido a tentativa de ' +
                  'renomear um banco de dados com a versão ' + CurrToStr(GerenciadorBackup.VerificarVersaoPostgres(Versao)) +
                  ' que é inferior a versão ' + CurrToStr(GerenciadorBackup.PgVersaoMinima) + ' .');
    MessageBox(Application.Handle,
              PChar('O DataManager não renomeia banco de dados com versão inferior a versão mínima: PostgreSQL ' +
                    CurrToStr(GerenciadorBackup.PgVersaoMinima) + ' .'),
              PChar('Renomear database'),
              MB_OK or MB_ICONWARNING);

  end;
  AtualizarListaBancos(True);
end;

function TFrmDataManager.ValidarSeDatabaseExiste(PNomeDoDatabase: String): boolean;
//Função que valida se já existe um database com o mesmo nome que o digitado
var
  i: integer;
begin
  for i := 0 to LbxDatabases.Items.Count - 1 do
  begin
    if PNomeDoDatabase = LbxDatabases.Items[i] then
    begin
      RegistrarLogs('TFormDataManager.ValidarSeDatabaseExiste', 'Database "' + PNomeDoDatabase + '" Existe');
      Result := true;
      exit;
    end
  end;
  Result := False;
  RegistrarLogs('TFormDataManager.ValidarSeDatabaseExiste', 'Database "' + PNomeDoDatabase + '" não existe');
end;

procedure TFrmDataManager.HabilitarDesabilitarElementos(PStatusConexao, PBancoSelecionado: Boolean);
// Habilita ou desabilita os edits de conexão conforme o banco está ou não está conectado
begin
  BtnConectarBD.Enabled := not PStatusConexao;
  CbxVersao.Enabled := not PStatusConexao;
  EdtHost.Enabled := not PStatusConexao;
  EdtPorta.Enabled := not PStatusConexao;
  EdtUsuario.Enabled := not PStatusConexao;
  EdtSenha.Enabled := not PStatusConexao;

  BtnDesconectar.Enabled := PStatusConexao;
  BtnAtualizar.Enabled := PStatusConexao;
  BtnNovoDataBase.enabled := PStatusConexao;
  BtnRenomearDatabase.Enabled := PBancoSelecionado;
  BtnExcluirDatabase.Enabled := PBancoSelecionado;
  BtnFazerBackupDatabase.Enabled := PBancoSelecionado;
  BtnFazerRestoreDatabase.Enabled := PBancoSelecionado;
  RegistrarLogs('TFormDataManager.HabilitarDesabilitarElementos', 'Função HabilitarDesabilitarElementos executada.');
end;

procedure TFrmDataManager.AtualizarListaBancos(PStatusConexao: Boolean);
//Atualiza a grid dos bancos de dados
begin
  case PStatusConexao of
    True:
      Begin
        GerenciadorBackup.SelectTodosDatabases;
        LbxDatabases.Items.Clear;
        While not GerenciadorBackup.Query.Eof do
        begin
          LbxDatabases.Items.Add(GerenciadorBackup.Query.FieldByName('Datname').Asstring);
          GerenciadorBackup.Query.Next;
        end;
      End;
    False:
      begin
        LbxDatabases.Items.Clear;
      end;
  end;
  LbxDatabases.ItemIndex := -1;
  RegistrarLogs('TFrmDataManager.AtualizarListaBancos', 'Lista de bancos de dados atualizada.');
end;

end.
