unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Mask, ExtCtrls, Buttons;

type
  TfmMain = class(TForm)
    Bevel1: TBevel;
    Image1: TImage;
    SpeedButton1: TSpeedButton;
    MaskEdit1: TMaskEdit;
    dlgCommon: TOpenDialog;
    Bevel2: TBevel;
    Label1: TLabel;
    SpeedButton2: TSpeedButton;
    Button1: TButton;
    Panel1: TPanel;
    Image2: TImage;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure MaskEdit1Change(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    procedure Draw(digit : Byte; X, Y : Integer);
    function Parce1(X : Integer): Boolean;
    function Parce2(Y , x1, x2 : Integer): Boolean;
    function Parce3(x1, y1, x2, y2 : Integer): String;
    function ParceBMP(Canvas1 : TCanvas): String;
  public
    { Public declarations }
  end;

var
  mas: array[0..9, 0..8] of byte =
       (((1),(1),(1),(0),(0),(1),(0),(1),(1)),
        ((0),(0),(1),(1),(0),(0),(0),(1),(0)),
        ((0),(1),(1),(0),(0),(0),(1),(0),(1)),
        ((0),(1),(0),(1),(1),(0),(1),(0),(0)),
        ((1),(0),(1),(0),(1),(0),(0),(1),(0)),
        ((1),(1),(0),(0),(1),(0),(0),(1),(1)),
        ((0),(0),(0),(1),(1),(1),(0),(1),(1)),
        ((0),(1),(0),(1),(0),(1),(0),(0),(0)),
        ((1),(1),(1),(0),(1),(1),(0),(1),(1)),
        ((1),(1),(1),(0),(1),(0),(1),(0),(0)));

var
  fmMain: TfmMain;

implementation

{$R *.dfm}

{ TForm1 }

procedure TfmMain.Draw(digit: Byte; X, Y: Integer);
  procedure DrawElement(index : Byte);
  begin
    with Image1.Canvas do
    case index of
      0:
        begin
          MoveTo(X, Y);
          LineTo(X, Y + 20);
        end;
      1:
        begin
          MoveTo(X, Y);
          LineTo(X + 20, Y);
        end;
      2:
        begin
          MoveTo(X + 20, Y);
          LineTo(X + 20, Y+ 20);
        end;
      3:
        begin
          MoveTo(X + 20, Y);
          LineTo(X, Y + 20);
        end;
      4:
        begin
          MoveTo(X, Y + 20);
          LineTo(X + 20, Y + 20);
        end;
      5:
        begin
          MoveTo(X, Y + 20);
          LineTo(X, Y + 40);
        end;
      6:
        begin
          MoveTo(X + 20, Y + 20);
          LineTo(X, Y + 40);
        end;
      7:
        begin
          MoveTo(X + 20, Y + 20);
          LineTo(X + 20, Y + 40);
        end;
      8:
        begin
          MoveTo(X, Y + 40);
          LineTo(X + 20, Y + 40);
        end;
     end;
  end;

var
  i: Byte;
begin
 for i := 0 to 8 do
  begin
   if mas[digit][i]=1
   then DrawElement(i);
  end;
end;

procedure TfmMain.MaskEdit1Change(Sender: TObject);
var
 i: Byte;
begin
  // стирание изображения
  image1.Canvas.Brush.Color := clWhite;
  image1.Canvas.FillRect(rect(0,0,image1.Width,image1.Height));

  if length(MaskEdit1.Text) <> 0 then
    for i := 1 to length(MaskEdit1.Text) do
      begin
        if MaskEdit1.Text[i] <> ' ' then
          Draw(StrToInt(MaskEdit1.Text[i]),40 * i - 30 ,10);
      end;
end;


///сохраниение в файле
procedure TfmMain.SpeedButton1Click(Sender: TObject);
begin
  dlgCommon.Title := 'Save';
  dlgCommon.Filter := 'BMP (*.bmp)|*.bmp';
  dlgCommon.InitialDir := ExtractFileDir(ParamStr(0));
  if dlgCommon.Execute then
    begin
      if AnsiUpperCase(ExtractFileExt(dlgCommon.FileName)) <> '.BMP'
        then dlgCommon.FileName := dlgCommon.FileName + '.bmp';
       Image1.Picture.SaveToFile(dlgCommon.FileName);
    end;
end;


/////распознавание

procedure TfmMain.SpeedButton2Click(Sender: TObject);
begin
  //открытие файла на рапознавание
  dlgCommon.Title := 'Open';
  dlgCommon.Filter := 'BMP (*.bmp)|*.bmp';
  dlgCommon.InitialDir := ExtractFileDir(ParamStr(0));
  if dlgCommon.Execute then
    begin
      Image2.Picture.LoadFromFile(dlgCommon.FileName);
    end;
end;


function TfmMain.Parce1(X: Integer): Boolean;
var
  i : Integer;
begin
  Result := False;
  with Image2.Picture do
    for i := 0 to Bitmap.Height - 1 do
      if Bitmap.Canvas.Pixels[x,i] = clBlack
        then
          begin
            Result := True;
            Break;
          end;
end;

function TfmMain.Parce2(Y, x1, x2: Integer): Boolean;
var
  i : Integer;
begin
  Result := False;
  with Image2.Picture do
    for i := x1 to x2 do
      if Bitmap.Canvas.Pixels[i,y] = clBlack
        then
          begin
            Result := True;
            Break;
          end;
end;

procedure TfmMain.Button1Click(Sender: TObject);
var
  i, q1, q2, j : Integer;
  str1  : String;
begin
  q1 := 0;
  q2 := 0;
  //сканирование картинки на предмет черной области (цифры)
  with Image2.Picture do
    for i := 2 to Bitmap.Width - 3 do
      begin
        if (not Parce1(i - 2)) and (not Parce1(i - 1)) and Parce1(i) and Parce1(i + 1) then q1 := i;
        if Parce1(i - 1) and Parce1(i) and (not Parce1(i + 1)) and (not Parce1(i + 2))
          then
            for j := 2 to Bitmap.Height - 3 do
              begin
                if (not Parce2(j - 2,q1,i)) and (not Parce2(j - 1,q1,i)) and Parce2(j,q1,i) and Parce2(j + 1,q1,i) then q2 := j;
                if Parce2(j - 1,q1,i) and Parce2(j,q1,i) and (not Parce2(j + 1,q1,i)) and (not Parce2(j + 2,q1,i))
                  then
                    str1 := str1 + Parce3(q1,q2,i,j);
              end;
      end;

 MessageDlg('Распознанное число: '+str1, mtInformation, [mbOK], 0);
end;

function TfmMain.Parce3(x1, y1, x2, y2: Integer): string;
var
  bmp : TBitmap;
begin
  //распознавание конктретной области

  //рисование красной рамки
  Result := '';
  with Image2.Picture.Bitmap do
    begin
      Canvas.Pen.Color := clRed;
      Canvas.MoveTo(x1-1, y1-1);
      Canvas.LineTo(x2+1, y1-1);
      Canvas.LineTo(x2+1, y2+1);
      Canvas.LineTo(x1-1, y2+1);
      Canvas.LineTo(x1-1, y1-1);
    end;

  bmp := TBitmap.Create; //создание объекта картинки
  bmp.Height := 40;
  bmp.Width  := 21;

  //масштабирование картинки к 20х40
  try
    StretchBlt(bmp.Canvas.Handle, //<<<------- куда копировать
               0,
               0,
               21,
               40,
               Image2.Picture.Bitmap.Canvas.Handle,
               x1,
               y1,
               x2 - x1+1,
               y2 - y1+1,
               SRCCOPY);
    Result := ParceBMP(bmp.Canvas);
  finally
    bmp.Free;
  end;
end;

function TfmMain.ParceBMP(Canvas1: TCanvas): String;
var
  tmpset : set of Byte; //множество
  i, j : Byte;
  tmp  : Boolean;
begin
  //распознавание картинки 20х40
  tmpset := [];
  Result := '';
  with Canvas1 do
    begin
      if (Pixels[0,10] = clBlack) or
         (Pixels[0,11] = clBlack) or
         (Pixels[0,9 ] = clBlack) or
         (Pixels[1,10] = clBlack)
        then Include(tmpset,0);

      if (Pixels[10,0] = clBlack) or
         (Pixels[ 9,0] = clBlack) or
         (Pixels[11,0] = clBlack) or
         (Pixels[10,1] = clBlack)
        then Include(tmpset,1);

      if (Pixels[20,10] = clBlack) or
         (Pixels[20, 9] = clBlack) or
         (Pixels[20,11] = clBlack) or
         (Pixels[19,10] = clBlack)
        then Include(tmpset,2);

      if (Pixels[10,10] = clBlack) or
         (Pixels[11,10] = clBlack) or
         (Pixels[ 9,10] = clBlack) or
         (Pixels[10, 9] = clBlack) or
         (Pixels[10,11] = clBlack)
        then Include(tmpset,3);

      if (Pixels[10,20] = clBlack) or
         (Pixels[ 9,20] = clBlack) or
         (Pixels[11,20] = clBlack) or
         (Pixels[10,21] = clBlack) or
         (Pixels[10,19] = clBlack)
        then Include(tmpset,4);

      if (Pixels[0,30] = clBlack) or
         (Pixels[0,29] = clBlack) or
         (Pixels[0,31] = clBlack) or
         (Pixels[1,30] = clBlack)
        then Include(tmpset,5);

      if (Pixels[10,30] = clBlack) or
         (Pixels[11,30] = clBlack) or
         (Pixels[ 9,30] = clBlack) or
         (Pixels[10,29] = clBlack) or
         (Pixels[10,31] = clBlack)
        then Include(tmpset,6);

      if (Pixels[20,29] = clBlack) or
         (Pixels[20,30] = clBlack) or
         (Pixels[20,31] = clBlack) or
         (Pixels[19,30] = clBlack)
        then Include(tmpset,7);

      if (Pixels[ 9,40] = clBlack) or
         (Pixels[10,40] = clBlack) or
         (Pixels[11,40] = clBlack) or
         (Pixels[10,39] = clBlack)
        then Include(tmpset,8);
    end;
  for i := 0 to 9 do
    begin
      tmp := True;
      for j := 0 to 8 do
        if (mas[i,j] = 0) and (j in tmpset)
          then tmp := False;

      if tmp then
        begin
          Result:=IntToStr(i); //результирующая цифра
          Break;
        end;
    end;
end;

end.
