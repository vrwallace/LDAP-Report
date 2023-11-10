unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Spin, ldapsend, synautil, Clipbrd, strutils;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    CheckBox: TCheckBox;
    CheckBoxautotls: TCheckBox;
    CheckBoxsasl: TCheckBox;
    username: TEdit;
    password: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    Path: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Results: TMemo;
    Query: TMemo;
    Server: TEdit;
    Port: TSpinEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure CheckBoxChange(Sender: TObject);
    function countchar(lookfor, stringtosearch: string): integer;
    //function indexsumchar(lookfor, stringtosearch: string): integer;
    // procedure FormCreate(Sender: TObject);
    function LDAPResultDumpCSV(const Value: TLDAPResultList): ansistring;
    function LDAPResultDumpMOD(const Value: TLDAPResultList): ansistring;
    procedure DumpExceptionCallStack(E: Exception);
    function parmfollows(lookfor, stringtosearch: string): boolean;
   {procedure CatchUnhandledException(Obj: TObject; Addr: Pointer; FrameCount: Longint; Frames: PPointer);
   procedure CustomExceptionHandler(Sender: TObject; E: Exception);}
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var
  ldap: TLDAPsend;
  l: TStringList;
  //crlf: string;

begin
  //crlf := chr(13) + chr(10);

  if checkbox.Checked = False then
  begin
    if ((trim(username.Text) = '') or (trim(password.Text) = '')) then
    begin
      ShowMessage('Anonymous login not selected, please enter username and password');
      exit;
    end;

  end;


  {if checkbox.Checked = False then
  begin
    if checkboxsasl.Checked = False then
    begin
      checkboxsasl.Checked := True;
      ShowMessage('You must enable SASL with non-anonymous login!');
    end;
  end;}

  if (trim(server.Text) = '') or (trim(path.Text) = '') or
    (trim(query.Text) = '') then
  begin
    ShowMessage('Please fill in Server, Path and Query');
    exit;
  end;

  if countchar('(', trim(query.Text)) <> countchar(')', trim(query.Text)) then
  begin
    ShowMessage('( or ) mismatch');
    exit;
  end;

  if ((parmfollows('&', query.Text) = False) or (parmfollows('!', query.Text) = False) or
    (parmfollows('|', query.Text) = False)) then
  begin
    ShowMessage('! or & or | missing following ( example (&(cn=someone)(pt=something)) is correct');
    exit;
  end;

  begin

  end;

  {if indexsumchar('(', trim(query.Text)) > indexsumchar(')', trim(query.Text)) then
  begin
    ShowMessage('( should alway proceed ) example (((()))) Not ))))((((');
    exit;
  end;  }

  if ((pos('(', query.Text) > 0) and (pos(')', query.Text) > 0)) and
    ((pos('<', query.Text) > 0) or (pos('>', query.Text) > 0) or
    (pos('=', query.Text) > 0) or (pos(':', query.Text) > 0) or
    (pos('~', query.Text) > 0)) then
  begin
  end
  else
  begin
    ShowMessage('Query must include (),  or = or ~ or : or < or > example (cn=somename)');
    exit;
  end;


  ldap := TLDAPsend.Create;
  l := TStringList.Create;
  results.Clear;
  try
    try
      ldap.TargetHost := trim(server.Text);
      ldap.TargetPort := IntToStr(port.Value);
      results.Lines.add('Logging in...');
      application.ProcessMessages;

      if not checkbox.Checked then
      begin

        ldap.UserName := trim(username.Text);
        ldap.Password := trim(password.Text);
      end
      else
      begin
        ldap.UserName := '';
        ldap.Password := '';
      end;


      //if port.value = 636 then ldap.autotls:=true ;
      //ldap.autotls:=true;

       {if checkboxautotls.checked=true then ldap.autotls:=true
       else
        ldap.autotls:=false;}
      //ldap.FullSSL:=true;

      ldap.Login;

      if not ldap.Login then
      begin
        results.Lines.add('Login failed! ' + IntToStr(ldap.ResultCode) +
          ':' + ldap.ResultString);
        application.ProcessMessages;
        ShowMessage('Login failed! ' + IntToStr(ldap.ResultCode) +
          ':' + ldap.ResultString);

        exit;
      end;


      {if checkboxsasl.Checked then
      begin
        results.Lines.add('SASL Binding...');
        application.ProcessMessages;
        ldap.Bindsasl;
        if not ldap.Bindsasl then
        begin
          results.Lines.add('SASL bind failed! ' + inttostr(ldap.ResultCode) + ':' +
            ldap.ResultString);
          application.ProcessMessages;
          ShowMessage('SASL bind failed! ' + inttostr(ldap.ResultCode) + ':' + ldap.ResultString);

          exit;
        end;
      end
      else
      begin}
      results.Lines.add('Binding...');
      application.ProcessMessages;
      ldap.Bind;
      if not ldap.Bind then
      begin
        results.Lines.add('Bind failed! ' + IntToStr(ldap.ResultCode) +
          ':' + ldap.ResultString);
        application.ProcessMessages;
        ShowMessage('Bind failed! ' + IntToStr(ldap.ResultCode) +
          ':' + ldap.ResultString);
        exit;
      end;
      //end;




      results.Lines.add('Running query please wait...');
      application.ProcessMessages;
      //l.Add('displayname');
      //l.Add('description');
      //l.Add('givenName');
      l.Add('*');
      ldap.Search(trim(path.Text), False, trim(query.Text), l);
      //Results.Lines.Add(LDAPResultDumpMOD(ldap.SearchResult));
      //results.
      LDAPResultDumpMOD(ldap.SearchResult);
      ldap.Logout;
      results.Lines.add('');
      results.Lines.add('Query complete');



    except
      on E: Exception do
        DumpExceptionCallStack(E);
    end;
  finally
    results.Lines.add('Closing...');
    ldap.Free;
    l.Free;

  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Clipboard.AsText := Results.Text;

end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  server.Text := '192.168.10.117';
  port.Value := 389;
  Path.Text := 'ou=Dallas,o=Company';
  query.Text := '(&(objectclass=user)(logindisabled=true))';
  username.Text := 'cn=username,ou=DALLAS,o=Company';
  checkboxsasl.Checked := True;
  checkbox.Checked := True;
  checkboxautotls.Checked := False;
  results.Clear;
end;

procedure TForm1.CheckBoxChange(Sender: TObject);
begin
  if checkbox.Checked then
  begin
   
    username.Enabled := False;
    password.Text := '';
    password.Enabled := False;

  end
  else
  begin
    username.Enabled := True;
    password.Text := '';
    password.Enabled := True;
  end;
end;


function TForm1.LDAPResultDumpCSV(const Value: TLDAPResultList): ansistring;
var
  n, m, o: integer;
  r: TLDAPResult;
  a: TLDAPAttribute;
begin
  Result := '"';
  //Result := 'Results: ' + IntToStr(Value.Count) + CRLF +CRLF;
  for n := 0 to Value.Count - 1 do
  begin

    //Result := Result + 'Result: ' + IntToStr(n) + CRLF;
    r := Value[n];
    //Result := Result + '  Object: ' + r.ObjectName + CRLF;
    for m := 0 to r.Attributes.Count - 1 do
    begin

      if m > 0 then
        Result := Result + '","';



      a := r.Attributes[m];
      // Result := Result + '  Attribute: ' + a.AttributeName + CRLF;

      for o := 0 to a.Count - 1 do
      begin
        if o = a.Count - 1 then
          Result := Result + a[o] + ''
        else
          Result := Result + a[o] + '|';
      end;
    end;
    //result:=result+ '"' +crlf;
  end;

end;

function TForm1.LDAPResultDumpMOD(const Value: TLDAPResultList): ansistring;
var
  n, m, o: integer;
  r: TLDAPResult;
  a: TLDAPAttribute;
  //crlf: string;

begin
  Result := '';
  //crlf := chr(13) + chr(10);

  //Result := 'Results: ' + IntToStr(Value.Count) + CRLF +CRLF;
  results.Lines.add('');
  results.Lines.add('Results: ' + IntToStr(Value.Count));
  for n := 0 to Value.Count - 1 do
  begin

    results.Lines.add('');
    results.Lines.add('----------------------------------------');
    results.Lines.add('Result: ' + IntToStr(n));
    results.Lines.add('----------------------------------------');
    results.Lines.add('');

    r := Value[n];
    results.Lines.add('  Object: ' + r.ObjectName);
    for m := 0 to r.Attributes.Count - 1 do
    begin
      a := r.Attributes[m];
      results.Lines.add('  Attribute: ' + a.AttributeName);

      for o := 0 to a.Count - 1 do
        results.Lines.add('    ' + a[o]);
    end;
  end;
end;

procedure TForm1.DumpExceptionCallStack(E: Exception);
var
  I: integer;
  Frames: PPointer;
  Report: string;
begin
  Report := 'Program exception! ' + LineEnding + 'Stacktrace:' +
    LineEnding + LineEnding;
  if E <> nil then
  begin
    Report := Report + 'Exception class: ' + E.ClassName + LineEnding +
      'Message: ' + E.Message + LineEnding;
  end;
  Report := Report + BackTraceStrFunc(ExceptAddr);
  Frames := ExceptFrames;
  for I := 0 to ExceptFrameCount - 1 do
    Report := Report + LineEnding + BackTraceStrFunc(Frames[I]);
  ShowMessage(Report);
  //Halt; // End of program execution
end;


{procedure tform1.CatchUnhandledException(Obj: TObject; Addr: Pointer; FrameCount: Longint; Frames: PPointer);
var
  Message: string;
  i: LongInt;
  hstdout: ^Text;
begin
  hstdout := @stdout;
  Writeln(hstdout^, 'An unhandled exception occurred at $', HexStr(PtrUInt(Addr), SizeOf(PtrUInt) * 2), ' :');
  if Obj is exception then
   begin
     Message := Exception(Obj).ClassName + ' : ' + Exception(Obj).Message;
     Writeln(hstdout^, Message);
   end
  else
    Writeln(hstdout^, 'Exception object ', Obj.ClassName, ' is not of class Exception.');
  Writeln(hstdout^, BackTraceStrFunc(Addr));
  if (FrameCount > 0) then
    begin
      for i := 0 to FrameCount - 1 do
        Writeln(hstdout^, BackTraceStrFunc(Frames[i]));
    end;
  Writeln(hstdout^,'');
end;

procedure TForm1.CustomExceptionHandler(Sender: TObject; E: Exception);
begin
  DumpExceptionCallStack(e);
  Halt; // End of program execution
end;

procedure Tform1.FormCreate(Sender: TObject);
begin
  Application.OnException := @CustomExceptionHandler;
end;}


function TForm1.countchar(lookfor, stringtosearch: string): integer;
var
  c, j: integer;

begin
  c := 0;
  for j := 1 to length(stringtosearch) do
  begin
    if midstr(stringtosearch, j, 1) = lookfor then
      c := c + 1;
  end;
  Result := c;
  // showmessage (inttostr(c));
end;

{function TForm1.indexsumchar(lookfor, stringtosearch: string): integer;
var
  c, j: integer;

begin
  c := 0;
  for j := 1 to length(stringtosearch) do
  begin
    if midstr(stringtosearch, j, 1) = lookfor then
      c := c + j;
  end;
  Result := c;
  // showmessage (inttostr(c));
end;  }

function TForm1.parmfollows(lookfor, stringtosearch: string): boolean;
var
  j: integer;
  c: boolean;

begin
  c := True;

  if pos(lookfor, stringtosearch) > 0 then
  begin
    if (midstr(stringtosearch, length(stringtosearch), 1) = lookfor) then
    begin
      Result := False;
      exit;
    end;

    for j := 1 to length(stringtosearch) - 1 do
    begin
      if ((midstr(stringtosearch, j, 1) = lookfor) and
        (midstr(stringtosearch, j + 1, 1) <> '(')) then
      begin
        c := False;

        break;
      end;

      // showmessage (inttostr(c));
    end;
  end;
  Result := c;
end;

end.
