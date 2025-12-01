{$mode objfpc}{$H+}
uses Sysutils, Classes, Crt; 

const nomfichier='input.txt';

var start,score:integer;
    myFile : TextFile;
    s: string;
    t:integer;

function tourne(direction:char;position,nombre:integer):integer;
var cadenas:Array[0..999] of integer;
    dummy,valeur,idx:integer;

begin
    cadenas[0]:=position;
    if UpperCase(direction)='R' then
    begin
        valeur:= position+1;
        for dummy:=1 to 999 do
        begin
            if valeur=100 then valeur:=0;
            cadenas[dummy]:=valeur;
            inc(valeur);
        end;
    end;
    if UpperCase(direction)='L' then
    begin
        valeur:= position-1;
        for dummy:=1 to 999 do
        begin
            if valeur=-1 then valeur:=99;
            cadenas[dummy]:=valeur;
            dec(valeur);
        end;
    end;
    tourne:=cadenas[nombre]; 
end;

begin
    start:=50;
    score:=0;
    AssignFile(myFile, 'input.txt');
    Reset(myFile);
    repeat
        readln(myFile, s);
        write('Depart : '+inttostr(start)+' - ordre : '+s+' - ');
        start:=tourne(s[1],start,StrToInt(Copy(s, 2, Length(s))));
        writeln('Arrivee : ' +inttostr(start));
        if start=0 then inc(score);
    until (eof(myFile));
    Closefile(myFile);
    write('score : '+inttostr(score));
end.
