{$mode objfpc}{$H+}
uses Sysutils, Classes, Crt, StrUtils; 

const nomfichier='input.txt';
      numlines=4;

var elements:TStringList;
    tableau: array of array of string;
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
var l,c,cpt:integer;
    line:string;
    myFile : TextFile;
    trigger:boolean; 
    raw:Array[1..numlines] of string;
    lastline:string;

begin
  hauteur:=0;
  AssignFile(myFile, nom);
  Reset(myFile);
  for cpt:=1 to numlines Do ReadLn(myFile,raw[cpt]);
  ReadLn(myFile,lastline);
  Closefile(myFile);

  for l:=1 to numlines do
  begin
    for cpt:=1 to length(raw[l]) do 
    begin
      if raw[l][cpt]=' ' then
      begin
        trigger:=false;
        for c:=1 to numlines do if raw[c][cpt]<>' ' then trigger:=true;
        if trigger=true then raw[l][cpt]:='X';  
      end;
    end;
  end;

  trigger:=false;
  for c:=1 to numlines do
  begin
    line:=raw[c];
    split(' ', Trim(line), elements);

    inc(hauteur);
    if trigger=false then
    begin
      trigger:=true;
      largeur:=elements.count;
    end;  
    SetLength(tableau, largeur , hauteur);
    for cpt:=0 to elements.Count-1 Do
    begin 
      tableau[cpt][hauteur-1]:=elements[cpt];
      write(elements[cpt]+' ');
    end;
    writeln();
  end;
  split(' ', CompressSpaces(Trim(lastline)), elements);

end;


function Calcule(operation:string;colonne:integer):int64;
var cpt,dummy:integer;
    chaine:String;

begin

  Calcule:=-1;
  for cpt:=length(tableau[colonne][0]) downto 1 do
  begin
    chaine:='';
    for dummy:=0 to hauteur-1 do if tableau[colonne][dummy][cpt]<>'X' then chaine:=chaine+tableau[colonne][dummy][cpt];
    writeln(chaine);
    if Calcule=-1 then Calcule:=StrToInt64(chaine) else
    begin
      if operation='+' then Calcule:=Calcule+StrToInt64(chaine);
      if operation='*' then Calcule:=Calcule*StrToInt64(chaine);
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