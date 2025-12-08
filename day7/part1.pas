{$mode objfpc}{$H+}
uses Sysutils, Classes, Crt, StrUtils; 

const nomfichier='input.txt';

type tuile=record
          valeur:char;
     end;

var carte:array of array of tuile;
    score,x,y,hauteur,largeur:integer;

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
  for y:=0 to hauteur-2 do
  begin
    for x:=0 to largeur-1 do
    begin
        if (carte[x,y].valeur='S') or (carte[x,y].valeur='|') then
        begin
            if (carte[x,y+1].valeur<>'^') then
            begin
                carte[x,y+1].valeur:='|';
            end
            else
            begin
                inc(score);
                if (carte[x-1,y+1].valeur<>'^') then carte[x-1,y+1].valeur:='|';
                if (carte[x+1,y+1].valeur<>'^') then carte[x+1,y+1].valeur:='|';
            end;
        end; 
    end;
  end;
  for y:=0 to hauteur-1 do
  begin
   for x:=0 to largeur-1 do write(carte[x,y].valeur);
   writeln();
  end;
  Writeln('Score : '+inttostr(score));
end.