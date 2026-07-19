unit Utils.Funcoes;

interface

procedure RegistrarLogs(PRotina: string; PLog: string);

var
  CaminhoDoArquivoDeLog: string;

implementation

uses System.IOUtils, System.SysUtils;

procedure RegistrarLogs(PRotina, PLog: string);
// Registra os acontecimentos do sistema em logs
Var
  ArquivoDeTexto: TextFile;
  NomeDoArquivoDeLog, CaminhoCompleto: string;
begin
  try
    try
      CaminhoDoArquivoDeLog := ExtractFilePath(ParamStr(0));
      NomeDoArquivoDeLog := FormatDateTime('dd-mm-yyyy', now()) + '-Logs.txt';

      if not DirectoryExists(CaminhoDoArquivoDeLog + 'Logs') then
        CreateDir(CaminhoDoArquivoDeLog + 'Logs');

      CaminhoCompleto := TPath.Combine(CaminhoDoArquivoDeLog, 'Logs', NomeDoArquivoDeLog);
      AssignFile(ArquivoDeTexto, CaminhoCompleto);
      if FileExists(CaminhoCompleto) then
        Append(ArquivoDeTexto)
      else
        begin
          Rewrite(ArquivoDeTexto);
          PLog := ('-------------------------------------------------------------------------------' + sLineBreak + '[' + DateTimeToStr(Now())
                   + '] - [Funcoes.RegistrarLogs] - Na abertura do sistema foi criado o arquivo "' + NomeDoArquivoDeLog + '", pois o mesmo não foi encontrado no diretório de logs.');
        end;
      Writeln(ArquivoDeTexto, '[' + DateTimeToStr(Now()) + '] - [' + PRotina + '] - ' + PLog + ' -');
    except
      //Silencioso, para não quebrar a aplicação
    end;
  finally
    CloseFile(ArquivoDeTexto);
  end;
end;
end.
