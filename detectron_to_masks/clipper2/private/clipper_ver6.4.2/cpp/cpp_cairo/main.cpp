//---------------------------------------------------------------------------

#include <windows.h>
#include <cstring>
#include <cmath>
#include <sstream>
#pragma hdrstop

#include "clipper.hpp"
#include "cairo.h"
#include "cairo-win32.h"
#include "cairo_clipper.hpp"
//---------------------------------------------------------------------------

int offsetVal;

LRESULT CALLBACK WndProcedure(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam);

int CALLBACK wWinMain(HINSTANCE hInstance,
  HINSTANCE hPrevInstance, LPTSTR lpCmdLine, int nCmdShow)
{
  WCHAR* ClsName = L"CairoApp";
  WCHAR* WndName = L"A Simple Cairo Clipper Demo";
  offsetVal = 0;

  MSG        Msg;
  HWND       hWnd;
  WNDCLASSEX WndClsEx;

  // Create the application window
  WndClsEx.cbSize        = sizeof(WNDCLASSEX);
  WndClsEx.style         = CS_HREDRAW | CS_VREDRAW;
  WndClsEx.lpfnWndProc   = WndProcedure;
  WndClsEx.cbClsExtra    = 0;
  WndClsEx.cbWndExtra    = 0;
  WndClsEx.hIcon         = LoadIcon(NULL, IDI_APPLICATION);
  WndClsEx.hCursor       = LoadCursor(NULL, IDC_ARROW);
  WndClsEx.hbrBackground = (HBRUSH)GetStockObject(WHITE_BRUSH);
  WndClsEx.lpszMenuName  = NULL;
  WndClsEx.lpszClassName = ClsName;
  WndClsEx.hInstance     = hInstance;
  WndClsEx.hIconSm       = LoadIcon(NULL, IDI_APPLICATION);

  // Register the application
  RegisterClassEx(&WndClsEx);

  // Create the window object
  hWnd = CreateWindow(ClsName, WndName, WS_OVERLAPPEDWINDOW,
    CW_USEDEFAULT, CW_USEDEFAULT, 400, 300,
    NULL, NULL, hInstance, NULL);
  if( !hWnd ) return 0;

  ShowWindow(hWnd, SW_SHOWNORMAL);
  UpdateWindow(hWnd);

  while( GetMessage(&Msg, NULL, 0, 0) )
  {
     TranslateMessage(&Msg);
     DispatchMessage(&Msg);
  }
  return Msg.wParam;
}
//------------------------------------------------------------------------------


void OnPaint(HWND hWnd, HDC dc)
{
  RECT rec;
  GetClientRect(hWnd, &rec);
  cairo_surface_t* surface = cairo_win32_surface_create(dc);
  cairo_t* cr = cairo_create(surface);

  cairo_set_fill_rule(cr, CAIRO_FILL_RULE_WINDING);
  cairo_set_line_width (cr, 2.0);

  //fill background with white ...
  cairo_rectangle(cr, 0, 0, rec.right, rec.bottom);
  cairo_set_source_rgba(cr, 1, 1, 1, 1);
  cairo_fill(cr);

  using namespace ClipperLib;

  const int scaling = 2;

  Clipper clpr;    //clipper class
  Paths pg; //std::vector for polygon(s) storage

  //create a circular pattern, add the path to clipper and then draw it ...
  cairo_arc(cr, 170,110,70,0,2*3.1415926);
  cairo_close_path(cr);
  cairo::cairo_to_clipper(cr, pg, scaling);
  clpr.AddPaths(pg, ptSubject, true);
  cairo_set_source_rgba(cr, 0, 0, 1, 0.25);
  cairo_fill_preserve (cr);
  cairo_set_source_rgba(cr, 0, 0, 0, 0.5);
  cairo_stroke (cr);

  //draw a star and another circle, add them to clipper and draw ...
  cairo_move_to(cr, 60,110);
  cairo_line_to (cr, 240,70);
  cairo_line_to (cr, 110,210);
  cairo_line_to (cr, 140,25);
  cairo_line_to (cr, 230,200);
  cairo_close_path(cr);
  cairo_new_sub_path(cr);
  cairo_arc(cr, 190,50,20,0,2*3.1415926);
  cairo_close_path(cr);
  cairo::cairo_to_clipper(cr, pg, scaling);
  clpr.AddPaths(pg, ptClip, true);
  cairo_set_source_rgba(cr, 1, 0, 0, 0.25);
  cairo_fill_preserve (cr);
  cairo_set_source_rgba(cr, 0, 0, 0, 0.5);
  cairo_stroke (cr);

  clpr.Execute(ctIntersection, pg, pftNonZero, pftNonZero);
  //now do something fancy with the returned polygons ...
  OffsetPaths(pg, pg, offsetVal * std::pow((double)10,scaling), jtMiter, etClosed);

  //finally copy the clipped path back to the cairo context and draw it ...
  cairo::clipper_to_cairo(pg, cr, scaling);
  cairo_set_source_rgba(cr, 1, 1, 0, 1);
  cairo_fill_preserve (cr);
  cairo_set_source_rgba(cr, 0, 0, 0, 1);
  cairo_stroke (cr);

  cairo_text_extents_t extent;
  cairo_set_font_size(cr,11);
  std::stringstream ss;
  ss << "Polygon offset = " << offsetVal << ".  (Adjust with arrow keys)";
  std::string s = ss.str();
  cairo_text_extents(cr, s.c_str(), &extent);
  cairo_move_to(cr, 10, rec.bottom - extent.height);
  cairo_show_text(cr, s.c_str());

  cairo_destroy (cr);
  cairo_surface_destroy (surface);
}
//------------------------------------------------------------------------------

LRESULT CALLBACK WndProcedure(HWND hWnd, UINT Msg, WPARAM wParam, LPARAM lParam)
{
    PAINTSTRUCT ps;
    HDC Handle;

    switch(Msg)
    {
      case WM_DESTROY:
        PostQuitMessage(WM_QUIT);
        return 0;

      case WM_PAINT:
        Handle = BeginPaint(hWnd, &ps);
        OnPaint(hWnd, Handle);
        EndPaint(hWnd, &ps);
        return 0;

      case WM_KEYDOWN:
        switch(wParam)
        {
          case VK_ESCAPE:
            PostQuitMessage(0);
            return 0;
          case VK_RIGHT:
          case VK_UP:
            if (offsetVal < 20) offsetVal++;
            InvalidateRect(hWnd, 0, false);
            return 0;
          case VK_LEFT:
          case VK_DOWN:
            if (offsetVal > -20) offsetVal--;
            InvalidateRect(hWnd, 0, false);
            return 0;
          default:
            return DefWindowProc(hWnd, Msg, wParam, lParam);
        }

      default:
        return DefWindowProc(hWnd, Msg, wParam, lParam);
    }
}
//---------------------------------------------------------------------------

