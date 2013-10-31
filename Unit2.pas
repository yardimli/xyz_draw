unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IdBaseComponent, IdComponent, IdCustomTCPServer, IdCustomHTTPServer, IdHTTPServer,idContext,
  ExtCtrls, CPort,inifiles, MidiDeviceComboBox, MidiType, MidiOut, Buttons, ComCtrls, Spin, Mask, AdvSpin;

type
  TForm2 = class(TForm)
    IdHTTPServer1: TIdHTTPServer;
    ComPort: TComPort;
    OpenDialog1: TOpenDialog;
    Panel4: TPanel;
    Panel3: TPanel;
    clearButton: TButton;
    onlineButton: TButton;
    Label1: TLabel;
    Button3: TButton;
    PortButton: TButton;
    ConnButton: TButton;
    Memo1: TMemo;
    Panel2: TPanel;
    ZoomLabel: TLabel;
    ScrollBar1: TScrollBar;
    xyzTimer: TTimer;
    BitBtn1: TBitBtn;
    ScrollBox1: TScrollBox;
    Image1: TPaintBox;
    Button1: TButton;
    ProgressBar1: TProgressBar;
    ProgressLabel: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Button2: TButton;
    XEdit: TAdvSpinEdit;
    YEdit: TAdvSpinEdit;
    ZEdit: TAdvSpinEdit;
    FlipX: TCheckBox;
    FlipY: TCheckBox;
    StepSpeedEdit: TAdvSpinEdit;
    Label8: TLabel;
    procedure IdHTTPServer1CommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo);
    procedure onlineButtonClick(Sender: TObject);
    procedure ConnButtonClick(Sender: TObject);
    procedure PortButtonClick(Sender: TObject);
    procedure ComPortAfterClose(Sender: TObject);
    procedure ComPortAfterOpen(Sender: TObject);
    procedure ComPortRxChar(Sender: TObject; Count: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure ScrollBar1Change(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure Image1Paint(Sender: TObject);
    procedure xyzTimerTimer(Sender: TObject);
    procedure XEditChange(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure StepSpeedEditChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    FInitFlag:Boolean;
    FIni:TMemIniFile;
    CanvasDraw : Boolean;
    LastX,LastY:integer;
    DeltaX,DeltaY:integer;
    CommandStr : String;
    xBuffer : integer;
    xBufferPos : integer;
    xArray : Array[1..10000] of string[25];
    isBusy : boolean;
    ArduinoStr : String;
    FirstClick : Boolean;
    xMover : integer;
    last_i2,last_i3,last_i4 : integer;
    SensorReads : Array[1..3,1..1000] of integer;
    maxSensorRead : integer;

    procedure PaintGCode;
  end;

var
  Form2: TForm2;
  j2,j3,j4:integer;
  CurrentFile : String;
  GCodeArray : Array[1..100000] of record command:integer; valueX,valueY,valueZ : double;  intX,intY,intZ : integer; end;
  MaxGCodeArray : integer;
  UniHighY : integer;
  GCodePrintPos : integer;
  GCodePrintStart : boolean;
  XYMoving : boolean;

implementation

{$R *.dfm}

procedure TForm2.onlineButtonClick(Sender: TObject);
begin
 if onlineButton.Caption = 'online' then
 begin
  IdHTTPServer1.Active := true;
  onlineButton.Caption := 'offline';
 end else
 if onlineButton.Caption = 'offline' then
 begin
  IdHTTPServer1.Active := true;
  onlineButton.Caption := 'online';
 end;
end;

procedure TForm2.XEditChange(Sender: TObject);
var
 sendX,sendY,sendZ : integer;
begin
 if ComPort.Connected then
 begin
  sendX := 10000 + round( XEdit.FloatValue / 0.0423 );
  if FlipX.Checked then sendX := 10000 - round( XEdit.FloatValue / 0.0423 );

  sendY := 10000 + round( YEdit.FloatValue / 0.0423 );
  if FlipY.Checked then sendY := 10000 - round( YEdit.FloatValue / 0.0423 );

  sendZ := 10000 + round( ZEdit.FloatValue / 0.0423 );

  Memo1.Lines.Add('1a'+inttostr(sendX )+'a'+inttostr(sendY )+'a'+inttostr(sendZ)+ 'a' );

  ComPort.WriteStr('1a'+inttostr(sendX )+'a'+inttostr(sendY )+'a'+inttostr(sendZ)+ 'a' );
 end;
end;

procedure TForm2.BitBtn1Click(Sender: TObject);
var
 highY,i,j,k:integer;

begin
 if (GCodePrintStart) then
 begin
  GCodePrintStart := false;
  BitBtn1.Caption := 'Start Send G-Code';
 end else
 begin
  BitBtn1.Caption := 'Stop Send G-Code';
  XYMoving := False;
  UniHighY := 0;

  for i := 1 to MaxGCodeArray do
   if GCodeArray[i].intY>UniHighY then UniHighY :=GCodeArray[i].intY;

  GCodePrintPos := 0;
  GCodePrintStart := true;
 end;
end;

procedure TForm2.Button2Click(Sender: TObject);
begin
 if ComPort.Connected then
 begin
  Memo1.Lines.Add( '3a10000a10000a10000a' );

  ComPort.WriteStr( '3a10000a10000a10000a' );

  XEdit.FloatValue := 0;
  YEdit.FloatValue := 0;
  ZEdit.FloatValue := 0;

 end;

end;

procedure TForm2.Button3Click(Sender: TObject);
var
 T :TextFile;
 xcommand,s,s1,s2,s3:String;
 xcommands : string;
 xnumber : Double;
 i,j,k,l:integer;
 addXYZ : boolean;
 lastXYZ : integer;
 lastX,lastY,lastZ : Double;
begin

 xcommands := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
 if OpenDialog1.Execute then
 begin
  ScrollBar1.Position := 81;
  CurrentFile := OpenDialog1.FileName;

  MaxGCodeArray := 0;
  AddXYZ := false;
  lastX := 0;
  lastY := 0;
  lastZ := 10;

  AssignFile(t,CurrentFile);
  reset(t);
  repeat
   readln(t,s);
   s := trim(s);
   if (s<>'') and (pos(';',s)<>1) then
   begin
    s := uppercase(s);
    s := StringReplace(s,chr(9),' ',[rfReplaceAll,rfIgnoreCase]);
    s := s+' ';
    for i := 1 to length(xcommands) do
    begin
     s := StringReplace(s,xcommands[i],xcommands[i]+' ',[rfReplaceAll]);
    end;
    s := StringReplace(s,'  ',' ',[rfReplaceAll]);
    s := StringReplace(s,'  ',' ',[rfReplaceAll]);

//   memo1.lines.add(s);

    //each new line is a new coordinate even withotu G00 or G01
    lastXYZ := 0;

    repeat
     //delete till non space char
     repeat
      if pos(' ',s)=1 then delete(s,1,1);
     until pos(' ',s)<>1;

     xCommand := copy(s,1,1);
     delete(s,1,1); //delete command

     if pos(xcommand,xcommands)<>0 then
     begin
      //delete till non space char
      repeat
       if pos(' ',s)=1 then delete(s,1,1);
      until pos(' ',s)<>1;

      //read numeric value
      i := pos(' ',s);
      s2 := copy(s,1,i-1);
      delete(s,1,i);

      val(s2,xnumber,i);
      if i = 0 then //conversion to double ok
      begin
//      memo1.lines.add(xcommand+' '+s2+' '+FloatToStr(xnumber));
       if (xcommand='G') and (xnumber=0) then
       begin
        inc(MaxGCodeArray);
        GCodeArray[MaxGCodeArray].command := 1; //G0
        GCodeArray[MaxGCodeArray].valueX   := 0;
        addXYZ := true;
        lastXYZ := 0;
       end else
       if (xcommand='G') and (xnumber=1) then
       begin
        inc(MaxGCodeArray);
        GCodeArray[MaxGCodeArray].command := 1; //G0
        GCodeArray[MaxGCodeArray].valueX   := 0;
        lastXYZ := 0;
        addXYZ := true;
       end else
       if (xcommand='G') then
       begin
        addXYZ := false;
       end else
       if not ((xcommand='X') or (xcommand='Y') or (xcommand='Z')) then
       begin
        addXYZ := false;
       end;


//      if addXYZ then
       begin

        if (xcommand='X') then
        begin

         if (lastXYZ=2) or (lastXYZ=0) then //XYZ
         begin
          inc(MaxGCodeArray);
          GCodeArray[MaxGCodeArray].command := 2;
          GCodeArray[MaxGCodeArray].valueX := lastX;
          GCodeArray[MaxGCodeArray].valueY := lastY;
          GCodeArray[MaxGCodeArray].valueZ := LastZ;
         end;

         lastX := xnumber;
         GCodeArray[MaxGCodeArray].valueX   := xnumber;
         lastXYZ := 2;
        end else

        if (xcommand='Y') then
        begin
         if (lastXYZ=3) or (lastXYZ=0) then //XYZ
         begin
          inc(MaxGCodeArray);
          GCodeArray[MaxGCodeArray].command := 2;
          GCodeArray[MaxGCodeArray].valueX := lastX;
          GCodeArray[MaxGCodeArray].valueY := lastY;
          GCodeArray[MaxGCodeArray].valueZ := LastZ;
         end;

         lastY := xnumber;
         GCodeArray[MaxGCodeArray].valueY   := xnumber;
         lastXYZ := 3;
        end else

        if (xcommand='Z') then
        begin
         if (lastXYZ=4) or (lastXYZ=0) then //XYZ
         begin
          inc(MaxGCodeArray);
          GCodeArray[MaxGCodeArray].command := 2;
          GCodeArray[MaxGCodeArray].valueX := lastX;
          GCodeArray[MaxGCodeArray].valueY := lastY;
          GCodeArray[MaxGCodeArray].valueZ := LastZ;
         end;

         lastZ := xnumber;
         GCodeArray[MaxGCodeArray].valueZ   := xnumber;
         lastXYZ := 4;
        end;
       end;
      end;
     end;
    until s='';
   end;

   //G90 absolute position
   //G91 relative position
   //G92 set position X,Y,Z
   //check for unit G21 mm
   //check for unit G20 inch
   //check for F feedrate

  until eof(t);
  CloseFile(t);
  memo1.lines.add(IntToStr(MaxGCodeArray));

  for i := 1 to MaxGCodeArray do
  begin
   if GCodeArray[i].command=2 then
   begin
//    Memo1.Lines.Add(FloatToStr(GCodeArray[i].valueX) +' '+FloatToStr(GCodeArray[i].valueY)+' '+FloatToStr(GCodeArray[i].valueZ));
//    Memo1.Lines.Add(IntToStr(GCodeArray[i].intX) +' '+IntToStr(GCodeArray[i].intY)+' '+IntToStr(GCodeArray[i].intZ));
   end;
  end;

  Image1.Refresh;

 end;

end;

procedure TForm2.ComPortAfterClose(Sender: TObject);
begin
  ConnButton.Caption := 'Connect';
end;

procedure TForm2.ComPortAfterOpen(Sender: TObject);
begin
  ConnButton.Caption := 'Disconnect';
end;

procedure TForm2.ComPortRxChar(Sender: TObject; Count: Integer);
var
 Str:String;
 s,s2,s3,s4:String;
 k2,k3,k4:string;
 i,j,k,l,m:integer;
 i1,i2,i3,i4:integer;
begin
 ComPort.ReadStr(Str, Count);

// if memo1.lines.Count>800 then Memo1.Lines.Clear;
  memo1.text := memo1.text + str;

  //memo1.lines.add('A: '+ Str);

  if pos('Z',Str)<>0 then
  begin
   XYMoving := false;
   memo1.lines.add('done');
  end;


end;

procedure TForm2.ConnButtonClick(Sender: TObject);
var
 i :integer;
begin
 j2 := 0;
 j3 := 0;
 j4 := 0;
   xBuffer :=0;
   xBufferPos := 0;
   for i := 1 to 10000 do
    xArray[i] := '';
  isBusy := false;

  if ComPort.Connected then
    ComPort.Close
  else
    ComPort.Open;
end;

procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   if Assigned(FIni) then
   begin
     FIni.WriteString('ComPort', 'ComPort', ComPort.Port );
     FIni.WriteString('ComPort','BaudRate', BaudRateToStr( ComPort.BaudRate ) );
     FIni.WriteString('ComPort','FlowControl', FlowControlToStr(ComPort.FlowControl.FlowControl ));
     FIni.UpdateFile;
     FIni.Free;
   end;
end;

procedure TForm2.FormCreate(Sender: TObject);
var
 i:integer;
 j:integer;
begin
 FirstClick := TRUE;

 xBuffer :=0;
 xBufferPos := 0;
 for i := 1 to 10000 do
  xArray[i] := '';
 isBusy := false;

end;

procedure TForm2.FormShow(Sender: TObject);
begin
 if not FInitFlag then
 begin
  FInitFlag := true;
  FIni := TMemIniFile.Create( ExtractFilePath(Application.ExeName)+'terminal.ini');
  ComPort.Port := FIni.ReadString('ComPort', 'ComPort',ComPort.Port);
  ComPort.BaudRate := StrToBaudRate( FIni.ReadString('ComPort','BaudRate', '19200'));
  ComPort.FlowControl.FlowControl := StrToFlowControl( FIni.ReadString('ComPort','FlowControl', 'Hardware'));
//ConnButton.Click;
 end;
end;

procedure TForm2.IdHTTPServer1CommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo;
  AResponseInfo: TIdHTTPResponseInfo);
var
  I: Integer;
  RequestedDocument, FileName, CheckFileName: string;
begin
  // requested document
  RequestedDocument := ARequestInfo.Document;
  // log request
  memo1.lines.add('Client: ' + ARequestInfo.RemoteIP + ' request for: ' + RequestedDocument);

  // 001
  if Copy(RequestedDocument, 1, 1) <> '/' then
    // invalid request
    raise Exception.Create('invalid request: ' + RequestedDocument);

  // 002
  // convert all '/' to '\'
  FileName := RequestedDocument;
  I := Pos('/', FileName);
  while I > 0 do
  begin
    FileName[I] := '\';
    I := Pos('/', FileName);
  end;

  // locate requested file
  FileName := ExtractFilePath(Application.ExeName) + FileName;

  try
    CheckFileName := FileName;
    if FileExists(CheckFileName) then
    begin
      // return file as-is
      // log
      Memo1.Lines.Add('Returning Document: ' + CheckFileName);
      // open file stream
      AResponseInfo.ContentStream := TFileStream.Create(CheckFileName, fmOpenRead or fmShareCompat);
    end;
  finally
    if Assigned(AResponseInfo.ContentStream) then
    begin
      // response stream does exist
      // set length
      AResponseInfo.ContentLength := AResponseInfo.ContentStream.Size;
      // write header
      AResponseInfo.WriteHeader;
      // return content
      AResponseInfo.WriteContent;
      // free stream
      AResponseInfo.ContentStream.Free;
      AResponseInfo.ContentStream := nil;
    end else
    if AResponseInfo.ContentText <> '' then
    begin
      // set length
      AResponseInfo.ContentLength := Length(AResponseInfo.ContentText);
      // write header
      AResponseInfo.WriteHeader;
      // return content
    end else
    begin
     if not AResponseInfo.HeaderHasBeenWritten then
     begin
        // set error code
        AResponseInfo.ResponseNo := 404;
        AResponseInfo.ResponseText := 'Document not found';
        // write header
        AResponseInfo.WriteHeader;
     end;
     // return content
     AResponseInfo.ContentText := 'The document requested is not availabe.';
     AResponseInfo.WriteContent;
    end;
  end;
end;

procedure TForm2.Image1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 if not CanvasDraw then
 begin
  Memo1.Lines.Add(inttostr(x)+';'+IntToStr(y));
  image1.Canvas.MoveTo(x,y);

  if not FirstClick then
  begin
   CommandStr := '';
   DeltaX := x-LastX;
   DeltaY := y-LastY;
   if (DeltaX<0) then CommandStr := CommandStr + chr(177)+chr(71)+chr(70+(DeltaX*(-1))) ;// '1;'+IntToStr(DeltaX*(-1))+';';
   if (DeltaX>0) then CommandStr := CommandStr + chr(177)+chr(72)+chr(70+(DeltaX*(1))) ;// '2;'+IntToStr(DeltaX)+';';

   if (DeltaY<0) then CommandStr := CommandStr + chr(177)+chr(73)+chr(70+(DeltaY*(-1)));// '3;'+IntToStr(DeltaY*(-1))+';';
   if (DeltaY>0) then CommandStr := CommandStr + chr(177)+chr(74)+chr(70+(DeltaY*(1)));// '4;'+IntToStr(DeltaY)+';';

   inc(xBuffer);
   if (xBuffer>10000) then xBuffer := 1;

   xArray[xBuffer] := CommandStr;
  end;
  FirstClick := False;

  LastX := x;
  LastY := y;
  inc(xBuffer);
  if (xBuffer>10000) then xBuffer := 1;
  xArray[xBuffer] := chr(177)+chr(76)+chr(70+100);

 end;

 CanvasDraw := True;
end;

procedure TForm2.Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if canvasDraw then
  begin

   CommandStr:='';
   DeltaX := x-LastX;
   DeltaY := y-LastY;
   if (DeltaX<0) then CommandStr := CommandStr + chr(177)+chr(71)+chr(70+(DeltaX*(-1))) ;// '1;'+IntToStr(DeltaX*(-1))+';';
   if (DeltaX>0) then CommandStr := CommandStr + chr(177)+chr(72)+chr(70+(DeltaX*(1))) ;// '2;'+IntToStr(DeltaX)+';';

   if (DeltaY<0) then CommandStr := CommandStr + chr(177)+chr(73)+chr(70+(DeltaY*(-1)));// '3;'+IntToStr(DeltaY*(-1))+';';
   if (DeltaY>0) then CommandStr := CommandStr + chr(177)+chr(74)+chr(70+(DeltaY*(1)));// '4;'+IntToStr(DeltaY)+';';

   if (ComPort.Connected) then
   begin
    inc(xBuffer);
    if (xBuffer>10000) then xBuffer := 1;

    xArray[xBuffer] := CommandStr;
//   ComPort.WriteStr(CommandStr);
   end;

   Memo1.Lines.Add('delta:'+inttostr(DeltaX)+';'+IntToStr(DeltaY));
   Image1.Canvas.LineTo(x,y);

   LastX := x;
   LastY := y;

  end;
end;

procedure TForm2.Image1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 CanvasDraw := False;
 inc(xBuffer);
 if (xBuffer>10000) then xBuffer := 1;
 xArray[xBuffer] := chr(177)+chr(75)+chr(70+100);
end;

procedure TForm2.Image1Paint(Sender: TObject);
begin
 PaintGCode;
end;

procedure TForm2.PaintGCode;
var
 i,j:integer;
 k : double;
 highX,highY : integer;

begin
  //convert mm to 600 dpi resolution
  if ScrollBar1.Position-80>=0 then
  begin
   k := ScrollBar1.Position-80;
   if k=0 then k := 1;
   ZoomLabel.Caption := 'Zoom '+FloatToStr(k)+'/1:';
  end else
  begin
   k := 80-ScrollBar1.Position;
   ZoomLabel.Caption := 'Zoom 1/'+FloatToStr(k)+':';
   k := 1/k;
  end;


  if MaxGCodeArray>0 then
  begin
   for i := 1 to MaxGCodeArray do
   begin
    if GCodeArray[i].command=2 then
    begin
     with GCodeArray[i] do
     begin
      intX := round(valueX / 0.0423 / k);
      intY := round(valueY / 0.0423 / k);
      intZ := round(valueZ / 0.0423 / k);
     end;
    end;
   end;

   highY := 0;
   for i := 1 to MaxGCodeArray do
    if GCodeArray[i].intY>highY then highY :=GCodeArray[i].intY;

   highX := 0;
   for i := 1 to MaxGCodeArray do
    if GCodeArray[i].intX>highX then highX :=GCodeArray[i].intX;

   Image1.Width := highX + 10;
   Image1.Height := highY + 10;
  end;

  Image1.Canvas.Brush.Color := clWhite;
  Image1.Canvas.Rectangle(0,0,Image1.Width,Image1.Height);

  Image1.Canvas.pen.Width := 1;



  Image1.Canvas.pen.Color := rgb(200,200,200);
  for i := 1 to 1000 do
  begin
   Image1.Canvas.moveto(i * round(1/0.0423),0);
   Image1.Canvas.lineto(i * round(1/0.0423),6000);
   if i mod 10 = 0 then
    Image1.Canvas.textout(i * round(1/0.0423),10,inttostr(i));
  end;

  for i := 1 to 1000 do
  begin
   Image1.Canvas.moveto(0, Image1.Height- ( i * round(1/0.0423)));
   Image1.Canvas.lineto(6000,Image1.Height- ( i * round(1/0.0423)));
   if i mod 10 = 0 then
    Image1.Canvas.textout(10,Image1.Height- ( i * round(1/0.0423)),inttostr(i));
  end;

  Image1.Canvas.MoveTo(0,0);



  if MaxGCodeArray>0 then
  begin
   for i := 1 to MaxGCodeArray do
   begin
    if GCodeArray[i].command=2 then
    begin
     if GCodeArray[i].intZ>0 then
     begin
      Image1.Canvas.pen.Color := rgb(120,255,0);
      Image1.Canvas.LineTo(GCodeArray[i].intX, highY- GCodeArray[i].intY )
     end else
     begin
      Image1.Canvas.pen.Color := rgb(0,0,0);
      Image1.Canvas.LineTo(GCodeArray[i].intX, highY- GCodeArray[i].intY );
     end;
    end;
   end;
  end;
end;

procedure TForm2.PortButtonClick(Sender: TObject);
begin
  ComPort.ShowSetupDialog;
end;

procedure TForm2.ScrollBar1Change(Sender: TObject);
begin
 Image1.Refresh;
end;

procedure TForm2.StepSpeedEditChange(Sender: TObject);
var
 sendX,sendY,sendZ : integer;
begin
 if ComPort.Connected then
 begin

  sendX := 10000 + StepSpeedEdit.value;
  sendY := 10000 + StepSpeedEdit.value;
  sendZ := 10000 + (StepSpeedEdit.value div 2 );

  Memo1.Lines.Add('2a'+inttostr(sendX )+'a'+inttostr(sendY )+'a'+inttostr(sendZ)+ 'a' );

  ComPort.WriteStr('2a'+inttostr(sendX )+'a'+inttostr(sendY )+'a'+inttostr(sendZ)+ 'a' );
 end;

end;

procedure TForm2.xyzTimerTimer(Sender: TObject);
var
 falseZ : integer;
 sendX,sendY,sendZ:integer;
begin
 if (GCodePrintStart) then
 begin
  Label1.Caption := inttostr(random(1000));

  if (not XYMoving) then
  begin
   inc(GCodePrintPos);
   if GCodePrintPos>=MaxGCodeArray then GCodePrintStart := False;
   ProgressLabel.Caption := '%: ('+inttostr(GCodePrintPos)+'/'+IntToStr(MaxGCodeArray)+')';

   if GCodeArray[GCodePrintPos].command=2 then
   begin

    if ComPort.Connected then
    begin
     XYMoving := true;
     // postive z moves up if z>0 send 100 else send z as 0
     // posetive y moves towards step moter
     // posetive x moves away from step moter

     Memo1.lines.add('moveto X:'+inttostr(GCodeArray[GCodePrintPos].intX)+' Y:'+inttostr(GCodeArray[GCodePrintPos].intY)+' Z:'+inttostr(GCodeArray[GCodePrintPos].intZ) );

     if GCodeArray[GCodePrintPos].intZ>0 then falseZ := 10100 else falseZ := 10000;

     sendX := 10000 + GCodeArray[GCodePrintPos].intX;
     if FlipX.Checked then sendX := 10000 - GCodeArray[GCodePrintPos].intX;

     sendY := 10000 + GCodeArray[GCodePrintPos].intY;
     if FlipY.Checked then sendY := 10000 - GCodeArray[GCodePrintPos].intY;

     Memo1.lines.add('moveto: 1a'+inttostr(SendX)+'a'+inttostr(SendY)+'a'+inttostr(falseZ)+'a' );

     ComPort.WriteStr( '1a'+inttostr(SendX)+'a'+inttostr(SendY)+'a'+inttostr(falseZ)+'a' );
    end else
    begin
     Memo1.lines.add('X:'+inttostr(GCodeArray[GCodePrintPos].intX)+' Y:'+inttostr(GCodeArray[GCodePrintPos].intY)+' Z:'+inttostr(GCodeArray[GCodePrintPos].intZ) );
    end;

    if GCodeArray[GCodePrintPos].intZ>0 then
    begin
     Image1.Canvas.pen.Width := 2;
     Image1.Canvas.pen.Color := rgb(120,255,128);
     Image1.Canvas.LineTo( GCodeArray[GCodePrintPos].intX , UniHighY - GCodeArray[GCodePrintPos].intY );
    end else
    begin
     Image1.Canvas.pen.Width := 2;
     Image1.Canvas.pen.Color := rgb(0,0,255);
     Image1.Canvas.LineTo( GCodeArray[GCodePrintPos].intX , UniHighY - GCodeArray[GCodePrintPos].intY  );
    end;
   end;
  end;
 end;
end;

end.
