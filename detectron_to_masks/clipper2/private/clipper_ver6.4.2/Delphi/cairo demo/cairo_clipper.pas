unit cairo_clipper;

(*******************************************************************************
*                                                                              *
* Author    :  Angus Johnson                                                   *
* Version   :  1.2                                                             *
* Date      :  29 September 2011                                               *
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
  SysUtils, Classes, Cairo, types, math, clipper;

//nb: Since Clipper only accepts integer coordinates, fractional values have to
//be scaled up and down when being passed to and from Clipper. This is easily
//accomplished by setting the scaling factor (10^x) in the following functions.
//When scaling, remember that on most platforms, integer is only a 32bit value.
function PointArrayToCairo(const polys: TPaths;
  cairo: Pcairo_t; scaling_factor: integer = 2): boolean;
function CairoToPointArray(cairo: Pcairo_t;
  out polys: TPaths; scaling_factor: integer = 2): boolean;

implementation

type
  PCairoPathDataArray = ^TCairoPathDataArray;
  TCairoPathDataArray =
    array [0.. MAXINT div sizeof(cairo_path_data_t) -1] of cairo_path_data_t;

function PointArrayToCairo(const polys: TPaths;
  cairo: Pcairo_t; scaling_factor: integer = 2): boolean;
var
  i,j: integer;
  scaling: double;
begin
  result := assigned(cairo);
  if not result then exit;
  if abs(scaling_factor) > 6 then
    raise Exception.Create('PointArrayToCairo: invalid scaling factor');
  scaling := power(10, scaling_factor);
  for i := 0 to high(polys) do
  begin
    cairo_new_sub_path(cairo);
    for j := 0 to high(polys[i]) do
      with polys[i][j] do cairo_line_to(cairo,X/scaling,Y/scaling);
    cairo_close_path(cairo);
  end;
end;
//------------------------------------------------------------------------------

function CairoToPointArray(cairo: Pcairo_t;
  out polys: TPaths; scaling_factor: integer = 2): boolean;
const
  buffLen1: integer = 32;
  buffLen2: integer = 128;
var
  i,currLen1, currLen2: integer;
  pdHdr: cairo_path_data_t;
  path: Pcairo_path_t;
  currPos: TIntPoint;
  scaling: double;
begin
  if abs(scaling_factor) > 6 then
    raise Exception.Create('PointArrayToCairo: invalid scaling factor');
  scaling := power(10, scaling_factor);
  result := false;
  setlength(polys, buffLen1);
  currLen1 := 1;
  currLen2 := 0;
  currPos := IntPoint(0,0);
  i := 0;
  path := cairo_copy_path_flat(cairo);
  try
    while i < path.num_data do
    begin
      pdHdr := PCairoPathDataArray(path.data)[i];
      case pdHdr.header._type of
      CAIRO_PATH_CLOSE_PATH:
        begin
          if currLen2 > 1 then //ie: ignore if < 3 points (not a polygon)
          begin
            setlength(polys[currLen1-1], currLen2);
            setlength(polys[currLen1], buffLen2);
            inc(currLen1);
          end;
          currLen2 := 0;
          currPos := IntPoint(0,0);
          result := true;
        end;
      CAIRO_PATH_MOVE_TO, CAIRO_PATH_LINE_TO:
        begin
          result := false;
          if (pdHdr.header._type = CAIRO_PATH_MOVE_TO) and
            (currLen2 > 0) then break; //ie enforce ClosePath for polygons
          if (currLen2 mod buffLen2 = 0) then
            SetLength(polys[currLen1-1], currLen2 + buffLen2);
          with PCairoPathDataArray(path.data)[i+1].point do
            currPos := IntPoint(Round(x*scaling),Round(y*scaling));
          polys[currLen1-1][currLen2] := currPos;
          inc(currLen2);
        end;
      end;
      inc(i, pdHdr.header.length);
    end;
  finally
    cairo_path_destroy(path);
  end;
  dec(currLen1); //ie enforces a ClosePath
  setlength(polys, currLen1);
end;
//------------------------------------------------------------------------------

end.
