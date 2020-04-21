library FDLib;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  System.SysUtils,
  System.Classes,FireDAC.Comp.Client,Data.DB,
  Firedac.Stan.Def, FireDAC.Phys.MSAccDef, FireDAC.Stan.Intf, FireDAC.Phys,
  FireDAC.Phys.ODBCBase, FireDAC.Phys.MSAcc, FireDAC.Phys.FBDef,
  FireDAC.Phys.IBBase, FireDAC.Phys.FB,FireDAC.DApt, FireDAC.UI.Intf,
  FireDAC.VCLUI.Wait, FireDAC.Comp.UI,firedac.stan.async,system.json;

{$R *.res}

type
  TFDQueryHelper = class helper for TFDquery
  function AsJSON : string;
end;

procedure setConfig(var AConfig : PAnsiChar ;var AConn : TFdConnection);
var
 LObj : TJSONObject;
begin
  LObj := TJSONObject.ParseJSONValue(ACOnfig) as TJSONObject;
  try
    AConn.Params.database := LObj.GetValue<string>('database');
    AConn.Params.DriverID := LObj.GetValue<string>('driverid');
    AConn.Params.UserName :=  LObj.GetValue<string>('username');
    AConn.Params.Password := LObj.GetValue<string>('password');
  finally
    LObj.Free;
  end;

end;


function update(AConfig ,ACmd : PAnsichar ) : PAnsiChar ;cdecl;
var
  LQuery : TFDQuery;
  LCOnn  : TFdConnection;
begin
 try
  LConn := TFdConnection.Create(nil);
  LConn.ConnectionName := IntToStr(LConn.GetHashCode());
  LConn.LoginPrompt := False;
  setConfig(AConfig,LConn);
  LConn.Connected := True;
  Lquery := TFDQuery.Create(nil);
  Lquery.Connection := LConn;
  try
   LQuery.SQL.Text := ACmd;
   LQuery.ExecSQL;

   result := PAnsiChar( AnsiString(
     Format('{"ok" : true,rows_affected : %d}',[ LQuery.RowsAffected ])

   ) );
  finally
    LQuery.Close;
    FreeAndNil(LQuery);
    LConn.Connected := False;
    FreeAndNil(LConn);
  end;
 except on e : Exception do
  begin
       result := PAnsiChar( AnsiString( Format('{"ok":false,"error":"%s","rows_affected" :0}',[e.Message])) );
  end;
 end;
end;

function query(AConfig ,ACmd : PAnsichar ) : PAnsiChar ;cdecl;
var
  LQuery : TFDQuery;
  LCOnn  : TFdConnection;
begin
 try
  LConn := TFdConnection.Create(nil);
  LConn.ConnectionName := IntToStr(LConn.GetHashCode());
  LConn.LoginPrompt := False;
  setConfig(AConfig,LConn);
  LConn.Connected := True;
  Lquery := TFDQuery.Create(nil);
  Lquery.Connection := LConn;
  try
   LQuery.SQL.Text := ACmd;
   LQuery.Active := true;
   result := PAnsiChar( AnsiString(LQuery.AsJson) );
  finally
    LQuery.Close;
    FreeAndNil(LQuery);
    LConn.Connected := False;
    FreeAndNil(LConn);
  end;
 except on e : Exception do
  begin
       result := PAnsiChar( AnsiString( Format('{"error":"%s"}',[e.Message])) );
  end;
 end;
end;



function TFDQueryHelper.AsJSON: string;
var
 book : TBookMark;
 i,j,len : integer;
 row : string;
 function comma(index,size : integer) : string;
 begin
   if index = (size-1) then
      Result := ''
   else
      Result := ',';
 end;
 function fmtField(f : TField) : string;
 begin
   case f.DataType of
     ftInteger,
     ftFloat :
       Result := f.AsString.Replace(',','.');
     ftDate,ftDateTime,ftTimeStamp,ftTime :
       Result := Format('"%s"',[ FormatDateTime('dd/MM/yyyy',f.AsDateTime)]);
     else
       Result := Format('"%s"',[f.AsString]);
   end;
   if Result.IsEmpty then
      Result := 'null';

 end;
begin
  len :=  self.RecordCount;
  book := self.Bookmark;
  self.DisableControls;
  row := '';
  Result := Format('{"rows" : %d,"result" : [',[len]);
  try
   First;
   i := 0;
   while not Eof do
   begin
     j := 0;
     row := '{';
     while j < Fields.Count  do
     begin
       row := row + '"'+LowerCase(Fields[j].FieldName)+'":'+fmtField(Fields[j])+comma(j,Fields.Count);
       Inc(j);
     end;
     row := row + '},';
     Result := Result + row;
     Inc(i);
     Next;
   end;
   Result := Trim(Result);
   if (Result.EndsWith(',')) then
   begin
     Result := Copy(Result,0,Result.Length-1);
   end;
   Result := Result + ']}';
  finally
   Bookmark := book;
   EnableControls;
  end;
end;

exports
  query,update;

begin
end.
