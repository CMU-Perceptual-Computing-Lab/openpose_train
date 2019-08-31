#include <windows.h>
#include <commctrl.h>
#include <gl/gl.h>
#include <gl/glu.h>
//#include <gl/glut.h>
#include <ctime>
#include <cmath>
#include <sstream>
#include <fstream>
#include <iomanip>
#include "../clipper.hpp"

using namespace std;
using namespace ClipperLib;

enum poly_color_type { pctSubject, pctClip, pctSolution };

//global vars ...
HWND		 hWnd;
HWND     hStatus; 
HDC			 hDC;
HGLRC		 hRC;
ClipType     ct = ctIntersection;
PolyFillType pft = pftEvenOdd;
JoinType jt = jtRound;
bool show_clipping = true;
Paths sub, clp, sol;
int VertCount = 5;
int scale = 10;
double delta = 0.0;

const LPCWSTR helpText = 
L"Clipper Demo tips...\n\n"
L"I - for Intersection operations.\n"
L"U - for Union operations.\n"
L"D - for Difference operations.\n"
L"X - for XOR operations.\n"
L"------------------------------\n"
L"Q - Toggle clipping on/off.\n"
L"------------------------------\n"
L"E - for EvenOdd fills.\n"
L"Z - for NonZero fills.\n"
L"P - for Positive fills.\n"
L"N - for Negative fills.\n"
L"------------------------------\n"
L"nn<ENTER> - number of vertices (3..50).\n"
L"------------------------------\n"
L"UP arrow - Expand Solution.\n"
L"DN arrow - Contract Solution.\n"
L"LT or RT arrow - Reset Solution.\n"
L"------------------------------\n"
L"M - Miter OffsetPolygons.\n"
L"S - Square OffsetPolygons.\n"
L"R - Round OffsetPolygons.\n"
L"------------------------------\n"
L"SPACE, ENTER or click to refresh.\n"
L"F1 - to see this help dialog again.\n"
L"Esc - to quit.\n";

typedef std::vector< GLdouble* > Vectors;
Vectors vectors;

//------------------------------------------------------------------------------
// heap memory management for GLUtesselator ...
//------------------------------------------------------------------------------

GLdouble* NewVector(GLdouble x, GLdouble y)
{
  GLdouble *vert = new GLdouble[3];
  vert[0] = x;
  vert[1] = y;
  vert[2] = 0;
  vectors.push_back(vert);
  return vert;
}
//------------------------------------------------------------------------------

void ClearVectors()
{
  for (Vectors::size_type i = 0; i < vectors.size(); ++i)
    delete[] vectors[i];
  vectors.clear(); 
}

//------------------------------------------------------------------------------
// GLUtesselator callback functions ...
//------------------------------------------------------------------------------

void CALLBACK BeginCallback(GLenum type)   
{   
    glBegin(type);   
} 
//------------------------------------------------------------------------------

void CALLBACK EndCallback()   
{   
    glEnd();   
}
//------------------------------------------------------------------------------

void CALLBACK VertexCallback(GLvoid *vertex)   
{   
	glVertex3dv( (const double *)vertex );   
} 
//------------------------------------------------------------------------------

void CALLBACK CombineCallback(GLdouble coords[3], 
  GLdouble*[4], GLfloat[4], GLdouble **dataOut )   
{   
  GLdouble *vert = NewVector(coords[0], coords[1]);
	*dataOut = vert;
}   
//------------------------------------------------------------------------------

wstring str2wstr(const std::string &s) {
	int slength = (int)s.length() + 1;
	int len = MultiByteToWideChar(CP_ACP, 0, s.c_str(), slength, 0, 0); 
	wchar_t* buf = new wchar_t[len];
  MultiByteToWideChar(CP_ACP, 0, s.c_str(), slength, buf, len);
  std::wstring r(buf);
  delete[] buf;
  return r;
}
//------------------------------------------------------------------------------

void CALLBACK ErrorCallback(GLenum errorCode)   
{   
	std::wstring s = str2wstr( (char *)gluErrorString(errorCode) );
	SetWindowText(hWnd, s.c_str());
}   

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

// Set up pixel format for graphics initialization
void SetupPixelFormat()
{
    PIXELFORMATDESCRIPTOR pfd;
    ZeroMemory( &pfd, sizeof(pfd));
    pfd.nSize = sizeof(PIXELFORMATDESCRIPTOR);
    pfd.nVersion = 1;
    pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER;
    pfd.iPixelType = PFD_TYPE_RGBA;
    pfd.cColorBits = 32;
    int pfIdx = ChoosePixelFormat(hDC, &pfd);
    if (pfIdx != 0) SetPixelFormat(hDC, pfIdx, &pfd);
}
//------------------------------------------------------------------------------

// Initialize OpenGL graphics
void InitGraphics()
{
  hDC = GetDC(hWnd);
  SetupPixelFormat();
  hRC = wglCreateContext(hDC);
  wglMakeCurrent(hDC, hRC);
	glDisable(GL_DEPTH_TEST);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glTranslatef (0.375, 0.375, 0);
}
//------------------------------------------------------------------------------

void MakeRandomPoly(Path &p, int width, int height, int edgeCount)
{
	p.resize(edgeCount);
	for (int i = 0; i < edgeCount; i++)
	{
		p[i].X = (rand()%(width -20) +10)*scale;
		p[i].Y = (rand()%(height -20) +10)*scale;
	}
}
//------------------------------------------------------------------------------

void ResizeGraphics(int width, int height)
{
  //setup 2D projection with origin at top-left corner ...
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(0, width, height, 0, 0, 1);
	glViewport(0, 0, width, height);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
}
//------------------------------------------------------------------------------

void DrawPolygon(Paths &pgs, poly_color_type pct)
{
	switch (pct)
	{
		case pctSubject: glColor4f(0.0f, 0.0f, 1.0f, 0.062f); break;
		case pctClip: glColor4f(1.0f, 1.0f, 0.0f, 0.062f); break;
		default: glColor4f(0.0f, 1.0f, 0.0f, 0.25f);
	}

	GLUtesselator* tess = gluNewTess();
  gluTessCallback(tess, GLU_TESS_BEGIN, (void (CALLBACK*)())&BeginCallback);    
  gluTessCallback(tess, GLU_TESS_VERTEX, (void (CALLBACK*)())&VertexCallback);    
  gluTessCallback(tess, GLU_TESS_END, (void (CALLBACK*)())&EndCallback);   
  gluTessCallback(tess, GLU_TESS_COMBINE, (void (CALLBACK*)())&CombineCallback);   
  gluTessCallback(tess, GLU_TESS_ERROR, (void (CALLBACK*)())&ErrorCallback);
  gluTessNormal(tess, 0.0, 0.0, 1.0);
	
	switch (pft)
  {
    case pftEvenOdd: 
      gluTessProperty(tess, GLU_TESS_WINDING_RULE, GLU_TESS_WINDING_ODD); 
      break;
    case pftNonZero: 
      gluTessProperty(tess, GLU_TESS_WINDING_RULE, GLU_TESS_WINDING_NONZERO); 
      break;
    case pftPositive: 
      gluTessProperty(tess, GLU_TESS_WINDING_RULE, GLU_TESS_WINDING_POSITIVE); 
      break;
    default: //case pftNegative
      if (pct == pctSolution)
        gluTessProperty(tess, GLU_TESS_WINDING_RULE, GLU_TESS_WINDING_NONZERO);
      else
        gluTessProperty(tess, GLU_TESS_WINDING_RULE, GLU_TESS_WINDING_NEGATIVE);
  }

	gluTessProperty(tess, GLU_TESS_BOUNDARY_ONLY, GL_FALSE); //GL_FALSE
	gluTessBeginPolygon(tess, NULL); 
	for (Paths::size_type i = 0; i < pgs.size(); ++i)
	{
		gluTessBeginContour(tess);
		for (Path::size_type j = 0; j < pgs[i].size(); ++j)
		{
      GLdouble *vert = 
        NewVector((GLdouble)pgs[i][j].X/scale, (GLdouble)pgs[i][j].Y/scale);
			gluTessVertex(tess, vert, vert); 
		}
		gluTessEndContour(tess); 
	}
	gluTessEndPolygon(tess);
  ClearVectors();

	switch (pct)
	{
		case pctSubject: 
      glColor4f(0.0f, 0.6f, 1.0f, 0.5f); 
      break;
		case pctClip: 
      glColor4f(1.0f, 0.6f, 0.0f, 0.5f); 
      break;
		default: 
      glColor4f(0.0f, 0.4f, 0.0f, 1.0f);
	}
	if (pct == pctSolution) glLineWidth(1.0f); else glLineWidth(0.8f);

  gluTessProperty(tess, GLU_TESS_WINDING_RULE, GLU_TESS_WINDING_ODD); 
	gluTessProperty(tess, GLU_TESS_BOUNDARY_ONLY, GL_TRUE);
	for (Paths::size_type i = 0; i < pgs.size(); ++i)
	{
    gluTessBeginPolygon(tess, NULL); 
		gluTessBeginContour(tess);
		for (Path::size_type j = 0; j < pgs[i].size(); ++j)
		{
			GLdouble *vert = 
        NewVector((GLdouble)pgs[i][j].X/scale, (GLdouble)pgs[i][j].Y/scale);
			gluTessVertex(tess, vert, vert); 
		}

    switch (pct)
	  {
		  case pctSubject: 
        glColor4f(0.0f, 0.0f, 0.8f, 0.5f); 
        break;
		  case pctClip: 
        glColor4f(0.6f, 0.0f, 0.0f, 0.5f); 
	  }
		gluTessEndContour(tess);
	  gluTessEndPolygon(tess);
	}

	//final cleanup ...
	gluDeleteTess(tess);
  ClearVectors();
}
//------------------------------------------------------------------------------

void DrawGraphics()
{
	//this can take a few moments ...
	HCURSOR hWaitCursor = LoadCursor(NULL, IDC_WAIT);
	SetCursor(hWaitCursor);
	SetClassLong(hWnd, GCL_HCURSOR, (DWORD)hWaitCursor);

	//fill background with a light off-gray color ...
	glClearColor(1,1,1,1);
	glClear(GL_COLOR_BUFFER_BIT);

  //glRasterPos2f(110, 340);
  //glColor4f(0.0f, 1.0f, 0.0f, 1.0f); 
  //char * text = "Positive Fills";
  //for (int i = 0; i < strlen(text); ++i)
  //  glutBitmapCharacter(GLUT_BITMAP_HELVETICA_12, text[i]);
	
  DrawPolygon(sub, pctSubject);
	DrawPolygon(clp, pctClip);
  if (show_clipping)
    DrawPolygon(sol, pctSolution);
  wstringstream ss;
  if (!show_clipping)
    ss << L"Clipper Demo - NO CLIPPING"; 
  else
	  switch (ct)
	  {
		  case ctUnion: 
        ss << L"Clipper Demo - UNION"; 
        break;
		  case ctDifference: 
        ss << L"Clipper Demo - DIFFERENCE"; 
        break;
		  case ctXor: 
        ss << L"Clipper Demo - XOR"; 
        break;
		  default: 
        ss << L"Clipper Demo - INTERSECTION"; 
	  }

	switch(pft)
  {
    case pftEvenOdd: 
      ss << L"  (EvenOdd filled polygons with "; 
      break;
    case pftNonZero: 
      ss << L"  (NonZero filled polygons with "; 
      break;
    case pftPositive: 
      ss << L"  (Positive filled polygons with "; 
      break;
    default: 
      ss << L"  (Negative filled polygons with "; 
  }
  ss << VertCount << " vertices each.)";
	SetWindowText(hWnd, ss.str().c_str());

	HCURSOR hArrowCursor = LoadCursor(NULL, IDC_ARROW);
	SetCursor(hArrowCursor);
	SetClassLong(hWnd, GCL_HCURSOR, (DWORD)hArrowCursor);
}
//------------------------------------------------------------------------------

inline long64 Round(double val)
{
  if ((val < 0)) return (long64)(val - 0.5); else return (long64)(val + 0.5);
}
//------------------------------------------------------------------------------

//bool LoadFromFile(Polygons &ppg, char * filename, double scale= 1,
//  int xOffset = 0, int yOffset = 0)
//{
//  ppg.clear();
//  ifstream infile(filename);
//  if (!infile.is_open()) return false;
//  int polyCnt, vertCnt;
//  double X, Y;
//  
//  infile >> polyCnt;
//  infile.ignore(80, '\n');
//  if (infile.good() && polyCnt > 0)
//  {
//    ppg.resize(polyCnt);
//    for (int i = 0; i < polyCnt; i++) 
//    {
//      infile >> vertCnt;
//      infile.ignore(80, '\n');
//      if (!infile.good() || vertCnt < 0) break;
//      ppg[i].resize(vertCnt);
//      for (int j = 0; infile.good() && j < vertCnt; j++) 
//      {
//        infile >> X;
//        while (infile.peek() == ' ') infile.ignore();
//        if (infile.peek() == ',') infile.ignore();
//        while (infile.peek() == ' ') infile.ignore();
//        infile >> Y;
//        ppg[i][j].X = Round((X + xOffset) * scale);
//        ppg[i][j].Y = Round((Y + yOffset) * scale);
//        infile.ignore(80, '\n');
//      }
//    }
//  }
//  infile.close();
//  return true;
//}
//------------------------------------------------------------------------------

void SaveToFile(const char *filename, Paths &pp, double scale = 1)
{
  ofstream of(filename);
  if (!of.is_open()) return;
  of << pp.size() << "\n";
  for (Paths::size_type i = 0; i < pp.size(); ++i)
  {
    of << pp[i].size() << "\n";
    if (scale > 1.01 || scale < 0.99) 
      of << fixed << setprecision(6);
    for (Path::size_type j = 0; j < pp[i].size(); ++j)
      of << (double)pp[i][j].X /scale << ", " << (double)pp[i][j].Y /scale << ",\n";
  }
  of.close();
}
//---------------------------------------------------------------------------

void UpdatePolygons(bool updateSolutionOnly)
{
	if (VertCount < 0) VertCount = -VertCount;
  if (VertCount > 50) VertCount = 50;
  if (VertCount < 3) VertCount = 3;

  Clipper c;
	if (!updateSolutionOnly)
	{
    delta = 0.0;

    RECT r;
    GetWindowRect(hStatus, &r);
    int statusHeight = r.bottom - r.top;
    GetClientRect(hWnd, &r);

    sub.resize(1);
    clp.resize(1);
    
 
    MakeRandomPoly(sub[0], r.right, r.bottom - statusHeight, VertCount);
    MakeRandomPoly(clp[0], r.right, r.bottom - statusHeight, VertCount);

    //SaveToFile("subj.txt", sub);
    //SaveToFile("clip.txt", clp);
	}

  c.AddPaths(sub, ptSubject, true);
  c.AddPaths(clp, ptClip, true);
	
  c.Execute(ct, sol, pft, pft);
  SaveToFile("solution.txt", sol);

  if (delta != 0.0)
  {
    ClipperOffset co;
    co.AddPaths(sol, jt, etClosedPolygon);
    co.Execute(sol, delta);
  }

	InvalidateRect(hWnd, NULL, false); 
}
//------------------------------------------------------------------------------

void DoNumericKeyPress(int  num)
{
  if (VertCount >= 0) VertCount = -num;
  else if (VertCount > -10) VertCount = VertCount*10 - num;
  else Beep(1000, 100);
}
//------------------------------------------------------------------------------

LONG WINAPI MainWndProc (HWND hWnd, UINT uMsg, WPARAM  wParam, LPARAM  lParam)
{
	int clientwidth, clientheight;
  switch (uMsg)
  {

	  case WM_SIZE:
		  clientwidth = LOWORD(lParam);
		  clientheight = HIWORD(lParam);
		  ResizeGraphics(clientwidth, clientheight);
		  SetWindowPos(hStatus, NULL, 0, 
        clientheight, clientwidth, 0, SWP_NOACTIVATE | SWP_NOZORDER);
          return 0;

	  case WM_PAINT:
		  HDC hdc;
		  PAINTSTRUCT ps;
		  hdc = BeginPaint(hWnd, &ps);
		  //do the drawing ...
		  DrawGraphics();
		  SwapBuffers(hdc);
		  EndPaint(hWnd, &ps);		
		  return 0;

    case WM_CLOSE: 
        DestroyWindow(hWnd);
        return 0;
 
    case WM_DESTROY:
        PostQuitMessage(0);
        return 0;

	  case WM_HELP:
      MessageBox(hWnd, helpText, L"Clipper Demo - Help", 0);
      return 0;

    case WM_COMMAND:
      switch(LOWORD(wParam))
      {
          case 1: case 27: PostQuitMessage(0); break; //escape
          case 98: MessageBox(hWnd, helpText, L"Clipper Demo - Help", 0); break;
          case 99: MessageBox(hWnd, L"After closing this dialog,\ntype the required number of vertices (3-50) then <Enter> ...", L"Clipper Demo", 0);
          case 101: show_clipping = true; ct = ctIntersection; UpdatePolygons(true); break;
          case 102: show_clipping = true; ct = ctUnion; UpdatePolygons(true); break;
          case 103: show_clipping = true; ct = ctDifference; UpdatePolygons(true); break;
          case 104: show_clipping = true; ct = ctXor; UpdatePolygons(true); break;
			    case 105: pft = pftEvenOdd; UpdatePolygons(true); break;
			    case 106: pft = pftNonZero; UpdatePolygons(true); break;
          case 107: pft = pftPositive; UpdatePolygons(true); break;
          case 108: pft = pftNegative; UpdatePolygons(true); break;
			    case 109: show_clipping = !show_clipping; UpdatePolygons(true); break;
          case 110: case 111: case 112: case 113: case 114:
          case 115: case 116: case 117: case 118: case 119: 
            DoNumericKeyPress(LOWORD(wParam) - 110); 
            break;
          case 120: UpdatePolygons(false); break; //space, return
          case 131: if (delta < 20*scale) {delta += scale; UpdatePolygons(true);} break;
          case 132: if (delta > -20*scale) {delta -= scale; UpdatePolygons(true);} break;
          case 133: if (delta != 0.0) {delta = 0.0; UpdatePolygons(true);} break;
          case 141: {jt = jtMiter; if (delta != 0.0) UpdatePolygons(true);} break;
          case 142: {jt = jtSquare; if (delta != 0.0) UpdatePolygons(true);} break;
          case 143: {jt = jtRound; if (delta != 0.0) UpdatePolygons(true);} break;
          default: return DefWindowProc (hWnd, uMsg, wParam, lParam); 
      }
      return 0; 

    case WM_LBUTTONUP:
		  UpdatePolygons(false);
		  return 0;

    // Default event handler
    default: return DefWindowProc (hWnd, uMsg, wParam, lParam); 
  }  
}
//------------------------------------------------------------------------------

int WINAPI WinMain (HINSTANCE hInstance, 
  HINSTANCE, LPSTR, int nCmdShow)
{

    const LPCWSTR appname = TEXT("Clipper Demo");

    WNDCLASS wndclass;
    MSG      msg;
 
    // Define the window class
    wndclass.style         = 0;
    wndclass.lpfnWndProc   = (WNDPROC)MainWndProc;
    wndclass.cbClsExtra    = 0;
    wndclass.cbWndExtra    = 0;
    wndclass.hInstance     = hInstance;
    wndclass.hIcon         = LoadIcon(hInstance, appname);
    wndclass.hCursor       = LoadCursor(NULL, IDC_ARROW);
    wndclass.hbrBackground = (HBRUSH)(COLOR_WINDOW+1);
    wndclass.lpszMenuName  = appname;
    wndclass.lpszClassName = appname;
 
    // Register the window class
    if (!RegisterClass(&wndclass)) return FALSE;

    HMENU menu = LoadMenu(hInstance, MAKEINTRESOURCE(1));
    HACCEL accel = LoadAccelerators(hInstance, MAKEINTRESOURCE(1));

    int windowSizeX = 540, windowSizeY = 400;

    int dx = GetSystemMetrics(SM_XVIRTUALSCREEN);
    int dy = GetSystemMetrics(SM_YVIRTUALSCREEN);
    dx += ((GetSystemMetrics(SM_CXSCREEN) -windowSizeX) /2);
    dy += ((GetSystemMetrics(SM_CYSCREEN) -windowSizeY) /2);

    // Create the window
    hWnd = CreateWindow(
            appname,
            appname,
            WS_OVERLAPPEDWINDOW | WS_CLIPSIBLINGS | WS_CLIPCHILDREN,
            dx, dy, windowSizeX, windowSizeY,
            NULL,
            menu,
            hInstance,
            NULL);
 
    if (!hWnd) return FALSE;

	//replace the main window icon with Resource Icon #1 ...
  HANDLE small_ico = LoadImage(hInstance, MAKEINTRESOURCE(1), IMAGE_ICON, 16, 16, 0);
	HANDLE big_ico = LoadImage(hInstance, MAKEINTRESOURCE(1), IMAGE_ICON, 32, 32, 0);
	SendMessage(hWnd, WM_SETICON, ICON_SMALL, (LPARAM)small_ico);
	SendMessage(hWnd, WM_SETICON, ICON_BIG, (LPARAM)big_ico);

	InitCommonControls();
	hStatus = CreateWindowEx(0, L"msctls_statusbar32", NULL, WS_CHILD | WS_VISIBLE,
		0, 0, 0, 0, hWnd, (HMENU)0, hInstance, NULL);
	SetWindowText(hStatus, L" Copyright © Angus Johnson 2011");

  // Initialize OpenGL
  InitGraphics();

	srand((unsigned)time(0)); 
	UpdatePolygons(false);

  // Display the window
  ShowWindow(hWnd, nCmdShow);
  UpdateWindow(hWnd);

  // Event loop
    for (;;)
    {
        if (PeekMessage(&msg, NULL, 0, 0, PM_NOREMOVE) == TRUE)
        {
            if (!GetMessage(&msg, NULL, 0, 0)) break;

            if (!TranslateAccelerator(hWnd, accel, &msg))
            {
              TranslateMessage(&msg);
              DispatchMessage(&msg);
            }
        }
    }
	  wglMakeCurrent(NULL, NULL);
    wglDeleteContext(hRC);
    ReleaseDC(hWnd, hDC);
    return TRUE;
}
//------------------------------------------------------------------------------
