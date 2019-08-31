unit clipper;

(*******************************************************************************
*                                                                              *
* Author    :  Angus Johnson                                                   *
* Version   :  6.4.2                                                           *
* Date      :  27 February 2017                                                *
* Website   :  http://www.angusj.com                                           *
* Copyright :  Angus Johnson 2010-2017                                         *
*                                                                              *
* License:                                                                     *
* Use, modification & distribution is subject to Boost Software License Ver 1. *
* http://www.boost.org/LICENSE_1_0.txt                                         *
*                                                                              *
* Attributions:                                                                *
* The code in this library is an extension of Bala Vatti's clipping algorithm: *
* "A generic solution to polygon clipping"                                     *
* Communications of the ACM, Vol 35, Issue 7 (July 1992) PP 56-63.             *
* http://portal.acm.org/citation.cfm?id=129906                                 *
*                                                                              *
* Computer graphics and geometric modeling: implementation and algorithms      *
* By Max K. Agoston                                                            *
* Springer; 1 edition (January 4, 2005)                                        *
* http://books.google.com/books?q=vatti+clipping+agoston                       *
*                                                                              *
* See also:                                                                    *
* "Polygon Offsetting by Computing Winding Numbers"                            *
* Paper no. DETC2005-85513 PP. 565-575                                         *
* ASME 2005 International Design Engineering Technical Conferences             *
* and Computers and Information in Engineering Conference (IDETC/CIE2005)      *
* September 24-28, 2005 , Long Beach, California, USA                          *
* http://www.me.berkeley.edu/~mcmains/pubs/DAC05OffsetPolygon.pdf              *
*                                                                              *
*******************************************************************************)

//use_int32: When enabled 32bit ints are used instead of 64bit ints. This
//improve performance but coordinate values are limited to the range +/- 46340
//{$DEFINE use_int32}

//use_xyz: adds a Z member to IntPoint (with only a minor cost to performance)
//{$DEFINE use_xyz}

//use_lines: Enables open path clipping (with a very minor cost to performance)
{$DEFINE use_lines}

{$IFDEF FPC}
  {$DEFINE INLINING}
  {$DEFINE UInt64Support}
{$ELSE}
  // enable LEGACYIFEND for Delphi XE4+
  {$IF CompilerVersion >= 25.0}
    {$LEGACYIFEND ON}
  {$IFEND}

  // use generic lists for NextGen compiler
  {$IFDEF NEXTGEN}
    {$DEFINE USEGENERICS}
  {$ENDIF}

  {$IFDEF ConditionalExpressions}
    {$IF CompilerVersion >= 15} //Delphi 7
      {$DEFINE UInt64Support} //nb: Delphi7 only marginally supports UInt64.
    {$IFEND}
    {$IF CompilerVersion >= 18} //Delphi 2007
      //Inline has been supported since D2005.
      //However D2005 and D2006 have an Inline codegen bug (QC41166).
      //http://www.thedelphigeek.com/2007/02/nasty-inline-codegen-bug-in-bds-2006.html
      {$DEFINE INLINING}
    {$IFEND}
  {$ENDIF}
{$ENDIF}

interface

uses
  SysUtils, Types, Classes,
  {$IFDEF USEGENERICS}
    Generics.Collections, Generics.Defaults,
  {$ENDIF}
  Math;

const
  def_arc_tolerance = 0.25;

type
{$IFDEF use_int32}
{$IF CompilerVersion < 20} //Delphi 2009
  cInt = Integer; //Int32 supported since D2009.
{$ELSE}
  cInt = Int32;
{$IFEND}
{$ELSE}
  cInt = Int64;
{$ENDIF}

  PIntPoint = ^TIntPoint;
{$IFDEF use_xyz}
  TIntPoint = record X, Y, Z: cInt; end;
{$ELSE}
  TIntPoint = record X, Y: cInt; end;
{$ENDIF}

  TIntRect = record Left, Top, Right, Bottom: cInt; end;

  TDoublePoint = record X, Y: Double; end;
  TArrayOfDoublePoint = array of TDoublePoint;

{$IFDEF use_xyz}
  TZFillCallback =
    procedure (const E1Bot, E1Top, E2Bot, E2Top: TIntPoint; var Pt: TIntPoint);
{$ENDIF}

  TInitOption = (ioReverseSolution, ioStrictlySimple, ioPreserveCollinear);
  TInitOptions = set of TInitOption;

  TClipType = (ctIntersection, ctUnion, ctDifference, ctXor);
  TPolyType = (ptSubject, ptClip);
  //By far the most widely used winding rules for polygon filling are
  //EvenOdd & NonZero (GDI, GDI+, XLib, OpenGL, Cairo, AGG, Quartz, SVG, Gr32)
  //Others rules include Positive, Negative and ABS_GTR_EQ_TWO (only in OpenGL)
  //see http://glprogramming.com/red/chapter11.html
  TPolyFillType = (pftEvenOdd, pftNonZero, pftPositive, pftNegative);

  //TJoinType & TEndType are used by OffsetPaths()
  TJoinType = (jtSquare, jtRound, jtMiter);
  TEndType = (etClosedPolygon, etClosedLine,
    etOpenButt, etOpenSquare, etOpenRound); //and etSingle still to come

  TPath = array of TIntPoint;
  TPaths = array of TPath;

  TPolyNode = class;
  TArrayOfPolyNode = array of TPolyNode;

  TPolyNode = class
  private
    FPath    : TPath;
    FParent  : TPolyNode;
    FIndex   : Integer;
    FCount   : Integer;
    FBuffLen : Integer;
    FIsOpen  : Boolean;
    FChilds  : TArrayOfPolyNode;
    FJoinType: TJoinType; //used by ClipperOffset only
    FEndType : TEndType;  //used by ClipperOffset only
    function  GetChild(Index: Integer): TPolyNode;
    function  IsHoleNode: boolean;
    procedure AddChild(PolyNode: TPolyNode);
    function  GetNextSiblingUp: TPolyNode;
  public
    function  GetNext: TPolyNode;
    property  ChildCount: Integer read FCount;
    property  Childs[index: Integer]: TPolyNode read GetChild;
    property  Parent: TPolyNode read FParent;
    property  IsHole: Boolean read IsHoleNode;
    property  IsOpen: Boolean read FIsOpen;
    property  Contour: TPath read FPath;
  end;

  TPolyTree = class(TPolyNode)
  private
    FAllNodes: TArrayOfPolyNode; //container for ALL PolyNodes
    function GetTotal: Integer;
  public
    procedure Clear;
    function GetFirst: TPolyNode;
    destructor Destroy; override;
    property Total: Integer read GetTotal;
  end;

  //the definitions below are used internally ...
  TEdgeSide = (esLeft, esRight);
  TDirection = (dRightToLeft, dLeftToRight);

  POutPt = ^TOutPt;

  PEdge = ^TEdge;
  TEdge = record
    Bot  : TIntPoint;      //bottom
    Curr : TIntPoint;      //current (updated for every new scanbeam)
    Top  : TIntPoint;      //top
    Dx   : Double;         //inverse of slope
    PolyType : TPolyType;
    Side     : TEdgeSide;  //side only refers to current side of solution poly
    WindDelta: Integer;    //1 or -1 depending on winding direction
    WindCnt  : Integer;
    WindCnt2 : Integer;    //winding count of the opposite PolyType
    OutIdx   : Integer;
    Next     : PEdge;
    Prev     : PEdge;
    NextInLML: PEdge;
    PrevInAEL: PEdge;
    NextInAEL: PEdge;
    PrevInSEL: PEdge;
    NextInSEL: PEdge;
  end;

  PEdgeArray = ^TEdgeArray;
  TEdgeArray = array[0.. MaxInt div sizeof(TEdge) -1] of TEdge;

  PScanbeam = ^TScanbeam;
  TScanbeam = record
    Y    : cInt;
    Next : PScanbeam;
  end;

  PMaxima = ^TMaxima;
  TMaxima = record
    X     : cInt;
    Next  : PMaxima;
    Prev  : PMaxima;
  end;

  PIntersectNode = ^TIntersectNode;
  TIntersectNode = record
    Edge1: PEdge;
    Edge2: PEdge;
    Pt   : TIntPoint;
  end;

  PLocalMinimum = ^TLocalMinimum;
  TLocalMinimum = record
    Y         : cInt;
    LeftBound : PEdge;
    RightBound: PEdge;
  end;

  //OutRec: contains a path in the clipping solution. Edges in the AEL will
  //carry a pointer to an OutRec when they are part of the clipping solution.
  POutRec = ^TOutRec;
  TOutRec = record
    Idx         : Integer;
    BottomPt    : POutPt;
    IsHole      : Boolean;
    IsOpen      : Boolean;
    //The 'FirstLeft' field points to another OutRec that contains or is the
    //'parent' of OutRec. It is 'first left' because the ActiveEdgeList (AEL) is
    //parsed left from the current edge (owning OutRec) until the owner OutRec
    //is found. This field simplifies sorting the polygons into a tree structure
    //which reflects the parent/child relationships of all polygons.
    //This field should be renamed Parent, and will be later.
    FirstLeft   : POutRec;
    Pts         : POutPt;
    PolyNode    : TPolyNode;
  end;

  TOutPt = record
    Idx      : Integer;
    Pt       : TIntPoint;
    Next     : POutPt;
    Prev     : POutPt;
  end;

  PJoin = ^TJoin;
  TJoin = record
    OutPt1   : POutPt;
    OutPt2   : POutPt;
    OffPt    : TIntPoint; //offset point (provides slope of common edges)
  end;

  {$IFDEF USEGENERICS}
  TEgdeList = TList<PEdgeArray>;
  TLocMinList = TList<PLocalMinimum>;
  TPolyOutList = TList<POutRec>;
  TJoinList = TList<PJoin>;
  TIntersecList = TList<PIntersectNode>;
  {$ELSE}
  TEgdeList = TList;
  TLocMinList = TList;
  TPolyOutList = TList;
  TJoinList = TList;
  TIntersecList = TList;
  {$ENDIF}

  TClipperBase = class
  private
    FEdgeList         : TEgdeList;
    FPolyOutList      : TPolyOutList;
    FScanbeam         : PScanbeam;    //scanbeam list
    FUse64BitRange    : Boolean;      //see LoRange and HiRange consts notes below
    FHasOpenPaths     : Boolean;
    procedure DisposeLocalMinimaList;
    procedure DisposePolyPts(PP: POutPt);
    function ProcessBound(E: PEdge; NextIsForward: Boolean): PEdge;
  protected
    FLocMinList       : TLocMinList;
    FCurrentLocMinIdx : Integer;
    FPreserveCollinear : Boolean;
    FActiveEdges      : PEdge;        //active Edge list
    procedure Reset; virtual;
    procedure InsertScanbeam(const Y: cInt);
    function PopScanbeam(out Y: cInt): Boolean;
    function LocalMinimaPending: Boolean;
    function PopLocalMinima(Y: cInt;
      out LocalMinima: PLocalMinimum): Boolean;
    procedure DisposeScanbeamList;
    function CreateOutRec: POutRec;
    procedure DisposeOutRec(Index: Integer);
    procedure DisposeAllOutRecs;
    procedure SwapPositionsInAEL(E1, E2: PEdge);
    procedure DeleteFromAEL(E: PEdge);
    procedure UpdateEdgeIntoAEL(var E: PEdge);
    property HasOpenPaths: Boolean read FHasOpenPaths;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Clear; virtual;

    function AddPath(const Path: TPath; PolyType: TPolyType; Closed: Boolean): Boolean; virtual;
    function AddPaths(const Paths: TPaths; PolyType: TPolyType; Closed: Boolean): Boolean;
    //PreserveCollinear: Prevents removal of 'inner' vertices when three or
    //more vertices are collinear in solution polygons.
    property PreserveCollinear: Boolean
      read FPreserveCollinear write FPreserveCollinear;
  end;

  TClipper = class(TClipperBase)
  private
    FJoinList         : TJoinList;
    FGhostJoinList    : TJoinList;
    FIntersectList    : TIntersecList;
    FSortedEdges      : PEdge;        //used for temporary sorting
    FClipType         : TClipType;
    FMaxima           : PMaxima;      //maxima XPos list
    FClipFillType     : TPolyFillType;
    FSubjFillType     : TPolyFillType;
    FExecuteLocked    : Boolean;
    FReverseOutput    : Boolean;
    FStrictSimple      : Boolean;
    FUsingPolyTree    : Boolean;
{$IFDEF use_xyz}
    FZFillCallback    : TZFillCallback;
{$ENDIF}
    procedure InsertMaxima(const X: cInt);
    procedure DisposeMaximaList;
    procedure SetWindingCount(Edge: PEdge);
    function IsEvenOddFillType(Edge: PEdge): Boolean;
    function IsEvenOddAltFillType(Edge: PEdge): Boolean;
    procedure AddEdgeToSEL(Edge: PEdge);
    function PopEdgeFromSEL(out E: PEdge): Boolean;
    procedure CopyAELToSEL;
    procedure InsertLocalMinimaIntoAEL(const BotY: cInt);
    procedure SwapPositionsInSEL(E1, E2: PEdge);
    procedure ProcessHorizontal(HorzEdge: PEdge);
    procedure ProcessHorizontals;
    function ProcessIntersections(const TopY: cInt): Boolean;
    procedure BuildIntersectList(const TopY: cInt);
    procedure ProcessIntersectList;
    procedure IntersectEdges(E1,E2: PEdge; Pt: TIntPoint);
    procedure DoMaxima(E: PEdge);
    function FixupIntersectionOrder: Boolean;
    procedure ProcessEdgesAtTopOfScanbeam(const TopY: cInt);
    function IsContributing(Edge: PEdge): Boolean;
    function GetLastOutPt(E: PEdge): POutPt;
    procedure AddLocalMaxPoly(E1, E2: PEdge; const Pt: TIntPoint);
    function AddLocalMinPoly(E1, E2: PEdge; const Pt: TIntPoint): POutPt;
    function AddOutPt(E: PEdge; const Pt: TIntPoint): POutPt;
    function GetOutRec(Idx: integer): POutRec;
    procedure AppendPolygon(E1, E2: PEdge);
    procedure DisposeIntersectNodes;
    function BuildResult: TPaths;
    function BuildResult2(PolyTree: TPolyTree): Boolean;
    procedure FixupOutPolygon(OutRec: POutRec);
    procedure FixupOutPolyline(OutRec: POutRec);
    procedure SetHoleState(E: PEdge; OutRec: POutRec);
    procedure AddJoin(Op1, Op2: POutPt; const OffPt: TIntPoint);
    procedure ClearJoins;
    procedure AddGhostJoin(OutPt: POutPt; const OffPt: TIntPoint);
    procedure ClearGhostJoins;
    function JoinPoints(Jr: PJoin; OutRec1, OutRec2: POutRec): Boolean;
    procedure FixupFirstLefts1(OldOutRec, NewOutRec: POutRec);
    procedure FixupFirstLefts2(InnerOutRec, OuterOutRec: POutRec);
    procedure FixupFirstLefts3(OldOutRec, NewOutRec: POutRec);
    procedure DoSimplePolygons;
    procedure JoinCommonEdges;
    procedure FixHoleLinkage(OutRec: POutRec);
  protected
    function ExecuteInternal: Boolean; virtual;
  public
    function Execute(clipType: TClipType;
      out solution: TPaths;
      FillType: TPolyFillType = pftEvenOdd): Boolean; overload;
    function Execute(clipType: TClipType;
      out solution: TPaths;
      subjFillType: TPolyFillType;
      clipFillType: TPolyFillType): Boolean; overload;
    function Execute(clipType: TClipType;
      out PolyTree: TPolyTree;
      FillType: TPolyFillType = pftEvenOdd): Boolean; overload;
    function Execute(clipType: TClipType;
      out PolyTree: TPolyTree;
      subjFillType: TPolyFillType;
      clipFillType: TPolyFillType): Boolean; overload;
    constructor Create(InitOptions: TInitOptions = []); reintroduce; overload;
    destructor Destroy; override;
    //ReverseSolution: reverses the default orientation
    property ReverseSolution: Boolean read FReverseOutput write FReverseOutput;
    //StrictlySimple: when false (the default) solutions are 'weakly' simple
    property StrictlySimple: Boolean read FStrictSimple write FStrictSimple;
{$IFDEF use_xyz}
    property ZFillFunction: TZFillCallback read FZFillCallback write FZFillCallback;
{$ENDIF}
  end;

  TClipperOffset = class
  private
    FDelta: Double;
    FSinA, FSin, FCos: Extended;
    FMiterLim, FStepsPerRad: Double;
    FNorms: TArrayOfDoublePoint;
    FSolution: TPaths;
    FOutPos: Integer;
    FInP: TPath;
    FOutP: TPath;

    FLowest: TIntPoint; //X = Path index, Y = Path offset (to lowest point)
    FPolyNodes: TPolyNode;
    FMiterLimit: Double;
    FArcTolerance: Double;

    procedure AddPoint(const Pt: TIntPoint);
    procedure DoSquare(J, K: Integer);
    procedure DoMiter(J, K: Integer; R: Double);
    procedure DoRound(J, K: Integer);
    procedure OffsetPoint(J: Integer;
      var K: Integer; JoinType: TJoinType);

    procedure FixOrientations;
    procedure DoOffset(Delta: Double);
  public
    constructor Create(MiterLimit: Double = 2; ArcTolerance: Double = def_arc_tolerance);
    destructor Destroy; override;
    procedure AddPath(const Path: TPath; JoinType: TJoinType; EndType: TEndType);
    procedure AddPaths(const Paths: TPaths; JoinType: TJoinType; EndType: TEndType);
    procedure Clear;
    procedure Execute(out solution: TPaths; Delta: Double); overload;
    procedure Execute(out solution: TPolyTree; Delta: Double); overload;
    property MiterLimit: double read FMiterLimit write FMiterLimit;
    property ArcTolerance: double read FArcTolerance write FArcTolerance;

  end;

function Orientation(const Pts: TPath): Boolean; overload;
function Area(const Pts: TPath): Double; overload;
function PointInPolygon (const pt: TIntPoint; const poly: TPath): Integer; overload;
function GetBounds(const polys: TPaths): TIntRect;

{$IFDEF use_xyz}
function IntPoint(const X, Y: Int64; Z: Int64 = 0): TIntPoint; overload;
function IntPoint(const X, Y: Double; Z: Double = 0): TIntPoint; overload;
{$ELSE}
function IntPoint(const X, Y: cInt): TIntPoint; overload;
function IntPoint(const X, Y: Double): TIntPoint; overload;
{$ENDIF}

function DoublePoint(const X, Y: Double): TDoublePoint; overload;
function DoublePoint(const Ip: TIntPoint): TDoublePoint; overload;

function ReversePath(const Pts: TPath): TPath;
function ReversePaths(const Pts: TPaths): TPaths;

//SimplifyPolygon converts a self-intersecting polygon into a simple polygon.
function SimplifyPolygon(const Poly: TPath; FillType: TPolyFillType = pftEvenOdd): TPaths;
function SimplifyPolygons(const Polys: TPaths; FillType: TPolyFillType = pftEvenOdd): TPaths;

//CleanPolygon removes adjacent vertices closer than the specified distance.
function CleanPolygon(const Poly: TPath; Distance: double = 1.415): TPath;
function CleanPolygons(const Polys: TPaths; Distance: double = 1.415): TPaths;

function MinkowskiSum(const Pattern, Path: TPath; PathIsClosed: Boolean): TPaths; overload;
function MinkowskiSum(const Pattern: TPath; const Paths: TPaths;
  PathFillType: TPolyFillType; PathIsClosed: Boolean): TPaths; overload;
function MinkowskiDiff(const Poly1, Poly2: TPath): TPaths;

function PolyTreeToPaths(PolyTree: TPolyTree): TPaths;
function ClosedPathsFromPolyTree(PolyTree: TPolyTree): TPaths;
function OpenPathsFromPolyTree(PolyTree: TPolyTree): TPaths;

const
  //The SlopesEqual function places the most limits on coordinate values
  //So, to avoid overflow errors, they must not exceed the following values...
  //Also, if all coordinates are within +/-LoRange, then calculations will be
  //faster. Otherwise using Int128 math will render the library ~10-15% slower.
{$IFDEF use_int32}
  LoRange: cInt = 46340;
  HiRange: cInt = 46340;
{$ELSE}
  LoRange: cInt = $B504F333;          //3.0e+9
  HiRange: cInt = $3FFFFFFFFFFFFFFF;  //9.2e+18
{$ENDIF}

implementation

//NOTE: The Clipper library has been developed with software that uses an
//inverted Y axis display. Therefore 'above' and 'below' in the code's comments
//will reflect this. For example: given coord A (0,20) and coord B (0,10),
//A.Y would be considered BELOW B.Y to correctly understand the comments.

const
  Horizontal: Double = -3.4e+38;

  Unassigned : Integer = -1;
  Skip       : Integer = -2; //flag for the edge that closes an open path
  Tolerance  : double = 1.0E-15;
  Two_Pi     : double = 2 * PI;

resourcestring
  rsDoMaxima = 'DoMaxima error';
  rsUpdateEdgeIntoAEL = 'UpdateEdgeIntoAEL error';
  rsHorizontal = 'ProcessHorizontal error';
  rsInvalidInt = 'Coordinate exceeds range bounds';
  rsIntersect = 'Intersection error';
  rsOpenPath  = 'AddPath: Open paths must be subject.';
  rsOpenPath2  = 'AddPath: Open paths have been disabled.';
  rsOpenPath3  = 'Error: TPolyTree struct is needed for open path clipping.';
  rsPolylines = 'Error intersecting polylines';
  rsClipperOffset = 'Error: No PolyTree assigned';

//------------------------------------------------------------------------------
// TPolyNode methods ...
//------------------------------------------------------------------------------

function TPolyNode.GetChild(Index: Integer): TPolyNode;
begin
  if (Index < 0) or (Index >= FCount) then
    raise Exception.Create('TPolyNode range error: ' + inttostr(Index));
  Result := FChilds[Index];
end;
//------------------------------------------------------------------------------

procedure TPolyNode.AddChild(PolyNode: TPolyNode);
begin
  if FCount = FBuffLen then
  begin
    Inc(FBuffLen, 16);
    SetLength(FChilds, FBuffLen);
  end;
  PolyNode.FParent := self;
  PolyNode.FIndex := FCount;
  FChilds[FCount] := PolyNode;
  Inc(FCount);
end;
//------------------------------------------------------------------------------

function TPolyNode.IsHoleNode: boolean;
var
  Node: TPolyNode;
begin
  Result := True;
  Node := FParent;
  while Assigned(Node) do
  begin
    Result := not Result;
    Node := Node.FParent;
  end;
end;
//------------------------------------------------------------------------------

function TPolyNode.GetNext: TPolyNode;
begin
  if FCount > 0 then
    Result := FChilds[0] else
    Result := GetNextSiblingUp;
end;
//------------------------------------------------------------------------------

function TPolyNode.GetNextSiblingUp: TPolyNode;
begin
  if not Assigned(FParent) then //protects against TPolyTree.GetNextSiblingUp()
    Result := nil
  else if FIndex = FParent.FCount -1 then
      Result := FParent.GetNextSiblingUp
  else
      Result := FParent.Childs[FIndex +1];
end;

//------------------------------------------------------------------------------
// TPolyTree methods ...
//------------------------------------------------------------------------------

destructor TPolyTree.Destroy;
begin
  Clear;
  inherited;
end;
//------------------------------------------------------------------------------

procedure TPolyTree.Clear;
var
  I: Integer;
begin
  for I := 0 to high(FAllNodes) do FAllNodes[I].Free;
  FAllNodes := nil;
  FBuffLen := 16;
  SetLength(FChilds, FBuffLen);
  FCount := 0;
end;
//------------------------------------------------------------------------------

function TPolyTree.GetFirst: TPolyNode;
begin
  if FCount > 0 then
    Result := FChilds[0] else
    Result := nil;
end;
//------------------------------------------------------------------------------

function TPolyTree.GetTotal: Integer;
begin
  Result := length(FAllNodes);
  //with negative offsets, ignore the hidden outer polygon ...
  if (Result > 0) and (FAllNodes[0] <> FChilds[0]) then dec(Result);
end;

{$IFNDEF use_int32}

//------------------------------------------------------------------------------
// UInt64 math support for Delphi 6
//------------------------------------------------------------------------------

{$OVERFLOWCHECKS OFF}
{$IFNDEF UInt64Support}
function CompareUInt64(const i, j: Int64): Integer;
begin
  if Int64Rec(i).Hi < Int64Rec(j).Hi then
    Result := -1
  else if Int64Rec(i).Hi > Int64Rec(j).Hi then
    Result := 1
  else if Int64Rec(i).Lo < Int64Rec(j).Lo then
    Result := -1
  else if Int64Rec(i).Lo > Int64Rec(j).Lo then
    Result := 1
  else
    Result := 0;
end;
{$ENDIF}

function UInt64LT(const i, j: Int64): Boolean; {$IFDEF INLINING} inline; {$ENDIF}
begin
{$IFDEF UInt64Support}
  Result := UInt64(i) < UInt64(j);
{$ELSE}
  Result := CompareUInt64(i, j) = -1;
{$ENDIF}
end;

function UInt64GT(const i, j: Int64): Boolean; {$IFDEF INLINING} inline; {$ENDIF}
begin
{$IFDEF UInt64Support}
  Result := UInt64(i) > UInt64(j);
{$ELSE}
  Result := CompareUInt64(i, j) = 1;
{$ENDIF}
end;
{$OVERFLOWCHECKS ON}

//------------------------------------------------------------------------------
// Int128 Functions ...
//------------------------------------------------------------------------------

const
  Mask32Bits = $FFFFFFFF;

type

  //nb: TInt128.Lo is typed Int64 instead of UInt64 to provide Delphi 7
  //compatability. However while UInt64 isn't a recognised type in
  //Delphi 7, it can still be used in typecasts.
  TInt128 = record
    Hi   : Int64;
    Lo   : Int64;
  end;

{$OVERFLOWCHECKS OFF}
procedure Int128Negate(var Val: TInt128);
begin
  if Val.Lo = 0 then
  begin
    Val.Hi := -Val.Hi;
  end else
  begin
    Val.Lo := -Val.Lo;
    Val.Hi := not Val.Hi;
  end;
end;
//------------------------------------------------------------------------------

function Int128(const val: Int64): TInt128; overload;
begin
  Result.Lo := val;
  if val < 0 then
    Result.Hi := -1 else
    Result.Hi := 0;
end;
//------------------------------------------------------------------------------

function Int128Equal(const Int1, Int2: TInt128): Boolean;
begin
  Result := (Int1.Lo = Int2.Lo) and (Int1.Hi = Int2.Hi);
end;
//------------------------------------------------------------------------------

function Int128LessThan(const Int1, Int2: TInt128): Boolean;
begin
  if (Int1.Hi <> Int2.Hi) then Result := Int1.Hi < Int2.Hi
  else Result := UInt64LT(Int1.Lo, Int2.Lo);
end;
//------------------------------------------------------------------------------

function Int128IsNegative(const Int: TInt128): Boolean;
begin
  Result := Int.Hi < 0;
end;
//------------------------------------------------------------------------------

function Int128IsPositive(const Int: TInt128): Boolean;
begin
  Result := (Int.Hi > 0) or ((Int.Hi = 0) and (Int.Lo <> 0));
end;
//------------------------------------------------------------------------------

function Int128Add(const Int1, Int2: TInt128): TInt128;
begin
  Result.Lo := Int1.Lo + Int2.Lo;
  Result.Hi := Int1.Hi + Int2.Hi;
  if UInt64LT(Result.Lo, Int1.Lo) then Inc(Result.Hi);
end;
//------------------------------------------------------------------------------

function Int128Sub(const Int1, Int2: TInt128): TInt128;
begin
  Result.Hi := Int1.Hi - Int2.Hi;
  Result.Lo := Int1.Lo - Int2.Lo;
  if UInt64GT(Result.Lo, Int1.Lo) then Dec(Result.Hi);
end;
//------------------------------------------------------------------------------

function Int128Mul(Int1, Int2: Int64): TInt128;
var
  A, B, C: Int64;
  Int1Hi, Int1Lo, Int2Hi, Int2Lo: Int64;
  Negate: Boolean;
begin
  //save the Result's sign before clearing both sign bits ...
  Negate := (Int1 < 0) <> (Int2 < 0);
  if Int1 < 0 then Int1 := -Int1;
  if Int2 < 0 then Int2 := -Int2;

  Int1Hi := Int1 shr 32;
  Int1Lo := Int1 and Mask32Bits;
  Int2Hi := Int2 shr 32;
  Int2Lo := Int2 and Mask32Bits;

  A := Int1Hi * Int2Hi;
  B := Int1Lo * Int2Lo;
  //because the high (sign) bits in both int1Hi & int2Hi have been zeroed,
  //there's no risk of 64 bit overflow in the following assignment
  //(ie: $7FFFFFFF*$FFFFFFFF + $7FFFFFFF*$FFFFFFFF < 64bits)
  C := Int1Hi*Int2Lo + Int2Hi*Int1Lo;
  //Result = A shl 64 + C shl 32 + B ...
  Result.Hi := A + (C shr 32);
  A := C shl 32;

  Result.Lo := A + B;
  if UInt64LT(Result.Lo, A) then
    Inc(Result.Hi);

  if Negate then Int128Negate(Result);
end;
//------------------------------------------------------------------------------

function Int128Div(Dividend, Divisor: TInt128{; out Remainder: TInt128}): TInt128;
var
  Cntr: TInt128;
  Negate: Boolean;
begin
  if (Divisor.Lo = 0) and (Divisor.Hi = 0) then
    raise Exception.create('int128Div error: divide by zero');

  Negate := (Divisor.Hi < 0) <> (Dividend.Hi < 0);
  if Dividend.Hi < 0 then Int128Negate(Dividend);
  if Divisor.Hi < 0 then Int128Negate(Divisor);

  if Int128LessThan(Divisor, Dividend) then
  begin
    Result.Hi := 0;
    Result.Lo := 0;
    Cntr.Lo := 1;
    Cntr.Hi := 0;
    //while (Dividend >= Divisor) do
    while not Int128LessThan(Dividend, Divisor) do
    begin
      //divisor := divisor shl 1;
      Divisor.Hi := Divisor.Hi shl 1;
      if Divisor.Lo < 0 then Inc(Divisor.Hi);
      Divisor.Lo := Divisor.Lo shl 1;

      //Cntr := Cntr shl 1;
      Cntr.Hi := Cntr.Hi shl 1;
      if Cntr.Lo < 0 then Inc(Cntr.Hi);
      Cntr.Lo := Cntr.Lo shl 1;
    end;
    //Divisor := Divisor shr 1;
    Divisor.Lo := Divisor.Lo shr 1;
    if Divisor.Hi and $1 = $1 then
      Int64Rec(Divisor.Lo).Hi := Cardinal(Int64Rec(Divisor.Lo).Hi) or $80000000;
    Divisor.Hi := Divisor.Hi shr 1;

    //Cntr := Cntr shr 1;
    Cntr.Lo := Cntr.Lo shr 1;
    if Cntr.Hi and $1 = $1 then
      Int64Rec(Cntr.Lo).Hi := Cardinal(Int64Rec(Cntr.Lo).Hi) or $80000000;
    Cntr.Hi := Cntr.Hi shr 1;

    //while (Cntr > 0) do
    while not ((Cntr.Hi = 0) and (Cntr.Lo = 0)) do
    begin
      //if ( Dividend >= Divisor) then
      if not Int128LessThan(Dividend, Divisor) then
      begin
        //Dividend := Dividend - Divisor;
        Dividend := Int128Sub(Dividend, Divisor);

        //Result := Result or Cntr;
        Result.Hi := Result.Hi or Cntr.Hi;
        Result.Lo := Result.Lo or Cntr.Lo;
      end;
      //Divisor := Divisor shr 1;
      Divisor.Lo := Divisor.Lo shr 1;
      if Divisor.Hi and $1 = $1 then
        Int64Rec(Divisor.Lo).Hi := Cardinal(Int64Rec(Divisor.Lo).Hi) or $80000000;
      Divisor.Hi := Divisor.Hi shr 1;

      //Cntr := Cntr shr 1;
      Cntr.Lo := Cntr.Lo shr 1;
      if Cntr.Hi and $1 = $1 then
        Int64Rec(Cntr.Lo).Hi := Cardinal(Int64Rec(Cntr.Lo).Hi) or $80000000;
      Cntr.Hi := Cntr.Hi shr 1;
    end;
    if Negate then Int128Negate(Result);
    //Remainder := Dividend;
  end
  else if (Divisor.Hi = Dividend.Hi) and (Divisor.Lo = Dividend.Lo) then
  begin
    if Negate then Result := Int128(-1) else Result := Int128(1);
  end else
  begin
    Result := Int128(0);
  end;
end;
//------------------------------------------------------------------------------

function Int128AsDouble(val: TInt128): Double;
const
  shift64: Double = 18446744073709551616.0;
var
  lo: Int64;
begin
  if (val.Hi < 0) then
  begin
    lo := -val.Lo;
    if lo = 0 then
      Result := val.Hi * shift64 else
      Result := -(not val.Hi * shift64 + UInt64(lo));
  end else
    Result := val.Hi * shift64 + UInt64(val.Lo);
end;
//------------------------------------------------------------------------------

{$OVERFLOWCHECKS ON}

{$ENDIF}

//------------------------------------------------------------------------------
// Miscellaneous Functions ...
//------------------------------------------------------------------------------

function PointCount(Pts: POutPt): Integer;
var
  P: POutPt;
begin
  Result := 0;
  if not Assigned(Pts) then Exit;
  P := Pts;
  repeat
    Inc(Result);
    P := P.Next;
  until P = Pts;
end;
//------------------------------------------------------------------------------

function PointsEqual(const P1, P2: TIntPoint): Boolean; {$IFDEF INLINING} inline; {$ENDIF}
begin
  Result := (P1.X = P2.X) and (P1.Y = P2.Y);
end;
//------------------------------------------------------------------------------

{$IFDEF use_xyz}
function IntPoint(const X, Y: Int64; Z: Int64 = 0): TIntPoint;
begin
  Result.X := X;
  Result.Y := Y;
  Result.Z := Z;
end;
//------------------------------------------------------------------------------

function IntPoint(const X, Y: Double; Z: Double = 0): TIntPoint;
begin
  Result.X := Round(X);
  Result.Y := Round(Y);
  Result.Z := Round(Z);
end;
//------------------------------------------------------------------------------

{$ELSE}

function IntPoint(const X, Y: cInt): TIntPoint;
begin
  Result.X := X;
  Result.Y := Y;
end;
//------------------------------------------------------------------------------

function IntPoint(const X, Y: Double): TIntPoint;
begin
  Result.X := Round(X);
  Result.Y := Round(Y);
end;

{$ENDIF}
//------------------------------------------------------------------------------

function DoublePoint(const X, Y: Double): TDoublePoint;
begin
  Result.X := X;
  Result.Y := Y;
end;
//------------------------------------------------------------------------------

function DoublePoint(const Ip: TIntPoint): TDoublePoint;
begin
  Result.X := Ip.X;
  Result.Y := Ip.Y;
end;
//------------------------------------------------------------------------------

function Area(const Pts: TPath): Double;
var
  I, J, Cnt: Integer;
  D: Double;
begin
  Result := 0.0;
  Cnt := Length(Pts);
  if (Cnt < 3) then Exit;
  J := cnt - 1;
  for I := 0 to Cnt -1 do
  begin
    D := (Pts[j].X + Pts[i].X);
    Result := Result + D * (Pts[j].Y - Pts[i].Y);
    J := I;
  end;
  Result := -Result * 0.5;
end;
//------------------------------------------------------------------------------

function Area(Op: POutPt): Double; overload;
var
  op2: POutPt;
  d2: Double;
begin
  Result := 0;
  op2 := op;
  if Assigned(op2) then
    repeat
      d2 := op2.Prev.Pt.X + op2.Pt.X;
      Result := Result + d2 * (op2.Prev.Pt.Y - op2.Pt.Y);
      op2 := op2.Next;
    until op2 = op;
  Result := Result * 0.5;
end;
//------------------------------------------------------------------------------

function Area(OutRec: POutRec): Double; overload;
begin
  result := Area(OutRec.Pts);
end;
//------------------------------------------------------------------------------

function Orientation(const Pts: TPath): Boolean;
begin
  Result := Area(Pts) >= 0;
end;
//------------------------------------------------------------------------------

function ReversePath(const Pts: TPath): TPath;
var
  I, HighI: Integer;
begin
  HighI := high(Pts);
  SetLength(Result, HighI +1);
  for I := 0 to HighI do
    Result[I] := Pts[HighI - I];
end;
//------------------------------------------------------------------------------

function ReversePaths(const Pts: TPaths): TPaths;
var
  I, J, highJ: Integer;
begin
  I := length(Pts);
  SetLength(Result, I);
  for I := 0 to I -1 do
  begin
    highJ := high(Pts[I]);
    SetLength(Result[I], highJ+1);
    for J := 0 to highJ do
      Result[I][J] := Pts[I][highJ - J];
  end;
end;
//------------------------------------------------------------------------------

function GetBounds(const polys: TPaths): TIntRect;
var
  I,J,Len: Integer;
begin
  Len := Length(polys);
  I := 0;
  while (I < Len) and (Length(polys[I]) = 0) do inc(I);
  if (I = Len) then
  begin
    with Result do begin Left := 0; Top := 0; Right := 0; Bottom := 0; end;
    Exit;
  end;
  Result.Left := polys[I][0].X;
  Result.Right := Result.Left;
  Result.Top := polys[I][0].Y;
  Result.Bottom := Result.Top;
  for I := I to Len -1 do
    for J := 0 to High(polys[I]) do
    begin
      if polys[I][J].X < Result.Left then Result.Left := polys[I][J].X
      else if polys[I][J].X > Result.Right then Result.Right := polys[I][J].X;
      if polys[I][J].Y < Result.Top then Result.Top := polys[I][J].Y
      else if polys[I][J].Y > Result.Bottom then Result.Bottom := polys[I][J].Y;
    end;
end;
//------------------------------------------------------------------------------

function PointInPolygon (const pt: TIntPoint; const poly: TPath): Integer;
var
  i, cnt: Integer;
  d, d2, d3: double; //use cInt ???
  ip, ipNext: TIntPoint;
begin
  //returns 0 if false, +1 if true, -1 if pt ON polygon boundary
  //http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.88.5498&rep=rep1&type=pdf
  //nb: if poly bounds are known, test them first before calling this function.
  result := 0;
  cnt := Length(poly);
  if cnt < 3 then Exit;
  ip := poly[0];
  for i := 1 to cnt do
  begin
    if i < cnt then ipNext := poly[i]
    else ipNext := poly[0];

    if (ipNext.Y = pt.Y) then
    begin
      if (ipNext.X = pt.X) or ((ip.Y = pt.Y) and
        ((ipNext.X > pt.X) = (ip.X < pt.X))) then
      begin
        result := -1;
        Exit;
      end;
    end;

    if ((ip.Y < pt.Y) <> (ipNext.Y < pt.Y)) then
    begin
      if (ip.X >= pt.X) then
      begin
        if (ipNext.X > pt.X) then
          result := 1 - result
        else
        begin
          d2 := (ip.X - pt.X);
          d3 := (ipNext.X - pt.X);
          d := d2 * (ipNext.Y - pt.Y) - d3 * (ip.Y - pt.Y);
          if (d = 0) then begin result := -1; Exit; end;
          if ((d > 0) = (ipNext.Y > ip.Y)) then
            result := 1 - result;
        end;
      end else
      begin
        if (ipNext.X > pt.X) then
        begin
          d2 := (ip.X - pt.X);
          d3 := (ipNext.X - pt.X);
          d := d2 * (ipNext.Y - pt.Y) - d3 * (ip.Y - pt.Y);
          if (d = 0) then begin result := -1; Exit; end;
          if ((d > 0) = (ipNext.Y > ip.Y)) then
            result := 1 - result;
        end;
      end;
    end;
    ip := ipNext;
  end;
end;
//---------------------------------------------------------------------------

//See "The Point in Polygon Problem for Arbitrary Polygons" by Hormann & Agathos
//http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.88.5498&rep=rep1&type=pdf
function PointInPolygon (const pt: TIntPoint; ops: POutPt): Integer; overload;
var
  d, d2, d3: double; //nb: double not cInt avoids potential overflow errors
  opStart: POutPt;
  pt1, ptN: TIntPoint;
begin
  //returns 0 if false, +1 if true, -1 if pt ON polygon boundary
  result := 0;
  opStart := ops;
  pt1.X := ops.Pt.X; pt1.Y := ops.Pt.Y;
  repeat
    ops := ops.Next;
    ptN.X := ops.Pt.X; ptN.Y := ops.Pt.Y;

    if (ptN.Y = pt.Y) then
    begin
      if (ptN.X = pt.X) or ((pt1.Y = pt.Y) and
        ((ptN.X > pt.X) = (pt1.X < pt.X))) then
      begin
        result := -1;
        Exit;
      end;
    end;

    if ((pt1.Y < pt.Y) <> (ptN.Y < pt.Y)) then
    begin
      if (pt1.X >= pt.X) then
      begin
        if (ptN.X > pt.X) then
          result := 1 - result
        else
        begin
          d2 := (pt1.X - pt.X);
          d3 := (ptN.X - pt.X);
          d := d2 * (ptN.Y - pt.Y) - d3 * (pt1.Y - pt.Y);
          if (d = 0) then begin result := -1; Exit; end;
          if ((d > 0) = (ptN.Y > pt1.Y)) then
            result := 1 - result;
        end;
      end else
      begin
        if (ptN.X > pt.X) then
        begin
          d2 := (pt1.X - pt.X);
          d3 := (ptN.X - pt.X);
          d := d2 * (ptN.Y - pt.Y) - d3 * (pt1.Y - pt.Y);
          if (d = 0) then begin result := -1; Exit; end;
          if ((d > 0) = (ptN.Y > pt1.Y)) then
            result := 1 - result;
        end;
      end;
    end;
    pt1 := ptN;
  until ops = opStart;
end;
//---------------------------------------------------------------------------

function Poly2ContainsPoly1(OutPt1, OutPt2: POutPt): Boolean;
var
  res: integer;
  op: POutPt;
begin
  op := OutPt1;
  repeat
    //nb: PointInPolygon returns 0 if false, +1 if true, -1 if pt on polygon
    res := PointInPolygon(op.Pt, OutPt2);
    if (res >= 0) then
    begin
      Result := res > 0;
      Exit;
    end;
    op := op.Next;
  until op = OutPt1;
  Result := true; //all points on line => result = true
end;
//---------------------------------------------------------------------------

function SlopesEqual(E1, E2: PEdge;
  UseFullInt64Range: Boolean): Boolean; overload;
begin
{$IFNDEF use_int32}
  if UseFullInt64Range then
    Result := Int128Equal(Int128Mul(E1.Top.Y-E1.Bot.Y, E2.Top.X-E2.Bot.X),
      Int128Mul(E1.Top.X-E1.Bot.X, E2.Top.Y-E2.Bot.Y))
  else
{$ENDIF}
    Result := (E1.Top.Y-E1.Bot.Y) * (E2.Top.X-E2.Bot.X) =
      (E1.Top.X-E1.Bot.X) * (E2.Top.Y-E2.Bot.Y);
end;
//---------------------------------------------------------------------------

function SlopesEqual(const Pt1, Pt2, Pt3: TIntPoint;
  UseFullInt64Range: Boolean): Boolean; overload;
begin
{$IFNDEF use_int32}
  if UseFullInt64Range then
    Result := Int128Equal(
      Int128Mul(Pt1.Y-Pt2.Y, Pt2.X-Pt3.X), Int128Mul(Pt1.X-Pt2.X, Pt2.Y-Pt3.Y))
  else
{$ENDIF}
    Result := (Pt1.Y-Pt2.Y)*(Pt2.X-Pt3.X) = (Pt1.X-Pt2.X)*(Pt2.Y-Pt3.Y);
end;
//---------------------------------------------------------------------------

function SlopesEqual(const L1a, L1b, L2a, L2b: TIntPoint;
  UseFullInt64Range: Boolean): Boolean; overload;
begin
{$IFNDEF use_int32}
  if UseFullInt64Range then
    Result := Int128Equal(
      Int128Mul(L1a.Y-L1b.Y, L2a.X-L2b.X), Int128Mul(L2a.Y-L2b.Y, L1a.X-L1b.X))
  else
{$ENDIF}
  //dy1 * dx2 = dy2 * dx1
  Result := (L1a.Y-L1b.Y)*(L2a.X-L2b.X) = (L2a.Y-L2b.Y)*(L1a.X-L1b.X);
end;

(*****************************************************************************
*  Dx:                  0(90º)                       Slope:   0  = Dx: -inf  *
*                       |                            Slope: 0.5  = Dx:   -2  *
*      +inf (180º) <--- o ---> -inf (0º)             Slope: 2.0  = Dx: -0.5  *
*                                                    Slope: inf  = Dx:    0  *
*****************************************************************************)

function GetDx(const Pt1, Pt2: TIntPoint): Double;
begin
  if (Pt1.Y = Pt2.Y) then Result := Horizontal
  else Result := (Pt2.X - Pt1.X)/(Pt2.Y - Pt1.Y);
end;
//---------------------------------------------------------------------------

procedure SetDx(E: PEdge); {$IFDEF INLINING} inline; {$ENDIF}
var
  dy: cInt;
begin
  dy := (E.Top.Y - E.Bot.Y);
  if dy = 0 then E.Dx := Horizontal
  else E.Dx := (E.Top.X - E.Bot.X)/dy;
end;
//---------------------------------------------------------------------------

function IsHorizontal(E: PEdge): Boolean; {$IFDEF INLINING} inline; {$ENDIF}
begin
  Result := E.Dx = Horizontal;
end;
//------------------------------------------------------------------------------

procedure Swap(var val1, val2: cInt); {$IFDEF INLINING} inline; {$ENDIF}
var
  tmp: cInt;
begin
  tmp := val1;
  val1 := val2;
  val2 := tmp;
end;
//---------------------------------------------------------------------------

procedure SwapSides(Edge1, Edge2: PEdge); {$IFDEF INLINING} inline; {$ENDIF}
var
  Side: TEdgeSide;
begin
  Side :=  Edge1.Side;
  Edge1.Side := Edge2.Side;
  Edge2.Side := Side;
end;
//------------------------------------------------------------------------------

procedure SwapPolyIndexes(Edge1, Edge2: PEdge);
{$IFDEF INLINING} inline; {$ENDIF}
var
  OutIdx: Integer;
begin
  OutIdx :=  Edge1.OutIdx;
  Edge1.OutIdx := Edge2.OutIdx;
  Edge2.OutIdx := OutIdx;
end;
//------------------------------------------------------------------------------

function NextIsHorz(Edge: PEdge): Boolean;
{$IFDEF INLINING} inline; {$ENDIF}
begin
  Result := assigned(Edge.NextInLML) and (Edge.NextInLML.Dx = Horizontal);
end;
//------------------------------------------------------------------------------

function NextIsHorzAt(Edge: PEdge; Y: cInt): Boolean;
{$IFDEF INLINING} inline; {$ENDIF}
begin
  Result := (Edge.Top.Y = Y) and assigned(Edge.NextInLML) and
    (Edge.NextInLML.Dx = Horizontal);
end;
//------------------------------------------------------------------------------

function TopX(Edge: PEdge; const currentY: cInt): cInt;
{$IFDEF INLINING} inline; {$ENDIF}
begin
  if currentY = Edge.Top.Y then Result := Edge.Top.X
  else if Edge.Top.X = Edge.Bot.X then Result := Edge.Bot.X
  else Result := Edge.Bot.X + Round(Edge.Dx*(currentY - Edge.Bot.Y));
end;
//------------------------------------------------------------------------------

{$IFDEF use_xyz}
Procedure SetZ(var Pt: TIntPoint; E1, E2: PEdge; ZFillFunc: TZFillCallback);
begin
  if (Pt.Z <> 0) or not assigned(ZFillFunc) then Exit
  else if PointsEqual(Pt, E1.Bot) then Pt.Z := E1.Bot.Z
  else if PointsEqual(Pt, E2.Bot) then Pt.Z := E2.Bot.Z
  else if PointsEqual(Pt, E1.Top) then Pt.Z := E1.Top.Z
  else if PointsEqual(Pt, E2.Top) then Pt.Z := E2.Top.Z
  else ZFillFunc(E1.Bot, E1.Top, E2.Bot, E2.Top, Pt);
end;
//------------------------------------------------------------------------------
{$ENDIF}

procedure IntersectPointEx(Edge1, Edge2: PEdge; out ip: TIntPoint);
var
  B1,B2,M: Double;
begin
{$IFDEF use_xyz}
  ip.Z := 0;
{$ENDIF}
  if (edge1.Dx = edge2.Dx) then
  begin
    ip.Y := edge1.Curr.Y;
    ip.X := TopX(edge1, ip.Y);
    Exit;
  end;

  if Edge1.Dx = 0 then
  begin
    ip.X := Edge1.Bot.X;
    if Edge2.Dx = Horizontal then
      ip.Y := Edge2.Bot.Y
    else
    begin
      with Edge2^ do B2 := Bot.Y - (Bot.X/Dx);
      ip.Y := round(ip.X/Edge2.Dx + B2);
    end;
  end
  else if Edge2.Dx = 0 then
  begin
    ip.X := Edge2.Bot.X;
    if Edge1.Dx = Horizontal then
      ip.Y := Edge1.Bot.Y
    else
    begin
      with Edge1^ do B1 := Bot.Y - (Bot.X/Dx);
      ip.Y := round(ip.X/Edge1.Dx + B1);
    end;
  end else
  begin
    with Edge1^ do B1 := Bot.X - Bot.Y * Dx;
    with Edge2^ do B2 := Bot.X - Bot.Y * Dx;
    M := (B2-B1)/(Edge1.Dx - Edge2.Dx);
    ip.Y := round(M);
    if Abs(Edge1.Dx) < Abs(Edge2.Dx) then
      ip.X := round(Edge1.Dx * M + B1)
    else
      ip.X := round(Edge2.Dx * M + B2);
  end;

  //The precondition - E.Curr.X > eNext.Curr.X - indicates that the two edges do
  //intersect below TopY (and hence below the tops of either Edge). However,
  //when edges are almost parallel, rounding errors may cause False positives -
  //indicating intersections when there really aren't any. Also, floating point
  //imprecision can incorrectly place an intersect point beyond/above an Edge.
  //Therfore, further adjustment to IP is warranted ...
  if (ip.Y < Edge1.Top.Y) or (ip.Y < Edge2.Top.Y) then
  begin
    //Find the lower top of the two edges and compare X's at this Y.
    //If Edge1's X is greater than Edge2's X then it's fair to assume an
    //intersection really has occurred...
    if (Edge1.Top.Y > Edge2.Top.Y) then
      ip.Y := edge1.Top.Y else
      ip.Y := edge2.Top.Y;
    if Abs(Edge1.Dx) < Abs(Edge2.Dx) then
      ip.X := TopX(Edge1, ip.Y) else
      ip.X := TopX(Edge2, ip.Y);
  end;
  //finally, don't allow 'ip' to be BELOW curr.Y (ie bottom of scanbeam) ...
  if (ip.Y > Edge1.Curr.Y) then
  begin
    ip.Y := Edge1.Curr.Y;
    if (abs(Edge1.Dx) > abs(Edge2.Dx)) then //ie use more vertical edge
      ip.X := TopX(Edge2, ip.Y) else
      ip.X := TopX(Edge1, ip.Y);
  end;
end;
//------------------------------------------------------------------------------

procedure ReversePolyPtLinks(PP: POutPt);
var
  Pp1,Pp2: POutPt;
begin
  if not Assigned(PP) then Exit;
  Pp1 := PP;
  repeat
    Pp2:= Pp1.Next;
    Pp1.Next := Pp1.Prev;
    Pp1.Prev := Pp2;
    Pp1 := Pp2;
  until Pp1 = PP;
end;
//------------------------------------------------------------------------------

function Pt2IsBetweenPt1AndPt3(const Pt1, Pt2, Pt3: TIntPoint): Boolean;
begin
  //nb: assumes collinearity.
  if PointsEqual(Pt1, Pt3) or PointsEqual(Pt1, Pt2) or PointsEqual(Pt3, Pt2) then
    Result := False
  else if (Pt1.X <> Pt3.X) then
    Result := (Pt2.X > Pt1.X) = (Pt2.X < Pt3.X)
  else
    Result := (Pt2.Y > Pt1.Y) = (Pt2.Y < Pt3.Y);
end;
//------------------------------------------------------------------------------

function GetOverlap(const A1, A2, B1, B2: cInt; out Left, Right: cInt): Boolean;
begin
  if (A1 < A2) then
  begin
    if (B1 < B2) then begin Left := Max(A1,B1); Right := Min(A2,B2); end
    else begin Left := Max(A1,B2); Right := Min(A2,B1); end;
  end else
  begin
    if (B1 < B2) then begin Left := Max(A2,B1); Right := Min(A1,B2); end
    else begin Left := Max(A2,B2); Right := Min(A1,B1); end
  end;
  Result := Left < Right;
end;
//------------------------------------------------------------------------------

procedure UpdateOutPtIdxs(OutRec: POutRec);
var
  op: POutPt;
begin
  op := OutRec.Pts;
  repeat
    op.Idx := OutRec.Idx;
    op := op.Prev;
  until op = OutRec.Pts;
end;
//------------------------------------------------------------------------------

procedure RangeTest(const Pt: TIntPoint; var Use64BitRange: Boolean);
begin
  if Use64BitRange then
  begin
    if (Pt.X > HiRange) or (Pt.Y > HiRange) or
      (-Pt.X > HiRange) or (-Pt.Y > HiRange) then
        raise exception.Create(rsInvalidInt);
  end
  else if (Pt.X > LoRange) or (Pt.Y > LoRange) or
    (-Pt.X > LoRange) or (-Pt.Y > LoRange) then
  begin
    Use64BitRange := true;
    RangeTest(Pt, Use64BitRange);
  end;
end;
//------------------------------------------------------------------------------

procedure ReverseHorizontal(E: PEdge);
begin
  //swap horizontal edges' top and bottom x's so they follow the natural
  //progression of the bounds - ie so their xbots will align with the
  //adjoining lower Edge. [Helpful in the ProcessHorizontal() method.]
  Swap(E.Top.X, E.Bot.X);
{$IFDEF use_xyz}
  Swap(E.Top.Z, E.Bot.Z);
{$ENDIF}
end;
//------------------------------------------------------------------------------

procedure InitEdge(E, Next, Prev: PEdge;
  const Pt: TIntPoint); {$IFDEF INLINING} inline; {$ENDIF}
begin
  E.Curr := Pt;
  E.Next := Next;
  E.Prev := Prev;
  E.OutIdx := Unassigned;
end;
//------------------------------------------------------------------------------

procedure InitEdge2(E: PEdge; PolyType: TPolyType);
{$IFDEF INLINING} inline; {$ENDIF}
begin
  if E.Curr.Y >= E.Next.Curr.Y then
  begin
    E.Bot := E.Curr;
    E.Top := E.Next.Curr;
  end else
  begin
    E.Top := E.Curr;
    E.Bot := E.Next.Curr;
  end;
  SetDx(E);
  E.PolyType := PolyType;
end;
//------------------------------------------------------------------------------

function RemoveEdge(E: PEdge): PEdge; {$IFDEF INLINING} inline; {$ENDIF}
begin
  //removes E from double_linked_list (but without disposing from memory)
  E.Prev.Next := E.Next;
  E.Next.Prev := E.Prev;
  Result := E.Next;
  E.Prev := nil; //flag as removed (see ClipperBase.Clear)
end;
//------------------------------------------------------------------------------

function FindNextLocMin(E: PEdge): PEdge; {$IFDEF INLINING} inline; {$ENDIF}
var
  E2: PEdge;
begin
  while True do
  begin
    while not PointsEqual(E.Bot, E.Prev.Bot) or
      PointsEqual(E.Curr, E.Top) do E := E.Next;
    if (E.Dx <> Horizontal) and (E.Prev.Dx <> Horizontal) then break;
    while (E.Prev.Dx = Horizontal) do E := E.Prev;
    E2 := E; //E2 == first horizontal
    while (E.Dx = Horizontal) do E := E.Next;
    if (E.Top.Y = E.Prev.Bot.Y) then Continue; //ie just an intermediate horz.
    //E == first edge past horizontals
    if E2.Prev.Bot.X < E.Bot.X then E := E2;
    //E is first horizontal when CW and first past horizontals when CCW
    break;
  end;
  Result := E;
end;
//------------------------------------------------------------------------------

function GetUnitNormal(const Pt1, Pt2: TIntPoint): TDoublePoint;
var
  Dx, Dy, F: Double;
begin
  if (Pt2.X = Pt1.X) and (Pt2.Y = Pt1.Y) then
  begin
    Result.X := 0;
    Result.Y := 0;
    Exit;
  end;

  Dx := (Pt2.X - Pt1.X);
  Dy := (Pt2.Y - Pt1.Y);
  F := 1 / Hypot(Dx, Dy);
  Dx := Dx * F;
  Dy := Dy * F;
  Result.X := Dy;
  Result.Y := -Dx
end;

//------------------------------------------------------------------------------
// TClipperBase methods ...
//------------------------------------------------------------------------------

constructor TClipperBase.Create;
begin
  inherited;
  FEdgeList := TEgdeList.Create;
  FLocMinList := TLocMinList.Create;
  FPolyOutList := TPolyOutList.Create;
  FCurrentLocMinIdx := 0;
  FUse64BitRange := False; //ie default is False
end;
//------------------------------------------------------------------------------

destructor TClipperBase.Destroy;
begin
  Clear;
  DisposeScanbeamList;
  FPolyOutList.Free;
  FEdgeList.Free;
  FLocMinList.Free;
  inherited;
end;
//------------------------------------------------------------------------------

function TClipperBase.ProcessBound(E: PEdge; NextIsForward: Boolean): PEdge;
var
  EStart, Horz: PEdge;
  locMin: PLocalMinimum;
begin
  Result := E;
  if (E.OutIdx = Skip) then
  begin
    //check if there are edges beyond the skip edge in the bound and if so
    //create another LocMin and calling ProcessBound once more ...
    if NextIsForward then
    begin
      while (E.Top.Y = E.Next.Bot.Y) do
        E := E.Next;
      //don't include top horizontals here ...
      while (E <> Result) and (E.Dx = Horizontal) do E := E.Prev;
    end else
    begin
      while (E.Top.Y = E.Prev.Bot.Y) do E := E.Prev;
      while (E <> Result) and (E.Dx = Horizontal) do E := E.Next;
    end;
    if E = Result then
    begin
      if NextIsForward then Result := E.Next
      else Result := E.Prev;
    end else
    begin
      if NextIsForward then
        E := Result.Next else
        E := Result.Prev;
      new(locMin);
      locMin.Y := E.Bot.Y;
      locMin.LeftBound := nil;
      locMin.RightBound := E;
      E.WindDelta := 0;
      Result := ProcessBound(E, NextIsForward);
      FLocMinList.Add(locMin);
    end;
    Exit;
  end;

  if (E.Dx = Horizontal) then
  begin
    //We need to be careful with open paths because this may not be a
    //true local minima (ie E may be following a skip edge).
    //Also, consecutive horz. edges may start heading left before going right.
    if NextIsForward then EStart := E.Prev
    else EStart := E.Next;
    if (EStart.Dx = Horizontal) then //ie an adjoining horizontal skip edge
    begin
      if (EStart.Bot.X <> E.Bot.X) and (EStart.Top.X <> E.Bot.X) then
        ReverseHorizontal(E);
    end
    else if (EStart.Bot.X <> E.Bot.X) then
        ReverseHorizontal(E);
  end;

  EStart := E;
  if NextIsForward then
  begin
    while (Result.Top.Y = Result.Next.Bot.Y) and (Result.Next.OutIdx <> Skip) do
      Result := Result.Next;
    if (Result.Dx = Horizontal) and (Result.Next.OutIdx <> Skip) then
    begin
      //nb: at the top of a bound, horizontals are added to the bound
      //only when the preceding edge attaches to the horizontal's left vertex
      //unless a Skip edge is encountered when that becomes the top divide
      Horz := Result;
      while (Horz.Prev.Dx = Horizontal) do Horz := Horz.Prev;
      if (Horz.Prev.Top.X > Result.Next.Top.X) then Result := Horz.Prev;
    end;
    while (E <> Result) do
    begin
      e.NextInLML := e.Next;
      if (E.Dx = Horizontal) and (e <> EStart) and
        (E.Bot.X <> E.Prev.Top.X) then ReverseHorizontal(E);
      E := E.Next;
    end;
    if (e <> EStart) and (E.Dx = Horizontal) and (E.Bot.X <> E.Prev.Top.X) then
      ReverseHorizontal(E);
    Result := Result.Next; //move to the edge just beyond current bound
  end else
  begin
    while (Result.Top.Y = Result.Prev.Bot.Y) and (Result.Prev.OutIdx <> Skip) do
      Result := Result.Prev;
    if (Result.Dx = Horizontal) and (Result.Prev.OutIdx <> Skip) then
    begin
      Horz := Result;
      while (Horz.Next.Dx = Horizontal) do Horz := Horz.Next;
      if (Horz.Next.Top.X = Result.Prev.Top.X) or
        (Horz.Next.Top.X > Result.Prev.Top.X) then Result := Horz.Next;
    end;
    while (E <> Result) do
    begin
      e.NextInLML := e.Prev;
      if (e.Dx = Horizontal) and (e <> EStart) and
        (E.Bot.X <> E.Next.Top.X) then ReverseHorizontal(E);
      E := E.Prev;
    end;
    if (e <> EStart) and (E.Dx = Horizontal) and (E.Bot.X <> E.Next.Top.X) then
      ReverseHorizontal(E);
    Result := Result.Prev; //move to the edge just beyond current bound
  end;
end;
//------------------------------------------------------------------------------

function TClipperBase.AddPath(const Path: TPath;
  PolyType: TPolyType; Closed: Boolean): Boolean;
var
  I, HighI: Integer;
  Edges: PEdgeArray;
  E, E2, EMin, EStart, ELoopStop: PEdge;
  IsFlat, leftBoundIsForward: Boolean;
  locMin: PLocalMinimum;
begin
{$IFDEF use_lines}
  if not Closed and (polyType = ptClip) then
    raise exception.Create(rsOpenPath);
{$ELSE}
  if not Closed then raise exception.Create(rsOpenPath2);
{$ENDIF}

  Result := false;
  IsFlat := true;

  //1. Basic (first) edge initialization ...
  HighI := High(Path);
  if Closed then
    while (HighI > 0) and PointsEqual(Path[HighI],Path[0]) do Dec(HighI);
  while (HighI > 0) and PointsEqual(Path[HighI],Path[HighI -1]) do Dec(HighI);
  if (Closed and (HighI < 2)) or (not Closed and (HighI < 1)) then Exit;

  GetMem(Edges, sizeof(TEdge)*(HighI +1));
  try
    FillChar(Edges^, sizeof(TEdge)*(HighI +1), 0);
    Edges[1].Curr := Path[1];
    RangeTest(Path[0], FUse64BitRange);
    RangeTest(Path[HighI], FUse64BitRange);
    InitEdge(@Edges[0], @Edges[1], @Edges[HighI], Path[0]);
    InitEdge(@Edges[HighI], @Edges[0], @Edges[HighI-1], Path[HighI]);
    for I := HighI - 1 downto 1 do
    begin
      RangeTest(Path[I], FUse64BitRange);
      InitEdge(@Edges[I], @Edges[I+1], @Edges[I-1], Path[I]);
    end;
  except
    FreeMem(Edges);
    raise; //Range test fails
  end;
  EStart := @Edges[0];

  //2. Remove duplicate vertices, and (when closed) collinear edges ...
  E := EStart;
  ELoopStop := EStart;
  while (E <> E.Next) do //ie in case loop reduces to a single vertex
  begin
    //allow matching start and end points when not Closed ...
    if PointsEqual(E.Curr, E.Next.Curr) and
      (Closed or (E.Next <> EStart)) then
    begin
      if E = EStart then EStart := E.Next;
      E := RemoveEdge(E);
      ELoopStop := E;
      Continue;
    end;
    if (E.Prev = E.Next) then
      Break //only two vertices
    else if Closed and
      SlopesEqual(E.Prev.Curr, E.Curr, E.Next.Curr, FUse64BitRange) and
      (not FPreserveCollinear or
      not Pt2IsBetweenPt1AndPt3(E.Prev.Curr, E.Curr, E.Next.Curr)) then
    begin
      //Collinear edges are allowed for open paths but in closed paths
      //the default is to merge adjacent collinear edges into a single edge.
      //However, if the PreserveCollinear property is enabled, only overlapping
      //collinear edges (ie spikes) will be removed from closed paths.
      if E = EStart then EStart := E.Next;
      E := RemoveEdge(E);
      E := E.Prev;
      ELoopStop := E;
      Continue;
    end;
    E := E.Next;
    //todo - manage open paths which start and end at same point
    if (E = eLoopStop) then Break;
    if E = ELoopStop then Break;
  end;

  if (not Closed and (E = E.Next)) or (Closed and (E.Prev = E.Next)) then
  begin
    FreeMem(Edges);
    Exit;
  end;

  if not Closed then
  begin
    FHasOpenPaths := true;
    EStart.Prev.OutIdx := Skip;
  end;

  //3. Do second stage of edge initialization ...
  E := EStart;
  repeat
    InitEdge2(E, polyType);
    E := E.Next;
    if IsFlat and (E.Curr.Y <> EStart.Curr.Y) then IsFlat := false;
  until E = EStart;
  //4. Finally, add edge bounds to LocalMinima list ...

  //Totally flat paths must be handled differently when adding them
  //to LocalMinima list to avoid endless loops etc ...
  if (IsFlat) then
  begin
    if Closed then
    begin
      FreeMem(Edges);
      Exit;
    end;
    new(locMin);
    locMin.Y := E.Bot.Y;
    locMin.LeftBound := nil;
    locMin.RightBound := E;
    locMin.RightBound.Side := esRight;
    locMin.RightBound.WindDelta := 0;
    while true do
    begin
      if E.Bot.X <> E.Prev.Top.X then ReverseHorizontal(E);
      if E.Next.OutIdx = Skip then break;
      E.NextInLML := E.Next;
      E := E.Next;
    end;
    FLocMinList.Add(locMin);
    Result := true;
    FEdgeList.Add(Edges);
    Exit;
  end;

  Result := true;
  FEdgeList.Add(Edges);
  EMin := nil;

  //workaround to avoid an endless loop in the while loop below when
  //open paths have matching start and end points ...
  if PointsEqual(E.Prev.Bot, E.Prev.Top) then E := E.Next;

  while true do
  begin
    E := FindNextLocMin(E);
    if (E = EMin) then break
    else if (EMin = nil) then EMin := E;

    //E and E.Prev now share a local minima (left aligned if horizontal).
    //Compare their slopes to find which starts which bound ...
    new(locMin);
    locMin.Y := E.Bot.Y;
    if (E.Dx < E.Prev.Dx) then
    begin
      locMin.LeftBound := E.Prev;
      locMin.RightBound := E; //can be horz when CW
      leftBoundIsForward := false; //Q.nextInLML = Q.prev
    end else
    begin
      locMin.LeftBound := E;
      locMin.RightBound := E.Prev; //can be horz when CCW
      leftBoundIsForward := true; //Q.nextInLML = Q.next
    end;

    if not Closed then locMin.LeftBound.WindDelta := 0
    else if (locMin.LeftBound.Next = locMin.RightBound) then
      locMin.LeftBound.WindDelta := -1
    else locMin.LeftBound.WindDelta := 1;
    locMin.RightBound.WindDelta := -locMin.LeftBound.WindDelta;

    E := ProcessBound(locMin.LeftBound, leftBoundIsForward);
    if E.OutIdx = Skip then E := ProcessBound(E, leftBoundIsForward);

    E2 := ProcessBound(locMin.RightBound, not leftBoundIsForward);
    if E2.OutIdx = Skip then E2 := ProcessBound(E2, not leftBoundIsForward);

    if (locMin.LeftBound.OutIdx = Skip) then locMin.LeftBound := nil
    else if (locMin.RightBound.OutIdx = Skip) then locMin.RightBound := nil;
    FLocMinList.Add(locMin);

    if not leftBoundIsForward then E := E2;
  end;
end;
//------------------------------------------------------------------------------

function TClipperBase.AddPaths(const Paths: TPaths;
  PolyType: TPolyType; Closed: Boolean): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to high(Paths) do
    if AddPath(Paths[I], PolyType, Closed) then Result := True;
end;
//------------------------------------------------------------------------------

procedure TClipperBase.Clear;
var
  I: Integer;
begin
  DisposeLocalMinimaList;
  //dispose of Edges ...
  for I := 0 to FEdgeList.Count -1 do
    FreeMem(PEdgeArray(fEdgeList[I]));
  FEdgeList.Clear;

  FUse64BitRange := False;
  FHasOpenPaths := False;
end;
//------------------------------------------------------------------------------

procedure TClipperBase.InsertScanbeam(const Y: cInt);
var
  newSb, sb: PScanbeam;
begin
  //single-linked list: sorted descending, ignoring dups.
  new(newSb);
  newSb.Y := Y;
  if not Assigned(fScanbeam) then
  begin
    FScanbeam := newSb;
    newSb.Next := nil;
  end else if Y > FScanbeam.Y then
  begin
    newSb.Next := FScanbeam;
    FScanbeam := newSb;
  end else
  begin
    sb := FScanbeam;
    while Assigned(sb.Next) and (Y <= sb.Next.Y) do sb := sb.Next;
    if Y <> sb.Y then
    begin
      newSb.Next := sb.Next;
      sb.Next := newSb;
    end
    else dispose(newSb);
  end;
end;
//------------------------------------------------------------------------------

function TClipperBase.PopScanbeam(out Y: cInt): Boolean;
var
  Sb: PScanbeam;
begin
  Result := assigned(FScanbeam);
  if not result then exit;
  Y := FScanbeam.Y;
  Sb := FScanbeam;
  FScanbeam := FScanbeam.Next;
  dispose(Sb);
end;
//------------------------------------------------------------------------------

function TClipperBase.LocalMinimaPending: Boolean;
begin
  Result := FCurrentLocMinIdx < FLocMinList.Count;
end;
//------------------------------------------------------------------------------

function TClipperBase.PopLocalMinima(Y: cInt;
  out LocalMinima: PLocalMinimum): Boolean;
begin
  Result := false;
  if (FCurrentLocMinIdx = FLocMinList.Count) then Exit;
  LocalMinima := PLocalMinimum(FLocMinList[FCurrentLocMinIdx]);
  if (LocalMinima.Y = Y) then
  begin
    inc(FCurrentLocMinIdx);
    Result := true;
  end;
end;
//------------------------------------------------------------------------------

procedure TClipperBase.DisposeScanbeamList;
var
  SB: PScanbeam;
begin
  while Assigned(fScanbeam) do
  begin
    SB := FScanbeam.Next;
    Dispose(fScanbeam);
    FScanbeam := SB;
  end;
end;
//------------------------------------------------------------------------------

{$IFNDEF USEGENERICS}
function LocMinListSort(item1, item2:Pointer): Integer;
var
  y: cInt;
begin
  y := PLocalMinimum(item2).Y - PLocalMinimum(item1).Y;
  if y < 0 then result := -1
  else if y > 0 then result := 1
  else result := 0;
end;
{$ENDIF}

//------------------------------------------------------------------------------

procedure TClipperBase.Reset;
var
  i: Integer;
  Lm: PLocalMinimum;
begin
  //Reset() allows various clipping operations to be executed
  //multiple times on the same polygon sets.
{$IFDEF USEGENERICS}
    FLocMinList.Sort(TComparer<PLocalMinimum>.Construct(
      function (const Item1, Item2 : PLocalMinimum) : integer
      var
        y: cInt;
      begin
        y := PLocalMinimum(item2).Y - PLocalMinimum(item1).Y;
        if y < 0 then result := -1
        else if y > 0 then result := 1
        else result := 0;
      end
    ));
{$ELSE}
  FLocMinList.Sort(LocMinListSort);
{$ENDIF}
  for i := 0 to FLocMinList.Count -1 do
  begin
    Lm := PLocalMinimum(FLocMinList[i]);
    InsertScanbeam(Lm.Y);
    //resets just the two (L & R) edges attached to each Local Minima ...
    if assigned(Lm.LeftBound) then
      with Lm.LeftBound^ do
      begin
        Curr := Bot;
        OutIdx := Unassigned;
      end;
    if assigned(Lm.RightBound) then
      with Lm.RightBound^ do
      begin
        Curr := Bot;
        OutIdx := Unassigned;
      end;
  end;
  FCurrentLocMinIdx := 0;
  FActiveEdges := nil;
end;
//------------------------------------------------------------------------------

procedure TClipperBase.DisposePolyPts(PP: POutPt);
var
  TmpPp: POutPt;
begin
  PP.Prev.Next := nil;
  while Assigned(PP) do
  begin
    TmpPp := PP;
    PP := PP.Next;
    dispose(TmpPp);
  end;
end;
//------------------------------------------------------------------------------

procedure TClipperBase.DisposeLocalMinimaList;
var
  i: Integer;
begin
  for i := 0 to FLocMinList.Count -1 do
    Dispose(PLocalMinimum(FLocMinList[i]));
  FLocMinList.Clear;
  FCurrentLocMinIdx := 0;
end;
//------------------------------------------------------------------------------

function TClipperBase.CreateOutRec: POutRec;
begin
  new(Result);
  Result.IsHole := False;
  Result.IsOpen := False;
  Result.FirstLeft := nil;
  Result.Pts := nil;
  Result.BottomPt := nil;
  Result.PolyNode := nil;
  Result.Idx := FPolyOutList.Add(Result);
end;
//------------------------------------------------------------------------------

procedure TClipperBase.DisposeOutRec(Index: Integer);
var
  OutRec: POutRec;
begin
  OutRec := FPolyOutList[Index];
  if Assigned(OutRec.Pts) then DisposePolyPts(OutRec.Pts);
  Dispose(OutRec);
  FPolyOutList[Index] := nil;
end;
//------------------------------------------------------------------------------

procedure TClipperBase.DisposeAllOutRecs;
var
  I: Integer;
begin
  for I := 0 to FPolyOutList.Count -1 do DisposeOutRec(I);
  FPolyOutList.Clear;
end;
//------------------------------------------------------------------------------

procedure TClipperBase.UpdateEdgeIntoAEL(var E: PEdge);
var
  AelPrev, AelNext: PEdge;
begin
  //return true when AddOutPt() call needed too
  if not Assigned(E.NextInLML) then
    raise exception.Create(rsUpdateEdgeIntoAEL);

  E.NextInLML.OutIdx := E.OutIdx;

  AelPrev := E.PrevInAEL;
  AelNext := E.NextInAEL;
  if Assigned(AelPrev) then
    AelPrev.NextInAEL := E.NextInLML else
    FActiveEdges := E.NextInLML;
  if Assigned(AelNext) then
    AelNext.PrevInAEL := E.NextInLML;
  E.NextInLML.Side := E.Side;
  E.NextInLML.WindDelta := E.WindDelta;
  E.NextInLML.WindCnt := E.WindCnt;
  E.NextInLML.WindCnt2 := E.WindCnt2;
  E := E.NextInLML; ////
  E.Curr := E.Bot;
  E.PrevInAEL := AelPrev;
  E.NextInAEL := AelNext;
  if E.Dx <> Horizontal then
    InsertScanbeam(E.Top.Y);
end;
//------------------------------------------------------------------------------

procedure TClipperBase.SwapPositionsInAEL(E1, E2: PEdge);
var
  Prev,Next: PEdge;
begin
  //check that one or other edge hasn't already been removed from AEL ...
  if (E1.NextInAEL = E1.PrevInAEL) or (E2.NextInAEL = E2.PrevInAEL) then
    Exit;

  if E1.NextInAEL = E2 then
  begin
    Next := E2.NextInAEL;
    if Assigned(Next) then Next.PrevInAEL := E1;
    Prev := E1.PrevInAEL;
    if Assigned(Prev) then Prev.NextInAEL := E2;
    E2.PrevInAEL := Prev;
    E2.NextInAEL := E1;
    E1.PrevInAEL := E2;
    E1.NextInAEL := Next;
  end
  else if E2.NextInAEL = E1 then
  begin
    Next := E1.NextInAEL;
    if Assigned(Next) then Next.PrevInAEL := E2;
    Prev := E2.PrevInAEL;
    if Assigned(Prev) then Prev.NextInAEL := E1;
    E1.PrevInAEL := Prev;
    E1.NextInAEL := E2;
    E2.PrevInAEL := E1;
    E2.NextInAEL := Next;
  end else
  begin
    Next := E1.NextInAEL;
    Prev := E1.PrevInAEL;
    E1.NextInAEL := E2.NextInAEL;
    if Assigned(E1.NextInAEL) then E1.NextInAEL.PrevInAEL := E1;
    E1.PrevInAEL := E2.PrevInAEL;
    if Assigned(E1.PrevInAEL) then E1.PrevInAEL.NextInAEL := E1;
    E2.NextInAEL := Next;
    if Assigned(E2.NextInAEL) then E2.NextInAEL.PrevInAEL := E2;
    E2.PrevInAEL := Prev;
    if Assigned(E2.PrevInAEL) then E2.PrevInAEL.NextInAEL := E2;
  end;
  if not Assigned(E1.PrevInAEL) then FActiveEdges := E1
  else if not Assigned(E2.PrevInAEL) then FActiveEdges := E2;
end;
//------------------------------------------------------------------------------

procedure TClipperBase.DeleteFromAEL(E: PEdge);
var
  AelPrev, AelNext: PEdge;
begin
  AelPrev := E.PrevInAEL;
  AelNext := E.NextInAEL;
  if not Assigned(AelPrev) and not Assigned(AelNext) and
    (E <> FActiveEdges) then Exit; //already deleted
  if Assigned(AelPrev) then AelPrev.NextInAEL := AelNext
  else FActiveEdges := AelNext;
  if Assigned(AelNext) then AelNext.PrevInAEL := AelPrev;
  E.NextInAEL := nil;
  E.PrevInAEL := nil;
end;

//------------------------------------------------------------------------------
// TClipper methods ...
//------------------------------------------------------------------------------

constructor TClipper.Create(InitOptions: TInitOptions = []);
begin
  inherited Create;
  FJoinList := TJoinList.Create;
  FGhostJoinList := TJoinList.Create;
  FIntersectList := TIntersecList.Create;
  if ioReverseSolution in InitOptions then
    FReverseOutput := true;
  if ioStrictlySimple in InitOptions then
    FStrictSimple := true;
  if ioPreserveCollinear in InitOptions then
    FPreserveCollinear := true;
end;
//------------------------------------------------------------------------------

destructor TClipper.Destroy;
begin
  inherited; //this must be first since inherited Destroy calls Clear.
  FJoinList.Free;
  FGhostJoinList.Free;
  FIntersectList.Free;
end;
//------------------------------------------------------------------------------

function TClipper.Execute(clipType: TClipType;
  out solution: TPaths;
  FillType: TPolyFillType = pftEvenOdd): Boolean;
begin
  Result := Execute(clipType, solution, FillType, FillType);
end;
//------------------------------------------------------------------------------

function TClipper.Execute(clipType: TClipType;
  out solution: TPaths;
  subjFillType: TPolyFillType; clipFillType: TPolyFillType): Boolean;
begin
  Result := False;
  solution := nil;
  if FExecuteLocked then Exit;
  //nb: Open paths can only be returned via the PolyTree structure ...
  if HasOpenPaths then raise Exception.Create(rsOpenPath3);
  try try
    FExecuteLocked := True;
    FSubjFillType := subjFillType;
    FClipFillType := clipFillType;
    FClipType := clipType;
    FUsingPolyTree := False;
    Result := ExecuteInternal;
    if Result then
      solution := BuildResult;
  except
    solution := nil;
    Result := False;
  end;
  finally
    DisposeAllOutRecs;
    FExecuteLocked := False;
  end;
end;
//------------------------------------------------------------------------------

function TClipper.Execute(clipType: TClipType;
  out PolyTree: TPolyTree;
  FillType: TPolyFillType = pftEvenOdd): Boolean;
begin
  Result := Execute(clipType, PolyTree, FillType, FillType);
end;
//------------------------------------------------------------------------------

function TClipper.Execute(clipType: TClipType;
  out PolyTree: TPolyTree;
  subjFillType: TPolyFillType;
  clipFillType: TPolyFillType): Boolean;
begin
  Result := False;
  if FExecuteLocked or not Assigned(PolyTree) then Exit;
  try try
    FExecuteLocked := True;
    FSubjFillType := subjFillType;
    FClipFillType := clipFillType;
    FClipType := clipType;
    FUsingPolyTree := True;
    Result := ExecuteInternal and BuildResult2(PolyTree);
  except
    Result := False;
  end;
  finally
    DisposeAllOutRecs;
    FExecuteLocked := False;
  end;
end;
//------------------------------------------------------------------------------

procedure TClipper.FixHoleLinkage(OutRec: POutRec);
var
  orfl: POutRec;
begin
  //skip if it's an outermost polygon or if FirstLeft
  //already points to the outer/owner polygon ...
  if not Assigned(OutRec.FirstLeft) or
    ((OutRec.IsHole <> OutRec.FirstLeft.IsHole) and
      Assigned(OutRec.FirstLeft.Pts)) then Exit;
  orfl := OutRec.FirstLeft;
  while Assigned(orfl) and
    ((orfl.IsHole = OutRec.IsHole) or not Assigned(orfl.Pts)) do
      orfl := orfl.FirstLeft;
  OutRec.FirstLeft := orfl;
end;
//------------------------------------------------------------------------------

function TClipper.ExecuteInternal: Boolean;
var
  I: Integer;
  OutRec: POutRec;
  BotY, TopY: cInt;
begin
  try
    Reset;
    FSortedEdges := nil;
    Result := false;
    if not PopScanbeam(BotY) then Exit;
    InsertLocalMinimaIntoAEL(BotY);
    while PopScanbeam(TopY) or LocalMinimaPending do
    begin
      ProcessHorizontals;
      ClearGhostJoins;
      if not ProcessIntersections(TopY) then Exit;
      ProcessEdgesAtTopOfScanbeam(TopY);
      BotY := TopY;
      InsertLocalMinimaIntoAEL(BotY);
    end;

    //fix orientations ...
    for I := 0 to FPolyOutList.Count -1 do
    begin
      OutRec := FPolyOutList[I];
      if Assigned(OutRec.Pts) and not OutRec.IsOpen and
        ((OutRec.IsHole xor FReverseOutput) = (Area(OutRec) > 0)) then
          ReversePolyPtLinks(OutRec.Pts);
    end;

    if FJoinList.count > 0 then JoinCommonEdges;

    //unfortunately FixupOutPolygon() must be done after JoinCommonEdges ...
    for I := 0 to FPolyOutList.Count -1 do
    begin
      OutRec := FPolyOutList[I];
      if not Assigned(OutRec.Pts) then continue;
      if OutRec.IsOpen then
        FixupOutPolyline(OutRec)
      else
        FixupOutPolygon(OutRec);
    end;

    if FStrictSimple then DoSimplePolygons;
    Result := True;
  finally
    ClearJoins;
    ClearGhostJoins;
  end;
end;
//------------------------------------------------------------------------------

procedure TClipper.InsertMaxima(const X: cInt);
var
  newMax, m: PMaxima;
begin
  //double-linked list: sorted ascending, ignoring dups.
  new(newMax);
  newMax.X := X;
  if not Assigned(FMaxima) then
  begin
    FMaxima := newMax;
    newMax.Next := nil;
    newMax.Prev := nil;
  end else if X < FMaxima.X then
  begin
    newMax.Next := FMaxima;
    newMax.Prev := nil;
    FMaxima.Prev := newMax;
    FMaxima := newMax;
  end else
  begin
    m := FMaxima;
    while Assigned(m.Next) and (X >= m.Next.X) do m := m.Next;
    if X <> m.X then
    begin
      //insert m1 between m2 and m2.Next ...
      newMax.Next := m.Next;
      newMax.Prev := m;
      if assigned(m.Next) then m.Next.Prev := newMax;
      m.Next := newMax;
    end
    else dispose(newMax);
  end;
end;
//------------------------------------------------------------------------------

procedure TClipper.DisposeMaximaList;
var
  m: PMaxima;
begin
  while Assigned(FMaxima) do
  begin
    m := FMaxima.Next;
    Dispose(FMaxima);
    FMaxima := m;
  end;
end;
//------------------------------------------------------------------------------

procedure TClipper.SetWindingCount(Edge: PEdge);
var
  E, E2: PEdge;
  Inside: Boolean;
  pft: TPolyFillType;
begin
  E := Edge.PrevInAEL;
  //find the Edge of the same PolyType that immediately preceeds 'Edge' in AEL
  while Assigned(E) and ((E.PolyType <> Edge.PolyType) or (E.WindDelta = 0)) do
    E := E.PrevInAEL;
  if not Assigned(E) then
  begin
    if Edge.WindDelta = 0 then
    begin
      if edge.PolyType = ptSubject then
        pft := FSubjFillType else
        pft :=  FClipFillType;
      if pft = pftNegative then
        Edge.WindCnt := -1 else
        Edge.WindCnt := 1;
    end else Edge.WindCnt := Edge.WindDelta;
    Edge.WindCnt2 := 0;
    E := FActiveEdges; //ie get ready to calc WindCnt2
  end
  else if (Edge.WindDelta = 0) and (FClipType <> ctUnion) then
  begin
    Edge.WindCnt := 1;
    Edge.WindCnt2 := E.WindCnt2;
    E := E.NextInAEL; //ie get ready to calc WindCnt2
  end
  else if IsEvenOddFillType(Edge) then
  begin
    //even-odd filling ...
    if (Edge.WindDelta = 0) then  //if edge is part of a line
    begin
      //are we inside a subj polygon ...
      Inside := true;
      E2 := E.PrevInAEL;
      while assigned(E2) do
      begin
        if (E2.PolyType = E.PolyType) and (E2.WindDelta <> 0) then
          Inside := not Inside;
        E2 := E2.PrevInAEL;
      end;
      if Inside then Edge.WindCnt := 0
      else Edge.WindCnt := 1;
    end
    else //else a polygon
    begin
      Edge.WindCnt := Edge.WindDelta;
    end;
    Edge.WindCnt2 := E.WindCnt2;
    E := E.NextInAEL; //ie get ready to calc WindCnt2
  end else
  begin
    //NonZero, Positive, or Negative filling ...
    if (E.WindCnt * E.WindDelta < 0) then
    begin
      //prev edge is 'decreasing' WindCount (WC) toward zero
      //so we're outside the previous polygon ...
      if (Abs(E.WindCnt) > 1) then
      begin
        //outside prev poly but still inside another.
        //when reversing direction of prev poly use the same WC
        if (E.WindDelta * Edge.WindDelta < 0) then
          Edge.WindCnt := E.WindCnt
        //otherwise continue to 'decrease' WC ...
        else Edge.WindCnt := E.WindCnt + Edge.WindDelta;
      end
      else
        //now outside all polys of same polytype so set own WC ...
        if Edge.WindDelta = 0 then Edge.WindCnt := 1
        else Edge.WindCnt := Edge.WindDelta;
    end else
    begin
      //prev edge is 'increasing' WindCount (WC) away from zero
      //so we're inside the previous polygon ...
      if (Edge.WindDelta = 0) then
      begin
        if (E.WindCnt < 0) then Edge.WindCnt := E.WindCnt -1
        else Edge.WindCnt := E.WindCnt +1;
      end
      //if wind direction is reversing prev then use same WC
      else if (E.WindDelta * Edge.WindDelta < 0) then
        Edge.WindCnt := E.WindCnt
      //otherwise add to WC ...
      else Edge.WindCnt := E.WindCnt + Edge.WindDelta;
    end;
    Edge.WindCnt2 := E.WindCnt2;
    E := E.NextInAEL; //ie get ready to calc WindCnt2
  end;

  //update WindCnt2 ...
  if IsEvenOddAltFillType(Edge) then
  begin
    //even-odd filling ...
    while (E <> Edge) do
    begin
      if E.WindDelta = 0 then //do nothing (ie ignore lines)
      else if Edge.WindCnt2 = 0 then Edge.WindCnt2 := 1
      else Edge.WindCnt2 := 0;
      E := E.NextInAEL;
    end;
  end else
  begin
    //NonZero, Positive, or Negative filling ...
    while (E <> Edge) do
    begin
      Inc(Edge.WindCnt2, E.WindDelta);
      E := E.NextInAEL;
    end;
  end;
end;
//------------------------------------------------------------------------------

function TClipper.IsEvenOddFillType(Edge: PEdge): Boolean;
begin
  if Edge.PolyType = ptSubject then
    Result := FSubjFillType = pftEvenOdd else
    Result := FClipFillType = pftEvenOdd;
end;
//------------------------------------------------------------------------------

function TClipper.IsEvenOddAltFillType(Edge: PEdge): Boolean;
begin
  if Edge.PolyType = ptSubject then
    Result := FClipFillType = pftEvenOdd else
    Result := FSubjFillType = pftEvenOdd;
end;
//------------------------------------------------------------------------------

function TClipper.IsContributing(Edge: PEdge): Boolean;
var
  Pft, Pft2: TPolyFillType;
begin
  if Edge.PolyType = ptSubject then
  begin
    Pft := FSubjFillType;
    Pft2 := FClipFillType;
  end else
  begin
    Pft := FClipFillType;
    Pft2 := FSubjFillType
  end;

  case Pft of
    pftEvenOdd: Result := (Edge.WindDelta <> 0) or (Edge.WindCnt = 1);
    pftNonZero: Result := abs(Edge.WindCnt) = 1;
    pftPositive: Result := (Edge.WindCnt = 1);
    else Result := (Edge.WindCnt = -1);
  end;
  if not Result then Exit;

  case FClipType of
    ctIntersection:
      case Pft2 of
        pftEvenOdd, pftNonZero: Result := (Edge.WindCnt2 <> 0);
        pftPositive: Result := (Edge.WindCnt2 > 0);
        pftNegative: Result := (Edge.WindCnt2 < 0);
      end;
    ctUnion:
      case Pft2 of
        pftEvenOdd, pftNonZero: Result := (Edge.WindCnt2 = 0);
        pftPositive: Result := (Edge.WindCnt2 <= 0);
        pftNegative: Result := (Edge.WindCnt2 >= 0);
      end;
    ctDifference:
      if Edge.PolyType = ptSubject then
        case Pft2 of
          pftEvenOdd, pftNonZero: Result := (Edge.WindCnt2 = 0);
          pftPositive: Result := (Edge.WindCnt2 <= 0);
          pftNegative: Result := (Edge.WindCnt2 >= 0);
        end
      else
        case Pft2 of
          pftEvenOdd, pftNonZero: Result := (Edge.WindCnt2 <> 0);
          pftPositive: Result := (Edge.WindCnt2 > 0);
          pftNegative: Result := (Edge.WindCnt2 < 0);
        end;
      ctXor:
        if Edge.WindDelta = 0 then //XOr always contributing unless open
          case Pft2 of
            pftEvenOdd, pftNonZero: Result := (Edge.WindCnt2 = 0);
            pftPositive: Result := (Edge.WindCnt2 <= 0);
            pftNegative: Result := (Edge.WindCnt2 >= 0);
          end;
  end;
end;
//------------------------------------------------------------------------------

function TClipper.AddLocalMinPoly(E1, E2: PEdge; const Pt: TIntPoint): POutPt;
var
  E, prevE: PEdge;
  OutPt: POutPt;
  X1, X2: cInt;
begin
  if (E2.Dx = Horizontal) or (E1.Dx > E2.Dx) then
  begin
    Result := AddOutPt(E1, Pt);
    E2.OutIdx := E1.OutIdx;
    E1.Side := esLeft;
    E2.Side := esRight;
    E := E1;
    if E.PrevInAEL = E2 then
      prevE := E2.PrevInAEL
    else
      prevE := E.PrevInAEL;
  end else
  begin
    Result := AddOutPt(E2, Pt);
    E1.OutIdx := E2.OutIdx;
    E1.Side := esRight;
    E2.Side := esLeft;

    E := E2;
    if E.PrevInAEL = E1 then
      prevE := E1.PrevInAEL
    else
      prevE := E.PrevInAEL;
  end;

  if Assigned(prevE) and (prevE.OutIdx >= 0) and
    (prevE.Top.Y < Pt.Y) and (E.Top.Y < Pt.Y) then
  begin
    X1 := TopX(prevE, Pt.Y);
    X2 := TopX(E, Pt.Y);
    if (X1 = X2) and
      SlopesEqual(IntPoint(X1, Pt.Y), prevE.Top, IntPoint(X2, Pt.Y), E.Top,
        FUse64BitRange) and (E.WindDelta <> 0) and (prevE.WindDelta <> 0) then
    begin
      OutPt := AddOutPt(prevE, Pt);
      AddJoin(Result, OutPt, E.Top);
    end;
  end;
end;
//------------------------------------------------------------------------------

procedure TClipper.AddLocalMaxPoly(E1, E2: PEdge; const Pt: TIntPoint);
begin
  AddOutPt(E1, Pt);
  if E2.WindDelta = 0 then AddOutPt(E2, Pt);
  if (E1.OutIdx = E2.OutIdx) then
  begin
    E1.OutIdx := Unassigned;
    E2.OutIdx := Unassigned;
  end
  else if E1.OutIdx < E2.OutIdx then
    AppendPolygon(E1, E2)
  else
    AppendPolygon(E2, E1);
  end;
//------------------------------------------------------------------------------

procedure TClipper.AddEdgeToSEL(Edge: PEdge);
begin
  //SEL pointers in PEdge are use to build transient lists of horizontal edges.
  //However, since we don't need to worry about processing order, all additions
  //are made to the front of the list ...
  if not Assigned(FSortedEdges) then
  begin
    FSortedEdges := Edge;
    Edge.PrevInSEL := nil;
    Edge.NextInSEL := nil;
  end else
  begin
    Edge.NextInSEL := FSortedEdges;
    Edge.PrevInSEL := nil;
    FSortedEdges.PrevInSEL := Edge;
    FSortedEdges := Edge;
  end;
end;
//------------------------------------------------------------------------------

function TClipper.PopEdgeFromSEL(out E: PEdge): Boolean;
begin
  //Pop edge from front of SEL (ie SEL is a FILO list)
  E := FSortedEdges;
  Result := assigned(E);
  if not Result then Exit;
  FSortedEdges := E.NextInSEL;
  if Assigned(FSortedEdges) then FSortedEdges.PrevInSEL := nil;
  E.NextInSEL := nil;
  E.PrevInSEL := nil;
end;
//------------------------------------------------------------------------------

procedure TClipper.CopyAELToSEL;
var
  E: PEdge;
begin
  E := FActiveEdges;
  FSortedEdges := E;
  while Assigned(E) do
  begin
    E.PrevInSEL := E.PrevInAEL;
    E.NextInSEL := E.NextInAEL;
    E := E.NextInAEL;
  end;
end;
//------------------------------------------------------------------------------

function TClipper.AddOutPt(E: PEdge; const Pt: TIntPoint): POutPt;
var
  OutRec: POutRec;
  PrevOp, Op: POutPt;
  ToFront: Boolean;
begin
  if E.OutIdx < 0 then
  begin
    OutRec := CreateOutRec;
    OutRec.IsOpen := (E.WindDelta = 0);
    new(Result);
    OutRec.Pts := Result;
    Result.Pt := Pt;
    Result.Next := Result;
    Result.Prev := Result;
    Result.Idx := OutRec.Idx;
    if not OutRec.IsOpen then
      SetHoleState(E, OutRec);
    E.OutIdx := OutRec.Idx;
  end else
  begin
    ToFront := E.Side = esLeft;
    OutRec := FPolyOutList[E.OutIdx];
    //OutRec.Pts is the 'left-most' point & OutRec.Pts.Prev is the 'right-most'
    Op := OutRec.Pts;
    if ToFront then PrevOp := Op else PrevOp := Op.Prev;
    if PointsEqual(Pt, PrevOp.Pt) then
    begin
      Result := PrevOp;
      Exit;
    end;
    new(Result);
    Result.Pt := Pt;
    Result.Idx := OutRec.Idx;
    Result.Next := Op;
    Result.Prev := Op.Prev;
    Op.Prev.Next := Result;
    Op.Prev := Result;
    if ToFront then OutRec.Pts := Result;
  end;
end;
//------------------------------------------------------------------------------

procedure TClipper.AddJoin(Op1, Op2: POutPt; const OffPt: TIntPoint);
var
  Jr: PJoin;
begin
  new(Jr);
  Jr.OutPt1 := Op1;
  Jr.OutPt2 := Op2;
  Jr.OffPt := OffPt;
  FJoinList.add(Jr);
end;
//------------------------------------------------------------------------------

procedure TClipper.ClearJoins;
var
  I: Integer;
begin
  for I := 0 to FJoinList.count -1 do
    Dispose(PJoin(fJoinList[I]));
  FJoinList.Clear;
end;
//------------------------------------------------------------------------------

procedure TClipper.AddGhostJoin(OutPt: POutPt; const OffPt: TIntPoint);
var
  Jr: PJoin;
begin
  //Ghost joins are used to find horizontal edges at the top of one scanbeam
  //that coincide with horizontal edges at the bottom of the next. Ghost joins
  //are converted to real joins when match ups occur.
  new(Jr);
  Jr.OutPt1 := OutPt;
  Jr.OffPt := OffPt;
  FGhostJoinList.Add(Jr);
end;
//------------------------------------------------------------------------------

procedure TClipper.ClearGhostJoins;
var
  I: Integer;
begin
  for I := 0 to FGhostJoinList.Count -1 do
    Dispose(PJoin(FGhostJoinList[I]));
  FGhostJoinList.Clear;
end;
//------------------------------------------------------------------------------

procedure SwapPoints(var Pt1, Pt2: TIntPoint);
var
  Tmp: TIntPoint;
begin
  Tmp := Pt1;
  Pt1 := Pt2;
  Pt2 := Tmp;
end;
//------------------------------------------------------------------------------

function HorzSegmentsOverlap(seg1a, seg1b, seg2a, seg2b: cInt): Boolean;
begin
  if (seg1a > seg1b) then Swap(seg1a, seg1b);
  if (seg2a > seg2b) then Swap(seg2a, seg2b);
  Result := (seg1a < seg2b) and (seg2a < seg1b);
end;
//------------------------------------------------------------------------------

function E2InsertsBeforeE1(E1, E2: PEdge): Boolean;
  {$IFDEF INLINING} inline; {$ENDIF}
begin
  if E2.Curr.X = E1.Curr.X then
  begin
    //nb: E1.Top.Y == E2.Bot.Y only occurs when an earlier Rb is horizontal
    if E2.Top.Y > E1.Top.Y then
      Result := E2.Top.X < TopX(E1, E2.Top.Y) else
      Result := E1.Top.X > TopX(E2, E1.Top.Y);
  end else
    Result := E2.Curr.X < E1.Curr.X;
end;
//----------------------------------------------------------------------

procedure TClipper.InsertLocalMinimaIntoAEL(const BotY: cInt);

  procedure InsertEdgeIntoAEL(Edge, StartEdge: PEdge);
  begin
    if not Assigned(FActiveEdges) then
    begin
      Edge.PrevInAEL := nil;
      Edge.NextInAEL := nil;
      FActiveEdges := Edge;
    end
    else if not Assigned(StartEdge) and
      E2InsertsBeforeE1(FActiveEdges, Edge) then
    begin
      Edge.PrevInAEL := nil;
      Edge.NextInAEL := FActiveEdges;
      FActiveEdges.PrevInAEL := Edge;
      FActiveEdges := Edge;
    end else
    begin
      if not Assigned(StartEdge) then StartEdge := FActiveEdges;
      while Assigned(StartEdge.NextInAEL) and
        not E2InsertsBeforeE1(StartEdge.NextInAEL, Edge) do
          StartEdge := StartEdge.NextInAEL;
      Edge.NextInAEL := StartEdge.NextInAEL;
      if Assigned(StartEdge.NextInAEL) then
        StartEdge.NextInAEL.PrevInAEL := Edge;
      Edge.PrevInAEL := StartEdge;
      StartEdge.NextInAEL := Edge;
    end;
  end;
  //----------------------------------------------------------------------

var
  I: Integer;
  E: PEdge;
  Lb, Rb: PEdge;
  Jr: PJoin;
  Op1, Op2: POutPt;
  LocMin: PLocalMinimum;
begin
  //Add any local minima at BotY ...
  while PopLocalMinima(BotY, LocMin) do
  begin
    Lb := LocMin.LeftBound;
    Rb := LocMin.RightBound;
    Op1 := nil;
    if not assigned(Lb) then
    begin
      InsertEdgeIntoAEL(Rb, nil);
      SetWindingCount(Rb);
      if IsContributing(Rb) then
        Op1 := AddOutPt(Rb, Rb.Bot);
    end
    else if not assigned(Rb) then
    begin
      InsertEdgeIntoAEL(Lb, nil);
      SetWindingCount(Lb);
      if IsContributing(Lb) then
        Op1 := AddOutPt(Lb, Lb.Bot);
      InsertScanbeam(Lb.Top.Y);
    end else
    begin
      InsertEdgeIntoAEL(Lb, nil);
      InsertEdgeIntoAEL(Rb, Lb);
      SetWindingCount(Lb);
      Rb.WindCnt := Lb.WindCnt;
      Rb.WindCnt2 := Lb.WindCnt2;
      if IsContributing(Lb) then
        Op1 := AddLocalMinPoly(Lb, Rb, Lb.Bot);
      InsertScanbeam(Lb.Top.Y);
    end;

    if Assigned(Rb) then
    begin
      if (Rb.Dx = Horizontal) then
      begin
        AddEdgeToSEL(Rb);
        if assigned(Rb.NextInLML) then
          InsertScanbeam(Rb.NextInLML.Top.Y);
      end else
        InsertScanbeam(Rb.Top.Y);
    end;

    if not assigned(Lb) or not assigned(Rb) then Continue;

    //if output polygons share an Edge with rb, they'll need joining later ...
    if assigned(Op1) and (Rb.Dx = Horizontal) and
      (FGhostJoinList.Count > 0) and (Rb.WindDelta <> 0) then
    begin
      for I := 0 to FGhostJoinList.Count -1 do
      begin
        //if the horizontal Rb and a 'ghost' horizontal overlap, then convert
        //the 'ghost' join to a real join ready for later ...
        Jr := PJoin(FGhostJoinList[I]);
        if HorzSegmentsOverlap(Jr.OutPt1.Pt.X, Jr.OffPt.X,
          Rb.Bot.X, Rb.Top.X) then
            AddJoin(Jr.OutPt1, Op1, Jr.OffPt);
      end;
    end;

    if (Lb.OutIdx >= 0) and assigned(Lb.PrevInAEL) and
      (Lb.PrevInAEL.Curr.X = Lb.Bot.X) and
      (Lb.PrevInAEL.OutIdx >= 0) and
      SlopesEqual(Lb.PrevInAEL.Curr, Lb.PrevInAEL.Top,
      Lb.Curr, Lb.Top, FUse64BitRange) and
      (Lb.WindDelta <> 0) and (Lb.PrevInAEL.WindDelta <> 0) then
    begin
        Op2 := AddOutPt(Lb.PrevInAEL, Lb.Bot);
        AddJoin(Op1, Op2, Lb.Top);
    end;

    if (Lb.NextInAEL <> Rb) then
    begin
      if (Rb.OutIdx >= 0) and (Rb.PrevInAEL.OutIdx >= 0) and
        SlopesEqual(Rb.PrevInAEL.Curr, Rb.PrevInAEL.Top,
        Rb.Curr, Rb.Top, FUse64BitRange) and
        (Rb.WindDelta <> 0) and (Rb.PrevInAEL.WindDelta <> 0) then
      begin
          Op2 := AddOutPt(Rb.PrevInAEL, Rb.Bot);
          AddJoin(Op1, Op2, Rb.Top);
      end;

      E := Lb.NextInAEL;
      if Assigned(E) then
        while (E <> Rb) do
        begin
          //nb: For calculating winding counts etc, IntersectEdges() assumes
          //that param1 will be to the right of param2 ABOVE the intersection ...
          IntersectEdges(Rb, E, Lb.Curr);
          E := E.NextInAEL;
        end;
    end;
  end;
end;
//------------------------------------------------------------------------------

procedure TClipper.IntersectEdges(E1,E2: PEdge; Pt: TIntPoint);
var
  E1Contributing, E2contributing: Boolean;
  E1FillType, E2FillType, E1FillType2, E2FillType2: TPolyFillType;
  E1Wc, E2Wc, E1Wc2, E2Wc2: Integer;
begin
  {IntersectEdges}
  //E1 will be to the left of E2 BELOW the intersection. Therefore E1 is before
  //E2 in AEL except when E1 is being inserted at the intersection point ...

  E1Contributing := (E1.OutIdx >= 0);
  E2contributing := (E2.OutIdx >= 0);

{$IFDEF use_xyz}
        SetZ(Pt, E1, E2, FZFillCallback);
{$ENDIF}

{$IFDEF use_lines}
  //if either edge is on an OPEN path ...
  if (E1.WindDelta = 0) or (E2.WindDelta = 0) then
  begin
    //ignore subject-subject open path intersections ...
    if (E1.WindDelta = 0) AND (E2.WindDelta = 0) then Exit
    //if intersecting a subj line with a subj poly ...
    else if (E1.PolyType = E2.PolyType) and
      (E1.WindDelta <> E2.WindDelta) and (FClipType = ctUnion) then
    begin
      if (E1.WindDelta = 0) then
      begin
        if (E2Contributing) then
        begin
          AddOutPt(E1, pt);
          if (E1Contributing) then E1.OutIdx := Unassigned;
        end;
      end else
      begin
        if (E1Contributing) then
        begin
          AddOutPt(E2, pt);
          if (E2Contributing) then E2.OutIdx := Unassigned;
        end;
      end;
    end
    else if (E1.PolyType <> E2.PolyType) then
    begin
      //toggle subj open path OutIdx on/off when Abs(clip.WndCnt) = 1 ...
      if (E1.WindDelta = 0) and (Abs(E2.WindCnt) = 1) and
       ((FClipType <> ctUnion) or (E2.WindCnt2 = 0)) then
      begin
        AddOutPt(E1, Pt);
        if E1Contributing then E1.OutIdx := Unassigned;
      end
      else if (E2.WindDelta = 0) and (Abs(E1.WindCnt) = 1) and
       ((FClipType <> ctUnion) or (E1.WindCnt2 = 0)) then
      begin
        AddOutPt(E2, Pt);
        if E2Contributing then E2.OutIdx := Unassigned;
      end
    end;
    Exit;
  end;
{$ENDIF}

  //update winding counts...
  //assumes that E1 will be to the right of E2 ABOVE the intersection
  if E1.PolyType = E2.PolyType then
  begin
    if IsEvenOddFillType(E1) then
    begin
      E1Wc := E1.WindCnt;
      E1.WindCnt := E2.WindCnt;
      E2.WindCnt := E1Wc;
    end else
    begin
      if E1.WindCnt + E2.WindDelta = 0 then
        E1.WindCnt := -E1.WindCnt else
        Inc(E1.WindCnt, E2.WindDelta);
      if E2.WindCnt - E1.WindDelta = 0 then
        E2.WindCnt := -E2.WindCnt else
        Dec(E2.WindCnt, E1.WindDelta);
    end;
  end else
  begin
    if not IsEvenOddFillType(E2) then Inc(E1.WindCnt2, E2.WindDelta)
    else if E1.WindCnt2 = 0 then E1.WindCnt2 := 1
    else E1.WindCnt2 := 0;

    if not IsEvenOddFillType(E1) then Dec(E2.WindCnt2, E1.WindDelta)
    else if E2.WindCnt2 = 0 then E2.WindCnt2 := 1
    else E2.WindCnt2 := 0;
  end;

  if E1.PolyType = ptSubject then
  begin
    E1FillType := FSubjFillType;
    E1FillType2 := FClipFillType;
  end else
  begin
    E1FillType := FClipFillType;
    E1FillType2 := FSubjFillType;
  end;
  if E2.PolyType = ptSubject then
  begin
    E2FillType := FSubjFillType;
    E2FillType2 := FClipFillType;
  end else
  begin
    E2FillType := FClipFillType;
    E2FillType2 := FSubjFillType;
  end;

  case E1FillType of
    pftPositive: E1Wc := E1.WindCnt;
    pftNegative : E1Wc := -E1.WindCnt;
    else E1Wc := abs(E1.WindCnt);
  end;
  case E2FillType of
    pftPositive: E2Wc := E2.WindCnt;
    pftNegative : E2Wc := -E2.WindCnt;
    else E2Wc := abs(E2.WindCnt);
  end;

  if E1Contributing and E2contributing then
  begin
    if not (E1Wc in [0,1]) or not (E2Wc in [0,1]) or
      ((E1.PolyType <> E2.PolyType) and (fClipType <> ctXor)) then
    begin
        AddLocalMaxPoly(E1, E2, Pt);
    end else
    begin
      AddOutPt(E1, Pt);
      AddOutPt(E2, Pt);
      SwapSides(E1, E2);
      SwapPolyIndexes(E1, E2);
    end;
  end else if E1Contributing then
  begin
    if (E2Wc = 0) or (E2Wc = 1) then
    begin
      AddOutPt(E1, Pt);
      SwapSides(E1, E2);
      SwapPolyIndexes(E1, E2);
    end;
  end
  else if E2contributing then
  begin
    if (E1Wc = 0) or (E1Wc = 1) then
    begin
      AddOutPt(E2, Pt);
      SwapSides(E1, E2);
      SwapPolyIndexes(E1, E2);
    end;
  end
  else if  ((E1Wc = 0) or (E1Wc = 1)) and ((E2Wc = 0) or (E2Wc = 1)) then
  begin
    //neither Edge is currently contributing ...

    case E1FillType2 of
      pftPositive: E1Wc2 := E1.WindCnt2;
      pftNegative : E1Wc2 := -E1.WindCnt2;
      else E1Wc2 := abs(E1.WindCnt2);
    end;
    case E2FillType2 of
      pftPositive: E2Wc2 := E2.WindCnt2;
      pftNegative : E2Wc2 := -E2.WindCnt2;
      else E2Wc2 := abs(E2.WindCnt2);
    end;

    if (E1.PolyType <> E2.PolyType) then
    begin
      AddLocalMinPoly(E1, E2, Pt);
    end
    else if (E1Wc = 1) and (E2Wc = 1) then
      case FClipType of
        ctIntersection:
          if (E1Wc2 > 0) and (E2Wc2 > 0) then
            AddLocalMinPoly(E1, E2, Pt);
        ctUnion:
          if (E1Wc2 <= 0) and (E2Wc2 <= 0) then
            AddLocalMinPoly(E1, E2, Pt);
        ctDifference:
          if ((E1.PolyType = ptClip) and (E1Wc2 > 0) and (E2Wc2 > 0)) or
            ((E1.PolyType = ptSubject) and (E1Wc2 <= 0) and (E2Wc2 <= 0)) then
              AddLocalMinPoly(E1, E2, Pt);
        ctXor:
          AddLocalMinPoly(E1, E2, Pt);
      end
    else
      swapsides(E1,E2);
  end;
end;
//------------------------------------------------------------------------------

function FirstParamIsBottomPt(btmPt1, btmPt2: POutPt): Boolean;
var
  Dx1n, Dx1p, Dx2n, Dx2p: Double;
  P: POutPt;
begin
  //Precondition: bottom-points share the same vertex.
  //Use inverse slopes of adjacent edges (ie dx/dy) to determine the outer
  //polygon and hence the 'real' bottompoint.
  //nb: Slope is vertical when dx == 0. If the greater abs(dx) of param1
  //is greater than or equal both abs(dx) in param2 then param1 is outer.
  P := btmPt1.Prev;
  while PointsEqual(P.Pt, btmPt1.Pt) and (P <> btmPt1) do P := P.Prev;
  Dx1p := abs(GetDx(btmPt1.Pt, P.Pt));
  P := btmPt1.Next;
  while PointsEqual(P.Pt, btmPt1.Pt) and (P <> btmPt1) do P := P.Next;
  Dx1n := abs(GetDx(btmPt1.Pt, P.Pt));

  P := btmPt2.Prev;
  while PointsEqual(P.Pt, btmPt2.Pt) and (P <> btmPt2) do P := P.Prev;
  Dx2p := abs(GetDx(btmPt2.Pt, P.Pt));
  P := btmPt2.Next;
  while PointsEqual(P.Pt, btmPt2.Pt) and (P <> btmPt2) do P := P.Next;
  Dx2n := abs(GetDx(btmPt2.Pt, P.Pt));
  if (Max(Dx1p, Dx1n) = Max(Dx2p, Dx2n)) and
    (Min(Dx1p, Dx1n) = Min(Dx2p, Dx2n)) then
      Result := Area(btmPt1) > 0 //if otherwise identical use orientation
  else
    Result := ((Dx1p >= Dx2p) and (Dx1p >= Dx2n)) or
      ((Dx1n >= Dx2p) and (Dx1n >= Dx2n));
end;
//------------------------------------------------------------------------------

function GetBottomPt(PP: POutPt): POutPt;
var
  P, Dups: POutPt;
begin
  Dups := nil;
  P := PP.Next;
  while P <> PP do
  begin
    if P.Pt.Y > PP.Pt.Y then
    begin
      PP := P;
      Dups := nil;
    end
    else if (P.Pt.Y = PP.Pt.Y) and (P.Pt.X <= PP.Pt.X) then
    begin
      if (P.Pt.X < PP.Pt.X) then
      begin
        Dups := nil;
        PP := P;
      end else
      begin
        if (P.Next <> PP) and (P.Prev <> PP) then Dups := P;
      end;
    end;
    P := P.Next;
  end;
  if Assigned(Dups) then
  begin
    //there appears to be at least 2 vertices at bottom-most point so ...
    while Dups <> P do
    begin
      if not FirstParamIsBottomPt(P, Dups) then PP := Dups;
      Dups := Dups.Next;
      while not PointsEqual(Dups.Pt, PP.Pt) do Dups := Dups.Next;
    end;
  end;
  Result := PP;
end;
//------------------------------------------------------------------------------

procedure TClipper.SetHoleState(E: PEdge; OutRec: POutRec);
var
  E2, eTmp: PEdge;
begin
  //E.FirstLeft is the parent/container OutRec of E if any, and is the first
  //unpaired OutRec to the left in AEL. (Paired OutRecs will either be a
  //sibling of E or a sibling of one of its 'parents'.)
  eTmp := nil;
  E2 := E.PrevInAEL;
  while Assigned(E2) do
  begin
    if (E2.OutIdx >= 0) and (E2.WindDelta <> 0) then
    begin
      if not assigned(eTmp) then
        eTmp := E2
      else if (eTmp.OutIdx = E2.OutIdx) then
        eTmp := nil; //paired
    end;
    E2 := E2.PrevInAEL;
  end;
  if assigned(eTmp) then
  begin
    OutRec.FirstLeft := POutRec(fPolyOutList[eTmp.OutIdx]);
    OutRec.IsHole := not OutRec.FirstLeft.IsHole;
  end else
  begin
    OutRec.FirstLeft := nil;
    OutRec.IsHole := False;
  end;
end;
//------------------------------------------------------------------------------

function GetLowermostRec(OutRec1, OutRec2: POutRec): POutRec;
var
  OutPt1, OutPt2: POutPt;
begin
  if not assigned(OutRec1.BottomPt) then
    OutRec1.BottomPt := GetBottomPt(OutRec1.Pts);
  if not assigned(OutRec2.BottomPt) then
    OutRec2.BottomPt := GetBottomPt(OutRec2.Pts);
  OutPt1 := OutRec1.BottomPt;
  OutPt2 := OutRec2.BottomPt;
  if (OutPt1.Pt.Y > OutPt2.Pt.Y) then Result := OutRec1
  else if (OutPt1.Pt.Y < OutPt2.Pt.Y) then Result := OutRec2
  else if (OutPt1.Pt.X < OutPt2.Pt.X) then Result := OutRec1
  else if (OutPt1.Pt.X > OutPt2.Pt.X) then Result := OutRec2
  else if (OutPt1.Next = OutPt1) then Result := OutRec2
  else if (OutPt2.Next = OutPt2) then Result := OutRec1
  else if FirstParamIsBottomPt(OutPt1, OutPt2) then Result := OutRec1
  else Result := OutRec2;
end;
//------------------------------------------------------------------------------

function OutRec1RightOfOutRec2(OutRec1, OutRec2: POutRec): Boolean;
begin
  Result := True;
  repeat
    OutRec1 := OutRec1.FirstLeft;
    if OutRec1 = OutRec2 then Exit;
  until not Assigned(OutRec1);
  Result := False;
end;
//------------------------------------------------------------------------------

function TClipper.GetOutRec(Idx: integer): POutRec;
begin
  Result := FPolyOutList[Idx];
  while Result <> FPolyOutList[Result.Idx] do
    Result := FPolyOutList[Result.Idx];
end;
//------------------------------------------------------------------------------

procedure TClipper.AppendPolygon(E1, E2: PEdge);
var
  HoleStateRec, OutRec1, OutRec2: POutRec;
  P1_lft, P1_rt, P2_lft, P2_rt: POutPt;
  OKIdx, ObsoleteIdx: Integer;
  E: PEdge;
begin
  OutRec1 := FPolyOutList[E1.OutIdx];
  OutRec2 := FPolyOutList[E2.OutIdx];

  //First work out which polygon fragment has the correct hole state.
  //Since we're working from the bottom upward and left to right, the left most
  //and lowermost polygon is outermost and must have the correct hole state ...
  if OutRec1RightOfOutRec2(OutRec1, OutRec2) then HoleStateRec := OutRec2
  else if OutRec1RightOfOutRec2(OutRec2, OutRec1) then HoleStateRec := OutRec1
  else HoleStateRec := GetLowermostRec(OutRec1, OutRec2);

  //get the start and ends of both output polygons and
  //join E2 poly onto E1 poly and delete pointers to E2 ...

  P1_lft := OutRec1.Pts;
  P2_lft := OutRec2.Pts;
  P1_rt := P1_lft.Prev;
  P2_rt := P2_lft.Prev;

  if E1.Side = esLeft then
  begin
    if E2.Side = esLeft then
    begin
      //z y x a b c
      ReversePolyPtLinks(P2_lft);
      P2_lft.Next := P1_lft;
      P1_lft.Prev := P2_lft;
      P1_rt.Next := P2_rt;
      P2_rt.Prev := P1_rt;
      OutRec1.Pts := P2_rt;
    end else
    begin
      //x y z a b c
      P2_rt.Next := P1_lft;
      P1_lft.Prev := P2_rt;
      P2_lft.Prev := P1_rt;
      P1_rt.Next := P2_lft;
      OutRec1.Pts := P2_lft;
    end;
  end else
  begin
    if E2.Side = esRight then
    begin
      //a b c z y x
      ReversePolyPtLinks(P2_lft);
      P1_rt.Next := P2_rt;
      P2_rt.Prev := P1_rt;
      P2_lft.Next := P1_lft;
      P1_lft.Prev := P2_lft;
    end else
    begin
      //a b c x y z
      P1_rt.Next := P2_lft;
      P2_lft.Prev := P1_rt;
      P1_lft.Prev := P2_rt;
      P2_rt.Next := P1_lft;
    end;
  end;

  OutRec1.BottomPt := nil;
  if HoleStateRec = OutRec2 then
  begin
    if OutRec2.FirstLeft <> OutRec1 then
      OutRec1.FirstLeft := OutRec2.FirstLeft;
    OutRec1.IsHole := OutRec2.IsHole;
  end;

  OutRec2.Pts := nil;
  OutRec2.BottomPt := nil;
  OutRec2.FirstLeft := OutRec1;

  OKIdx := OutRec1.Idx;
  ObsoleteIdx := OutRec2.Idx;

  E1.OutIdx := Unassigned; //safe because we only get here via AddLocalMaxPoly
  E2.OutIdx := Unassigned;

  E := FActiveEdges;
  while Assigned(E) do
  begin
    if (E.OutIdx = ObsoleteIdx) then
    begin
      E.OutIdx := OKIdx;
      E.Side := E1.Side;
      Break;
    end;
    E := E.NextInAEL;
  end;

  OutRec2.Idx := OutRec1.Idx;
end;
//------------------------------------------------------------------------------

function TClipper.GetLastOutPt(E: PEdge): POutPt;
var
  OutRec: POutRec;
begin
  OutRec := FPolyOutList[E.OutIdx];
  if E.Side = esLeft then
    Result := OutRec.Pts else
    Result := OutRec.Pts.Prev;
end;
//------------------------------------------------------------------------------

procedure TClipper.ProcessHorizontals;
var
  E: PEdge;
begin
  while PopEdgeFromSEL(E) do
    ProcessHorizontal(E);
end;
//------------------------------------------------------------------------------

function IsMinima(E: PEdge): Boolean; {$IFDEF INLINING} inline; {$ENDIF}
begin
  Result := Assigned(E) and (E.Prev.NextInLML <> E) and (E.Next.NextInLML <> E);
end;
//------------------------------------------------------------------------------

function IsMaxima(E: PEdge; const Y: cInt): Boolean;
{$IFDEF INLINING} inline; {$ENDIF}
begin
  Result := Assigned(E) and (E.Top.Y = Y) and not Assigned(E.NextInLML);
end;
//------------------------------------------------------------------------------

function IsIntermediate(E: PEdge; const Y: cInt): Boolean;
{$IFDEF INLINING} inline; {$ENDIF}
begin
  Result := (E.Top.Y = Y) and Assigned(E.NextInLML);
end;
//------------------------------------------------------------------------------

function GetMaximaPair(E: PEdge): PEdge;
begin
  if PointsEqual(E.Next.Top, E.Top) and not assigned(E.Next.NextInLML) then
    Result := E.Next
  else if PointsEqual(E.Prev.Top, E.Top) and not assigned(E.Prev.NextInLML) then
    Result := E.Prev
  else
    Result := nil;
end;
//------------------------------------------------------------------------------

function GetMaximaPairEx(E: PEdge): PEdge;
begin
  //as above but returns nil if MaxPair isn't in AEL (unless it's horizontal)
  Result := GetMaximaPair(E);
  if not assigned(Result) or (Result.OutIdx = Skip) or
    ((Result.NextInAEL = Result.PrevInAEL) and not IsHorizontal(Result)) then
      Result := nil;
end;
//------------------------------------------------------------------------------

procedure TClipper.SwapPositionsInSEL(E1, E2: PEdge);
var
  Prev,Next: PEdge;
begin
  if E1.NextInSEL = E2 then
  begin
    Next    := E2.NextInSEL;
    if Assigned(Next) then Next.PrevInSEL := E1;
    Prev    := E1.PrevInSEL;
    if Assigned(Prev) then Prev.NextInSEL := E2;
    E2.PrevInSEL := Prev;
    E2.NextInSEL := E1;
    E1.PrevInSEL := E2;
    E1.NextInSEL := Next;
  end
  else if E2.NextInSEL = E1 then
  begin
    Next    := E1.NextInSEL;
    if Assigned(Next) then Next.PrevInSEL := E2;
    Prev    := E2.PrevInSEL;
    if Assigned(Prev) then Prev.NextInSEL := E1;
    E1.PrevInSEL := Prev;
    E1.NextInSEL := E2;
    E2.PrevInSEL := E1;
    E2.NextInSEL := Next;
  end else
  begin
    Next    := E1.NextInSEL;
    Prev    := E1.PrevInSEL;
    E1.NextInSEL := E2.NextInSEL;
    if Assigned(E1.NextInSEL) then E1.NextInSEL.PrevInSEL := E1;
    E1.PrevInSEL := E2.PrevInSEL;
    if Assigned(E1.PrevInSEL) then E1.PrevInSEL.NextInSEL := E1;
    E2.NextInSEL := Next;
    if Assigned(E2.NextInSEL) then E2.NextInSEL.PrevInSEL := E2;
    E2.PrevInSEL := Prev;
    if Assigned(E2.PrevInSEL) then E2.PrevInSEL.NextInSEL := E2;
  end;
  if not Assigned(E1.PrevInSEL) then FSortedEdges := E1
  else if not Assigned(E2.PrevInSEL) then FSortedEdges := E2;
end;
//------------------------------------------------------------------------------

function GetNextInAEL(E: PEdge; Direction: TDirection): PEdge;
  {$IFDEF INLINING} inline; {$ENDIF}
begin
  if Direction = dLeftToRight then
    Result := E.NextInAEL else
    Result := E.PrevInAEL;
end;
//------------------------------------------------------------------------

procedure GetHorzDirection(HorzEdge: PEdge; out Dir: TDirection;
  out Left, Right: cInt); {$IFDEF INLINING} inline; {$ENDIF}
begin
  if HorzEdge.Bot.X < HorzEdge.Top.X then
  begin
    Left := HorzEdge.Bot.X;
    Right := HorzEdge.Top.X;
    Dir := dLeftToRight;
  end else
  begin
    Left := HorzEdge.Top.X;
    Right := HorzEdge.Bot.X;
    Dir := dRightToLeft;
  end;
end;
//------------------------------------------------------------------------

procedure TClipper.ProcessHorizontal(HorzEdge: PEdge);
var
  E, eNext, eNextHorz, ePrev, eMaxPair, eLastHorz: PEdge;
  HorzLeft, HorzRight: cInt;
  Direction: TDirection;
  Pt: TIntPoint;
  Op1, Op2: POutPt;
  IsLastHorz, IsOpen: Boolean;
  currMax: PMaxima;
begin
(*******************************************************************************
* Notes: Horizontal edges (HEs) at scanline intersections (ie at the top or    *
* bottom of a scanbeam) are processed as if layered. The order in which HEs    *
* are processed doesn't matter. HEs intersect with other HE Bot.Xs only [#]    *
* (or they could intersect with Top.Xs only, ie EITHER Bot.Xs OR Top.Xs),      *
* and with other non-horizontal edges [*]. Once these intersections are        *
* processed, intermediate HEs then 'promote' the Edge above (NextInLML) into   *
* the AEL. These 'promoted' edges may in turn intersect [%] with other HEs.    *
*******************************************************************************)

(*******************************************************************************
*           \   nb: HE processing order doesn't matter         /          /    *
*            \                                                /          /     *
* { --------  \  -------------------  /  \  - (3) o==========%==========o  - } *
* {            o==========o (2)      /    \       .          .               } *
* {                       .         /      \      .          .               } *
* { ----  o===============#========*========*=====#==========o  (1)  ------- } *
*        /                 \      /          \   /                             *
*******************************************************************************)

  GetHorzDirection(HorzEdge, Direction, HorzLeft, HorzRight);
  IsOpen := (HorzEdge.WindDelta = 0);

  eLastHorz := HorzEdge;
  while Assigned(eLastHorz.NextInLML) and
    (eLastHorz.NextInLML.Dx = Horizontal) do
      eLastHorz := eLastHorz.NextInLML;
  if Assigned(eLastHorz.NextInLML) then
    eMaxPair := nil else
    eMaxPair := GetMaximaPair(eLastHorz);

  Op1 := nil;
  currMax := FMaxima;
  //nb: FMaxima will only be assigned when the Simplify property is set true.

  if assigned(currMax) then
  begin
    //get the first useful Maxima ...
    if (Direction = dLeftToRight) then
    begin
      while Assigned(currMax) and (currMax.X <= HorzEdge.Bot.X) do
        currMax := currMax.Next;
      if Assigned(currMax) and (currMax.X >= eLastHorz.Top.X) then
        currMax := nil;
    end else
    begin
      while Assigned(currMax.Next) and (currMax.Next.X < HorzEdge.Bot.X) do
        currMax := currMax.Next;
      if (currMax.X <= eLastHorz.Top.X) then currMax := nil;
    end;
  end;

  while true do //loops through consec. horizontal edges
  begin
    IsLastHorz := (HorzEdge = eLastHorz);
    E := GetNextInAEL(HorzEdge, Direction);
    while Assigned(E) do
    begin

      //this code block inserts extra coords into horizontal edges (in output
      //polygons) whereever maxima touch these horizontal edges. This helps
      //'simplifying' polygons (ie if the Simplify property is set).
      if assigned(currMax) then
      begin
        if (Direction = dLeftToRight) then
        begin
          while assigned(currMax) and (currMax.X < E.Curr.X) do
          begin
            if (HorzEdge.OutIdx >= 0) and not IsOpen then
              AddOutPt(HorzEdge, IntPoint(currMax.X, HorzEdge.Bot.Y));
            currMax := currMax.Next;
          end;
        end else
        begin
          while assigned(currMax) and (currMax.X > E.Curr.X) do
          begin
            if (HorzEdge.OutIdx >= 0) and not IsOpen then
              AddOutPt(HorzEdge, IntPoint(currMax.X, HorzEdge.Bot.Y));
            currMax := currMax.Prev;
          end;
        end;
      end;

      if ((Direction = dLeftToRight) and (E.Curr.X > HorzRight)) or
        ((Direction = dRightToLeft) and (E.Curr.X < HorzLeft)) then
          Break;

      //also break if we've got to the end of an intermediate horizontal edge
      //nb: Smaller Dx's are to the right of larger Dx's ABOVE the horizontal.
      if (E.Curr.X = HorzEdge.Top.X) and
        Assigned(HorzEdge.NextInLML) and (E.Dx < HorzEdge.NextInLML.Dx) then
          Break;

      if (HorzEdge.OutIdx >= 0) and not IsOpen then //may be done multiple times
      begin
{$IFDEF use_xyz}
      if (Direction = dLeftToRight) then SetZ(E.Curr, HorzEdge, E, FZFillCallback)
      else SetZ(E.Curr, E, HorzEdge, FZFillCallback);
{$ENDIF}
        Op1 := AddOutPt(HorzEdge, E.Curr);
        eNextHorz := FSortedEdges;
        while Assigned(eNextHorz) do
        begin
          if (eNextHorz.OutIdx >= 0) and
            HorzSegmentsOverlap(HorzEdge.Bot.X,
            HorzEdge.Top.X, eNextHorz.Bot.X, eNextHorz.Top.X) then
          begin
            Op2 := GetLastOutPt(eNextHorz);
            AddJoin(Op2, Op1, eNextHorz.Top);
          end;
          eNextHorz := eNextHorz.NextInSEL;
        end;
        AddGhostJoin(Op1, HorzEdge.Bot);
      end;

      //OK, so far we're still in range of the horizontal Edge  but make sure
      //we're at the last of consec. horizontals when matching with eMaxPair
      if (E = eMaxPair) and IsLastHorz then
      begin
        if HorzEdge.OutIdx >= 0 then
          AddLocalMaxPoly(HorzEdge, eMaxPair, HorzEdge.Top);
        deleteFromAEL(HorzEdge);
        deleteFromAEL(eMaxPair);
        Exit;
      end;

      if (Direction = dLeftToRight) then
      begin
        Pt := IntPoint(E.Curr.X, HorzEdge.Curr.Y);
        IntersectEdges(HorzEdge, E, Pt);
      end else
      begin
        Pt := IntPoint(E.Curr.X, HorzEdge.Curr.Y);
        IntersectEdges(E, HorzEdge, Pt);
      end;
      eNext := GetNextInAEL(E, Direction);
      SwapPositionsInAEL(HorzEdge, E);
      E := eNext;
    end;

    //Break out of loop if HorzEdge.NextInLML is not also horizontal ...
    if not Assigned(HorzEdge.NextInLML) or
      (HorzEdge.NextInLML.Dx <> Horizontal) then Break;

    UpdateEdgeIntoAEL(HorzEdge);
    if (HorzEdge.OutIdx >= 0) then AddOutPt(HorzEdge, HorzEdge.Bot);
    GetHorzDirection(HorzEdge, Direction, HorzLeft, HorzRight);
  end;

  if (HorzEdge.OutIdx >= 0) and not Assigned(Op1) then
  begin
    Op1 := GetLastOutPt(HorzEdge);
    eNextHorz := FSortedEdges;
    while Assigned(eNextHorz) do
    begin
      if (eNextHorz.OutIdx >= 0) and
        HorzSegmentsOverlap(HorzEdge.Bot.X,
        HorzEdge.Top.X, eNextHorz.Bot.X, eNextHorz.Top.X) then
      begin
        Op2 := GetLastOutPt(eNextHorz);
        AddJoin(Op2, Op1, eNextHorz.Top);
      end;
      eNextHorz := eNextHorz.NextInSEL;
    end;
    AddGhostJoin(Op1, HorzEdge.Top);
  end;

  if Assigned(HorzEdge.NextInLML) then
  begin
    if (HorzEdge.OutIdx >= 0) then
    begin
      Op1 := AddOutPt(HorzEdge, HorzEdge.Top);

      UpdateEdgeIntoAEL(HorzEdge);
      if (HorzEdge.WindDelta = 0) then Exit;
      //nb: HorzEdge is no longer horizontal here
      ePrev := HorzEdge.PrevInAEL;
      eNext := HorzEdge.NextInAEL;
      if Assigned(ePrev) and (ePrev.Curr.X = HorzEdge.Bot.X) and
        (ePrev.Curr.Y = HorzEdge.Bot.Y) and (ePrev.WindDelta <> 0) and
        (ePrev.OutIdx >= 0) and (ePrev.Curr.Y > ePrev.Top.Y) and
        SlopesEqual(HorzEdge, ePrev, FUse64BitRange) then
      begin
        Op2 := AddOutPt(ePrev, HorzEdge.Bot);
        AddJoin(Op1, Op2, HorzEdge.Top);
      end
      else if Assigned(eNext) and (eNext.Curr.X = HorzEdge.Bot.X) and
        (eNext.Curr.Y = HorzEdge.Bot.Y) and (eNext.WindDelta <> 0) and
          (eNext.OutIdx >= 0) and (eNext.Curr.Y > eNext.Top.Y) and
        SlopesEqual(HorzEdge, eNext, FUse64BitRange) then
      begin
        Op2 := AddOutPt(eNext, HorzEdge.Bot);
        AddJoin(Op1, Op2, HorzEdge.Top);
      end;
    end else
      UpdateEdgeIntoAEL(HorzEdge);
  end else
  begin
    if (HorzEdge.OutIdx >= 0) then AddOutPt(HorzEdge, HorzEdge.Top);
    DeleteFromAEL(HorzEdge);
  end;
end;
//------------------------------------------------------------------------------

function TClipper.ProcessIntersections(const TopY: cInt): Boolean;
begin
  Result := True;
  try
    BuildIntersectList(TopY);
    if (FIntersectList.Count = 0) then
      Exit
    else if FixupIntersectionOrder then
      ProcessIntersectList()
    else
      Result := False;
  finally
    DisposeIntersectNodes; //clean up if there's been an error
    FSortedEdges := nil;
  end;
end;
//------------------------------------------------------------------------------

procedure TClipper.DisposeIntersectNodes;
var
  I: Integer;
begin
  for I := 0 to FIntersectList.Count - 1 do
    Dispose(PIntersectNode(FIntersectList[I]));
  FIntersectList.Clear;
end;
//------------------------------------------------------------------------------

procedure TClipper.BuildIntersectList(const TopY: cInt);
var
  E, eNext: PEdge;
  Pt: TIntPoint;
  IsModified: Boolean;
  NewNode: PIntersectNode;
begin
  if not Assigned(fActiveEdges) then Exit;

  //prepare for sorting ...
  E := FActiveEdges;
  FSortedEdges := E;
  while Assigned(E) do
  begin
    E.PrevInSEL := E.PrevInAEL;
    E.NextInSEL := E.NextInAEL;
    E.Curr.X := TopX(E, TopY);
    E := E.NextInAEL;
  end;

  //bubblesort (because adjacent swaps are required) ...
  repeat
    IsModified := False;
    E := FSortedEdges;
    while Assigned(E.NextInSEL) do
    begin
      eNext := E.NextInSEL;
      if (E.Curr.X > eNext.Curr.X) then
      begin
        IntersectPointEx(E, eNext, Pt);
        if Pt.Y < TopY then
          Pt := IntPoint(TopX(E, TopY), TopY);
        new(NewNode);
        NewNode.Edge1 := E;
        NewNode.Edge2 := eNext;
        NewNode.Pt := Pt;
        FIntersectList.Add(NewNode);

        SwapPositionsInSEL(E, eNext);
        IsModified := True;
      end else
        E := eNext;
    end;
    if Assigned(E.PrevInSEL) then
      E.PrevInSEL.NextInSEL := nil
    else Break;
  until not IsModified;
end;
//------------------------------------------------------------------------------

procedure TClipper.ProcessIntersectList;
var
  I: Integer;
begin
  for I := 0 to FIntersectList.Count - 1 do
  begin
    with PIntersectNode(FIntersectList[I])^ do
    begin
      IntersectEdges(Edge1, Edge2, Pt);
      SwapPositionsInAEL(Edge1, Edge2);
    end;
    dispose(PIntersectNode(FIntersectList[I]));
  end;
  FIntersectList.Clear;
end;
//------------------------------------------------------------------------------

procedure TClipper.DoMaxima(E: PEdge);
var
  ENext, EMaxPair: PEdge;
begin
  EMaxPair := GetMaximaPairEx(E);
  if not assigned(EMaxPair) then
  begin
    if E.OutIdx >= 0 then
      AddOutPt(E, E.Top);
    DeleteFromAEL(E);
    Exit;
  end;

  ENext := E.NextInAEL;
  //rarely, with overlapping collinear edges (in open paths) ENext can be nil
  while Assigned(ENext) and (ENext <> EMaxPair) do
  begin
    IntersectEdges(E, ENext, E.Top);
    SwapPositionsInAEL(E, ENext);
    ENext := E.NextInAEL;
  end;

  if (E.OutIdx = Unassigned) and (EMaxPair.OutIdx = Unassigned) then
  begin
    DeleteFromAEL(E);
    DeleteFromAEL(EMaxPair);
  end
  else if (E.OutIdx >= 0) and (EMaxPair.OutIdx >= 0) then
  begin
    if E.OutIdx >= 0 then
      AddLocalMaxPoly(E, EMaxPair, E.Top);
    deleteFromAEL(E);
    deleteFromAEL(eMaxPair);
  end
{$IFDEF use_lines}
  else if E.WindDelta = 0 then
  begin
    if (E.OutIdx >= 0) then
    begin
      AddOutPt(E, E.Top);
      E.OutIdx := Unassigned;
    end;
    DeleteFromAEL(E);

    if (EMaxPair.OutIdx >= 0) then
    begin
      AddOutPt(EMaxPair, E.Top);
      EMaxPair.OutIdx := Unassigned;
    end;
    DeleteFromAEL(EMaxPair);
  end
{$ENDIF}
  else
    raise exception.Create(rsDoMaxima);
end;
//------------------------------------------------------------------------------

procedure TClipper.ProcessEdgesAtTopOfScanbeam(const TopY: cInt);
var
  E, EMaxPair, ePrev, eNext: PEdge;
  Op, Op2: POutPt;
  IsMaximaEdge: Boolean;
  Pt: TIntPoint;
begin
(*******************************************************************************
* Notes: Processing edges at scanline intersections (ie at the top or bottom   *
* of a scanbeam) needs to be done in multiple stages and in the correct order. *
* Firstly, edges forming a 'maxima' need to be processed and then removed.     *
* Next, 'intermediate' and 'maxima' horizontal edges are processed. Then edges *
* that intersect exactly at the top of the scanbeam are processed [%].         *
* Finally, new minima are added and any intersects they create are processed.  *
*******************************************************************************)

(*******************************************************************************
*     \                          /    /          \   /                         *
*      \   Horizontal minima    /    /            \ /                          *
* { --  o======================#====o   --------   .     ------------------- } *
* {       Horizontal maxima    .                   %  scanline intersect     } *
* { -- o=======================#===================#========o     ---------- } *
*      |                      /                   / \        \                 *
*      + maxima intersect    /                   /   \        \                *
*     /|\                   /                   /     \        \               *
*    / | \                 /                   /       \        \              *
*******************************************************************************)

  E := FActiveEdges;
  while Assigned(E) do
  begin
    //1. process maxima, treating them as if they're 'bent' horizontal edges,
    //   but exclude maxima with Horizontal edges. nb: E can't be a Horizontal.
    IsMaximaEdge := IsMaxima(E, TopY);
    if IsMaximaEdge then
    begin
      EMaxPair := GetMaximaPairEx(E);
      IsMaximaEdge := not assigned(EMaxPair) or (EMaxPair.Dx <> Horizontal);
    end;

    if IsMaximaEdge then
    begin
      if FStrictSimple then
        InsertMaxima(E.Top.X);
      //'E' might be removed from AEL, as may any following edges so ...
      ePrev := E.PrevInAEL;
      DoMaxima(E);
      if not Assigned(ePrev) then
        E := FActiveEdges else
        E := ePrev.NextInAEL;
    end else
    begin
      //2. promote horizontal edges, otherwise update Curr.X and Curr.Y ...
      if IsIntermediate(E, TopY) and (E.NextInLML.Dx = Horizontal) then
      begin
        UpdateEdgeIntoAEL(E);
        if (E.OutIdx >= 0) then
          AddOutPt(E, E.Bot);
        AddEdgeToSEL(E);
      end else
      begin
        E.Curr.X := TopX(E, TopY);
        E.Curr.Y := TopY;
{$IFDEF use_xyz}
        if E.Top.Y = TopY then e.Curr.Z := e.Top.Z
        else if (E.Bot.Y = TopY) then e.Curr.Z := E.Bot.Z else
        e.Curr.Z := 0;
{$ENDIF}
      end;

      //When StrictlySimple and 'e' is being touched by another edge, then
      //make sure both edges have a vertex here ...
      if FStrictSimple then
      begin
        ePrev := E.PrevInAEL;
        if (E.OutIdx >= 0) and (E.WindDelta <> 0) and
          Assigned(ePrev) and (ePrev.Curr.X = E.Curr.X) and
          (ePrev.OutIdx >= 0) and (ePrev.WindDelta <> 0) then
        begin
          Pt := E.Curr;
{$IFDEF use_xyz}
          SetZ(Pt, ePrev, E, FZFillCallback);
{$ENDIF}
          Op := AddOutPt(ePrev, Pt);
          Op2 := AddOutPt(E, Pt);
          AddJoin(Op, Op2, Pt); //strictly-simple (type-3) 'join'
        end;
      end;

      E := E.NextInAEL;
    end;
  end;

  //3. Process horizontals at the top of the scanbeam ...
  ProcessHorizontals;
  if FStrictSimple then DisposeMaximaList;

  //4. Promote intermediate vertices ...
  E := FActiveEdges;
  while Assigned(E) do
  begin
    if IsIntermediate(E, TopY) then
    begin
      if (E.OutIdx >= 0) then
        Op := AddOutPt(E, E.Top) else
        Op := nil;
      UpdateEdgeIntoAEL(E);

      //if output polygons share an Edge, they'll need joining later ...
      ePrev := E.PrevInAEL;
      eNext  := E.NextInAEL;
      if Assigned(ePrev) and (ePrev.Curr.X = E.Bot.X) and
        (ePrev.Curr.Y = E.Bot.Y) and assigned(Op) and
        (ePrev.OutIdx >= 0) and (ePrev.Curr.Y > ePrev.Top.Y) and
        SlopesEqual(E.Curr, E.Top, ePrev.Curr, ePrev.Top, FUse64BitRange) and
        (E.WindDelta <> 0) and (ePrev.WindDelta <> 0) then
      begin
        Op2 := AddOutPt(ePrev, E.Bot);
        AddJoin(Op, Op2, E.Top);
      end
      else if Assigned(eNext) and (eNext.Curr.X = E.Bot.X) and
        (eNext.Curr.Y = E.Bot.Y) and assigned(Op) and
          (eNext.OutIdx >= 0) and (eNext.Curr.Y > eNext.Top.Y) and
        SlopesEqual(E.Curr, E.Top, eNext.Curr, eNext.Top, FUse64BitRange) and
        (E.WindDelta <> 0) and (eNext.WindDelta <> 0) then
      begin
        Op2 := AddOutPt(eNext, E.Bot);
        AddJoin(Op, Op2, E.Top);
      end;
    end;
    E := E.NextInAEL;
  end;
end;
//------------------------------------------------------------------------------

function TClipper.BuildResult: TPaths;
var
  I, J, K, Cnt: Integer;
  OutRec: POutRec;
  Op: POutPt;
begin
  J := 0;
  SetLength(Result, FPolyOutList.Count);
  for I := 0 to FPolyOutList.Count -1 do
    if Assigned(fPolyOutList[I]) then
    begin
      OutRec := FPolyOutList[I];
      if not assigned(OutRec.Pts) then Continue;

      Op := OutRec.Pts.Prev;
      Cnt := PointCount(Op);
      if (Cnt < 2) then Continue;
      SetLength(Result[J], Cnt);
      for K := 0 to Cnt -1 do
      begin
        Result[J][K] := Op.Pt;
        Op := Op.Prev;
      end;
      Inc(J);
    end;
  SetLength(Result, J);
end;
//------------------------------------------------------------------------------

function TClipper.BuildResult2(PolyTree: TPolyTree): Boolean;
var
  I, J, Cnt, CntAll: Integer;
  Op: POutPt;
  OutRec: POutRec;
  PolyNode: TPolyNode;
begin
  try
    PolyTree.Clear;
    SetLength(PolyTree.FAllNodes, FPolyOutList.Count);

    //add PolyTree ...
    CntAll := 0;
    for I := 0 to FPolyOutList.Count -1 do
    begin
      OutRec := fPolyOutList[I];
      Cnt := PointCount(OutRec.Pts);
      if (OutRec.IsOpen and (cnt < 2)) or
        (not outRec.IsOpen and (cnt < 3)) then Continue;
      FixHoleLinkage(OutRec);

      PolyNode := TPolyNode.Create;
      PolyTree.FAllNodes[CntAll] := PolyNode;
      OutRec.PolyNode := PolyNode;
      Inc(CntAll);
      SetLength(PolyNode.FPath, Cnt);
      Op := OutRec.Pts.Prev;
      for J := 0 to Cnt -1 do
      begin
        PolyNode.FPath[J] := Op.Pt;
        Op := Op.Prev;
      end;
    end;

    //fix Poly links ...
    SetLength(PolyTree.FAllNodes, CntAll);
    SetLength(PolyTree.FChilds, CntAll);
    for I := 0 to FPolyOutList.Count -1 do
    begin
      OutRec := fPolyOutList[I];
      if Assigned(OutRec.PolyNode) then
      begin
        if OutRec.IsOpen then
        begin
          OutRec.PolyNode.FIsOpen := true;
          PolyTree.AddChild(OutRec.PolyNode);
        end
        else if Assigned(OutRec.FirstLeft) and
          assigned(OutRec.FirstLeft.PolyNode)then
          OutRec.FirstLeft.PolyNode.AddChild(OutRec.PolyNode)
        else
          PolyTree.AddChild(OutRec.PolyNode);
      end;
    end;
    SetLength(PolyTree.FChilds, PolyTree.FCount);
    Result := True;
  except
    Result := False;
  end;
end;
//------------------------------------------------------------------------------

procedure TClipper.FixupOutPolyline(OutRec: POutRec);
var
  PP, LastPP, TmpPP: POutPt;
begin
  //remove duplicate points ...
  PP := OutRec.Pts;
  LastPP := PP.Prev;
  while (PP <> LastPP) do
  begin
    PP := PP.Next;
    //strip duplicate points ...
    if PointsEqual(PP.Pt, PP.Prev.Pt) then
    begin
      if PP = LastPP then LastPP := PP.Prev;
      TmpPP := PP.Prev;
      TmpPP.Next := PP.Next;
      PP.Next.Prev := TmpPP;
      dispose(PP);
      PP := TmpPP;
    end;
  end;

  if (PP = PP.Prev) then
  begin
    Dispose(PP);
    OutRec.Pts := nil;
    Exit;
  end;

end;
//------------------------------------------------------------------------------

procedure TClipper.FixupOutPolygon(OutRec: POutRec);
var
  PP, Tmp, LastOK: POutPt;
  PreserveCol: Boolean;
begin
  //remove duplicate points and collinear edges
  LastOK := nil;
  OutRec.BottomPt := nil; //flag as stale
  PP := OutRec.Pts;
  PreserveCol := FPreserveCollinear or FStrictSimple;
  while True do
  begin
    if (PP = PP.Prev) or (PP.Next = PP.Prev) then
    begin
      DisposePolyPts(PP);
      OutRec.Pts := nil;
      Exit;
    end;

    //test for duplicate points and collinear edges ...
    if PointsEqual(PP.Pt, PP.Next.Pt) or PointsEqual(PP.Pt, PP.Prev.Pt) or
      (SlopesEqual(PP.Prev.Pt, PP.Pt, PP.Next.Pt, FUse64BitRange) and
      (not PreserveCol or
      not Pt2IsBetweenPt1AndPt3(PP.Prev.Pt, PP.Pt, PP.Next.Pt))) then
    begin
      //OK, we need to delete a point ...
      LastOK := nil;
      Tmp := PP;
      PP.Prev.Next := PP.Next;
      PP.Next.Prev := PP.Prev;
      PP := PP.Prev;
      dispose(Tmp);
    end
    else if PP = LastOK then Break
    else
    begin
      if not Assigned(LastOK) then LastOK := PP;
      PP := PP.Next;
    end;
  end;
  OutRec.Pts := PP;
end;
//------------------------------------------------------------------------------

function EdgesAdjacent(Inode: PIntersectNode): Boolean; {$IFDEF INLINING} inline; {$ENDIF}
begin
  Result := (Inode.Edge1.NextInSEL = Inode.Edge2) or
    (Inode.Edge1.PrevInSEL = Inode.Edge2);
end;
//------------------------------------------------------------------------------

function IntersectListSort(Node1, Node2: Pointer): Integer;
var
  i: cInt;
begin
  i := PIntersectNode(Node2).Pt.Y - PIntersectNode(Node1).Pt.Y;
  if i < 0 then Result := -1
  else if i > 0 then Result := 1
  else Result := 0;
end;
//------------------------------------------------------------------------------

function TClipper.FixupIntersectionOrder: Boolean;
var
  I, J, Cnt: Integer;
  Node: PIntersectNode;
begin
  //pre-condition: intersections are sorted bottom-most first.
  //Now it's crucial that intersections are made only between adjacent edges,
  //and to ensure this the order of intersections may need adjusting ...
  Result := True;
  Cnt := FIntersectList.Count;
  if Cnt < 2 then exit;

  CopyAELToSEL;
  {$IFDEF USEGENERICS}
  FIntersectList.Sort(TComparer<PIntersectNode>.Construct(
    function (const Node1, Node2 : PIntersectNode) : integer
    var
      i: cInt;
    begin
      i := PIntersectNode(Node2).Pt.Y - PIntersectNode(Node1).Pt.Y;
      if i < 0 then Result := -1
      else if i > 0 then Result := 1
      else Result := 0;
    end
    ));
  {$ELSE}
  FIntersectList.Sort(IntersectListSort);
  {$ENDIF}
  for I := 0 to Cnt - 1 do
  begin
    if not EdgesAdjacent(FIntersectList[I]) then
    begin
      J := I + 1;
      while (J < Cnt) and not EdgesAdjacent(FIntersectList[J]) do inc(J);
      if J = Cnt then
      begin
        Result := False;
        Exit; //error!!
      end;
      //Swap IntersectNodes ...
      Node := FIntersectList[I];
      FIntersectList[I] := FIntersectList[J];
      FIntersectList[J] := Node;
    end;
    with PIntersectNode(FIntersectList[I])^ do
      SwapPositionsInSEL(Edge1, Edge2);
  end;
end;
//------------------------------------------------------------------------------

function DupOutPt(OutPt: POutPt; InsertAfter: Boolean = true): POutPt;
begin
  new(Result);
  Result.Pt := OutPt.Pt;
  Result.Idx := OutPt.Idx;
  if InsertAfter then
  begin
    Result.Next := OutPt.Next;
    Result.Prev := OutPt;
    OutPt.Next.Prev := Result;
    OutPt.Next := Result;
  end else
  begin
    Result.Prev := OutPt.Prev;
    Result.Next := OutPt;
    OutPt.Prev.Next := Result;
    OutPt.Prev := Result;
  end;
end;
//------------------------------------------------------------------------------

function JoinHorz(Op1, Op1b, Op2, Op2b: POutPt;
  const Pt: TIntPoint; DiscardLeft: Boolean): Boolean;
var
  Dir1, Dir2: TDirection;
begin
  if Op1.Pt.X > Op1b.Pt.X then Dir1 := dRightToLeft else Dir1 := dLeftToRight;
  if Op2.Pt.X > Op2b.Pt.X then Dir2 := dRightToLeft else Dir2 := dLeftToRight;
  Result := Dir1 <> Dir2;
  if not Result then Exit;

  //When DiscardLeft, we want Op1b to be on the left of Op1, otherwise we
  //want Op1b to be on the right. (And likewise with Op2 and Op2b.)
  //To facilitate this while inserting Op1b & Op2b when DiscardLeft == true,
  //make sure we're either AT or RIGHT OF Pt before adding Op1b, otherwise
  //make sure we're AT or LEFT OF Pt. (Likewise with Op2b.)
  if Dir1 = dLeftToRight then
  begin
    while (Op1.Next.Pt.X <= Pt.X) and
      (Op1.Next.Pt.X >= Op1.Pt.X) and (Op1.Next.Pt.Y = Pt.Y) do
      Op1 := Op1.Next;
    if DiscardLeft and (Op1.Pt.X <> Pt.X) then Op1 := Op1.Next;
    Op1b := DupOutPt(Op1, not DiscardLeft);
    if not PointsEqual(Op1b.Pt, Pt) then
    begin
      Op1 := Op1b;
      Op1.Pt := Pt;
      Op1b := DupOutPt(Op1, not DiscardLeft);
    end;
  end else
  begin
    while (Op1.Next.Pt.X >= Pt.X) and
      (Op1.Next.Pt.X <= Op1.Pt.X) and (Op1.Next.Pt.Y = Pt.Y) do
      Op1 := Op1.Next;
    if not DiscardLeft and (Op1.Pt.X <> Pt.X) then Op1 := Op1.Next;
    Op1b := DupOutPt(Op1, DiscardLeft);
    if not PointsEqual(Op1b.Pt, Pt) then
    begin
      Op1 := Op1b;
      Op1.Pt := Pt;
      Op1b := DupOutPt(Op1, DiscardLeft);
    end;
  end;

  if Dir2 = dLeftToRight then
  begin
    while (Op2.Next.Pt.X <= Pt.X) and
      (Op2.Next.Pt.X >= Op2.Pt.X) and (Op2.Next.Pt.Y = Pt.Y) do
        Op2 := Op2.Next;
    if DiscardLeft and (Op2.Pt.X <> Pt.X) then Op2 := Op2.Next;
    Op2b := DupOutPt(Op2, not DiscardLeft);
    if not PointsEqual(Op2b.Pt, Pt) then
    begin
      Op2 := Op2b;
      Op2.Pt := Pt;
      Op2b := DupOutPt(Op2, not DiscardLeft);
    end;
  end else
  begin
    while (Op2.Next.Pt.X >= Pt.X) and
      (Op2.Next.Pt.X <= Op2.Pt.X) and (Op2.Next.Pt.Y = Pt.Y) do
      Op2 := Op2.Next;
    if not DiscardLeft and (Op2.Pt.X <> Pt.X) then Op2 := Op2.Next;
    Op2b := DupOutPt(Op2, DiscardLeft);
    if not PointsEqual(Op2b.Pt, Pt) then
    begin
      Op2 := Op2b;
      Op2.Pt := Pt;
      Op2b := DupOutPt(Op2, DiscardLeft);
    end;
  end;

  if (Dir1 = dLeftToRight) = DiscardLeft then
  begin
    Op1.Prev := Op2;
    Op2.Next := Op1;
    Op1b.Next := Op2b;
    Op2b.Prev := Op1b;
  end
  else
  begin
    Op1.Next := Op2;
    Op2.Prev := Op1;
    Op1b.Prev := Op2b;
    Op2b.Next := Op1b;
  end;
end;
//------------------------------------------------------------------------------

function TClipper.JoinPoints(Jr: PJoin; OutRec1, OutRec2: POutRec): Boolean;
var
  Op1, Op1b, Op2, Op2b: POutPt;
  Pt: TIntPoint;
  Reverse1, Reverse2, DiscardLeftSide: Boolean;
  IsHorizontal: Boolean;
  Left, Right: cInt;
begin
  Result := False;
  Op1 := Jr.OutPt1;
  Op2 := Jr.OutPt2;

  //There are 3 kinds of joins for output polygons ...
  //1. Horizontal joins where Join.OutPt1 & Join.OutPt2 are vertices anywhere
  //along (horizontal) collinear edges (& Join.OffPt is on the same horizontal).
  //2. Non-horizontal joins where Join.OutPt1 & Join.OutPt2 are at the same
  //location at the bottom of the overlapping segment (& Join.OffPt is above).
  //3. StrictlySimple joins where edges touch but are not collinear and where
  //Join.OutPt1, Join.OutPt2 & Join.OffPt all share the same point.
  IsHorizontal := (Jr.OutPt1.Pt.Y = Jr.OffPt.Y);

  if IsHorizontal and PointsEqual(Jr.OffPt, Jr.OutPt1.Pt) and
  PointsEqual(Jr.OffPt, Jr.OutPt2.Pt) then
  begin
    //Strictly Simple join ...
    if (OutRec1 <> OutRec2) then 
      Exit;

    Op1b := Jr.OutPt1.Next;
    while (Op1b <> Op1) and
      PointsEqual(Op1b.Pt, Jr.OffPt) do Op1b := Op1b.Next;
    Reverse1 := (Op1b.Pt.Y > Jr.OffPt.Y);
    Op2b := Jr.OutPt2.Next;
    while (Op2b <> Op2) and
      PointsEqual(Op2b.Pt, Jr.OffPt) do Op2b := Op2b.Next;
    Reverse2 := (Op2b.Pt.Y > Jr.OffPt.Y);
    if (Reverse1 = Reverse2) then Exit;

    if Reverse1 then
    begin
      Op1b := DupOutPt(Op1, False);
      Op2b := DupOutPt(Op2, True);
      Op1.Prev := Op2;
      Op2.Next := Op1;
      Op1b.Next := Op2b;
      Op2b.Prev := Op1b;
      Jr.OutPt1 := Op1;
      Jr.OutPt2 := Op1b;
      Result := True;
    end else
    begin
      Op1b := DupOutPt(Op1, True);
      Op2b := DupOutPt(Op2, False);
      Op1.Next := Op2;
      Op2.Prev := Op1;
      Op1b.Prev := Op2b;
      Op2b.Next := Op1b;
      Jr.OutPt1 := Op1;
      Jr.OutPt2 := Op1b;
      Result := True;
    end;
  end
  else if IsHorizontal then
  begin
    op1b := op1;
    while (op1.Prev.Pt.Y = op1.Pt.Y) and
      (op1.Prev <> Op1b) and (op1.Prev <> op2) do
        op1 := op1.Prev;
    while (op1b.Next.Pt.Y = op1b.Pt.Y) and
      (op1b.Next <> Op1) and (op1b.Next <> op2) do
        op1b := op1b.Next;
    if (op1b.Next = Op1) or (op1b.Next = op2) then Exit; //a flat 'polygon'

    op2b := op2;
    while (op2.Prev.Pt.Y = op2.Pt.Y) and
      (op2.Prev <> Op2b) and (op2.Prev <> op1b) do
        op2 := op2.Prev;
    while (op2b.Next.Pt.Y = op2b.Pt.Y) and
      (op2b.Next <> Op2) and (op2b.Next <> op1) do
        op2b := op2b.Next;
    if (op2b.Next = Op2) or (op2b.Next = op1) then Exit; //a flat 'polygon'

    //Op1 --> Op1b & Op2 --> Op2b are the extremites of the horizontal edges
    if not GetOverlap(Op1.Pt.X, Op1b.Pt.X, Op2.Pt.X, Op2b.Pt.X, Left, Right) then
      Exit;

    //DiscardLeftSide: when joining overlapping edges, a spike will be created
    //which needs to be cleaned up. However, we don't want Op1 or Op2 caught up
    //on the discard side as either may still be needed for other joins ...
    if (Op1.Pt.X >= Left) and (Op1.Pt.X <= Right) then
    begin
      Pt := Op1.Pt; DiscardLeftSide := Op1.Pt.X > Op1b.Pt.X;
    end else if (Op2.Pt.X >= Left) and (Op2.Pt.X <= Right) then
    begin
      Pt := Op2.Pt; DiscardLeftSide := Op2.Pt.X > Op2b.Pt.X;
    end else if (Op1b.Pt.X >= Left) and (Op1b.Pt.X <= Right) then
    begin
      Pt := Op1b.Pt; DiscardLeftSide := Op1b.Pt.X > Op1.Pt.X;
    end else
    begin
      Pt := Op2b.Pt; DiscardLeftSide := Op2b.Pt.X > Op2.Pt.X;
    end;

    Result := JoinHorz(Op1, Op1b, Op2, Op2b, Pt, DiscardLeftSide);
    if not Result then Exit;
    Jr.OutPt1 := Op1;
    Jr.OutPt2 := Op2;
  end else
  begin
    //make sure the polygons are correctly oriented ...
    Op1b := Op1.Next;
    while PointsEqual(Op1b.Pt, Op1.Pt) and (Op1b <> Op1) do Op1b := Op1b.Next;
    Reverse1 := (Op1b.Pt.Y > Op1.Pt.Y) or
      not SlopesEqual(Op1.Pt, Op1b.Pt, Jr.OffPt, FUse64BitRange);
    if Reverse1 then
    begin
      Op1b := Op1.Prev;
      while PointsEqual(Op1b.Pt, Op1.Pt) and (Op1b <> Op1) do Op1b := Op1b.Prev;
      if (Op1b.Pt.Y > Op1.Pt.Y) or
        not SlopesEqual(Op1.Pt, Op1b.Pt, Jr.OffPt, FUse64BitRange) then Exit;
    end;
    Op2b := Op2.Next;
    while PointsEqual(Op2b.Pt, Op2.Pt) and (Op2b <> Op2) do Op2b := Op2b.Next;
    Reverse2 := (Op2b.Pt.Y > Op2.Pt.Y) or
      not SlopesEqual(Op2.Pt, Op2b.Pt, Jr.OffPt, FUse64BitRange);
    if Reverse2 then
    begin
      Op2b := Op2.Prev;
      while PointsEqual(Op2b.Pt, Op2.Pt) and (Op2b <> Op2) do Op2b := Op2b.Prev;
      if (Op2b.Pt.Y > Op2.Pt.Y) or
        not SlopesEqual(Op2.Pt, Op2b.Pt, Jr.OffPt, FUse64BitRange) then Exit;
    end;

    if (Op1b = Op1) or (Op2b = Op2) or (Op1b = Op2b) or
      ((OutRec1 = OutRec2) and (Reverse1 = Reverse2)) then Exit;

    if Reverse1 then
    begin
      Op1b := DupOutPt(Op1, False);
      Op2b := DupOutPt(Op2, True);
      Op1.Prev := Op2;
      Op2.Next := Op1;
      Op1b.Next := Op2b;
      Op2b.Prev := Op1b;
      Jr.OutPt1 := Op1;
      Jr.OutPt2 := Op1b;
      Result := True;
    end else
    begin
      Op1b := DupOutPt(Op1, True);
      Op2b := DupOutPt(Op2, False);
      Op1.Next := Op2;
      Op2.Prev := Op1;
      Op1b.Prev := Op2b;
      Op2b.Next := Op1b;
      Jr.OutPt1 := Op1;
      Jr.OutPt2 := Op1b;
      Result := True;
    end;
  end;
end;
//------------------------------------------------------------------------------

function ParseFirstLeft(FirstLeft: POutRec): POutRec;
begin
  while Assigned(FirstLeft) and not Assigned(FirstLeft.Pts) do
    FirstLeft := FirstLeft.FirstLeft;
  Result := FirstLeft;
end;
//------------------------------------------------------------------------------

procedure TClipper.FixupFirstLefts1(OldOutRec, NewOutRec: POutRec);
var
  I: Integer;
  outRec: POutRec;
  firstLeft: POutRec;
begin
  //tests if NewOutRec contains the polygon before reassigning FirstLeft
  for I := 0 to FPolyOutList.Count -1 do
  begin
    outRec := fPolyOutList[I];
    firstLeft := ParseFirstLeft(outRec.FirstLeft);
    if Assigned(outRec.Pts) and (firstLeft = OldOutRec) then
    begin
      if Poly2ContainsPoly1(outRec.Pts, NewOutRec.Pts) then
        outRec.FirstLeft := NewOutRec;
    end;
  end;
end;
//------------------------------------------------------------------------------

procedure TClipper.FixupFirstLefts2(InnerOutRec, OuterOutRec: POutRec);
var
  I: Integer;
  orfl, orec: POutRec;
  firstLeft: POutRec;
begin
  //A polygon has split into two such that one is now the inner of the other.
  //It's possible that these polygons now wrap around other polygons, so check
  //every polygon that's also contained by OuterOutRec's FirstLeft container
  //(including nil) to see if they've become inner to the new inner polygon ...
  orfl := OuterOutRec.FirstLeft;
  for I := 0 to FPolyOutList.Count -1 do
  begin
    orec := POutRec(fPolyOutList[I]);
    if not Assigned(orec.Pts) or
      (orec = OuterOutRec) or (orec = InnerOutRec) then continue;
    firstLeft := ParseFirstLeft(orec.FirstLeft);
    if (firstLeft <> orfl) and (firstLeft <> InnerOutRec) and
      (firstLeft <> OuterOutRec) then Continue;
    if Poly2ContainsPoly1(orec.Pts, InnerOutRec.Pts) then
      orec.FirstLeft := InnerOutRec
    else if Poly2ContainsPoly1(orec.Pts, OuterOutRec.Pts) then
      orec.FirstLeft := OuterOutRec
    else if (orec.FirstLeft = InnerOutRec) or
      (orec.FirstLeft = OuterOutRec) then
        orec.FirstLeft := orfl;
  end;
end;
//------------------------------------------------------------------------------

procedure TClipper.FixupFirstLefts3(OldOutRec, NewOutRec: POutRec);
var
  I: Integer;
  outRec: POutRec;
  firstLeft: POutRec;
begin
  //same as FixupFirstLefts1 but doesn't call Poly2ContainsPoly1()
  for I := 0 to FPolyOutList.Count -1 do
  begin
    outRec := fPolyOutList[I];
    firstLeft := ParseFirstLeft(outRec.FirstLeft);
    if Assigned(outRec.Pts) and (firstLeft = OldOutRec) then
       outRec.FirstLeft := NewOutRec;
  end;
end;
//------------------------------------------------------------------------------

procedure TClipper.JoinCommonEdges;
var
  I: Integer;
  Jr: PJoin;
  OutRec1, OutRec2, HoleStateRec: POutRec;
begin
  for I := 0 to FJoinList.count -1 do
  begin
    Jr := FJoinList[I];

    OutRec1 := GetOutRec(Jr.OutPt1.Idx);
    OutRec2 := GetOutRec(Jr.OutPt2.Idx);

    if not Assigned(OutRec1.Pts) or not Assigned(OutRec2.Pts) then Continue;
    if OutRec1.IsOpen or OutRec2.IsOpen then Continue;

    //get the polygon fragment with the correct hole state (FirstLeft)
    //before calling JoinPoints() ...
    if OutRec1 = OutRec2 then HoleStateRec := OutRec1
    else if OutRec1RightOfOutRec2(OutRec1, OutRec2) then HoleStateRec := OutRec2
    else if OutRec1RightOfOutRec2(OutRec2, OutRec1) then HoleStateRec := OutRec1
    else HoleStateRec := GetLowermostRec(OutRec1, OutRec2);

    if not JoinPoints(Jr, OutRec1, OutRec2) then Continue;

    if (OutRec1 = OutRec2) then
    begin
      //instead of joining two polygons, we've just created a new one by
      //splitting one polygon into two.
      OutRec1.Pts := Jr.OutPt1;
      OutRec1.BottomPt := nil;
      OutRec2 := CreateOutRec;
      OutRec2.Pts := Jr.OutPt2;

      //update all OutRec2.Pts idx's ...
      UpdateOutPtIdxs(OutRec2);

      //sort out the hole states of both polygon ...
      if Poly2ContainsPoly1(OutRec2.Pts, OutRec1.Pts) then
      begin
        //OutRec1 contains OutRec2 ...
        OutRec2.IsHole := not OutRec1.IsHole;
        OutRec2.FirstLeft := OutRec1;

        if FUsingPolyTree then
          FixupFirstLefts2(OutRec2, OutRec1);

        if (OutRec2.IsHole xor FReverseOutput) = (Area(OutRec2) > 0) then
            ReversePolyPtLinks(OutRec2.Pts);
      end else if Poly2ContainsPoly1(OutRec1.Pts, OutRec2.Pts) then
      begin
        //OutRec2 contains OutRec1 ...
        OutRec2.IsHole := OutRec1.IsHole;
        OutRec1.IsHole := not OutRec2.IsHole;
        OutRec2.FirstLeft := OutRec1.FirstLeft;
        OutRec1.FirstLeft := OutRec2;
        if FUsingPolyTree then
          FixupFirstLefts2(OutRec1, OutRec2);

        if (OutRec1.IsHole xor FReverseOutput) = (Area(OutRec1) > 0) then
          ReversePolyPtLinks(OutRec1.Pts);
      end else
      begin
        //the 2 polygons are completely separate ...
        OutRec2.IsHole := OutRec1.IsHole;
        OutRec2.FirstLeft := OutRec1.FirstLeft;

        //fixup FirstLeft pointers that may need reassigning to OutRec2
        if FUsingPolyTree then FixupFirstLefts1(OutRec1, OutRec2);
      end;
    end else
    begin
      //joined 2 polygons together ...

      //delete the obsolete pointer ...
      OutRec2.Pts := nil;
      OutRec2.BottomPt := nil;
      OutRec2.Idx := OutRec1.Idx;

      OutRec1.IsHole := HoleStateRec.IsHole;
      if HoleStateRec = OutRec2 then
        OutRec1.FirstLeft := OutRec2.FirstLeft;
      OutRec2.FirstLeft := OutRec1;

      if FUsingPolyTree then
        FixupFirstLefts3(OutRec2, OutRec1);
    end;
  end;
end;
//------------------------------------------------------------------------------

procedure TClipper.DoSimplePolygons;
var
  I: Integer;
  OutRec1, OutRec2: POutRec;
  Op, Op2, Op3, Op4: POutPt;
begin
  I := 0;
  while I < FPolyOutList.Count do
  begin
    OutRec1 := POutRec(fPolyOutList[I]);
    inc(I);
    Op := OutRec1.Pts;
    if not assigned(Op) or OutRec1.IsOpen then Continue;
    repeat //for each Pt in Path until duplicate found do ...
      Op2 := Op.Next;
      while (Op2 <> OutRec1.Pts) do
      begin
        if (PointsEqual(Op.Pt, Op2.Pt) and
          (Op2.Next <> Op) and (Op2.Prev <> Op)) then
        begin
          //split the polygon into two ...
          Op3 := Op.Prev;
          Op4 := Op2.Prev;
          Op.Prev := Op4;
          Op4.Next := Op;
          Op2.Prev := Op3;
          Op3.Next := Op2;

          OutRec1.Pts := Op;

          OutRec2 := CreateOutRec;
          OutRec2.Pts := Op2;
          UpdateOutPtIdxs(OutRec2);
          if Poly2ContainsPoly1(OutRec2.Pts, OutRec1.Pts) then
          begin
            //OutRec2 is contained by OutRec1 ...
            OutRec2.IsHole := not OutRec1.IsHole;
            OutRec2.FirstLeft := OutRec1;
            if FUsingPolyTree then FixupFirstLefts2(OutRec2, OutRec1);
          end
          else
          if Poly2ContainsPoly1(OutRec1.Pts, OutRec2.Pts) then
          begin
            //OutRec1 is contained by OutRec2 ...
            OutRec2.IsHole := OutRec1.IsHole;
            OutRec1.IsHole := not OutRec2.IsHole;
            OutRec2.FirstLeft := OutRec1.FirstLeft;
            OutRec1.FirstLeft := OutRec2;
            if FUsingPolyTree then FixupFirstLefts2(OutRec1, OutRec2);
          end else
          begin
            //the 2 polygons are separate ...
            OutRec2.IsHole := OutRec1.IsHole;
            OutRec2.FirstLeft := OutRec1.FirstLeft;
            if FUsingPolyTree then FixupFirstLefts1(OutRec1, OutRec2);
          end;
          Op2 := Op; //ie get ready for the next iteration
        end;
        Op2 := Op2.Next;
      end;
      Op := Op.Next;
    until (Op = OutRec1.Pts);
  end;
end;

//------------------------------------------------------------------------------
// TClipperOffset methods
//------------------------------------------------------------------------------

constructor TClipperOffset.Create(
  MiterLimit: Double = 2;
  ArcTolerance: Double = def_arc_tolerance);
begin
  inherited Create;
  FPolyNodes := TPolyNode.Create;
  FLowest.X := -1;
  FMiterLimit := MiterLimit;
  FArcTolerance := ArcTolerance;
end;
//------------------------------------------------------------------------------

destructor TClipperOffset.Destroy;
begin
  Clear;
  FPolyNodes.Free;
  inherited;
end;
//------------------------------------------------------------------------------

procedure TClipperOffset.Clear;
var
  I: Integer;
  PolyNode: TPolyNode;
begin
  for I := 0 to FPolyNodes.ChildCount -1 do
    begin
      PolyNode:= FPolyNodes.Childs[I];
      PolyNode.Free;
    end;
  FPolyNodes.FCount := 0;
  FPolyNodes.FBuffLen := 16;
  SetLength(FPolyNodes.FChilds, 16);
  FLowest.X := -1;
end;
//------------------------------------------------------------------------------

procedure TClipperOffset.AddPath(const Path: TPath;
  JoinType: TJoinType; EndType: TEndType);
var
  I, J, K, HighI: Integer;
  NewNode: TPolyNode;
  ip: TIntPoint;
begin
  HighI := High(Path);
  if HighI < 0 then Exit;
  NewNode := TPolyNode.Create;
  NewNode.FJoinType := JoinType;
  NewNode.FEndType := EndType;

  //strip duplicate points from path and also get index to the lowest point ...
  if EndType in [etClosedLine, etClosedPolygon] then
    while (HighI > 0) and PointsEqual(Path[0], Path[HighI]) do dec(HighI);
  SetLength(NewNode.FPath, HighI +1);
  NewNode.FPath[0] := Path[0];
  J := 0; K := 0;
  for I := 1 to HighI do
    if not PointsEqual(NewNode.FPath[J], Path[I]) then
    begin
      inc(J);
      NewNode.FPath[J] := Path[I];
      if (NewNode.FPath[K].Y < Path[I].Y) or
        ((NewNode.FPath[K].Y = Path[I].Y) and
        (NewNode.FPath[K].X > Path[I].X)) then
          K := J;
    end;
  inc(J);
  if J < HighI +1 then
    SetLength(NewNode.FPath, J);
  if (EndType = etClosedPolygon) and (J < 3) then
  begin
    NewNode.free;
    Exit;
  end;
  FPolyNodes.AddChild(NewNode);

  if EndType <> etClosedPolygon then Exit;
  //if this path's lowest pt is lower than all the others then update FLowest
  if (FLowest.X < 0) then
  begin
    FLowest := IntPoint(FPolyNodes.ChildCount -1, K);
  end else
  begin
    ip := FPolyNodes.Childs[FLowest.X].FPath[FLowest.Y];
    if (NewNode.FPath[K].Y > ip.Y) or
      ((NewNode.FPath[K].Y = ip.Y) and
      (NewNode.FPath[K].X < ip.X)) then
        FLowest := IntPoint(FPolyNodes.ChildCount -1, K);
  end;
end;
//------------------------------------------------------------------------------

procedure TClipperOffset.AddPaths(const Paths: TPaths;
  JoinType: TJoinType; EndType: TEndType);
var
  I: Integer;
begin
  for I := 0 to High(Paths) do AddPath(Paths[I], JoinType, EndType);
end;
//------------------------------------------------------------------------------

procedure TClipperOffset.FixOrientations;
var
  I: Integer;
begin
  //fixup orientations of all closed paths if the orientation of the
  //closed path with the lowermost vertex is wrong ...
  if (FLowest.X >= 0) and
    not Orientation(FPolyNodes.Childs[FLowest.X].FPath) then
  begin
    for I := 0 to FPolyNodes.ChildCount -1 do
      if FPolyNodes.Childs[I].FEndType = etClosedPolygon then
        FPolyNodes.Childs[I].FPath := ReversePath(FPolyNodes.Childs[I].FPath)
      else if (FPolyNodes.Childs[I].FEndType = etClosedLine) and
        Orientation(FPolyNodes.Childs[I].FPath) then
          FPolyNodes.Childs[I].FPath := ReversePath(FPolyNodes.Childs[I].FPath);
  end else
  begin
    for I := 0 to FPolyNodes.ChildCount -1 do
      if (FPolyNodes.Childs[I].FEndType = etClosedLine) and
        not Orientation(FPolyNodes.Childs[I].FPath) then
          FPolyNodes.Childs[I].FPath := ReversePath(FPolyNodes.Childs[I].FPath);
  end;
end;
//------------------------------------------------------------------------------

procedure TClipperOffset.DoOffset(Delta: Double);
var
  I, J, K, Len, solCount: Integer;
  X, X2, Y, Steps, AbsDelta: Double;
  Node: TPolyNode;
  N: TDoublePoint;
begin
  FSolution := nil;
  FDelta := Delta;
  AbsDelta := Abs(Delta);

  //if Zero offset, just copy any CLOSED polygons to FSolution and return ...
  if AbsDelta < Tolerance then
  begin
    solCount := 0;
    SetLength(FSolution, FPolyNodes.ChildCount);
    for I := 0 to FPolyNodes.ChildCount -1 do
      if FPolyNodes.Childs[I].FEndType = etClosedPolygon then
      begin
        FSolution[solCount] := FPolyNodes.Childs[I].FPath;
        inc(solCount);
      end;
    SetLength(FSolution, solCount);
    Exit;
  end;

  //FMiterLimit: see offset_triginometry3.svg in the documentation folder ...
  if FMiterLimit > 2 then FMiterLim := 2/(sqr(FMiterLimit))
  else FMiterLim := 0.5;

  if (FArcTolerance <= 0) then Y := def_arc_tolerance
  else if FArcTolerance > AbsDelta * def_arc_tolerance then
    Y := AbsDelta * def_arc_tolerance
  else Y := FArcTolerance;

  //see offset_triginometry2.svg in the documentation folder ...
  Steps := PI / ArcCos(1 - Y / AbsDelta);  //steps per 360 degrees
  if (Steps > AbsDelta * Pi) then
    Steps := AbsDelta * Pi;                //ie excessive precision check

  Math.SinCos(Two_Pi / Steps, FSin, FCos); //sin & cos per step
  if Delta < 0 then FSin := -FSin;
  FStepsPerRad := Steps / Two_Pi;

  SetLength(FSolution, FPolyNodes.ChildCount * 2);
  solCount := 0;
  for I := 0 to FPolyNodes.ChildCount -1 do
  begin
    Node := FPolyNodes.Childs[I];
    FInP := Node.FPath;
    Len := length(FInP);

    if (Len = 0) or
      ((Delta <= 0) and ((Len < 3) or (Node.FEndType <> etClosedPolygon))) then
        Continue;

    FOutPos := 0;
    FOutP := nil;

    //if a single vertex then build circle or a square ...
    if (Len = 1) then
    begin
      if Node.FJoinType = jtRound then
      begin
        X := 1; Y := 0;
        for J := 1 to Round(Steps) do
        begin
          AddPoint(IntPoint(
            Round(FInP[0].X + X * FDelta),
            Round(FInP[0].Y + Y * FDelta)));
          X2 := X;
          X := X * FCos - FSin * Y;
          Y := X2 * FSin + Y * FCos;
        end
      end else
      begin
        X := -1; Y := -1;
        for J := 1 to 4 do
        begin
          AddPoint(IntPoint( Round(FInP[0].X + X * FDelta),
            Round(FInP[0].Y + Y * FDelta)));
          if X < 0 then X := 1
          else if Y < 0 then Y := 1
          else X := -1;
        end;
      end;
      SetLength(FOutP, FOutPos);
      FSolution[solCount] := FOutP;
      Inc(solCount);
      Continue;
    end;

    //build Normals ...
    SetLength(FNorms, Len);
    for J := 0 to Len-2 do
      FNorms[J] := GetUnitNormal(FInP[J], FInP[J+1]);
    if not (Node.FEndType in [etClosedLine, etClosedPolygon]) then
      FNorms[Len-1] := FNorms[Len-2] else
      FNorms[Len-1] := GetUnitNormal(FInP[Len-1], FInP[0]);

    if Node.FEndType = etClosedPolygon then
    begin
      K := Len -1;
      for J := 0 to Len-1 do
        OffsetPoint(J, K, Node.FJoinType);
      SetLength(FOutP, FOutPos);
      FSolution[solCount] := FOutP;
      Inc(solCount);
    end
    else if (Node.FEndType = etClosedLine) then
    begin
      K := Len -1;
      for J := 0 to Len-1 do
        OffsetPoint(J, K, Node.FJoinType);
      SetLength(FOutP, FOutPos);
      FSolution[solCount] := FOutP;
      Inc(solCount);

      FOutPos := 0;
      FOutP := nil;

      //re-build Normals ...
      N := FNorms[Len - 1];
      for J := Len-1 downto 1 do
      begin
        FNorms[J].X := -FNorms[J-1].X;
        FNorms[J].Y := -FNorms[J-1].Y;
      end;
      FNorms[0].X := -N.X;
      FNorms[0].Y := -N.Y;

      K := 0;
      for J := Len-1 downto 0 do
        OffsetPoint(J, K, Node.FJoinType);
      SetLength(FOutP, FOutPos);

      FSolution[solCount] := FOutP;
      Inc(solCount);
    end else
    begin
      //offset the polyline going forward ...
      K := 0;
      for J := 1 to Len-2 do
        OffsetPoint(J, K, Node.FJoinType);

      //handle the end (butt, round or square) ...
      if Node.FEndType = etOpenButt then
      begin
        J := Len - 1;
        AddPoint(IntPoint(round(FInP[J].X + FNorms[J].X *FDelta),
          round(FInP[J].Y + FNorms[J].Y * FDelta)));
        AddPoint(IntPoint(round(FInP[J].X - FNorms[J].X *FDelta),
          round(FInP[J].Y - FNorms[J].Y * FDelta)));
      end else
      begin
        J := Len - 1;
        K := Len - 2;
        FNorms[J].X := -FNorms[J].X;
        FNorms[J].Y := -FNorms[J].Y;
        FSinA := 0;
        if Node.FEndType = etOpenSquare then
          DoSquare(J, K) else
          DoRound(J, K);
      end;

      //re-build Normals ...
      for J := Len-1 downto 1 do
      begin
        FNorms[J].X := -FNorms[J-1].X;
        FNorms[J].Y := -FNorms[J-1].Y;
      end;
      FNorms[0].X := -FNorms[1].X;
      FNorms[0].Y := -FNorms[1].Y;

      //offset the polyline going backward ...
      K := Len -1;
      for J := Len -2 downto 1 do
        OffsetPoint(J, K, Node.FJoinType);

      //finally handle the start (butt, round or square) ...
      if Node.FEndType = etOpenButt then
      begin
        AddPoint(IntPoint(round(FInP[0].X - FNorms[0].X *FDelta),
          round(FInP[0].Y - FNorms[0].Y * FDelta)));
        AddPoint(IntPoint(round(FInP[0].X + FNorms[0].X *FDelta),
          round(FInP[0].Y + FNorms[0].Y * FDelta)));
      end else
      begin
        FSinA := 0;
        if Node.FEndType = etOpenSquare then
          DoSquare(0, 1) else
          DoRound(0, 1);
      end;
      SetLength(FOutP, FOutPos);
      FSolution[solCount] := FOutP;
      Inc(solCount);
    end;
  end;
  SetLength(FSolution, solCount);
end;
//------------------------------------------------------------------------------

procedure TClipperOffset.Execute(out solution: TPaths; Delta: Double);
var
  I, Len: Integer;
  Outer: TPath;
  Bounds: TIntRect;
begin
  FixOrientations;
  DoOffset(Delta);
  //now clean up 'corners' ...
  with TClipper.Create do
  try
    AddPaths(FSolution, ptSubject, True);
    if Delta > 0 then
    begin
      Execute(ctUnion, solution, pftPositive, pftPositive);
    end else
    begin
      Bounds := GetBounds(FSolution);
      SetLength(Outer, 4);
      Outer[0] := IntPoint(Bounds.left-10, Bounds.bottom+10);
      Outer[1] := IntPoint(Bounds.right+10, Bounds.bottom+10);
      Outer[2] := IntPoint(Bounds.right+10, Bounds.top-10);
      Outer[3] := IntPoint(Bounds.left-10, Bounds.top-10);
      AddPath(Outer, ptSubject, True);
      ReverseSolution := True;
      Execute(ctUnion, solution, pftNegative, pftNegative);
      //delete the outer rectangle ...
      Len := length(solution);
      for I := 1 to Len -1 do solution[I-1] := solution[I];
      if Len > 0 then SetLength(solution, Len -1);
    end;
  finally
    free;
  end;
end;
//------------------------------------------------------------------------------

procedure TClipperOffset.Execute(out solution: TPolyTree; Delta: Double);
var
  I: Integer;
  Outer: TPath;
  Bounds: TIntRect;
  OuterNode: TPolyNode;
begin
  if not assigned(solution) then
    raise exception.Create(rsClipperOffset);
  solution.Clear;

  FixOrientations;
  DoOffset(Delta);

  //now clean up 'corners' ...
  with TClipper.Create do
  try
    AddPaths(FSolution, ptSubject, True);
    if Delta > 0 then
    begin
      Execute(ctUnion, solution, pftPositive, pftPositive);
    end else
    begin
      Bounds := GetBounds(FSolution);
      SetLength(Outer, 4);
      Outer[0] := IntPoint(Bounds.left-10, Bounds.bottom+10);
      Outer[1] := IntPoint(Bounds.right+10, Bounds.bottom+10);
      Outer[2] := IntPoint(Bounds.right+10, Bounds.top-10);
      Outer[3] := IntPoint(Bounds.left-10, Bounds.top-10);
      AddPath(Outer, ptSubject, True);
      ReverseSolution := True;
      Execute(ctUnion, solution, pftNegative, pftNegative);
      //remove the outer PolyNode rectangle ...
      if (solution.ChildCount = 1) and (solution.Childs[0].ChildCount > 0) then
      begin
        OuterNode := solution.Childs[0];
        SetLength(solution.FChilds, OuterNode.ChildCount);
        solution.FChilds[0] := OuterNode.Childs[0];
        solution.FChilds[0].FParent := solution;
        for I := 1 to OuterNode.ChildCount -1 do
          solution.AddChild(OuterNode.Childs[I]);
      end else
        solution.Clear;
    end;
  finally
    free;
  end;
end;
//------------------------------------------------------------------------------

procedure TClipperOffset.AddPoint(const Pt: TIntPoint);
const
  BuffLength = 32;
begin
  if FOutPos = length(FOutP) then
    SetLength(FOutP, FOutPos + BuffLength);
  FOutP[FOutPos] := Pt;
  Inc(FOutPos);
end;
//------------------------------------------------------------------------------

procedure TClipperOffset.DoSquare(J, K: Integer);
begin
  AddPoint(IntPoint(
    round(FInP[J].X + FDelta * (FNorms[K].X - FNorms[K].Y)),
    round(FInP[J].Y + FDelta * (FNorms[K].Y + FNorms[K].X))));
  AddPoint(IntPoint(
    round(FInP[J].X + FDelta * (FNorms[J].X + FNorms[J].Y)),
    round(FInP[J].Y + FDelta * (FNorms[J].Y - FNorms[J].X))));
end;
//------------------------------------------------------------------------------

procedure TClipperOffset.DoMiter(J, K: Integer; R: Double);
var
  Q: Double;
begin
  Q := FDelta / R;
  AddPoint(IntPoint(round(FInP[J].X + (FNorms[K].X + FNorms[J].X)*Q),
    round(FInP[J].Y + (FNorms[K].Y + FNorms[J].Y)*Q)));
end;
//------------------------------------------------------------------------------

procedure TClipperOffset.DoRound(J, K: Integer);
var
  I, Steps: Integer;
  A, X, X2, Y: Double;
begin
  A := ArcTan2(FSinA, FNorms[K].X * FNorms[J].X + FNorms[K].Y * FNorms[J].Y);
  Steps := Max(Round(FStepsPerRad * Abs(A)), 1);

  X := FNorms[K].X;
  Y := FNorms[K].Y;
  for I := 1 to Steps do
  begin
    AddPoint(IntPoint(
      round(FInP[J].X + X * FDelta),
      round(FInP[J].Y + Y * FDelta)));
    X2 := X;
    X := X * FCos - FSin * Y;
    Y := X2 * FSin + Y * FCos;
  end;
  AddPoint(IntPoint(
    round(FInP[J].X + FNorms[J].X * FDelta),
    round(FInP[J].Y + FNorms[J].Y * FDelta)));
end;
//------------------------------------------------------------------------------

procedure TClipperOffset.OffsetPoint(J: Integer;
  var K: Integer; JoinType: TJoinType);
var
  R, cosA: Double;
begin
  //cross product ...
  FSinA := (FNorms[K].X * FNorms[J].Y - FNorms[J].X * FNorms[K].Y);
  if (Abs(FSinA * FDelta) < 1.0) then
  begin
    //very nearly collinear edges can occasionally cause tiny self-intersections
    //due to rounding so offset with a single vertex here. (nb: The two offset
    //vertices that would otherwise have been used would be < 1 unit apart.)
    //dot product ...
    cosA := (FNorms[K].X * FNorms[J].X + FNorms[J].Y * FNorms[K].Y );
    if (cosA > 0) then // angle => 0 deg.
    begin
      AddPoint(IntPoint(round(FInP[J].X + FNorms[K].X * FDelta),
        round(FInP[J].Y + FNorms[K].Y * FDelta)));
      Exit;
    end
    //else angle => 180 deg.
  end
  else if (FSinA > 1.0) then FSinA := 1.0
  else if (FSinA < -1.0) then FSinA := -1.0;

  if FSinA * FDelta < 0 then
  begin
    AddPoint(IntPoint(round(FInP[J].X + FNorms[K].X * FDelta),
      round(FInP[J].Y + FNorms[K].Y * FDelta)));
    AddPoint(FInP[J]);
    AddPoint(IntPoint(round(FInP[J].X + FNorms[J].X * FDelta),
      round(FInP[J].Y + FNorms[J].Y * FDelta)));
  end
  else
    case JoinType of
      jtMiter:
      begin
        R := 1 + (FNorms[J].X * FNorms[K].X + FNorms[J].Y * FNorms[K].Y);
        if (R >= FMiterLim) then DoMiter(J, K, R)
        else DoSquare(J, K);
      end;
      jtSquare: DoSquare(J, K);
      jtRound: DoRound(J, K);
    end;
  K := J;
end;
//------------------------------------------------------------------------------

function SimplifyPolygon(const Poly: TPath; FillType: TPolyFillType = pftEvenOdd): TPaths;
begin
  with TClipper.Create do
  try
    StrictlySimple := True;
    AddPath(Poly, ptSubject, True);
    Execute(ctUnion, Result, FillType, FillType);
  finally
    free;
  end;
end;
//------------------------------------------------------------------------------

function SimplifyPolygons(const Polys: TPaths; FillType: TPolyFillType = pftEvenOdd): TPaths;
begin
  with TClipper.Create do
  try
    StrictlySimple := True;
    AddPaths(Polys, ptSubject, True);
    Execute(ctUnion, Result, FillType, FillType);
  finally
    free;
  end;
end;
//------------------------------------------------------------------------------

function DistanceSqrd(const Pt1, Pt2: TIntPoint): Double;
{$IFDEF INLINING} inline; {$ENDIF}
var
  dx, dy: Double;
begin
  dx := (Pt1.X - Pt2.X);
  dy := (Pt1.Y - Pt2.Y);
  result := (dx*dx + dy*dy);
end;
//------------------------------------------------------------------------------

function DistanceFromLineSqrd(const pt, ln1, ln2: TIntPoint): double;
var
  A, B, C: double;
begin
  //The equation of a line in general form (Ax + By + C = 0)
  //given 2 points (x¹,y¹) & (x²,y²) is ...
  //(y¹ - y²)x + (x² - x¹)y + (y² - y¹)x¹ - (x² - x¹)y¹ = 0
  //A = (y¹ - y²); B = (x² - x¹); C = (y² - y¹)x¹ - (x² - x¹)y¹
  //perpendicular distance of point (x³,y³) = (Ax³ + By³ + C)/Sqrt(A² + B²)
  //see http://en.wikipedia.org/wiki/Perpendicular_distance
  A := ln1.Y - ln2.Y;
  B := ln2.X - ln1.X;
  C := A * ln1.X  + B * ln1.Y;
  C := A * pt.X + B * pt.Y - C;
  Result := (C * C) / (A * A + B * B);
end;
//---------------------------------------------------------------------------

function SlopesNearCollinear(const Pt1, Pt2, Pt3: TIntPoint;
  DistSqrd: Double): Boolean;
begin
  //this function is more accurate when the point that's geometrically
  //between the other 2 points is the one that's tested for distance.
  //ie makes it more likely to pick up 'spikes' ...
  if Abs(Pt1.X - Pt2.X) > Abs(Pt1.Y - Pt2.Y) then
  begin
    if (Pt1.X > Pt2.X) = (Pt1.X < Pt3.X) then
      result := DistanceFromLineSqrd(Pt1, Pt2, Pt3) < DistSqrd
    else if (Pt2.X > Pt1.X) = (Pt2.X < Pt3.X) then
      result := DistanceFromLineSqrd(Pt2, Pt1, Pt3) < DistSqrd
    else
      result := DistanceFromLineSqrd(Pt3, Pt1, Pt2) < DistSqrd;
  end else
  begin
    if (Pt1.Y > Pt2.Y) = (Pt1.Y < Pt3.Y) then
      result := DistanceFromLineSqrd(Pt1, Pt2, Pt3) < DistSqrd
    else if (Pt2.Y > Pt1.Y) = (Pt2.Y < Pt3.Y) then
      result := DistanceFromLineSqrd(Pt2, Pt1, Pt3) < DistSqrd
    else
      result := DistanceFromLineSqrd(Pt3, Pt1, Pt2) < DistSqrd;
  end;
end;
//------------------------------------------------------------------------------

function PointsAreClose(const Pt1, Pt2: TIntPoint;
  DistSqrd: Double): Boolean;
begin
  result := DistanceSqrd(Pt1, Pt2) <= DistSqrd;
end;
//------------------------------------------------------------------------------

function CleanPolygon(const Poly: TPath; Distance: Double = 1.415): TPath;
var
  I, Len: Integer;
  DistSqrd: double;
  OutPts: array of TOutPt;
  op: POutPt;

  function ExcludeOp(op: POutPt): POutPt;
  begin
    Result := op.Prev;
    Result.Next := op.Next;
    op.Next.Prev := Result;
    Result.Idx := 0;
  end;

begin
  //Distance = proximity in units/pixels below which vertices
  //will be stripped. Default ~= sqrt(2) so when adjacent
  //vertices have both x & y coords within 1 unit, then
  //the second vertex will be stripped.
  DistSqrd := Round(Distance * Distance);
  Result := nil;
  Len := Length(Poly);
  if Len = 0 then Exit;

  SetLength(OutPts, Len);
  for I := 0 to Len -1 do
  begin
    OutPts[I].Pt := Poly[I];
    OutPts[I].Next := @OutPts[(I + 1) mod Len];
    OutPts[I].Next.Prev := @OutPts[I];
    OutPts[I].Idx := 0;
  end;

  op := @OutPts[0];
  while (op.Idx = 0) and (op.Next <> op.Prev) do
  begin
    if PointsAreClose(op.Pt, op.Prev.Pt, DistSqrd) then
    begin
      op := ExcludeOp(op);
      Dec(Len);
    end else if PointsAreClose(op.Prev.Pt, op.Next.Pt, DistSqrd) then
    begin
      ExcludeOp(op.Next);
      op := ExcludeOp(op);
      Dec(Len, 2);
    end
    else if SlopesNearCollinear(op.Prev.Pt, op.Pt, op.Next.Pt, DistSqrd) then
    begin
      op := ExcludeOp(op);
      Dec(Len);
    end
    else
    begin
      op.Idx := 1;
      op := op.Next;
    end;
  end;

  if Len < 3 then Len := 0;
  SetLength(Result, Len);
  for I := 0 to Len -1 do
  begin
    Result[I] := op.Pt;
    op := op.Next;
  end;
end;
//------------------------------------------------------------------------------

function CleanPolygons(const Polys: TPaths; Distance: double = 1.415): TPaths;
var
  I, Len: Integer;
begin
  Len := Length(Polys);
  SetLength(Result, Len);
  for I := 0 to Len - 1 do
    Result[I] := CleanPolygon(Polys[I], Distance);
end;
//------------------------------------------------------------------------------

function Minkowski(const Base, Path: TPath;
  IsSum: Boolean; IsClosed: Boolean): TPaths;
var
  i, j, delta, baseLen, pathLen: integer;
  quad: TPath;
  tmp: TPaths;
begin
  if IsClosed then delta := 1 else delta := 0;

  baseLen := Length(Base);
  pathLen := Length(Path);
  setLength(tmp, pathLen);
  if IsSum then
    for i := 0 to pathLen -1 do
    begin
      setLength(tmp[i], baseLen);
      for j := 0 to baseLen -1 do
      begin
        tmp[i][j].X := Path[i].X + Base[j].X;
        tmp[i][j].Y := Path[i].Y + Base[j].Y;
      end;
    end
  else
    for i := 0 to pathLen -1 do
    begin
      setLength(tmp[i], baseLen);
      for j := 0 to baseLen -1 do
      begin
        tmp[i][j].X := Path[i].X - Base[j].X;
        tmp[i][j].Y := Path[i].Y - Base[j].Y;
      end;
    end;

  SetLength(quad, 4);
  SetLength(Result, (pathLen + delta) * (baseLen + 1));
  for i := 0 to pathLen - 2 + delta do
  begin
    for j := 0 to baseLen - 1 do
    begin
      quad[0] := tmp[i mod pathLen][j mod baseLen];
      quad[1] := tmp[(i+1) mod pathLen][j mod baseLen];
      quad[2] := tmp[(i+1) mod pathLen][(j+1) mod baseLen];
      quad[3] := tmp[i mod pathLen][(j+1) mod baseLen];
      if not Orientation(quad) then quad := ReversePath(quad);
      Result[i*baseLen + j] := copy(quad, 0, 4);
    end;
  end;
end;
//------------------------------------------------------------------------------

function TranslatePath(const Path: TPath; const Delta: TIntPoint): TPath;
var
  i, len: Integer;
begin
  len := Length(Path);
  SetLength(Result, len);
  for i := 0 to High(Path) do
  begin
    Result[i].X := Path[i].X + Delta.X;
    Result[i].Y := Path[i].Y + Delta.Y;
  end;
end;
//------------------------------------------------------------------------------

function MinkowskiSum(const Pattern, Path: TPath; PathIsClosed: Boolean): TPaths;
begin
  Result := Minkowski(Pattern, Path, true, PathIsClosed);
  with TClipper.Create() do
  try
    AddPaths(Result, ptSubject, True);
    Execute(ctUnion, Result, pftNonZero);
  finally
    Free;
  end;
end;
//------------------------------------------------------------------------------

function MinkowskiSum(const Pattern: TPath; const Paths: TPaths;
  PathFillType: TPolyFillType; PathIsClosed: Boolean): TPaths;
var
  I, Cnt: Integer;
  Paths2: TPaths;
  Path: TPath;
begin
  Result := nil;
  if Length(Pattern) = 0 then Exit;
  Cnt := Length(Paths);
  with TClipper.Create() do
  try
    for I := 0 to Cnt -1 do
    begin
      Paths2 := Minkowski(Pattern, Paths[I], true, PathIsClosed);
      AddPaths( Paths2, ptSubject, true);
      if PathIsClosed then
      begin
        Path := TranslatePath(Paths[I], Pattern[0]);
        AddPath(Path, ptClip, true);
      end;
    end;
    Execute(ctUnion, Result, PathFillType, PathFillType);
  finally
    Free;
  end;
end;
//------------------------------------------------------------------------------

function MinkowskiDiff(const Poly1, Poly2: TPath): TPaths;
begin
  Result := Minkowski(Poly1, Poly2, false, true);
  with TClipper.Create() do
  try
    AddPaths(Result, ptSubject, True);
    Execute(ctUnion, Result, pftNonZero);
  finally
    Free;
  end;
end;
//------------------------------------------------------------------------------

type
  TNodeType = (ntAny, ntOpen, ntClosed);

procedure AddPolyNodeToPaths(PolyNode: TPolyNode;
  NodeType: TNodeType; var Paths: TPaths);
var
  I: Integer;
  Match: Boolean;
begin
  case NodeType of
    ntAny: Match := True;
    ntClosed: Match := not PolyNode.IsOpen;
    else Exit;
  end;

  if (Length(PolyNode.Contour) > 0) and Match then
  begin
    I := Length(Paths);
    SetLength(Paths, I +1);
    Paths[I] := PolyNode.Contour;
  end;
  for I := 0 to PolyNode.ChildCount - 1 do
    AddPolyNodeToPaths(PolyNode.Childs[I], NodeType, Paths);
end;
//------------------------------------------------------------------------------

function PolyTreeToPaths(PolyTree: TPolyTree): TPaths;
begin
  Result := nil;
  AddPolyNodeToPaths(PolyTree, ntAny, Result);
end;
//------------------------------------------------------------------------------

function ClosedPathsFromPolyTree(PolyTree: TPolyTree): TPaths;
begin
  Result := nil;
  AddPolyNodeToPaths(PolyTree, ntClosed, Result);
end;
//------------------------------------------------------------------------------

function OpenPathsFromPolyTree(PolyTree: TPolyTree): TPaths;
var
  I, J: Integer;
begin
  Result := nil;
  //Open polys are top level only, so ...
  for I := 0 to PolyTree.ChildCount - 1 do
    if PolyTree.Childs[I].IsOpen then
    begin
      J := Length(Result);
      SetLength(Result, J +1);
      Result[J] := PolyTree.Childs[I].Contour;
    end;
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

end.
