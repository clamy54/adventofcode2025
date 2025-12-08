{$mode objfpc}{$H+}
uses Sysutils, Classes, Crt, StrUtils,generics.collections;

const nomfichier='input.txt';

type tuile=record
          valeur:char;
     end;
    TCache = specialize TDictionary<string, int64>;


var carte:array of array of tuile;
    x,y,hauteur,largeur:integer;
    score:int64;
    cache: Tcache;

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
  largeur:=a;
  hauteur:=b;
  WriteLn('Dimensions: largeur=', largeur, ', hauteur=', hauteur);
  // dimensionnement du tableau
  SetLength(carte, largeur, hauteur);
  // Second passage pour mettre les donnees dans le tableau
  Reset(myFile);
  b:=0;
  repeat
    ReadLn(myFile, line);
    for a:=1 to Length(line) do
    begin
      carte[a-1,b].valeur:=line[a];
    end;
    inc(b);
   until (eof(myFile));
  Closefile(myFile);
end;

function explore(x,y:integer):int64;
var s:string;
    c:char;
    resultat:int64;
begin
  s:=inttostr(x)+'-'+inttostr(y);
  if cache.ContainsKey(s) then
  begin
    exit(cache[s]);
  end;

  if y >= hauteur then
  begin
    exit(1);
  end;

  c := carte[x,y].valeur;
  if c = '^' then
  begin
    resultat := explore(x-1, y) + explore(x+1, y);
  end
  else
  begin
    resultat := explore(x, y+1);
  end;
  explore := resultat;
  cache.Add(s, resultat);
end;

begin
  Loadfile(nomfichier);
  score:=0;
  cache:=TCache.Create;
  for x:=0 to largeur-1 do
  begin
    if (carte[x,0].valeur='S') then
    begin
      WriteLn('S trouvé à x=', x);
      score:=explore(x,0);
      WriteLn('Résultat de explore: ', score);
      break;
    end;
  end;
  Writeln('Score final : '+inttostr(score));
  cache.Free;
end.
