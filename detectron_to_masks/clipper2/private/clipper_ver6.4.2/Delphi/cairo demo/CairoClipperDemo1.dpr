{$A8,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O+,P+,Q+,R+,S-,T-,U-,V+,W-,X+,Y+,Z1}
{$MINSTACKSIZE $00004000}
{$MAXSTACKSIZE $00100000}
{$IMAGEBASE $00400000}
{$APPTYPE GUI}
{$WARN SYMBOL_DEPRECATED ON}
{$WARN SYMBOL_LIBRARY ON}
{$WARN SYMBOL_PLATFORM ON}
{$WARN UNIT_LIBRARY ON}
{$WARN UNIT_PLATFORM ON}
{$WARN UNIT_DEPRECATED ON}
{$WARN HRESULT_COMPAT ON}
{$WARN HIDING_MEMBER ON}
{$WARN HIDDEN_VIRTUAL ON}
{$WARN GARBAGE ON}
{$WARN BOUNDS_ERROR ON}
{$WARN ZERO_NIL_COMPAT ON}
{$WARN STRING_CONST_TRUNCED ON}
{$WARN FOR_LOOP_VAR_VARPAR ON}
{$WARN TYPED_CONST_VARPAR ON}
{$WARN ASG_TO_TYPED_CONST ON}
{$WARN CASE_LABEL_RANGE ON}
{$WARN FOR_VARIABLE ON}
{$WARN CONSTRUCTING_ABSTRACT ON}
{$WARN COMPARISON_FALSE ON}
{$WARN COMPARISON_TRUE ON}
{$WARN COMPARING_SIGNED_UNSIGNED ON}
{$WARN COMBINING_SIGNED_UNSIGNED ON}
{$WARN UNSUPPORTED_CONSTRUCT ON}
{$WARN FILE_OPEN ON}
{$WARN FILE_OPEN_UNITSRC ON}
{$WARN BAD_GLOBAL_SYMBOL ON}
{$WARN DUPLICATE_CTOR_DTOR ON}
{$WARN INVALID_DIRECTIVE ON}
{$WARN PACKAGE_NO_LINK ON}
{$WARN PACKAGED_THREADVAR ON}
{$WARN IMPLICIT_IMPORT ON}
{$WARN HPPEMIT_IGNORED ON}
{$WARN NO_RETVAL ON}
{$WARN USE_BEFORE_DEF ON}
{$WARN FOR_LOOP_VAR_UNDEF ON}
{$WARN UNIT_NAME_MISMATCH ON}
{$WARN NO_CFG_FILE_FOUND ON}
{$WARN MESSAGE_DIRECTIVE ON}
{$WARN IMPLICIT_VARIANTS ON}
{$WARN UNICODE_TO_LOCALE ON}
{$WARN LOCALE_TO_UNICODE ON}
{$WARN IMAGEBASE_MULTIPLE ON}
{$WARN SUSPICIOUS_TYPECAST ON}
{$WARN PRIVATE_PROPACCESSOR ON}
{$WARN UNSAFE_TYPE OFF}
{$WARN UNSAFE_CODE OFF}
{$WARN UNSAFE_CAST OFF}
program CairoClipperDemo1;

uses
  Windows,
  sysutils,
  Messages,
  Graphics,
  Math,
  Cairo in 'cairo.pas',
  CairoWin32 in 'cairowin32.pas',
  cairo_clipper in 'cairo_clipper.pas',
  clipper in '..\..\clipper.pas';

{$R *.res}

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

var
  offsetVal: integer = 0;
  bmp: graphics.TBitmap; //just to buffer drawing and minimize flicker

procedure PaintBitmap;
var
  surface: Pcairo_surface_t;
  cr: Pcairo_t;
  extent: cairo_text_extents_t;
  clipper: TClipper;
  ppa: TPaths;
  rec: TRect;
  text: string;
const
  scaling = 2; //because Clipper now only accepts integer coordinates
begin
  //create a cairo context for the bitmap surface ...
  surface := cairo_win32_surface_create(bmp.canvas.handle);
  cr := cairo_create(surface);
  cairo_set_fill_rule(cr, CAIRO_FILL_RULE_WINDING);

  clipper := TClipper.Create;

  //fill the context background with white ...
  cairo_rectangle(cr, 0, 0, bmp.Width, bmp.Height);
  cairo_set_source_rgba(cr, 1, 1, 1, 1);
  cairo_fill(cr);

  //create a circular pattern, add the path to clipper and then draw it ...
  cairo_arc(cr, 165,110,70,0,2*3.1415926);
  cairo_close_path(cr); //important because we can only clip polygons
  CairoToPointArray(cr, ppa, scaling);
  clipper.AddPaths(ppa, ptSubject, true);
  cairo_set_line_width(cr, 2.0);
  cairo_set_source_rgba(cr, 0, 0, 1, 0.25);
  cairo_fill_preserve(cr);
  cairo_set_source_rgba(cr, 0, 0, 0, 0.5);
  cairo_stroke(cr);
  cairo_new_path(cr);

  //create a star pattern, add the path to clipper and then draw it ...
  cairo_move_to(cr, 60,110);
  cairo_line_to(cr, 240,70);
  cairo_line_to(cr, 110,210);
  cairo_line_to(cr, 140,25);
  cairo_line_to(cr, 230,200);
  cairo_close_path(cr);
  cairo_new_sub_path(cr);
  cairo_arc(cr, 185,50,20,0,2*3.1415926);
  cairo_close_path(cr);
  CairoToPointArray(cr, ppa, scaling);
  clipper.AddPaths(ppa, ptClip, true);
  cairo_set_source_rgba(cr, 1, 0, 0, 0.25);
  cairo_fill_preserve(cr);
  cairo_set_source_rgba(cr, 0, 0, 0, 0.5);
  cairo_stroke(cr);

  //now clip and draw the paths previously added to clipper ....
  clipper.Execute(ctIntersection, ppa, pftNonZero, pftNonZero);

  cairo_set_line_width(cr, 2.0);
  if offsetVal <> 0 then
  begin
    with TClipperOffset.Create() do
    try
      AddPaths(ppa, jtRound, etClosedPolygon);
      Execute(ppa, offsetVal*power(10,scaling));
    finally
      Free;
    end;
  end;
  PointArrayToCairo(ppa, cr, scaling);
  cairo_set_source_rgba(cr, 1, 1, 0, 1);
  cairo_fill_preserve(cr);
  cairo_set_source_rgba(cr, 0, 0, 0, 1);
  cairo_stroke(cr);

  GetClientRect(GetActiveWindow, rec);
  cairo_set_font_size(cr,11);
  text := 'Polygon offset = '+ inttostr(offsetVal) + '.  (Adjust with arrow keys)';
  cairo_text_extents(cr, pchar(text), @extent);
  cairo_move_to(cr, 10, rec.Bottom - extent.height);
  cairo_show_text(cr, pchar(text));

  //clean up ...
  cairo_surface_finish(surface);
end;
//------------------------------------------------------------------------------

function WndProc(Wnd : HWND; message : UINT;
  wParam : Integer; lParam: Integer) : Integer; stdcall;
var
  dc: HDC;
  ps: PAINTSTRUCT;
begin
  case message of
    WM_PAINT:
      begin
        dc := BeginPaint(Wnd, ps);
        with bmp do BitBlt(dc,0,0,Width,Height,canvas.Handle,0,0,SRCCOPY);
        EndPaint(Wnd, ps);
        result := 0;
      end;

    WM_CREATE:
      begin
        bmp := graphics.TBitmap.Create;
        result := DefWindowProc(Wnd, message, wParam, lParam);
      end;
    WM_DESTROY:
      begin
        bmp.Free;
        PostQuitMessage(0);
        result := 0;
      end;

    WM_SIZE:
      begin
        bmp.Width := loword(lparam);
        bmp.Height := hiword(lparam);
        PaintBitmap;
        result := DefWindowProc(Wnd, message, wParam, lParam);
      end;

    WM_KEYDOWN:
      case wParam of
        VK_ESCAPE:
          begin
            PostQuitMessage(0);
            result := 0;
          end;
        VK_RIGHT, VK_UP:
          begin
            if offsetVal < 20 then inc(offsetVal);
            PaintBitmap;
            InvalidateRect(0, nil, false);
            result := 0;
          end;
        VK_LEFT, VK_DOWN:
          begin
            if offsetVal > -20 then dec(offsetVal);
            PaintBitmap;
            InvalidateRect(0, nil, false);
            result := 0;
          end;
        else
          result := DefWindowProc(Wnd, message, wParam, lParam);
      end;

   else
     result := DefWindowProc(Wnd, message, wParam, lParam);
   end;
end;
//------------------------------------------------------------------------------

var
  hWnd     : THandle;
  Msg      : TMsg;
  wndClass : TWndClass;
begin
  wndClass.style         := CS_HREDRAW or CS_VREDRAW;
  wndClass.lpfnWndProc   := @WndProc;
  wndClass.cbClsExtra    := 0;
  wndClass.cbWndExtra    := 0;
  wndClass.hInstance     := hInstance;
  wndClass.hIcon         := LoadIcon(0, IDI_APPLICATION);
  wndClass.hCursor       := LoadCursor(0, IDC_ARROW);
  wndClass.hbrBackground := HBRUSH(GetStockObject(WHITE_BRUSH));
  wndClass.lpszMenuName  := nil;
  wndClass.lpszClassName := 'CairoClipper';

  RegisterClass(wndClass);

  hWnd := CreateWindow(
     'CairoClipper',         // window class name
     'Cairo-Clipper Demo',   // window caption
     WS_OVERLAPPEDWINDOW,    // window style
     Integer(CW_USEDEFAULT), // initial x position
     Integer(CW_USEDEFAULT), // initial y position
     400,                    // initial x size
     300,                    // initial y size
     0,                      // parent window handle
     0,                      // window menu handle
     hInstance,              // program instance handle
     nil);                   // creation parameters

  ShowWindow(hWnd, SW_SHOW);
  UpdateWindow(hWnd);

  while(GetMessage(msg, 0, 0, 0)) do
  begin
    TranslateMessage(msg);
    DispatchMessage(msg);
  end;
end.

