{$mode objfpc}{$H+}
uses Sysutils, Classes, Crt, StrUtils; 

const nomfichier='input.txt';

var elements:TStringList;
    tableau: array of array of Int64;
    dummy,hauteur,largeur:integer;
    score:int64;

function CompressSpaces(const s: string): string;
begin
  Result := s;
  while Pos('  ', Result) > 0 do
    Result := StringReplace(Result, '  ', ' ', [rfReplaceAll]);
end;

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
var cpt:integer;
    line:string;
    myFile : TextFile;
    trigger:boolean; 

begin
  hauteur:=0;
  trigger:=false;
  AssignFile(myFile, nom);
  Reset(myFile);  
  repeat
    ReadLn(myFile,line);
    split(' ', CompressSpaces(Trim(line)), elements);
    if not(eof(myFile)) then
    begin
      inc(hauteur);
      if trigger=false then
      begin
        trigger:=true;
        largeur:=elements.count;
      end;  
      SetLength(tableau, largeur , hauteur);
      for cpt:=0 to elements.Count-1 Do tableau[cpt][hauteur-1]:=StrToInt64(elements[cpt]);
    end;
  until eof(myFile);
  Closefile(myFile);
end;


function Calcule(operation:string;colonne:integer):int64;
var cpt:integer;

begin
  Calcule:=0;
  for cpt:=0 to hauteur-1 Do
  begin
    if cpt=0 then Calcule:=tableau[colonne][cpt] else 
    begin
      if operation='+' then Calcule:=Calcule+tableau[colonne][cpt];
      if operation='*' then Calcule:=Calcule*tableau[colonne][cpt];
    end;
  end;
  writeln('colonne '+inttostr(colonne)+' : '+inttostr(Calcule));
end;



begin
  elements := TStringList.Create;
  Loadfile(nomfichier);
  score:=0;
  for dummy:=0 to elements.count-1 do
    score:=score+Calcule(elements[dummy],dummy);
  Writeln('Score Total : '+inttostr(score));
  elements.Free;
end.