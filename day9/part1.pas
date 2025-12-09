{$mode objfpc}{$H+}
uses Sysutils, Classes, Crt, StrUtils; 

const nomfichier='input.txt';

type tuile=record
          x,y:int64;
     end;

var carte:array of tuile;
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


procedure Loadfile(nom:string);
var a,b:integer;
    line:string;
    myFile : TextFile;
 
begin
  a:=0;
  b:=0;
  // Premier passage pour dimensionner le tableau dynamique
  AssignFile(myFile, nom);
  Reset(myFile);
  repeat
    ReadLn(myFile, line);
    inc(b);
    if Length(line)>a then a:=Length(line);
  until (eof(myFile));
  Closefile(myFile);
  hauteur:=b;
  // dimensionnement du tableau
  SetLength(carte,hauteur);
  // Second passage pour mettre les donnees dans le tableau
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
end;

function Solve(const nom: string): Int64;
var a,b:integer;
    surface:Int64;
    s:string;
begin
 Solve:=0;
 s:='';
 Loadfile(nom);
 for a:=0 to hauteur-1 do
  for b:=a+1 to hauteur-1 do
  begin
    surface:=(abs(carte[a].x-carte[b].x)+1)*(abs(carte[a].y-carte[b].y)+1);
    if surface>Solve then
    begin
     Solve:=surface;
     s:='('+inttostr(carte[a].x)+','+inttostr(carte[a].y)+') - ('+inttostr(carte[b].x)+','+inttostr(carte[b].y)+')';
    end;
  end;
  WriteLn('Coordonnées : '+s);
end;


begin
  elements := TStringList.Create;
  WriteLn('Score : ' + IntToStr(Solve(nomfichier)));
  elements.Free;
end.