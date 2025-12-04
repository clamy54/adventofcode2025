{$mode objfpc}{$H+}
uses Sysutils, Classes, Crt, StrUtils; 

const nomfichier='input.txt';

type tuile=record
          valeur:char;
     end;


var carte:array of array of tuile;
    x,y,hauteur,largeur:integer;
    score:longint;
    proximite:byte;

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

begin
 Loadfile(nomfichier);
 score:=0;
 for y:=0 to hauteur-1 do
 begin
  for x:=0 to largeur-1 do
  begin
    if carte[x,y].valeur='@' then
    begin
      proximite:=0;
      if (x>0) then if carte[x-1,y].valeur='@' then inc(proximite);
      if (x>0) and (y>0) then if carte[x-1,y-1].valeur='@' then inc(proximite);
      if (x>0) and (y<hauteur-1) then if carte[x-1,y+1].valeur='@' then inc(proximite);

      if (y>0) then if carte[x,y-1].valeur='@' then inc(proximite);
      if (y<hauteur-1) then if carte[x,y+1].valeur='@' then inc(proximite);

      if (x<largeur-1) then if carte[x+1,y].valeur='@' then inc(proximite);
      if (x<largeur-1) and (y>0) then if carte[x+1,y-1].valeur='@' then inc(proximite);
      if (x<largeur-1) and (y<hauteur-1) then if carte[x+1,y+1].valeur='@' then inc(proximite);

      if proximite<4 then inc(score);

    end;
  end;
 end;
 writeln('Score : '+inttostr(score));

end.