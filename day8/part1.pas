{$mode objfpc}{$H+}

uses Sysutils, Classes, Crt, StrUtils; 

Const nomfichier='input.txt';
      numConnections=1000;

type
  TPoint = record
    x, y, z: Int64;
  end;

  TPair = record
    a, b: Integer;
    dist: Int64;
  end;

var
  points: array of TPoint;
  paires : array of TPair;
  elements : TStringList;
  parent: array of Integer;
  taille: array of Int64;


procedure Split(const Delimiter: Char; Input: string; const Strings: TStrings);
var a: int64;
    subs:string;

begin
   Assert(Assigned(Strings)) ;
   Strings.Clear;
   subs:='';
   for a:=1 to length(Input) do
   begin
      if Input[a]=Delimiter then
      begin
        Strings.Add(subs);
        subs:='';
      end
      else
        subs:=subs+Input[a];
   end;
   Strings.Add(subs);
end;


function Trouve(i: Integer): Integer;
begin
  while parent[i] <> i do
  begin
    parent[i] := parent[parent[i]]; 
    i := parent[i];
  end;
  Trouve := i;
end;

procedure Union(a, b: Integer);
var
  pa, pb: Integer;
begin
  pa := Trouve(a);
  pb := Trouve(b);

  if pa = pb then Exit;

  if taille[pa] < taille[pb] then
  begin
    parent[pa] := pb;
    taille[pb] := taille[pb] + taille[pa];
  end
  else
  begin
    parent[pb] := pa;
    taille[pa] := taille[pa] + taille[pb];
  end;
end;


function DistanceSq(const p1, p2: TPoint): Int64;
begin
  DistanceSq := Sqr(p1.x-p2.x)+Sqr(p1.y-p2.y)+Sqr(p1.z - p2.z);
end;


procedure Swap(var a, b: TPair);
var
  t: TPair;
begin
  t := a; a := b; b := t;
end;

procedure Tri(var a: array of TPair; l, r: Integer);
var
  i, j: Integer;
  pivot: Int64;
begin
  i := l;
  j := r;
  pivot := a[(l+r) div 2].dist;

  repeat
    while a[i].dist < pivot do inc(i);
    while a[j].dist > pivot do dec(j);
    if i <= j then
    begin
      Swap(a[i], a[j]);
      inc(i);
      dec(j);
    end;
  until i > j;

  if l < j then Tri(a, l, j);
  if i < r then Tri(a, i, r);
end;


function Loadfile(const nom: string): Integer;
var
  f : TextFile;
  line: string;
  n, i: Integer;
begin
  AssignFile(f, nom);
  Reset(f);

  n := 0;
  while not EOF(f) do
  begin
    ReadLn(f, line);
    if Trim(line) <> '' then
      Inc(n);
  end;
  CloseFile(f);

  SetLength(points, n);

  AssignFile(f, nom);
  Reset(f);

  i := 0;
  while not EOF(f) do
  begin
    ReadLn(f, line);
    if Trim(line) <> '' then
    begin
      Split(',',line,elements);
      points[i].x := StrToInt64(elements[0]);
      points[i].y := StrToInt64(elements[1]);
      points[i].z := StrToInt64(elements[2]);
      Inc(i);
    end;
  end;

  CloseFile(f);
  Loadfile := n;
end;

function Solve(const nom: string): Int64;
var
  n, totalpaires, idx, i, j: Integer;
  sizes: array of Int64;
  tmp: Int64;
begin
  n := Loadfile(nom);

  totalpaires := n*(n-1) div 2;
  SetLength(paires, totalpaires);

  idx := 0;
  for i := 0 to n-1 do
    for j := i+1 to n-1 do
    begin
      paires[idx].a := i;
      paires[idx].b := j;
      paires[idx].dist := DistanceSq(points[i], points[j]);
      Inc(idx);
    end;

  Tri(paires, 0, totalpaires - 1);

  SetLength(parent, n);
  SetLength(taille, n);
  for i := 0 to n-1 do
  begin
    parent[i] := i;
    taille[i] := 1;
  end;
  for idx := 0 to numConnections-1 do
  begin
    Union(paires[idx].a, paires[idx].b);
  end;
  SetLength(sizes, n);
  for i := 0 to n-1 do sizes[i] := taille[i];

  for i := 0 to n-2 do
    for j := i+1 to n-1 do
      if sizes[j] > sizes[i] then
      begin
        tmp := sizes[i];
        sizes[i] := sizes[j];
        sizes[j] := tmp;
      end;

  Solve := sizes[0] * sizes[1] * sizes[2];
end;

begin
  elements := TStringList.Create;
  WriteLn('Score : ' + IntToStr(Solve(nomfichier)));
  elements.Free;
end.
