unit main;

(*******************************************************************************
*                                                                              *
* Author    :  Angus Johnson                                                   *
* Website   :  http://www.angusj.com                                           *
* Copyright :  Angus Johnson 2010-2011                                         *
*                                                                              *
* License:                                                                     *
* Use, modification & distribution is subject to Boost Software License Ver 1. *
* http://www.boost.org/LICENSE_1_0.txt                                         *
*                                                                              *
*******************************************************************************)

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, Math,
  //requires Graphics32 (revision 2180 or later) ...
  //https://sourceforge.net/p/graphics32/code/HEAD/tree/trunk/Source/
  GR32, GR32_Image, GR32_Polygons,
  GR32_Misc, clipper;

type

  //SVG Builder structures ////////////////////////////////////////

  TStyleInfo = record
    pft: TPolyFillType;
    brushClr: TColor32;
    penClr: TColor32;
    dashArray: TArrayOfInteger;
    penWidth: double;
    showCoords: boolean;
  end;

  TPolyInfo = record
    paths: TPaths;
    si: TStyleInfo;
  end;
  TPolyInfos = array of TPolyInfo;

  TTextInfo = record
    text: string;
    x,y: integer;
    fontName: string;
    fontSize: integer;
    fontColor: string;
  end;
  TTextInfos = array of TTextInfo;

  /////////////////////////////////////////////////////////////////

  TSvgBuilder = class
  private
    polyList: TPolyInfos;
    textList: TTextInfos;
    function Color32ToHtml(clr: TColor32): string;
  public
    fontName: string;
    fontSize: integer;
    fontColor: TColor32;
    style: TStyleInfo;
    constructor Create;
    procedure Clear;
    procedure AddPaths(const poly: TPaths);
    procedure AddText(const text: string; X,Y: integer);
    function SaveToFile(filename: string;
      scale: double = 1.0; margin: integer = 10): boolean;
  end;

  TMainForm = class(TForm)
    Panel1: TPanel;
    StatusBar1: TStatusBar;
    ImgView321: TImgView32;
    GroupBox1: TGroupBox;
    rbIntersection: TRadioButton;
    rbUnion: TRadioButton;
    rbDifference: TRadioButton;
    rbXOR: TRadioButton;
    rbStatic: TRadioButton;
    bExit: TButton;
    rbNone: TRadioButton;
    gbRandom: TGroupBox;
    lblSubjCount: TLabel;
    lblClipCount: TLabel;
    tbSubj: TTrackBar;
    tbClip: TTrackBar;
    rbRandom1: TRadioButton;
    bNext: TButton;
    tbClipOpacity: TTrackBar;
    lblClipOpacity: TLabel;
    lblSubjOpacity: TLabel;
    tbSubjOpacity: TTrackBar;
    rbRandom2: TRadioButton;
    rbEvenOdd: TRadioButton;
    rbNonZero: TRadioButton;
    bSaveSvg: TButton;
    SaveDialog1: TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure ImgView321Resize(Sender: TObject);
    procedure rbIntersectionClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure tbSubjChange(Sender: TObject);
    procedure bNextClick(Sender: TObject);
    procedure bExitClick(Sender: TObject);
    procedure tbClipOpacityChange(Sender: TObject);
    procedure rbStaticClick(Sender: TObject);
    procedure tbSubjOpacityChange(Sender: TObject);
    procedure rbEvenOddClick(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure bSaveSvgClick(Sender: TObject);
  private
    offsetMul2: integer; //accommodates 0.5 steps
    function GetFillTypeI: TPolyFillType;
    function GetOpTypeI: TClipType;
    procedure ShowStaticPolys;
    procedure ShowRandomPolys1(newPoly: boolean);
    procedure ShowRandomPolys2(newPoly: boolean);
    procedure RePaintBitmapI;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

//------------------------------------------------------------------------------
// TSvgBuilder
//------------------------------------------------------------------------------

constructor TSvgBuilder.Create;
begin
  fontName := 'Verdana';
  fontSize := 12;
  fontColor := clBlack32;
  style.brushClr := clWhite32;
  style.penClr := clBlack32;
  style.penWidth := 1.5;
end;
//------------------------------------------------------------------------------

procedure TSvgBuilder.Clear;
begin
  polyList := nil;
  textList := nil;
end;
//------------------------------------------------------------------------------

function TSvgBuilder.Color32ToHtml(clr: TColor32): string;
begin
  with TColor32Entry(clr) do
    result := format('#%.2x%.2x%.2x', [R, G, B]) ;
end;
//------------------------------------------------------------------------------

function IntArrayToStr(a: TArrayOfInteger; scale: double = 1.0;
  dx: integer = 0; dy: integer = 0): string;
var
  i: integer;
begin
  result := format('%1.1n',[a[0] * scale + dx]);
  for i := 1 to high(a) do
    if odd(i) then
      result := result + format(', %1.1n',[a[i] * scale + dy]) else
      result := result + format(', %1.1n',[a[i] * scale + dx]);
end;
//------------------------------------------------------------------------------

procedure TSvgBuilder.AddPaths(const poly: TPaths);
var
  i, len: integer;
begin
  i := length(poly);
  if i = 0 then Exit;
  len := length(polyList);
  setlength(polyList, len+1);
  setlength(polyList[len].paths, i);
  for i := 0 to i-1 do
    polyList[len].paths[i] := Copy(poly[i], 0, MaxInt);
  polyList[len].si.pft := style.pft;
  polyList[len].si.brushClr := style.brushClr;
  polyList[len].si.penClr := style.penClr;
  polyList[len].si.dashArray := copy(style.dashArray, 0, maxint);
  polyList[len].si.penWidth := style.penWidth;
  polyList[len].si.showCoords := style.showCoords;
end;
//------------------------------------------------------------------------------

procedure TSvgBuilder.AddText(const text: string; X,Y: integer);
var
  len: integer;
begin
  len := length(textList);
  setlength(textList, len +1);
  textList[len].text := text;
  textList[len].x := X;
  textList[len].y := Y;
  textList[len].fontName := fontName;
  textList[len].fontSize := fontSize;
  textList[len].fontColor := Color32ToHtml(fontColor);
end;
//------------------------------------------------------------------------------

function TSvgBuilder.SaveToFile(filename: string;
  scale: double = 1.0; margin: integer = 10): boolean;
const
  pft_string: array[TPolyFillType] of string = ('evenodd', 'nonzero', 'positive', 'negative');
  svg_xml_start: array [0..1] of string =
    ('<?xml version="1.0" standalone="no"?>'+#10+
     '<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN"'+#10+
     '"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">'+#10+#10+'<svg ',
     'version="1.1" xmlns="http://www.w3.org/2000/svg">'+#10+#10);
  poly_start: string = ' <path d="';
  svg_xml_end: string = '</svg>'+#10;
var
  i,j,k,len,len2: integer;
  offsetX, offsetY: Int64;
  rec: TIntRect;
  ds: char;
  ss: TStringStream;
  dashArrayStr: string;
begin
  result := false;
  len := length(polyList);
  if len = 0 then Exit;

  if (scale = 0) then scale := 1.0;
  if (margin < 0) then margin := 0;
  i := 0; j := 0;
  //calculate the bounding rect (skipping empty polygons) ...
  while i < len do
  begin
    len2 := length(polyList[i].paths);
    j := 0;
    while (j < len2) and (length(polyList[i].paths[j]) < 3) do inc(j);
    if j < len2 then Break;
    inc(i);
  end;
  if i = len then Exit;
  rec.left := polyList[i].paths[j][0].X;
  rec.right := rec.left;
  rec.top := polyList[i].paths[j][0].Y;
  rec.bottom := rec.top;
  for i := i to len -1 do
    for j := 0 to length(polyList[i].paths) -1 do
      for k := 0 to length(polyList[i].paths[j]) -1 do
        with polyList[i].paths[j][k] do
      begin
        if X < rec.left then rec.left := X
        else if X > rec.right then rec.right := X;
        if Y < rec.top then rec.top := Y
        else if Y > rec.bottom then rec.bottom := Y;
      end;
  rec.left := round(rec.left * scale);
  rec.top := round(rec.top * scale);
  rec.right := round(rec.right * scale);
  rec.bottom := round(rec.bottom * scale);
  offsetX := -rec.left + margin;
  offsetY := -rec.top + margin;

  ds := DecimalSeparator;
  DecimalSeparator := '.';
  ss := TStringStream.Create('');
  try
    ss.WriteString(
      format('%s width="%dpx" height="%dpx" viewBox="0 0 %d %d" %s',
      [svg_xml_start[0],
      (rec.right - rec.left) + margin*2,
      (rec.bottom - rec.top) + margin*2,
      (rec.right - rec.left) + margin*2,
      (rec.bottom - rec.top) + margin*2,
      svg_xml_start[1]]));

    for i := 0 to len -1 do
      if assigned(polyList[i].paths) then
      begin
        ss.WriteString(poly_start);
        for j := 0 to high(polyList[i].paths) do
        begin
          if (length(polyList[i].paths[j]) < 3) then continue;
          with polyList[i].paths[j][0] do
            ss.WriteString( format(' M %1.2f %1.2f',
            [X * scale + offsetX, Y * scale + offsetY]));
          for k := 1 to high(polyList[i].paths[j]) do
            with polyList[i].paths[j][k] do
              ss.WriteString( format(' L %1.2f %1.2f',
                [X * scale + offsetX, Y * scale + offsetY]));
          ss.WriteString(' z');
        end;

        with polyList[i].si do
        begin
          if length(dashArray) > 1 then
            dashArrayStr := 'stroke-dasharray:'+ IntArrayToStr(dashArray) +';'
          else
            dashArrayStr := '';
          ss.WriteString(format('"'#10+
            ' style="fill:%s; fill-opacity:%1.2n; fill-rule:%s;'#10+
            ' stroke:%s; stroke-opacity:%1.2n; %s stroke-width:%1.2n;"/>'#10#10,
              [Color32ToHtml(brushClr), AlphaComponent(brushClr)/255,
              pft_string[pft], Color32ToHtml(penClr), AlphaComponent(penClr)/255,
              dashArrayStr, penWidth]));
        end;

        if polyList[i].si.showCoords then
        begin
          ss.WriteString('<g font-family="Verdana" font-size="11" fill="black">'#10#10);
          for j := 0 to high(polyList[i].paths) do
          begin
            if (length(polyList[i].paths[j]) < 3) then continue;
            for k := 0 to high(polyList[i].paths[j]) do
              with polyList[i].paths[j][k] do
                ss.WriteString(format('<text x="%1.0n" y="%1.0n">%1.0n,%1.0n</text>'#10,
                  [X * scale + offsetX,  Y * scale + offsetY, X, Y]));
            ss.WriteString(#10);
          end;
          ss.WriteString('</g>'#10);
        end;
      end;

      for i := 0 to high(textList) do
        with textList[i] do
        begin
          if fontSize < 7 then fontSize := 7 else if fontSize > 30 then fontSize := 30;
          ss.WriteString(format('<g font-family="%s" font-size="%d" fill="%s">'#10,
            [fontName, fontSize, fontColor]));
          ss.WriteString(format('<text x="%1.0n" y="%1.0n">%s</text>'#10'</g>'#10#10,
            [X * scale + offsetX,  Y * scale + offsetY, text]));
        end;

    ss.WriteString(svg_xml_end);
    //finally write to file ...
    with TFileStream.Create(filename, fmCreate) do
    try CopyFrom(ss, 0); finally free; end;
  finally
    ss.Free;
    DecimalSeparator := ds;
  end;

end;

//------------------------------------------------------------------------------
// Miscellaneous functions ...
//------------------------------------------------------------------------------

const
  subjPenColor: TColor32 = $60C3C9CF;
  subjBrushColor: TColor32 = $00DDDDF0;
  clipPenColor: TColor32 = $30F9BEA6;
  clipBrushColor: TColor32 = $00FFE0E0;
  solPenColor: TColor32 = $7F003300;
  solBrushColor: TColor32 = $8066EF7F;

var
  scale: integer = 1; //scale bitmap to 10 decimal places
  subj: TArrayOfArrayOfFloatPoint = nil;
  clip: TArrayOfArrayOfFloatPoint = nil;
  subjI: TPaths = nil;
  clipI: TPaths = nil;
  solution: TArrayOfArrayOfFloatPoint = nil;
  solutionI: TPaths = nil;
  subjOpacity: cardinal = $FF000000;
  clipOpacity: cardinal = $FF000000;

{$R *.dfm}
{$R polygons.res}

//------------------------------------------------------------------------------

function AAFloatPoint2AAPoint(const a: TArrayOfArrayOfFloatPoint;
  decimals: integer = 0): TPaths;
var
  i,j,decScale: integer;
begin
  decScale := round(power(10,decimals));
  setlength(result, length(a));
  for i := 0 to high(a) do
  begin
    setlength(result[i], length(a[i]));
    for j := 0 to high(a[i]) do
    begin
      result[i][j].X := round(a[i][j].X *decScale);
      result[i][j].Y := round(a[i][j].Y *decScale);
    end;
  end;
end;
//------------------------------------------------------------------------------

function AAPoint2AAFloatPoint(const a: TPaths;
  decimals: integer = 0): TArrayOfArrayOfFloatPoint;
var
  i,j,decScale: integer;
begin
  decScale := round(power(10,decimals));
  setlength(result, length(a));
  for i := 0 to high(a) do
  begin
    setlength(result[i], length(a[i]));
    for j := 0 to high(a[i]) do
    begin
      result[i][j].X := a[i][j].X /decScale;
      result[i][j].Y := a[i][j].Y /decScale;
    end;
  end;
end;
//------------------------------------------------------------------------------

procedure LoadBinaryStreamToArrayOfArrayOfFloatPoint(stream: TStream;
  out fpa: TArrayOfArrayOfFloatPoint);
var
  i,j: integer;
begin
  try
    stream.Read(i, sizeof(i));
    setlength(fpa, i);
    for i := 0 to i-1 do
    begin
      stream.Read(j, sizeof(j));
      setlength(fpa[i], j);
      for j := 0 to j-1 do
        stream.Read(fpa[i][j], sizeof(TFloatPoint));
    end;
  except
    fpa := nil;
  end;
end;

//------------------------------------------------------------------------------
//  TMainForm methods
//------------------------------------------------------------------------------

procedure TMainForm.FormCreate(Sender: TObject);
begin
  tbSubjOpacity.Position := 156;
  tbClipOpacity.Position := 156;
  Randomize;
  StatusBar1.SimpleText :=
    ' Use the mouse wheel (or +,- & 0) to adjust the clipped region''s offset.';
  ImgView321.Bitmap.Font.Style := [fsBold];
end;
//------------------------------------------------------------------------------

procedure TMainForm.bExitClick(Sender: TObject);
begin
  close;
end;
//------------------------------------------------------------------------------

procedure TMainForm.ImgView321Resize(Sender: TObject);
begin
  ImgView321.SetupBitmap(true, clWhite32);
end;
//------------------------------------------------------------------------------

procedure TMainForm.RepaintBitmapI;
var
  pfm: TPolyFillMode;
  sol: TArrayOfArrayOfFloatPoint;
  solI: TPaths;
  scaling: single;
begin
  ImgView321.Bitmap.Clear(clWhite32);

  if rbEvenOdd.Checked then pfm := pfAlternate else pfm := pfWinding;
  PolyPolygonFS(ImgView321.Bitmap, subj, subjBrushColor or subjOpacity, pfm);
  PolyPolylineFS(ImgView321.Bitmap, subj, subjPenColor or subjOpacity, true);
  PolyPolygonFS(ImgView321.Bitmap, clip, clipBrushColor or clipOpacity, pfm);
  PolyPolylineFS(ImgView321.Bitmap, clip, clipPenColor or clipOpacity, true);
  if assigned(solutionI) and not rbNone.Checked then
  begin
    if offsetMul2 = 0 then
    begin
      sol := AAPoint2AAFloatPoint(solutionI, scale);
    end else
    begin
      //do offsetting ...
      sol := AAPoint2AAFloatPoint(solutionI, scale);
      PolyPolylineFS(ImgView321.Bitmap, sol, clGray32, true);
      scaling := power(10, scale);
      with TClipperOffset.Create() do
      try
        AddPaths(solutionI, jtRound, etClosedPolygon);
        Execute(solI, offsetMul2/2 *scaling);
      finally
        Free;
      end;
      sol := AAPoint2AAFloatPoint(solI, scale);
    end;
    PolyPolygonFS(ImgView321.Bitmap, sol, solBrushColor);

    //now add a 3D effect to the solution to make it stand out ...
    Simple3D(ImgView321.Bitmap, sol, 3, 3, MAXIMUM_SHADOW_FADE, clWhite32, clBlack32);
    PolyPolylineFS(ImgView321.Bitmap, sol, solPenColor, true);
  end;
  with ImgView321.Bitmap do
  begin
    Textout(10, height-20, format('Offset = %1.1n pixels',[offsetMul2/2]));
  end;
  ImgView321.Repaint;
end;
//------------------------------------------------------------------------------

function TMainForm.GetFillTypeI: TPolyFillType;
begin
  if rbEvenOdd.checked then
    result := pftEvenOdd else
    result := pftNonZero;
end;
//------------------------------------------------------------------------------

function TMainForm.GetOpTypeI: TClipType;
begin
  if rbIntersection.Checked then result := ctIntersection
  else if rbUnion.Checked then result := ctUnion
  else if rbDifference.Checked then result := ctDifference
  else result := ctXor;
end;
//------------------------------------------------------------------------------

procedure TMainForm.tbSubjOpacityChange(Sender: TObject);
begin
  lblSubjOpacity.Caption := format('Subj &Opacity (%d):',[tbSubjOpacity.Position]);
  subjOpacity := cardinal(tbSubjOpacity.Position) shl 24;
  RePaintBitmapI;
end;
//------------------------------------------------------------------------------

procedure TMainForm.tbClipOpacityChange(Sender: TObject);
begin
  lblClipOpacity.Caption := format('Clip &Opacity (%d):',[tbClipOpacity.Position]);
  clipOpacity := cardinal(tbClipOpacity.Position) shl 24;
  RePaintBitmapI;
end;
//------------------------------------------------------------------------------

procedure TMainForm.rbStaticClick(Sender: TObject);
begin
  if rbStatic.Checked then
    ShowStaticPolys
  else if rbRandom1.Checked then
    ShowRandomPolys1(true)
  else
    ShowRandomPolys2(true);

  rbNonZero.Enabled := not rbStatic.Checked;
  rbEvenOdd.Enabled := not rbStatic.Checked;
  lblSubjCount.Enabled := rbRandom1.Checked;
  tbSubj.Enabled := rbRandom1.Checked;
  tbClip.Enabled := not rbStatic.Checked;
  lblClipCount.Enabled := not rbStatic.Checked;
end;
//------------------------------------------------------------------------------

procedure TMainForm.rbIntersectionClick(Sender: TObject);
begin
  if rbStatic.Checked then ShowStaticPolys
  else if rbRandom1.Checked then ShowRandomPolys1(false)
  else ShowRandomPolys2(false);
end;
//------------------------------------------------------------------------------

procedure TMainForm.bNextClick(Sender: TObject);
begin
  if not bNext.Enabled then exit;
  if rbRandom1.Checked then ShowRandomPolys1(true)
  else ShowRandomPolys2(true);
end;
//------------------------------------------------------------------------------

procedure TMainForm.FormResize(Sender: TObject);
begin
  if visible then rbIntersectionClick(nil);
end;
//------------------------------------------------------------------------------

procedure TMainForm.tbSubjChange(Sender: TObject);
begin
  lblSubjCount.Caption := format('Random Subj Count (%d):',[tbSubj.Position]);
  lblClipCount.Caption := format('Random Clip Count (%d):',[tbClip.Position]);
  if not bNext.Enabled then exit;
  //only update random polygons once the mouse has been released ...
  if (GetAsyncKeyState(VK_LBUTTON) < 0) then exit;
  if rbRandom1.Checked then ShowRandomPolys1(true)
  else ShowRandomPolys2(true);
end;
//------------------------------------------------------------------------------

procedure TMainForm.rbEvenOddClick(Sender: TObject);
begin
  if rbRandom1.Checked then ShowRandomPolys1(false)
  else ShowRandomPolys2(false);
end;
//------------------------------------------------------------------------------

procedure TMainForm.ShowStaticPolys;
var
  rs: TResourceStream;
begin
  solution := nil;
  rs := TResourceStream.Create(HInstance, 'POLYGON', RT_RCDATA);
  LoadBinaryStreamToArrayOfArrayOfFloatPoint(rs, subj);
  rs.Free;

  rs := TResourceStream.Create(HInstance, 'CLIP', RT_RCDATA);
  LoadBinaryStreamToArrayOfArrayOfFloatPoint(rs, clip);
  rs.Free;

  subjI := AAFloatPoint2AAPoint(subj, scale);
  clipI := AAFloatPoint2AAPoint(clip, scale);

  if not rbNone.Checked then
    with TClipper.Create do
    try
      AddPaths(subjI, ptSubject, true);
      AddPaths(clipI, ptClip, true);
      Execute(GetOpTypeI, solutionI, pftNonZero, pftNonZero);
    finally
      free;
    end;
  RepaintBitmapI;
end;
//------------------------------------------------------------------------------

procedure TMainForm.ShowRandomPolys1(newPoly: boolean);
var
  i,highI,w,h: integer;
  fillType: TPolyFillType;
begin
  w := (ImgView321.ClientWidth -30);
  h := (ImgView321.ClientHeight -30);
  fillType := GetFillTypeI;

  if newPoly then
  begin
    solution := nil;
    //nb: although for this demo I chose to display just one random subject
    //and one random clip polygon, it would be very easy to make multiple
    //subject and clip polygons here. Clipper would handle them just as easily
    //(as is demonstrated in ShowStaticPolys).
    setLength(subj, 1);
    highI := tbSubj.Position -1;
    setLength(subj[0], highI+1);
    for i := 0 to highI do
      subj[0][i] := FloatPoint(10+round(random*w), 10+round(random*h));
    setLength(clip, 1);
    highI := tbClip.Position - 1;
    setLength(clip[0], highI+1);
    for i := 0 to highI do
      clip[0][i] := FloatPoint(10+round(random*w), 10+round(random*h));
  end;

  subjI := AAFloatPoint2AAPoint(subj, scale);
  clipI := AAFloatPoint2AAPoint(clip, scale);

  if not rbNone.Checked then
    with TClipper.Create do
    try
      AddPaths(subjI, ptSubject, true);
      AddPaths(clipI, ptClip, true);
      Execute(GetOpTypeI, solutionI, fillType, fillType);
    finally
      free;
    end;
  RepaintBitmapI;
end;
//------------------------------------------------------------------------------

procedure TMainForm.ShowRandomPolys2(newPoly: boolean);
var
  i,j,w,h: integer;
  pt: TFloatPoint;
  rec: TFloatRect;
  fillType: TPolyFillType;
  rs: TResourceStream;
begin

  w := (ImgView321.ClientWidth -30);
  h := (ImgView321.ClientHeight -30);
  fillType := GetFillTypeI;

  if newPoly then
  begin
    solution := nil;

    rs := TResourceStream.Create(HInstance, 'AUSTRALIA', RT_RCDATA);
    LoadBinaryStreamToArrayOfArrayOfFloatPoint(rs, subj);
    rs.Free;

    //make bubbles for clip ...
    setlength(clip, tbClip.Position);
    for i := 0 to high(clip) do
    begin
      pt := FloatPoint(random*(w-100) +50, random*(h-100) +50);
      j := round(random*45) + 5;
      rec := FloatRect(pt.X -j, pt.Y - j, pt.X +j, pt.Y + j);
      clip[i] := GetEllipsePoints(rec);
    end;
  end;

  subjI := AAFloatPoint2AAPoint(subj, scale);
  clipI := AAFloatPoint2AAPoint(clip, scale);

  if not rbNone.Checked then
    with TClipper.Create do
    try
      AddPaths(subjI, ptSubject, true);
      AddPaths(clipI, ptClip, true);
      Execute(GetOpTypeI, solutionI, fillType, fillType);
    finally
      free;
    end;
  RepaintBitmapI;
end;
//------------------------------------------------------------------------------

procedure TMainForm.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  if WheelDelta > 0 then
  begin
    if offsetMul2 = 20 then exit;
    inc(offsetMul2);
    RePaintBitmapI;
  end
  else if WheelDelta < 0 then
  begin
    if offsetMul2 = -20 then exit;
    dec(offsetMul2);
    RePaintBitmapI;
  end;
end;
//------------------------------------------------------------------------------

procedure TMainForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  case Key of
    '0',')': offsetMul2 := 0;
    '=','+': if offsetMul2 = 20 then exit else inc(offsetMul2);
    '-','_': if offsetMul2 = -20 then exit else dec(offsetMul2);
    else exit;
  end;
  RePaintBitmapI;
end;
//------------------------------------------------------------------------------

function MakeArrayOfIntPoint(const pts: array of integer): TPath;
var
  i, len: integer;
begin
  result := nil;
  len := length(pts) div 2;
  if len < 1 then exit;
  setlength(result, len);
  for i := 0 to len -1 do
  begin
    result[i].X := pts[i*2];
    result[i].Y := pts[i*2 +1];
  end;
end;
//------------------------------------------------------------------------------

procedure TMainForm.bSaveSvgClick(Sender: TObject);
var
  invScale: single;
begin
  if not SaveDialog1.Execute then exit;
  invScale := 1/ power(10, scale);
  with TSvgBuilder.Create do
  try
    style.penWidth := 0.8;

    style.brushClr := $0F0000FF;
    style.penClr := $800099FF;
    AddPaths(subjI);

    style.brushClr := $0FFFFF00;
    style.penClr := $80FF9900;
    AddPaths(clipI);

    style.brushClr := $2000FF00;
    style.penClr := $FF006600;
    AddPaths(solutionI);

    SaveToFile(SaveDialog1.FileName, invScale);
  finally
    free;
  end;
end;
//------------------------------------------------------------------------------

end.
