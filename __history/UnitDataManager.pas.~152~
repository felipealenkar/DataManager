unit UnitDataManager;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, DateUtils,
  System.IOUtils,
  System.Classes, Vcl.Graphics, ShellAPI,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, Math,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  FireDAC.Phys.PGDef, FireDAC.Phys.PG, Data.DB, FireDAC.Comp.Client,
  Vcl.StdCtrls, TypInfo,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, Vcl.Grids, Vcl.DBGrids, System.ImageList, Vcl.ImgList,
  Vcl.VirtualImageList, Vcl.BaseImageCollection, Vcl.ImageCollection,
  Vcl.ExtCtrls, FireDAC.Phys.FBDef, FireDAC.Phys.IBBase, FireDAC.Phys.FB,
  System.UITypes, Vcl.ComCtrls, StrUtils, System.SyncObjs, Vcl.DBCtrls,
  FireDAC.Comp.UI,
  Vcl.Buttons, FireDAC.Phys.IBWrapper, FireDAC.Phys.IB;

type
  TDriverBDConexao = class
    procedure DefineParametros(PNomeDoDriverBD: String);
  public
    Driver: string;
    Host: string;
    Porta: string;
    Versao: string;
    Biblioteca: string;
    Dump: string;
    Restore: string;
    Psql: string;
    Database:String;
    OwnerPadrao: string;
    Senha: string;
    Formato: Char;
    Extensao: string;
    TipoQueryDlg: string;
  End;

type
  TFormDataManager = class(TForm)
    //Criado por james
    Button2: TButton;
    Button3: TButton;
    Delete: TButton;
    EditFormaDePagamento: TEdit;
    //Criado por james

    FDConnectionDB: TFDConnection;
    BtnConectaBD: TButton;
    FDPhysPgDriverLinkBD: TFDPhysPgDriverLink;
    DBGridTabela: TDBGrid;
    DataSourceBD: TDataSource;
    FDQueryBD: TFDQuery;
    ImageCollectionManager: TImageCollection;
    VirtualImageListManager: TVirtualImageList;
    EdtHost: TEdit;
    LblHost: TLabel;
    LblPorta: TLabel;
    EdtPorta: TEdit;
    LblUsuario: TLabel;
    EdtUsuario: TEdit;
    LblSenha: TLabel;
    EdtSenha: TEdit;
    PnlConexao: TPanel;
    LblBd: TLabel;
    BtnDesconectar: TButton;
    CboxDriverBD: TComboBox;
    LblBancosDeDados: TLabel;
    BtnNovoDataBase: TButton;
    PnlGerenciar: TPanel;
    BtnAtualizar: TButton;
    BtnRenomearDatabase: TButton;
    BtnExcluirDatabase: TButton;
    BtnFazerBackupDatabase: TButton;
    PnlBackupRestore: TPanel;
    BtnFazerRestoreDatabase: TButton;
    RadioGroupTipoArquivo: TRadioGroup;
    LbxDatabases: TListBox;
    SaveDialogBackup: TSaveDialog;
    OpenDialogRestore: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure BtnConectaBDClick(Sender: TObject);
    procedure DeleteClick(Sender: TObject);
    procedure BtnDesconectarClick(Sender: TObject);
    procedure BtnNovoDataBaseClick(Sender: TObject);
    procedure BtnAtualizarClick(Sender: TObject);
    procedure BtnRenomearDatabaseClick(Sender: TObject);
    procedure BtnExcluirDatabaseClick(Sender: TObject);
    procedure BtnFazerBackupDatabaseClick(Sender: TObject);
    procedure BtnFazerRestoreDatabaseClick(Sender: TObject);
    procedure LbxDatabasesClick(Sender: TObject);

    // jAMES CRIOU
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    // JAMES CRIOU

    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DBRadioGroupTipoBackupChange(Sender: TObject);

  private
    { Private declarations }
  type
    TEnumAcao = (Conectar, Desconectar, Criar, Dropar, Adicionar, Remover, Renomear, Backup, Restore);
    TEnumModoQuery = (Open, ExecSQL);

  procedure ConectarDesconectarDriverDoDatabase(PNomeDoDatabase: string; PAcao: TEnumAcao);
  procedure HabilitarDesabilitarElementos(PStatusConexao, PBancoSelecionado: Boolean);
  procedure AtualizaListaBancos(PStatusConexao: Boolean);
  function CapturarNomeDoDatabase(PNomeDoDatabase: string; PAcao: TEnumAcao; OUT PDigitou: boolean):string;
  procedure CriarDroparRoles(PNomeDoDatabase: string; PAcao: TEnumAcao);
  procedure CriarDroparDataBase(PNomeDoDatabase: string; PAcao: TEnumAcao);
  procedure AdicionarOuRemoverPermissoesNosRoles(PNomeDoDatabase: string; PAcao: TEnumAcao);
  procedure RenomearDatabase(PNomeDoDatabaseAntigo, PNomeDoDatabaseNovo: string);
  function ValidaDatabaseExistente(PNomeDoDatabase: String): boolean;
  procedure RegistrarLogs(PAcao: string);
  function CriaComando(PAcao: TEnumAcao; POutputFile: string;
    PDumpPath, PRestorePath, PPsqlPath, PHost, PPorta, PNomeDoDatabase,
    PSenha: string; PFormato: Char): string;
  function ValidaOwnerDatabase(PNomeDoDatabase, POwnerPadrao: string; out POwnerBD: string): Boolean;

  public
    { Public declarations }

  end;

var
  FormDataManager: TFormDataManager;
  DriverBDConexao: TDriverBDConexao;

implementation

uses
  UnitBackupRestore;

{$R *.dfm}

// ===========================================================================
// Implementação das Funções Auxiliares do processo de backup/Restore
// ===========================================================================

function TFormDataManager.CriaComando(PAcao: TEnumAcao ; POutputFile: string; PDumpPath, PRestorePath, PPsqlPath,
                                        PHost, PPorta, PNomeDoDatabase, PSenha: string; PFormato: char): string;
var
  DumpRestorePsqlPath: string;
begin
  Result := ''; // Default

  case PAcao of
    Backup:
      begin
        DumpRestorePsqlPath := PDumpPath;
        Result := Format('"%s" -U postgres -h %s -p %s -F %s -b -v -f "%s" %s',
                         [DumpRestorePsqlPath, PHost, PPorta, PFormato, POutputFile, PNomeDoDatabase]);
      end;
    Restore:
      begin
        if PFormato = 'c' then
          DumpRestorePsqlPath := PRestorePath
        else
          DumpRestorePsqlPath := PPsqlPath;

        if PFormato = 'c' then
          Result := Format('"%s" -U postgres -h %s -p %s -d %s -v --no-owner --no-acl --no-comments "%s"',
                           [DumpRestorePsqlPath, PHost, PPorta, PNomeDoDatabase, POutputFile])
        else if PFormato = 'p' then
          Result := Format('"%s" -U postgres -h %s -p %s -d %s -f "%s"',
                           [DumpRestorePsqlPath, PHost, PPorta, PNomeDoDatabase, POutputFile]);
      end;
  end;
end;

// ===========================================================================
// Fim da implementação das Funções Auxiliares do processo de backup/Restore
// ===========================================================================

procedure TFormDataManager.ConectarDesconectarDriverDoDatabase(PNomeDoDatabase: string; PAcao: TEnumAcao);
// Inicia ou encerra a conexão com o BD Selecionado
// PostgreSQL password #abc123#
Var
  TipoLog1: string;
begin
  case PAcao of
    Conectar:
      begin
        DriverBDConexao.DefineParametros(CboxDriverBD.Text);
        FDConnectionDB.close;
        FDConnectionDB.Params.Clear;
        FDConnectionDB.DriverName := DriverBDConexao.Driver;
        FDPhysPgDriverLinkBD.VendorLib := DriverBDConexao.Biblioteca;
        FDConnectionDB.Params.Values['Host'] := EdtHost.text;
        FDConnectionDB.Params.Values['Port'] := EdtPorta.text;
        FDConnectionDB.Params.Values['User_Name'] := EdtUsuario.text;
        FDConnectionDB.Params.Values['Password'] := EdtSenha.text;
        FDConnectionDB.Params.Values['Database'] := PNomeDoDatabase;
        FDConnectionDB.Params.Values['CharacterSet'] := 'UTF8';
        FDConnectionDB.LoginPrompt := False;
        FDConnectionDB.Open;
        TipoLog1 := 'iniciada com sucesso.';
      end;
    Desconectar:
      begin
        FDConnectionDB.close;
        TipoLog1 := 'encerrada com sucesso.';
      end;
  end;

  RegistrarLogs('Conexão com o banco de dados "' + FDConnectionDB.DriverName + '" ' + TipoLog1);
end;

function TFormDataManager.CapturarNomeDoDatabase(PNomeDoDatabase: string; PAcao: TEnumAcao; OUT PDigitou: boolean): string;
// Colhe o nome do database dejesado e o retorna
Var
  Mensagem: string;
begin
  if PAcao = Criar then
  Mensagem := 'Criação de novo database'
  else if PAcao = Renomear then
  Mensagem := 'Renomear database';

  repeat
    begin
      PDigitou := InputQuery(Mensagem, 'Digite o nome do novo banco de dados', PNomeDoDatabase);
      if PDigitou and (PNomeDoDatabase = '') then
      MessageDlg('O nome do banco de dados não pode ser vazio.', TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], 0);
    end;
  until (not PDigitou) or (PNomeDoDatabase <> '');
  Result:= PNomeDoDatabase;
end;

procedure TFormDataManager.CriarDroparRoles(PNomeDoDatabase: string; PAcao: TEnumAcao);
// Cria Roles para o banco de dados
Var
  TipoLog1: string;
begin
  FDQueryBD.close;
  FDQueryBD.sql.Clear;
  case PAcao of
    Criar: FDQueryBD.sql.Add('CREATE ROLE "' + DriverBDConexao.OwnerPadrao + '" LOGIN PASSWORD ''#abc123#''');
    Dropar: FDQueryBD.sql.Add('DROP ROLE "' + DriverBDConexao.OwnerPadrao + '" LOGIN PASSWORD ''#abc123#''');
  end;
  try
    FDQueryBD.ExecSQL;
    FDQueryBD.close;
  Except
    FDQueryBD.close;
  END;
  FDQueryBD.sql.Clear;

  case PAcao of
    Criar: FDQueryBD.sql.Add('CREATE ROLE "PRODFAB_GROUP"');
    Dropar: FDQueryBD.sql.Add('DROP ROLE "PRODFAB_GROUP"');
  end;
  TRY
    FDQueryBD.ExecSQL;
    FDQueryBD.close;
  Except
    FDQueryBD.close;
  END;
  FDQueryBD.sql.Clear;

  case PAcao of
    Criar:
      begin
        FDQueryBD.sql.Add('CREATE ROLE "PRODFAB_GROUP_' + PNomeDoDatabase + '"');
        TipoLog1 := 'cadastrados';
      end;
    Dropar:
      begin
        FDQueryBD.sql.Add('DROP ROLE "PRODFAB_GROUP_' + PNomeDoDatabase + '"');
        TipoLog1 := 'excluídos';
      end;
  end;
  TRY
    FDQueryBD.ExecSQL;
    FDQueryBD.close;
  Except
    FDQueryBD.close;
  END;
  RegistrarLogs('Usuários padrão do database "' + PNomeDoDatabase + '" ' + TipoLog1 + ' com sucesso.');
end;

procedure TFormDataManager.CriarDroparDataBase(PNomeDoDatabase: string; PAcao: TEnumAcao);
// Cria databases novos
var
  TipoLog1, TipoLog2: string;
begin
  FDQueryBD.close;
  FDQueryBD.sql.Clear;
  case PAcao of
    Criar:
      begin
        FDQueryBD.sql.Add('CREATE DATABASE "' + PNomeDoDatabase + '"');
        FDQueryBD.sql.Add('WITH OWNER = "' + DriverBDConexao.OwnerPadrao + '"');
        FDQueryBD.sql.Add('ENCODING = ''UTF8''');
        FDQueryBD.sql.Add('TABLESPACE = pg_default');
        FDQueryBD.sql.Add('LC_COLLATE = ''Portuguese_Brazil.1252''');
        FDQueryBD.sql.Add('LC_CTYPE = ''Portuguese_Brazil.1252''');
        FDQueryBD.sql.Add('CONNECTION LIMIT = -1');
        TipoLog1 := 'criação';
        TipoLog2 := 'criado';
      end;
    Dropar:
      begin
        FDQueryBD.sql.Add('DROP DATABASE "' + PNomeDoDatabase + '"');
        TipoLog1 := 'exclusão';
        TipoLog2 := 'excluído';
      end;
  end;
  FDQueryBD.ExecSQL;
  FDQueryBD.close;
  RegistrarLogs('Query de ' + TipoLog1 + ' de database executada:' + sLineBreak + sLineBreak + FDQueryBD.sql.Text + sLineBreak);
  RegistrarLogs('Database "' + PNomeDoDatabase + '" ' + TipoLog2 + ' com sucesso.');
end;

procedure TFormDataManager.AdicionarOuRemoverPermissoesNosRoles(PNomeDoDatabase: string; PAcao: TEnumAcao);
// Atribúi permissão nos roles
Var
  TipoLog1 : string;
begin
  try
    FDQueryBD.close;
    FDQueryBD.sql.Clear;
    case PAcao of
      Adicionar: FDQueryBD.sql.Add('GRANT CONNECT, TEMPORARY ON DATABASE "' + PNomeDoDatabase + '" TO public');
      Remover: FDQueryBD.sql.Add('REVOKE CONNECT, TEMPORARY ON DATABASE "' + PNomeDoDatabase + '" FROM public');
    end;
    FDQueryBD.ExecSQL;
    FDQueryBD.close;
    FDQueryBD.sql.Clear;
  Except
  end;

  try
    case PAcao of
    Adicionar: FDQueryBD.sql.Add('GRANT ALL ON DATABASE "' + PNomeDoDatabase + '" TO "' + DriverBDConexao.OwnerPadrao + '"');
    Remover: FDQueryBD.sql.Add('REVOKE ALL ON DATABASE "' + PNomeDoDatabase + '" FROM "' + DriverBDConexao.OwnerPadrao + '"');
    end;
    FDQueryBD.ExecSQL;
    FDQueryBD.close;
    FDQueryBD.sql.Clear;
  Except

  end;

  try
    case PAcao of
      Adicionar:
        begin
          FDQueryBD.sql.Add('GRANT ALL ON DATABASE "' + PNomeDoDatabase + '" TO "PRODFAB_GROUP_' + PNomeDoDatabase + '"');
          TipoLog1 := 'adicionadas aos';
        end;
      Remover:
        begin
          FDQueryBD.sql.Add('REVOKE ALL ON DATABASE "' + PNomeDoDatabase + '" FROM "PRODFAB_GROUP_' + PNomeDoDatabase + '"');
          TipoLog1 := 'removidas dos';
        end;
    end;
    FDQueryBD.ExecSQL;
    FDQueryBD.close;
    FDQueryBD.sql.Clear;
  Except

  end;
  RegistrarLogs('Permissões ' + TipoLog1 + ' usuários do database "' + PNomeDoDatabase + '".');
end;

procedure TFormDataManager.FormCreate(Sender: TObject);
// Cria a janela e classes da aplicação
begin
  HabilitarDesabilitarElementos(False, False);
  RegistrarLogs('-------------------------------------------------------------------------------');
  RegistrarLogs('Aplicação iniciada.');
  DriverBDConexao := TDriverBDConexao.Create;
end;

procedure TFormDataManager.FormClose(Sender: TObject; var Action: TCloseAction);
// Fecha a janela da aplicação
begin
  HabilitarDesabilitarElementos(False, False);
  RegistrarLogs('Aplicação Encerrada.');
  RegistrarLogs('-------------------------------------------------------------------------------');
end;

procedure TFormDataManager.FormDestroy(Sender: TObject);
// Destrói a janela e classes da aplicação
begin
  DriverBDConexao.free;
end;

procedure TFormDataManager.BtnConectaBDClick(Sender: TObject);
// Botão Conectar
begin
  ConectarDesconectarDriverDoDatabase('postgres', Conectar);
  HabilitarDesabilitarElementos(True, False);
  AtualizaListaBancos(True);
end;

procedure TFormDataManager.BtnDesconectarClick(Sender: TObject);
// Botão Desconectar
begin
  ConectarDesconectarDriverDoDatabase('Postgres', Desconectar);
  HabilitarDesabilitarElementos(False, False);
  AtualizaListaBancos(False);
end;

procedure TFormDataManager.BtnAtualizarClick(Sender: TObject);
// Botão atualizar(Refresh)
begin
  AtualizaListaBancos(True);
  HabilitarDesabilitarElementos(True, False);
end;

procedure TFormDataManager.BtnNovoDataBaseClick(Sender: TObject);
// Botão novo database
var
  NomeDoDatabase: string;
  NomeExiste: boolean;
  Digitou: boolean;
begin
  HabilitarDesabilitarElementos(True, False);
  NomeDoDatabase := CapturarNomeDoDatabase(NomeDoDatabase, Criar, Digitou);
  if not Digitou then
  exit
  else
  begin
    repeat
    begin
      NomeExiste := ValidaDatabaseExistente(NomeDoDatabase);
      if NomeExiste then
      begin
        MessageDlg('Já existe um database com o nome "' + NomeDoDatabase + '", digite um nome diferente', mtInformation, [mbOK], 0);
        NomeDoDatabase := CapturarNomeDoDatabase(NomeDoDatabase, Criar, Digitou);
        if not Digitou then
        exit;
      end
    end;
    until not NomeExiste;

    if NomeDoDatabase <> '' then
    begin
      CriarDroparRoles(NomeDoDatabase, Criar);
      CriarDroparDataBase(NomeDoDatabase, Criar);
      AdicionarOuRemoverPermissoesNosRoles(NomeDoDatabase, Adicionar);
      MessageDlg('Database "' + NomeDoDatabase + '" criado com sucesso', TMsgDlgType.mtInformation, [mbOK], 0);
      AtualizaListaBancos(True);
    end;
  end;
end;

procedure TFormDataManager.BtnRenomearDatabaseClick(Sender: TObject);
// Botão renomear database
var
  NomeDoDatabaseAntigo, NomeDoDatabaseNovo, POwnerBD: string; NomeExiste: boolean;
  Digitou: boolean;
begin
  HabilitarDesabilitarElementos(True, False);
  NomeDoDatabaseAntigo := LbxDatabases.Items[LbxDatabases.ItemIndex];
  if ValidaOwnerDatabase(NomeDoDatabaseAntigo, DriverBDConexao.OwnerPadrao, POwnerBD) then
  begin
    NomeDoDatabaseNovo := CapturarNomeDoDatabase(NomeDoDatabaseAntigo, Renomear, Digitou);
    if NomeDoDatabaseNovo <> NomeDoDatabaseAntigo then
    begin
      if not Digitou then
      exit
      else
      begin
        repeat
        begin
          NomeExiste := ValidaDatabaseExistente(NomeDoDatabaseNovo);
          if NomeExiste then
          begin
            MessageDlg('Já existe um database com o nome "' + NomeDoDatabaseNovo + '", digite um nome diferente', mtInformation, [mbOK], 0);
            NomeDoDatabaseNovo := CapturarNomeDoDatabase(NomeDoDatabaseNovo, Criar, Digitou);
            if not Digitou then
            exit;
          end
        end;
        until not NomeExiste;

        if NomeDoDatabaseNovo <> NomeDoDatabaseAntigo then
        begin
          AdicionarOuRemoverPermissoesNosRoles(NomeDoDatabaseAntigo, Remover);
          CriarDroparRoles(NomeDoDatabaseAntigo, Dropar);
          RenomearDatabase(NomeDoDatabaseAntigo, NomeDoDatabaseNovo);
          CriarDroparRoles(NomeDoDatabaseNovo, Criar);
          AdicionarOuRemoverPermissoesNosRoles(NomeDoDatabaseNovo, Adicionar);
          MessageDlg('Database "' + NomeDoDatabaseAntigo + '" renomeado com sucesso para "' + NomeDoDatabaseNovo + '.', TMsgDlgType.mtInformation, [mbOK], 0);
          AtualizaListaBancos(True);
        end;
      end;
    end;
  end
  else
    Messagedlg('O DataManager não pode renomear o banco de dados "' + NomeDoDatabaseAntigo + '", pois ele pertence ao proprietário "' +
     POwnerBD + '". Torne-se o proprietário do banco para poder executar esta tarefa ou renomeie o banco por outra ferramenta.'
     , TMsgDlgType.mtWarning, [mbOk], 0);
end;

procedure TFormDataManager.BtnExcluirDatabaseClick(Sender: TObject);
// Botão excluir database
var
  NomeDoDatabase, POwnerBD: string;
  ConfircamaoExcluirDatabase: TModalResult;
begin
  POwnerBD := '';
  HabilitarDesabilitarElementos(True, False);
  NomeDoDatabase := LbxDatabases.Items[LbxDatabases.ItemIndex];

    if ValidaOwnerDatabase(NomeDoDatabase, DriverBDConexao.OwnerPadrao, POwnerBD) then
    begin
      ConfircamaoExcluirDatabase := MessageDlg('Tem certeza que deseja excluir o Database "' + NomeDoDatabase + '" ?', TMsgDlgType.mtWarning, mbYesNo, 0);
      if ConfircamaoExcluirDatabase = mryes then
      begin
        AdicionarOuRemoverPermissoesNosRoles(NomeDoDatabase, Remover);
        CriarDroparRoles(NomeDoDatabase, Dropar);
        CriarDroparRoles(NomeDoDatabase, Dropar);
        CriarDroparDataBase(NomeDoDatabase, Dropar);
        MessageDlg('Database "' + NomeDoDatabase + '" excluído com sucesso', TMsgDlgType.mtInformation, [mbOK], 0);
        AtualizaListaBancos(True);
      end;
    end
    else
    Messagedlg('O DataManager não pode excluir o banco de dados "' + NomeDoDatabase + '", pois ele pertence ao proprietário "' +
     POwnerBD + '". Torne-se o proprietário do banco para poder executar esta tarefa ou exclua o banco por outra ferramenta.'
     , TMsgDlgType.mtWarning, [mbOk], 0);
end;

procedure TFormDataManager.BtnFazerBackupDatabaseClick(Sender: TObject);
//Boatão fazer Backup
var
  FormBackupRestore : TFormBackupRestore; // Declara uma variável para o seu formulário de progresso
  NomeDoDatabase, OutputFile, Comando: string;

begin
  HabilitarDesabilitarElementos(True, False);
  NomeDoDatabase := LbxDatabases.Items[LbxDatabases.ItemIndex];
  ConectarDesconectarDriverDoDatabase(NomeDoDatabase, Conectar);

  SaveDialogBackup.FileName := NomeDoDatabase + '_[' + FormatDateTime('dd.mm.yyyy_hh.mm.ss', Now) + '].' + DriverBDConexao.Extensao;
  SaveDialogBackup.Filter := DriverBDConexao.TipoQueryDlg + ' (*.' + DriverBDConexao.Extensao + ')|*.' + DriverBDConexao.Extensao + '|Todos os arquivos (*.*)|*.*';
  SaveDialogBackup.DefaultExt := DriverBDConexao.Extensao;
  SaveDialogBackup.Title := 'Salvar Backup do Banco de Dados';
  SaveDialogBackup.Options := SaveDialogBackup.Options + [ofOverwritePrompt];

  if not SaveDialogBackup.Execute then
    Exit;
  OutputFile := SaveDialogBackup.FileName;

  Comando := CriaComando(Backup, OutputFile, DriverBDConexao.Dump, DriverBDConexao.Restore, DriverBDConexao.Psql, DriverBDConexao.Host,
                          DriverBDConexao.Porta, NomeDoDatabase, DriverBDConexao.Senha, DriverBDConexao.Formato);

  FormBackupRestore := TFormBackupRestore.Create(Self);
  try
    // Configura o formulário de progresso com os parâmetros necessários
    FormBackupRestore.IniciarOperacao(Comando, OutputFile, DriverBDConexao.Dump, DriverBDConexao.Restore, DriverBDConexao.Psql, DriverBDConexao.Host,
                          DriverBDConexao.Porta, NomeDoDatabase, DriverBDConexao.Senha, DriverBDConexao.Formato, TEnumAcaoBackup.Backup, FDConnectionDB); // Passa a conexão

    FormBackupRestore.ShowModal;
    // Após ShowModal, o código continua aqui (quando o FormBackupRestore é fechado)
  finally
    FormBackupRestore.Free; // Libera o formulário de progresso
    ConectarDesconectarDriverDoDatabase('postgres', Conectar);
  end;
end;

procedure TFormDataManager.BtnFazerRestoreDatabaseClick(Sender: TObject);
//Boatão fazer Backup
var
  FormBackupRestore : TFormBackupRestore; // Declara uma variável para o seu formulário de progresso
  NomeDoDatabase: string;
begin
  HabilitarDesabilitarElementos(True, False);
  NomeDoDatabase := LbxDatabases.Items[LbxDatabases.ItemIndex];
  ConectarDesconectarDriverDoDatabase(NomeDoDatabase, Conectar);
  FormBackupRestore := TFormBackupRestore.Create(Self);
  try
    FormBackupRestore.PGDumpPath := DriverBDConexao.dump;
    FormBackupRestore.PGRestorePath := DriverBDConexao.restore;
    FormBackupRestore.PQPsqlPath := DriverBDConexao.PSql;
    FormBackupRestore.PGHost := DriverBDConexao.Host;
    FormBackupRestore.PGPorta := DriverBDConexao.porta;
    FormBackupRestore.PGNomeDoDatabase := NomeDoDatabase;
    FormBackupRestore.PGSenha := DriverBDConexao.senha;
    FormBackupRestore.PGFormato := DriverBDConexao.Formato;
    FormBackupRestore.PGAcao := TEnumAcaoBackup.Restore;
    FormBackupRestore.Connection := FDConnectionDB;
    FormBackupRestore.ShowModal;

  finally
    FormBackupRestore.Free;
  end;
end;

procedure TFormDataManager.LbxDatabasesClick(Sender: TObject);
// procedimento de clicar na lista de databases
begin
  HabilitarDesabilitarElementos(True, True);
end;

procedure TFormDataManager.RegistrarLogs(PAcao: string);
// Registra os acontecimentos do sistema em logs
Var
  ArquivoDeTexto: TextFile;
begin
  try
    AssignFile(ArquivoDeTexto, 'Logs.txt');
    if FileExists('Logs.txt') then
      Append(ArquivoDeTexto)
    else
      begin
        Rewrite(ArquivoDeTexto);
        PAcao := ('-------------------------------------------------------------------------------' + sLineBreak + '[' + DateTimeToStr(Now()) + '] - Foi criado o arquivo "Logs.txt", pois o mesmo não foi encontrado no diretório da aplicação.');
      end;
    Writeln(ArquivoDeTexto, '[' + DateTimeToStr(Now()) + '] - ' + PAcao + ' -');
  finally
    CloseFile(ArquivoDeTexto);
  end;
end;

procedure TFormDataManager.RenomearDatabase(PNomeDoDatabaseAntigo, PNomeDoDatabaseNovo: string);
// Renomeia o database
begin
  FDQueryBD.close;
  FDQueryBD.sql.Clear;
  FDQueryBD.sql.add('ALTER DATABASE "' + PNomeDoDatabaseAntigo + '" RENAME TO "' + PNomeDoDatabaseNovo + '"');
  FDQueryBD.ExecSQL;
  FDQueryBD.close;
  RegistrarLogs('Database "' + PNomeDoDatabaseAntigo + '" renomeado para "' + PNomeDoDatabaseNovo + '" com sucesso');
end;

function TFormDataManager.ValidaDatabaseExistente(PNomeDoDatabase: String): boolean;
//Função que valida se já existe um database com o mesmo nome que o digitado
var
  i: integer;
begin
  for i := 0 to LbxDatabases.Items.Count - 1 do
    begin
      if PNomeDoDatabase = LbxDatabases.Items[i] then
      begin
        Result := true;
        exit;
      end
    end;
    Result := False;
end;

function TFormDataManager.ValidaOwnerDatabase(PNomeDoDatabase, POwnerPadrao: string; out POwnerBD: string): Boolean;
//Função para validar se o Owner do banco selecionado é = POwner
begin
  FDQueryBD.close;
  FDQueryBD.sql.Clear;
  FDQueryBD.sql.add('SELECT pg_catalog.pg_get_userbyid(datdba) AS owner FROM pg_database where datname = ''' + PNomeDoDatabase + '''');
  FDQueryBD.Open;
  POwnerBD := FDQueryBD.FieldByName('owner').AsString;
  if POwnerPadrao = POwnerBD then
  Result := True
  else
  Result := False;
end;

procedure TFormDataManager.HabilitarDesabilitarElementos(PStatusConexao, PBancoSelecionado: Boolean);
// Habilita ou desabilita os edits de conexão conforme o banco está ou não está conectado
begin
  BtnConectaBD.Enabled := not PStatusConexao;
  BtnConectaBD.Enabled := not PStatusConexao;
  CboxDriverBD.Enabled := not PStatusConexao;
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

end;

procedure TFormDataManager.AtualizaListaBancos(PStatusConexao: Boolean);
//Atualiza a grid dos bancos de dados
begin
  case PStatusConexao of
    True:
      Begin
        FDQueryBD.SQL.text := 'select datname from pg_database where datistemplate = false and datname <> ''postgres'' order by datname';
        FDQueryBD.Open;
        LbxDatabases.Items.Clear;
        While not FDQueryBD.Eof do
        begin
          LbxDatabases.Items.Add(FDQueryBD.FieldByName('Datname').Asstring);
          FDQueryBD.Next;
        end;
      End;
    False:
      begin
        LbxDatabases.Items.Clear;
      end;
  end;
end;

procedure TFormDataManager.Button2Click(Sender: TObject);
// Faz um select no banco
// FDQuery1.Open Só roda selec
// FDQuery1.
begin
  FDQueryBD.close;
  FDQueryBD.SQL.Clear;
  FDQueryBD.SQL.Add('select * from wshop.tprec');
  FDQueryBD.SQL.Add('order by cdtiporec');
  FDQueryBD.Open;
end;

procedure TFormDataManager.Button3Click(Sender: TObject);
// Faz um update no banco
begin
  FDQueryBD.close;
  FDQueryBD.SQL.Clear;
  FDQueryBD.SQL.Add('update wshop.tprec');
  FDQueryBD.SQL.Add('set nmtprecebimento = :pnmtprecebimento');
  FDQueryBD.SQL.Add('where idtprecebimento = :pidtprecebimento');
  FDQueryBD.ParamByName('pnmtprecebimento').Asstring :=
    EditFormaDePagamento.text;
  FDQueryBD.ParamByName('pidtprecebimento').Asstring := '0RR0000001';
  FDQueryBD.ExecSQL;
  Button2Click(nil);
end;

procedure TFormDataManager.DBRadioGroupTipoBackupChange(Sender: TObject);
begin
   beep;
end;

procedure TFormDataManager.DeleteClick(Sender: TObject);
// Faz um delete no banco
begin
  FDQueryBD.close;
  FDQueryBD.SQL.Clear;
  FDQueryBD.SQL.Add('delete from wshop.tprec');
  FDQueryBD.SQL.Add('where nmtprecebimento = :pnmtprecebimento');
  FDQueryBD.ParamByName('pnmtprecebimento').Asstring :=
  EditFormaDePagamento.text;
  FDQueryBD.ExecSQL;
  Button2Click(nil);
end;



{ TDriverBD }

procedure TDriverBDConexao.DefineParametros(PNomeDoDriverBD: string);
// Retorna qual driver de banco de dados usar com base na opção escolhida
begin
  Host := FormDataManager.EdtHost.text;
  Senha := FormDataManager.EdtSenha.text;
  Porta := FormDataManager.EdtPorta.text;
  OwnerPadrao := 'PRODFAB_ADMIN';

  if FormDataManager.RadioGroupTipoArquivo.Items[FormDataManager.RadioGroupTipoArquivo.ItemIndex] = 'Custom' then
  begin
    Formato := 'c';
    Extensao := 'postgresql';
    TipoQueryDlg := 'Backup PostgreSQL';
  end
  else if FormDataManager.RadioGroupTipoArquivo.Items[FormDataManager.RadioGroupTipoArquivo.ItemIndex] = 'Plain' then
  begin
    Formato := 'p';
    Extensao := 'sql';
    TipoQueryDlg := 'Backup QuerySQL';
  end;

  if PNomeDoDriverBD = 'Firebird 5.0' then
    begin
       Driver := 'FB';
       Versao := '5.0';
       Biblioteca := 'C:\Program Files\Firebird\Firebird_5_0\fbclient.dll';
       Dump := '';
    end
  else if (PNomeDoDriverBD = 'PostgreSQL 9.6') then
    begin
      Driver := 'PG';
      Versao := '9.6';
      Biblioteca := 'C:\Program Files\PostgreSQL\9.6\bin\libpq.dll';
      Dump := 'C:\Program Files\PostgreSQL\9.6\bin\pg_dump.exe';
      Restore := 'C:\Program Files\PostgreSQL\9.6\bin\pg_restore.exe';
      Psql := 'C:\Program Files\PostgreSQL\9.6\bin\psql.exe';
    end
  else if (PNomeDoDriverBD = 'PostgreSQL 17') then
    begin
      Driver := 'PG';
      Versao := '17';
      Biblioteca := 'C:\Program Files\PostgreSQL\17\bin\libpq.dll';
      Dump := 'C:\Program Files\PostgreSQL\17\bin\pg_dump.exe';
      Restore := 'C:\Program Files\PostgreSQL\17\bin\pg_restore.exe';
      Psql := 'C:\Program Files\PostgreSQL\17\bin\psql.exe';
    end
  else
    begin
      Driver := '';
      Versao := '';
      Biblioteca := '';
      Dump := '';
      Restore := '';
      Psql := '';
    end;

end;
end.
