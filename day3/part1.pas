{$mode objfpc}{$H+}
uses Sysutils, Classes, Crt, StrUtils; 

const nomfichier='input.txt';

var myfile:TextFile;
    score:int64;
    ligne:string;

function teste(p:string):int64;
var dummy:byte;
    sortie:string;
begin
  Write(p+' : ');
  for dummy:=9 downto 0 do
  begin
    if  (pos(inttostr(dummy),p)>0) and (pos(inttostr(dummy),p)<>(length(p)) then
    begin
       sortie:=inttostr(dummy);
       delete(p,1,pos(inttostr(dummy),p));
       break;
    end;
  end; 

  write (' ( '+p+' ) ');
  for dummy:=9 downto 0 do
  begin
    if  (pos(inttostr(dummy),p)>0) then
    begin
       sortie:=sortie+inttostr(dummy);
       break;
    end;
  end; 
  writeln(sortie);
  teste:=StrToInt64(sortie);
end;


begin
    score:=0;
    AssignFile(myFile, nomfichier);
    Reset(myFile);
    repeat
      readln(myFile, ligne);
      score:=score+teste(ligne);
    until eof(myFile);
    Closefile(myFile);
    writeln('Score : '+inttostr(score));
end.
