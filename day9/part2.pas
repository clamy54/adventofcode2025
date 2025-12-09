{$mode objfpc}{$H+}
uses Sysutils, Classes, Crt, StrUtils; 

const nomfichier='input.txt';

type tuile=record
          x,y:int64;
     end;

var carte:array of tuile;
    sheet:array of array of char;
    coordX, coordY: array of int64;  // Coordonnées uniques triées
    x,y,hauteur:int64;
    elements : TStringList;

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


function TrouveIdxX(x: int64): integer;
var i: integer;
begin
  for i := 0 to High(coordX) do
    if coordX[i] = x then exit(i);
  exit(-1);
end;


function TrouveIdxY(y: int64): integer;
var i: integer;
begin
  for i := 0 to High(coordY) do
    if coordY[i] = y then exit(i);
  exit(-1);
end;

 
procedure Tri(var arr: array of int64);
var i, j: integer;
    temp: int64;
begin
  for i := 0 to High(arr) - 1 do
    for j := i + 1 to High(arr) do
      if arr[i] > arr[j] then
      begin
        temp := arr[i];
        arr[i] := arr[j];
        arr[j] := temp;
      end;
end;

procedure Remplissage(ax, ay, maxX, maxY: int64);
begin
  if (ax < 0) or (ax >= maxX) or (ay < 0) or (ay >= maxY) then exit;
  if sheet[ax, ay] <> '.' then exit;

  sheet[ax, ay] := 'O';

  Remplissage(ax + 1, ay, maxX, maxY);
  Remplissage(ax - 1, ay, maxX, maxY);
  Remplissage(ax, ay + 1, maxX, maxY);
  Remplissage(ax, ay - 1, maxX, maxY);
end;


procedure Loadfile(nom:string);
var t,a,b,i:integer;
    line:string;
    myFile : TextFile;
    maxx,maxy: integer;
    x, y: int64;
    found: boolean;
    ix1, iy1, ix2, iy2: integer;

begin
  a:=0;
  b:=0;
  SetLength(coordX, 0);
  SetLength(coordY, 0);

  // Premier passage : extraire toutes les coordonnées uniques
  AssignFile(myFile, nom);
  Reset(myFile);
  repeat
    ReadLn(myFile, line);
    Split(',',line,elements);
    x := StrToInt64(elements[0]);
    y := StrToInt64(elements[1]);

    // Ajouter X si unique
    found:=false;
    for i:=0 to High(coordX) do
    begin
      if coordX[i] = x then
      begin 
       found:=true;
       break; 
      end;
    end;
    if not found then
    begin
      SetLength(coordX, Length(coordX) + 1);
      coordX[High(coordX)] := x;
    end;

    // Ajouter Y si unique
    found:=false;
    for i:=0 to High(coordY) do
    begin
      if coordY[i]=y then
      begin
       found:=true;
       break;
      end;
    end;
    if not found then
    begin
      SetLength(coordY, Length(coordY) + 1);
      coordY[High(coordY)] := y;
    end;
    inc(b);
  until (eof(myFile));
  Closefile(myFile);
  Tri(coordX);
  Tri(coordY);
  WriteLn('Coordonnées uniques : X=', Length(coordX), ' Y=', Length(coordY));
  WriteLn('Taille grille compressée : ', Length(coordX) * Length(coordY), ' cellules');
  hauteur:=b+1;
  SetLength(carte,hauteur);

  // Second passage pour charger les données
  AssignFile(myFile, nom);
  Reset(myFile);
  b:=0;
  repeat
    ReadLn(myFile, line);
    Split(',',line,elements);
    carte[b].x:=StrToInt64(elements[0]);
    carte[b].y:=StrToInt64(elements[1]);
    inc(b);
   until (eof(myFile));
  Closefile(myFile);
  carte[b].x:=carte[0].x; // on boucle pour fermer le lacet
  carte[b].y:=carte[0].y;

  // Créer la grille compressée
  maxx := Length(coordX);
  maxy := Length(coordY);
  WriteLn('initialisation sheet compressée : '+IntToStr(maxx)+'-'+IntToStr(maxy));
  SetLength(sheet, maxx, maxy);
  for b:=0 to maxy-1 do
      for a:=0 to maxx-1 do
        sheet[a,b]:='.';
  WriteLn('generation map');
  for a:=0 to hauteur-1 do
  begin
    ix1:=TrouveIdxX(carte[a].x);
    iy1:=TrouveIdxY(carte[a].y);
    ix2:=TrouveIdxX(carte[a+1].x);
    iy2:=TrouveIdxY(carte[a+1].y);

    if carte[a].x=carte[a+1].x then
    begin
        if iy1<iy2 then
        begin
          for t:=iy1 to iy2 do sheet[ix1,t]:='X';
        end
        else
        begin
          for t:=iy2 to iy1 do sheet[ix1,t]:='X';
        end;
    end;
    if carte[a].y=carte[a+1].y then
    begin
        if ix1<ix2 then
        begin
         for t:=ix1 to ix2 do sheet[t,iy1]:='X';
        end
        else
        begin
          for t:=ix2 to ix1 do sheet[t,iy1]:='X';
        end;
    end;
    sheet[ix1,iy1]:='#';
    if a<hauteur-1 then sheet[ix2,iy2]:='#';
  end;     


  // Marquer l'exterieur en partant des bords avec un caractere temporaire 'O'
  // On commence depuis les 4 bords
  WriteLn('fill avec des O');
  for a:=0 to maxx-1 do
  begin
    if sheet[a, 0] = '.' then
      Remplissage(a, 0, maxx, maxy);
    if sheet[a, maxy-1] = '.' then
      Remplissage(a, maxy-1, maxx, maxy);
  end;

  for b:=0 to maxy-1 do
  begin
    if sheet[0, b] = '.' then
      Remplissage(0, b, maxx, maxy);
    if sheet[maxx-1, b] = '.' then
      Remplissage(maxx-1, b, maxx, maxy);
  end;

  // Maintenant, tout ce qui est encore '.' est a l'interieur, on le remplit de 'X'
  // Et on remet l'exterieur en '.'
  WriteLn('fill interieur');
  for b:=0 to maxy-1 do
    for a:=0 to maxx-1 do
    begin
      if sheet[a,b] = '.' then sheet[a,b] := 'X'
      else if sheet[a,b] = 'O' then sheet[a,b] := '.';
    end;

  //for b:=0 to maxy-1 do
  //begin
  //    for a:=0 to maxx-1 do
  //      Write(sheet[a,b]);
  // writeln();
  // end;

end;

function lowest(a,b:int64):int64;
begin
  if a<b then lowest:=a else lowest:=b;
end;

function greatest(a,b:int64):int64;
begin
  if a>b then greatest:=a else greatest:=b;
end;


function Verifie(a,b,x,y:int64):boolean;
var t,d:integer;
    ix1, iy1, ix2, iy2: integer;
begin
  Verifie:=true;

  // Convertir les coordonnées réelles en indices compressés
  ix1 := TrouveIdxX(lowest(a,x));
  ix2 := TrouveIdxX(greatest(a,x));
  iy1 := TrouveIdxY(lowest(b,y));
  iy2 := TrouveIdxY(greatest(b,y));

  for t:=ix1 to ix2 do
  begin
    for d:=iy1 to iy2 do
    begin
      if sheet[t,d]='.' then exit(false);
    end;
  end;
end;

function Solve(const nom: string): Int64;
var a,b:integer;
    surface:Int64;
    s:string;
begin
 Solve:=0;
 s:='';
 Loadfile(nom);
 WriteLn('Chargement terminé, résolution en cours ...');
 for a:=0 to hauteur-1 do
  for b:=a+1 to hauteur-1 do
  begin
    surface:=(abs(carte[a].x-carte[b].x)+1)*(abs(carte[a].y-carte[b].y)+1);
    if surface>Solve then
    begin
     if Verifie(carte[a].x,carte[a].y,carte[b].x,carte[b].y)=true then
     begin 
       Solve:=surface;
       s:='('+inttostr(carte[a].x)+','+inttostr(carte[a].y)+') - ('+inttostr(carte[b].x)+','+inttostr(carte[b].y)+')';
     end;
   end;
  end;
  WriteLn('Coordonnées : '+s);
end;


begin
  elements := TStringList.Create;
  WriteLn('Score : ' + IntToStr(Solve(nomfichier)));
  elements.Free;
end.